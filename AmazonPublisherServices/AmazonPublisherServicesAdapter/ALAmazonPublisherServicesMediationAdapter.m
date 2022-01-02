//
//  ALAmazonPublisherServicesMediationAdapter.m
//  AppLovinSDK
//
//  Created by Thomas So on 10/22/21.
//  Copyright © 2021 AppLovin. All rights reserved.
//

#import "ALAmazonPublisherServicesMediationAdapter.h"
#import <DTBiOSSDK/DTBiOSSDK.h>

#define ADAPTER_VERSION @"4.2.1.2"

/**
 * Container object for holding mediation hints dict generated from Amazon's SDK and the timestamp it was geenrated at.
 */
@interface ALAmazonMediationHints : NSObject<NSCopying>

/**
 * The bid info / mediation hints dict generated from Amazon's SDK.
 */
@property (nonatomic, strong) NSDictionary *value;

/**
 * The unique identifier for this instance of the mediation hints.
 */
@property (nonatomic, copy) NSString *identifier;

- (instancetype)initWithValue:(NSDictionary *)value;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface ALAmazonPublisherServicesMediationAdapterAdViewDelegate : NSObject<DTBAdBannerDispatcherDelegate>
@property (nonatomic, weak) ALAmazonPublisherServicesMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALAmazonPublisherServicesMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALAmazonPublisherServicesMediationAdapterInterstitialAdDelegate : NSObject<DTBAdInterstitialDispatcherDelegate>
@property (nonatomic,   weak) ALAmazonPublisherServicesMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALAmazonPublisherServicesMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALAmazonPublisherServicesMediationAdapter()<DTBAdCallback>

// Signal Collection
@property (nonatomic, strong, nullable) id<MASignalCollectionDelegate> signalCollectionDelegate;
@property (nonatomic, assign) NSTimeInterval mediationHintsCacheCleanupDelaySec;

@property (nonatomic, strong) DTBAdLoader *adLoader;

// AdView
@property (nonatomic, strong) ALAmazonPublisherServicesMediationAdapterAdViewDelegate *adViewAdapterDelegate;

// Interstitial
@property (nonatomic, strong) DTBAdInterstitialDispatcher *interstitialDispatcher;
@property (nonatomic, strong) ALAmazonPublisherServicesMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;

@end

@implementation ALAmazonPublisherServicesMediationAdapter

// Contains mapping of encoded bid id -> mediation hints / bid info
static NSMutableDictionary<NSString *, ALAmazonMediationHints *> *ALMediationHintsCache;
static NSObject *ALMediationHintsCacheLock;

