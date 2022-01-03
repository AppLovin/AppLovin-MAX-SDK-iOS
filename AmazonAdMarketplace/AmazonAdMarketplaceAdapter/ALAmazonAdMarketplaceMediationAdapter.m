//
//  ALAmazonAdMarketplaceMediationAdapter.m
//  AppLovinSDK
//
//  Created by Thomas So on 10/22/21.
//  Copyright © 2021 AppLovin. All rights reserved.
//

#import "ALAmazonAdMarketplaceMediationAdapter.h"
#import <DTBiOSSDK/DTBiOSSDK.h>

#define ADAPTER_VERSION @"4.2.1.0"

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

@interface ALAmazonAdMarketplaceMediationAdapterAdViewDelegate : NSObject<DTBAdBannerDispatcherDelegate>
@property (nonatomic,   weak) ALAmazonAdMarketplaceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALAmazonAdMarketplaceMediationAdapterInterstitialAdDelegate : NSObject<DTBAdInterstitialDispatcherDelegate>
@property (nonatomic,   weak) ALAmazonAdMarketplaceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALAmazonSignalCollectionDelegate : NSObject<DTBAdCallback>
@property (nonatomic, strong) ALAmazonAdMarketplaceMediationAdapter *parentAdapter; // Needs `strong`
@property (nonatomic, strong) id<MAAdapterParameters> parameters;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MASignalCollectionDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterParameters>)parameters
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MASignalCollectionDelegate>)delegate;
@end

@interface ALAmazonAdMarketplaceMediationAdapter()

@property (nonatomic, strong) ALAmazonSignalCollectionDelegate *signalCollectionDelegate;

// AdView
@property (nonatomic, strong) ALAmazonAdMarketplaceMediationAdapterAdViewDelegate *adViewAdapterDelegate;

// Interstitial
@property (nonatomic, strong) DTBAdInterstitialDispatcher *interstitialDispatcher;
@property (nonatomic, strong) ALAmazonAdMarketplaceMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;

@end

@implementation ALAmazonAdMarketplaceMediationAdapter

// Ad loader object used for collecting signal in non-maiden requests
static NSMutableDictionary<MAAdFormat *, DTBAdLoader *> *ALAmazonAdLoaders;

// Contains mapping of encoded bid id -> mediation hints / bid info
static NSMutableDictionary<NSString *, ALAmazonMediationHints *> *ALMediationHintsCache;
static NSObject *ALMediationHintsCacheLock;

+ (void)initialize
{
    [super initialize];
    
    ALAmazonAdLoaders = [NSMutableDictionary dictionary];
    
    ALMediationHintsCache = [NSMutableDictionary dictionary];
    ALMediationHintsCacheLock = [[NSObject alloc] init];
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [parameters isTesting] )
    {
        [[DTBAds sharedInstance] setTestMode: YES];
        [[DTBAds sharedInstance] setLogLevel: DTBLogLevelAll];
    }
    
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
    self.adViewAdapterDelegate = nil;
    self.interstitialDispatcher = nil;
    self.interstitialAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    MAAdFormat *adFormat = parameters.adFormat;
    
    //
    // See if ad loader for this ad format exists or not
    //
    DTBAdLoader *adLoader = ALAmazonAdLoaders[adFormat];
    if ( adLoader )
    {
        [self d: @"Found existing ad loader for format: %@", adFormat];
        
        self.signalCollectionDelegate = [[ALAmazonSignalCollectionDelegate alloc] initWithParentAdapter: self
                                                                                             parameters: parameters
                                                                                               adFormat: parameters.adFormat
                                                                                              andNotify: delegate];
        [adLoader loadAd: self.signalCollectionDelegate];
        
        return;
    }
    
    //
    // This is the initial ad load for this particular ad format
    //
    
    [self d: @"Collecting initial signal for format: %@", adFormat];
    
//    id adResponseObj = parameters.localExtraParameters[@"amazon_ad_response"];
//    id adErrorObj = parameters.localExtraParameters[@"amazon_ad_error"];
//
//    if ( [adResponseObj isKindOfClass: [DTBAdResponse class]] )
//    {
//        DTBAdResponse *adResponse = (DTBAdResponse *) adResponseObj;
//
//        // Store ad loader for future ad refresh token collection
//        ALAmazonAdLoaders[adFormat] = adResponse.dtbAdLoader;
//
//        [self processAdResponseWithParameters: parameters adResponse: adResponse andNotify: delegate];
//    }
//    else if ( [adErrorObj isKindOfClass: [DTBAdErrorInfo class]] )
//    {
//        DTBAdErrorInfo *adError = (DTBAdErrorInfo *) adErrorObj;
//
//        // Store ad loader for future ad refresh token collection
//        ALAmazonAdLoaders[adFormat] = adError.dtbAdLoader;
//
//        [self failSignalCollectionWithError: adError andNotify: delegate];
//    }
//    else
//    {
//        [self failSignalCollectionWithErrorMessage: @"DTBAdResponse or DTBAdErrorInfo not passed in ad load API" andNotify: delegate];
//    }
}

- (void)processAdResponseWithParameters:(id<MAAdapterParameters>)parameters adResponse:(DTBAdResponse *)adResponse andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self d: @"Processing ad response..."];
    
    NSString *encodedBidId = [adResponse amznSlots];
    if ( [encodedBidId al_isValidString] )
    {
        ALAmazonMediationHints *mediationHints = [[ALAmazonMediationHints alloc] initWithValue: [adResponse mediationHints]];
        
        @synchronized ( ALMediationHintsCacheLock )
        {
            // Store mediation hints for the actual ad request
            ALMediationHintsCache[encodedBidId] = mediationHints;
        }
        
        // In the case that Amazon loses the auction - clean up the mediation hints
        
        NSTimeInterval mediationHintsCacheCleanupDelaySec = [parameters.serverParameters al_numberForKey: @"mediation_hints_cleanup_delay_sec"
                                                                                            defaultValue: @(5 * 60)].al_timeIntervalValue;
        
        if ( mediationHintsCacheCleanupDelaySec > 0 )
        {
            dispatchOnMainQueueAfter(mediationHintsCacheCleanupDelaySec, ^{
                
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
        
        [delegate didCollectSignal: encodedBidId];
    }
    else
    {
        [self failSignalCollectionWithErrorMessage: @"Received empty bid id" andNotify: delegate];
    }
}

//- (void)failSignalCollectionWithError:(DTBAdErrorInfo *)adError andNotify:(id<MASignalCollectionDelegate>)delegate
//{
//    NSString *errorMessage = [NSString stringWithFormat: @"Signal collection failed: %d", adError.dtbAdError];
//    [self failSignalCollectionWithErrorMessage: errorMessage andNotify: delegate];
//}

- (void)failSignalCollectionWithErrorMessage:(NSString *)errorMessage andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self e: errorMessage];
    [delegate didFailToCollectSignalWithErrorMessage: errorMessage];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *encodedBidId = parameters.serverParameters[@"encoded_bid_id"];
    [self d: @"Loading %@ ad view ad for encoded bid id: %@...", adFormat.label, encodedBidId];
    
    if ( ![encodedBidId al_isValidString] )
    {
        [delegate didFailToLoadAdViewAdWithError: MAAdapterError.invalidConfiguration];
        return;
    }
    
    CGRect frame = (CGRect) { CGPointZero, adFormat.size };
    self.adViewAdapterDelegate = [[ALAmazonAdMarketplaceMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
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

#pragma mark - MAInterstitialAdapter Adapter

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *encodedBidId = parameters.serverParameters[@"encoded_bid_id"];
    [self d: @"Loading interstitial ad for encoded bid id: %@...", encodedBidId];
    
    if ( ![encodedBidId al_isValidString] )
    {
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.invalidConfiguration];
        return;
    }
    
    self.interstitialAdapterDelegate = [[ALAmazonAdMarketplaceMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
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

#pragma mark - Utility Methods

+ (MAAdapterError *)toMaxError:(DTBAdErrorCode)amazonErrorCode
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( amazonErrorCode )
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
                  thirdPartySdkErrorCode: amazonErrorCode
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

@implementation ALAmazonSignalCollectionDelegate

- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterParameters>)parameters
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MASignalCollectionDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.parameters = parameters;
        self.delegate = delegate;
        self.adFormat = adFormat;
    }
    return self;
}

//- (void)onSuccess:(DTBAdResponse *)adResponse
//{
//    // Store ad loader for future ad refresh token collection
//    ALAmazonAdLoaders[self.adFormat] = adResponse.dtbAdLoader;
//
//    [self.parentAdapter processAdResponseWithParameters: self.parameters
//                                             adResponse: adResponse
//                                              andNotify: self.delegate];
//}
//
//- (void)onFailure:(DTBAdError)error dtbAdErrorInfo:(DTBAdErrorInfo *)dtbAdErrorInfo
//{
//    // Store ad loader for future ad refresh token collection
//    ALAmazonAdLoaders[self.adFormat] = dtbAdErrorInfo.dtbAdLoader;
//
//    [self.parentAdapter failSignalCollectionWithError: dtbAdErrorInfo andNotify: self.delegate];
//}

@end

@implementation ALAmazonAdMarketplaceMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
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
    [self.parentAdapter e: @"AdView failed to load: %ld", errorCode];
    
    MAAdapterError *adapterError = [ALAmazonAdMarketplaceMediationAdapter toMaxError: errorCode];
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

@implementation ALAmazonAdMarketplaceMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
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
    
    MAAdapterError *adapterError = [ALAmazonAdMarketplaceMediationAdapter toMaxError: errorCode];
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