+ (void)initialize
{
    [super initialize];
    
    ALMediationHintsCache = [NSMutableDictionary dictionary];
    ALMediationHintsCacheLock = [[NSObject alloc] init];
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *appId = parameters.serverParameters[@"app_id"];
        [self d: @"Initializing with app id: %@...", appId];
        
        if ( [parameters isTesting] )
        {
            [[DTBAds sharedInstance] setTestMode: YES];
            [[DTBAds sharedInstance] setLogLevel: DTBLogLevelAll];
        }
        
        [self updateConsentWithParameters: parameters];
        
        [[DTBAds sharedInstance] setAppKey: appId];
    });
    
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (NSString *)SDKVersion
{
    return [DTBAds version];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.signalCollectionDelegate = nil;
    self.adLoader = nil;
    self.adViewAdapterDelegate = nil;
    self.interstitialAdapterDelegate = nil;
    self.interstitialDispatcher = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    MAAdFormat *adFormat = parameters.adFormat;
    
    if ( adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader || adFormat == MAAdFormat.interstitial )
    {
        [self updateConsentWithParameters: parameters];
        
        // NOTE: "ad slot ids" is Amazon's terminology for placements - for O&Os it will be 1:1 for each ad format
        NSDictionary<NSString *, NSString *> *adSlotIds = parameters.serverParameters[@"ad_slot_ids"];
        NSString *adSlotId = adSlotIds[adFormat.label.lowercaseString];
        
        if ( [adSlotId al_isValidString] )
        {
            [self d: @"Collecting signal for ad slot id: %@...", adSlotId];
            
            self.signalCollectionDelegate = delegate;
            self.mediationHintsCacheCleanupDelaySec = [parameters.serverParameters al_numberForKey: @"mediation_hints_cleanup_delay_sec"
                                                                                      defaultValue: @(5 * 60 * 60)].al_timeIntervalValue; // 5 min
            
            DTBAdSize *size;
            if ( adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader )
            {
                CGSize rawSize = parameters.adFormat.size;
                size = [[DTBAdSize alloc] initBannerAdSizeWithWidth: rawSize.width
                                                             height: rawSize.height
                                                        andSlotUUID: adSlotId];
            }
            else
            {
                size = [[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID: adSlotId];
            }
            
            self.adLoader = [[DTBAdLoader alloc] init];
            [self.adLoader setSizes: size, nil];
            [self.adLoader stop];
            
            [self.adLoader loadAd: self];
        }
        else
        {
            [delegate didFailToCollectSignalWithErrorMessage: @"Ad slot id unavailable"];
        }
    }
    else
    {
        [delegate didFailToCollectSignalWithErrorMessage: @"Ineligible ad format"];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *encodedBidId = parameters.serverParameters[@"encoded_bid_id"];
    [self d: @"Loading %@ ad view ad for encoded bid id: %@...", adFormat.label, encodedBidId];
    
    [self updateConsentWithParameters: parameters];
    
    CGRect frame = (CGRect) { CGPointZero, adFormat.size };
    self.adViewAdapterDelegate = [[ALAmazonPublisherServicesMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    DTBAdBannerDispatcher *dispatcher = [[DTBAdBannerDispatcher alloc] initWithAdFrame: frame delegate: self.adViewAdapterDelegate];
    
    ALAmazonMediationHints *mediationHints;
    @synchronized ( ALMediationHintsCacheLock )
    {
        mediationHints = ALMediationHintsCache[encodedBidId];
        [ALMediationHintsCache removeObjectForKey: encodedBidId];
    }
    
    // Paranoia
    if ( mediationHints )
    {
        [dispatcher fetchBannerAdWithParameters: mediationHints.value];
    }
    else
    {
        [self e: @"Unable to find mediation hints"];
        [delegate didFailToLoadAdViewAdWithError: MAAdapterError.invalidLoadState];
    }
}

#pragma mark - Interstitial Adapter

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *encodedBidId = parameters.serverParameters[@"encoded_bid_id"];
    [self d: @"Loading interstitial ad for encoded bid id: %@...", encodedBidId];
    
    [self updateConsentWithParameters: parameters];
    
    self.interstitialAdapterDelegate = [[ALAmazonPublisherServicesMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialDispatcher = [[DTBAdInterstitialDispatcher alloc] initWithDelegate: self.interstitialAdapterDelegate];
    
    ALAmazonMediationHints *mediationHints;
    @synchronized ( ALMediationHintsCacheLock )
    {
        mediationHints = ALMediationHintsCache[encodedBidId];
        [ALMediationHintsCache removeObjectForKey: encodedBidId];
    }
    
    // Paranoia
    if ( mediationHints )
    {
        [self.interstitialDispatcher fetchAdWithParameters: mediationHints.value];
    }
    else
    {
        [self e: @"Unable to find mediation hints"];
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.invalidLoadState];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( self.interstitialDispatcher.interstitialLoaded )
    {
        [self.interstitialDispatcher showFromController: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - DTBAdCallback

- (void)onSuccess:(DTBAdResponse *)adResponse
{
    NSString *encodedBidId = [adResponse amznSlots];
    if ( [encodedBidId al_isValidString] )
    {
        if ( self.signalCollectionDelegate )
        {
            ALAmazonMediationHints *mediationHints = [[ALAmazonMediationHints alloc] initWithValue: [adResponse mediationHints]];
            
            @synchronized ( ALMediationHintsCacheLock )
            {
                // Store mediation hints for the actual ad request
                ALMediationHintsCache[encodedBidId] = mediationHints;
            }
            
            // In the case that Amazon loses the auction - clean up the mediation hints
            if ( self.mediationHintsCacheCleanupDelaySec > 0 )
            {
                dispatchOnMainQueueAfter(self.mediationHintsCacheCleanupDelaySec, ^{
                    
                    @synchronized ( ALMediationHintsCacheLock )
                    {
                        // Check if this is the same mediation hints / bid info as when the cleanup was scheduled
                        ALAmazonMediationHints *currentMediationHints = ALMediationHintsCache[encodedBidId];
                        if ( [currentMediationHints.identifier isEqual: mediationHints.identifier] )
                        {
                            [ALMediationHintsCache removeObjectForKey: encodedBidId];
                        }
                    }
                });
            }
            
            [self d: @"Successfully loaded encoded bid id: %@", encodedBidId];
            
            [self.signalCollectionDelegate didCollectSignal: encodedBidId];
            self.signalCollectionDelegate = nil;
        }
        else
        {
            [self e: @"Received bid but no signal collection delegate available"];
        }
    }
    else
    {
        [self failSignalCollectionWithErrorMessage: @"Received empty bid id"];
    }
}

- (void)onFailure:(DTBAdError)errorCode
{
    NSString *errorMessage = [NSString stringWithFormat: @"Failed to load bid id: %d", errorCode];
    [self failSignalCollectionWithErrorMessage: errorMessage];
}

- (void)failSignalCollectionWithErrorMessage:(NSString *)errorMessage
{
    [self e: errorMessage];
    
    if ( self.signalCollectionDelegate )
    {
        [self.signalCollectionDelegate didFailToCollectSignalWithErrorMessage: errorMessage];
        self.signalCollectionDelegate = nil;
    }
    else
    {
        [self e: @"No signal collection delegate available"];
    }
}

#pragma mark - Shared Methods

- (void)updateConsentWithParameters:(id<MAAdapterParameters>)parameters
{
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = parameters.hasUserConsent;
        if ( hasUserConsent )
        {
            [[DTBAds sharedInstance] setConsentStatus: hasUserConsent.boolValue ? EXPLICIT_YES : EXPLICIT_NO];
        }
    }
}

+ (MAAdapterError *)toMaxError:(DTBAdErrorCode)amazonPublisherServicesErrorCode
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( amazonPublisherServicesErrorCode )
    {
        case SampleErrorCodeBadRequest:
            adapterError = MAAdapterError.badRequest;
            break;
        case SampleErrorCodeUnknown:
            adapterError = MAAdapterError.unspecified;
            break;
        case SampleErrorCodeNetworkError:
            adapterError = MAAdapterError.noConnection;
            break;
        case SampleErrorCodeNoInventory:
            adapterError = MAAdapterError.noFill;
            break;
    }
    
    return [MAAdapterError errorWithCode: adapterError.code
                             errorString: adapterError.message
                  thirdPartySdkErrorCode: amazonPublisherServicesErrorCode
               thirdPartySdkErrorMessage: @""];
}

@end

@implementation ALAmazonMediationHints

- (instancetype)initWithValue:(NSDictionary *)value
{
    self = [super init];
    if ( self )
    {
        self.identifier = [NSUUID UUID].UUIDString.lowercaseString;
        self.value = value;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ALAmazonMediationHints *copy = [[[self class] allocWithZone: zone] init];
    copy.value                   = self.value;
    copy.identifier              = self.identifier;
    
    return copy;
}

- (BOOL)isEqual:(ALAmazonMediationHints *)other
{
    if ( self == other )
        return YES;
    if ( !other )
        return NO;
    if ( ![self.identifier isEqualToString: other.identifier] )
        return NO;
    if ( ![self.value isEqualToDictionary: other.value] )
        return NO;
    
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = [super hash];
    hash = hash * 31u + [self.identifier hash];
    hash = hash * 31u + [self.value hash];
    
    return hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"[ALAmazonMediationHints: identifier=%@, value=%@]", self.identifier, self.value];
}

@end

@implementation ALAmazonPublisherServicesMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALAmazonPublisherServicesMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidLoad:(UIView *)adView
{
    [self.parentAdapter d: @"AdView ad loaded"];
    [self.delegate didLoadAdForAdView: adView];
}

- (void)adFailedToLoad:(nullable UIView *)banner errorCode:(NSInteger)errorCode
{
    [self.parentAdapter e: @"AdView failed to load with error: %ld", errorCode];
    
    MAAdapterError *adapterError = [ALAmazonPublisherServicesMediationAdapter toMaxError: errorCode];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)impressionFired
{
    [self.parentAdapter d: @"AdView impression fired"];
    [self.delegate didDisplayAdViewAd];
}

- (void)bannerWillLeaveApplication:(UIView *)adView
{
    [self.parentAdapter d: @"AdView will leave application"];
    [self.delegate didClickAdViewAd];
}

@end

@implementation ALAmazonPublisherServicesMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALAmazonPublisherServicesMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialDidLoad:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter log: @"Interstitial loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitial:(nullable DTBAdInterstitialDispatcher *)interstitial didFailToLoadAdWithErrorCode:(DTBAdErrorCode)errorCode
{
    [self.parentAdapter log: @"Interstitial failed to load with error: %ld", errorCode];
    
    MAAdapterError *adapterError = [ALAmazonPublisherServicesMediationAdapter toMaxError: errorCode];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialWillPresentScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter log: @"Interstitial will present screen"];
}

- (void)interstitialDidPresentScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter log: @"Interstitial did present screen"];
}

- (void)impressionFired
{
    [self.parentAdapter log: @"Interstitial impression fired"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialWillDismissScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter log: @"Interstitial will dismiss screen"];
}

- (void)interstitialDidDismissScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter log: @"Interstitial did dismiss screen"];
    [self.delegate didHideInterstitialAd];
}

- (void)interstitialWillLeaveApplication:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter log: @"Interstitial will leave application"];
}

- (void)showFromRootViewController:(UIViewController *)controller
{
    [self.parentAdapter log: @"Show interstitial from root view controller: %@", controller];
}

@end
