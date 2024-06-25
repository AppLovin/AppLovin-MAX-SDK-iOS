//
//  ALAmazonAdMarketplaceMediationAdapter.m
//  AppLovinSDK
//
//  Created by Thomas So on 10/22/21.
//  Copyright © 2021 AppLovin. All rights reserved.
//

#import "ALAmazonAdMarketplaceMediationAdapter.h"
#import <DTBiOSSDK/DTBiOSSDK.h>

#define ADAPTER_VERSION @"4.9.6.0"

/**
 * Container object for holding mediation hints dict generated from Amazon's SDK and the timestamp it was geenrated at.
 */
@interface ALTAMAmazonMediationHints : NSObject <NSCopying>

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

@interface ALAmazonAdMarketplaceMediationAdapterAdViewDelegate : NSObject <DTBAdBannerDispatcherDelegate>
@property (nonatomic,   weak) ALAmazonAdMarketplaceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@property (nonatomic,   weak) MAAdFormat *adFormat;
- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALAmazonAdMarketplaceMediationAdapterInterstitialAdDelegate : NSObject <DTBAdInterstitialDispatcherDelegate>
@property (nonatomic,   weak) ALAmazonAdMarketplaceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALAmazonAdMarketplaceMediationAdapterRewardedAdDelegate : NSObject <DTBAdInterstitialDispatcherDelegate>
@property (nonatomic,   weak) ALAmazonAdMarketplaceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALAmazonSignalCollectionDelegate : NSObject <DTBAdCallback>
@property (nonatomic, strong) ALAmazonAdMarketplaceMediationAdapter *parentAdapter; // Needs `strong`
@property (nonatomic, strong) id<MAAdapterParameters> parameters;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MASignalCollectionDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterParameters>)parameters
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MASignalCollectionDelegate>)delegate;
@end

@interface ALAmazonAdMarketplaceMediationAdapter ()

@property (nonatomic, strong) ALAmazonSignalCollectionDelegate *signalCollectionDelegate;

// AdView
@property (nonatomic, strong) ALAmazonAdMarketplaceMediationAdapterAdViewDelegate *adViewAdapterDelegate;

// Interstitial
@property (nonatomic, strong) DTBAdInterstitialDispatcher *interstitialDispatcher;
@property (nonatomic, strong) ALAmazonAdMarketplaceMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;

// Rewarded
@property (nonatomic, strong) DTBAdInterstitialDispatcher *rewardedDispatcher;
@property (nonatomic, strong) ALAmazonAdMarketplaceMediationAdapterRewardedAdDelegate *rewardedAdapterDelegate;

@end

@implementation ALAmazonAdMarketplaceMediationAdapter

// Ad loader object used for collecting signal in non-maiden requests
static NSMutableDictionary<MAAdFormat *, DTBAdLoader *> *ALAmazonAdLoaders;

// Contains mapping of encoded (bid id)_(ad format) -> mediation hints / bid info
static NSMutableDictionary<NSString *, ALTAMAmazonMediationHints *> *ALMediationHintsCache;
static NSObject *ALMediationHintsCacheLock;

// Contains mapping of ad format -> crid
static NSMutableDictionary<MAAdFormat *, NSString *> *ALAmazonCreativeIdentifiers;
static NSObject *ALAmazonCreativeIdentifiersLock;

// Contains mapping of ad format -> amazon hashed bidder identifier / amznp
static NSMutableDictionary<MAAdFormat *, NSString *> *ALAmazonHashedBidderIdentifiers;
static NSObject *ALAmazonHashedBidderIdentifiersLock;

static NSMutableSet<NSNumber *> *ALUsedAmazonAdLoaderHashes;
static NSString *ALAPSSDKVersion;

+ (void)initialize
{
    [super initialize];
    
    ALAmazonAdLoaders = [NSMutableDictionary dictionary];
    
    ALMediationHintsCache = [NSMutableDictionary dictionary];
    ALMediationHintsCacheLock = [[NSObject alloc] init];
    
    ALAmazonCreativeIdentifiers = [NSMutableDictionary dictionary];
    ALAmazonCreativeIdentifiersLock = [[NSObject alloc] init];
    
    ALAmazonHashedBidderIdentifiers = [NSMutableDictionary dictionary];
    ALAmazonHashedBidderIdentifiersLock = [[NSObject alloc] init];
    
    ALUsedAmazonAdLoaderHashes = [NSMutableSet set];
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
    if ( ALAPSSDKVersion ) return ALAPSSDKVersion;
    
    // APS 4.5.2 crashes if SDK version is not retrieved in main thread
    dispatchSyncOnMainQueue(^{
        ALAPSSDKVersion = [DTBAds version];
    });
    
    return ALAPSSDKVersion;
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.signalCollectionDelegate.delegate = nil;
    self.signalCollectionDelegate = nil;
    
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
    
    self.interstitialDispatcher.delegate = nil;
    self.interstitialDispatcher = nil;
    self.interstitialAdapterDelegate.delegate = nil;
    self.interstitialAdapterDelegate = nil;
    
    self.rewardedDispatcher.delegate = nil;
    self.rewardedDispatcher = nil;
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    MAAdFormat *adFormat = parameters.adFormat;
    id adResponseObj = parameters.localExtraParameters[@"amazon_ad_response"];
    id adErrorObj = parameters.localExtraParameters[@"amazon_ad_error"];
    
    // There may be cases where pubs pass in info from integration (e.g. CCPA) directly into a _new_ ad loader - check (and update) for that
    // There may also be cases where we have both a response and error object - for which one is stale - check for that
    DTBAdLoader *adLoader;
    
    if ( [adResponseObj isKindOfClass: [DTBAdResponse class]] )
    {
        DTBAdLoader *retrievedAdLoader = ((DTBAdResponse *) adResponseObj).dtbAdLoader;
        if ( ![ALUsedAmazonAdLoaderHashes containsObject: @(retrievedAdLoader.hash)] )
        {
            [self d: @"Using ad loader from ad response object: %@", retrievedAdLoader];
            adLoader = retrievedAdLoader;
        }
        else if ( [parameters.localExtraParameters isKindOfClass: [NSMutableDictionary class]] )
        {
            NSMutableDictionary *mutableLocalExtraParams = (NSMutableDictionary *) parameters.localExtraParameters;
            mutableLocalExtraParams[@"amazon_ad_response"] = nil;
        }
    }
    
    if ( [adErrorObj isKindOfClass: [DTBAdErrorInfo class]] )
    {
        DTBAdLoader *retrievedAdLoader = ((DTBAdErrorInfo *) adErrorObj).dtbAdLoader;
        if ( ![ALUsedAmazonAdLoaderHashes containsObject: @(retrievedAdLoader.hash)] )
        {
            [self d: @"Using ad loader from ad error object: %@", retrievedAdLoader];
            adLoader = retrievedAdLoader;
        }
        else if ( [parameters.localExtraParameters isKindOfClass: [NSMutableDictionary class]] )
        {
            NSMutableDictionary *mutableLocalExtraParams = (NSMutableDictionary *) parameters.localExtraParameters;
            mutableLocalExtraParams[@"amazon_ad_error"] = nil;
        }
    }
    
    DTBAdLoader *currentAdLoader = ALAmazonAdLoaders[adFormat];
    
    if ( adLoader )
    {
        // We already have this ad loader - load _new_ signal
        if ( adLoader == currentAdLoader )
        {
            [self d: @"Passed in ad loader same as current ad loader: %@", currentAdLoader];
            [self loadSubsequentSignalForAdLoader: adLoader
                                       parameters: parameters
                                         adFormat: adFormat
                                        andNotify: delegate];
        }
        // If new ad loader - update for ad format and proceed to initial signal collection logic
        else
        {
            [self d: @"New loader passed in for %@: %@, replacing current ad loader: %@", adFormat.label, adLoader, currentAdLoader];
            
            ALAmazonAdLoaders[adFormat] = adLoader;
            [ALUsedAmazonAdLoaderHashes addObject: @(adLoader.hash)];
            
            if ( [adResponseObj isKindOfClass: [DTBAdResponse class]] )
            {
                DTBAdResponse *adResponse = (DTBAdResponse *)adResponseObj;
                
                [self processAdResponseWithParameters: parameters
                                           adResponse: adResponse
                                             adFormat: adFormat
                                            andNotify: delegate];
            }
            else // DTBAdErrorInfo
            {
                [self failSignalCollectionWithError: (DTBAdErrorInfo *) adErrorObj andNotify: delegate];
            }
        }
    }
    else
    {
        // Use cached ad loader
        if ( currentAdLoader )
        {
            [self d: @"Using cached ad loader: %@", currentAdLoader];
            [self loadSubsequentSignalForAdLoader: currentAdLoader
                                       parameters: parameters
                                         adFormat: adFormat
                                        andNotify: delegate];
        }
        // No ad loader passed in, and no ad loaders cached - fail signal collection
        else
        {
            [self failSignalCollectionWithErrorMessage: @"DTBAdResponse or DTBAdErrorInfo not passed in ad load API" andNotify: delegate];
        }
    }
}

- (void)loadSubsequentSignalForAdLoader:(DTBAdLoader *)adLoader
                             parameters:(id<MASignalCollectionParameters>)parameters
                               adFormat:(MAAdFormat *)adFormat
                              andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self d: @"Found existing ad loader (%@) for format: %@ - loading...", adLoader, adFormat];
    self.signalCollectionDelegate = [[ALAmazonSignalCollectionDelegate alloc] initWithParentAdapter: self
                                                                                         parameters: parameters
                                                                                           adFormat: adFormat
                                                                                          andNotify: delegate];
    [adLoader loadAd: self.signalCollectionDelegate];
}

- (void)processAdResponseWithParameters:(id<MAAdapterParameters>)parameters adResponse:(DTBAdResponse *)adResponse adFormat:(MAAdFormat *)adFormat andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self d: @"Processing ad response..."];
    
    @try
    {
        NSString *encodedBidId = [adResponse amznSlots];
        if ( [encodedBidId al_isValidString] )
        {
            ALTAMAmazonMediationHints *mediationHints = [[ALTAMAmazonMediationHints alloc] initWithValue: [adResponse mediationHints]];
            NSString *mediationHintsCacheId = [self mediationHintsCacheId: encodedBidId adFormat: adFormat];
            
            @synchronized ( ALMediationHintsCacheLock )
            {
                // Store mediation hints for the actual ad request
                ALMediationHintsCache[mediationHintsCacheId] = mediationHints;
            }
            
            // In the case that Amazon loses the auction - clean up the mediation hints
            NSTimeInterval mediationHintsCacheCleanupDelaySec = [parameters.serverParameters al_numberForKey: @"mediation_hints_cleanup_delay_sec"
                                                                                                defaultValue: @(5 * 60)].al_timeIntervalValue;
            
            if ( mediationHintsCacheCleanupDelaySec > 0 )
            {
                NSString *mediationHintsId = mediationHints.identifier;
                
                dispatchOnMainQueueAfter(mediationHintsCacheCleanupDelaySec, ^{
                    
                    @synchronized ( ALMediationHintsCacheLock )
                    {
                        // Check if this is the same mediation hints / bid info as when the cleanup was scheduled
                        ALTAMAmazonMediationHints *currentMediationHints = ALMediationHintsCache[mediationHintsCacheId];
                        if ( [currentMediationHints.identifier isEqual: mediationHintsId] )
                        {
                            [ALMediationHintsCache removeObjectForKey: mediationHintsCacheId];
                        }
                    }
                });
            }
            
            [self setCreativeIdentifier: adResponse.crid forAdFormat: adFormat];
            [self setHashedBidderIdentifier: adResponse.customTargeting[@"amznp"] forAdFormat: adFormat];
            
            [self d: @"Successfully loaded encoded bid id: %@", encodedBidId];
            
            [delegate didCollectSignal: encodedBidId];
        }
        else
        {
            [self failSignalCollectionWithErrorMessage: @"Received empty bid id" andNotify: delegate];
        }
    }
    @catch ( NSException *exception )
    {
        [self e: @"Ad response processing failed" becauseOf: exception];
        [self failSignalCollectionWithErrorMessage: @"Exception thrown while processing ad response" andNotify: delegate];
    }
}

- (void)failSignalCollectionWithError:(DTBAdErrorInfo *)adError andNotify:(id<MASignalCollectionDelegate>)delegate
{
    // Note: `adError.dtbAdError` is currently always 0, but if Amazon fixes it, this will start logging correct error information.
    NSString *errorMessage = [NSString stringWithFormat: @"Signal collection failed: %@", [ALAmazonAdMarketplaceMediationAdapter stringFromDTBAdError: adError.dtbAdError]];
    [self failSignalCollectionWithErrorMessage: errorMessage andNotify: delegate];
}

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
    self.adViewAdapterDelegate = [[ALAmazonAdMarketplaceMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self
                                                                                                           adFormat: adFormat
                                                                                                          andNotify: delegate];
    DTBAdBannerDispatcher *dispatcher = [[DTBAdBannerDispatcher alloc] initWithAdFrame: frame delegate: self.adViewAdapterDelegate];
    
    ALTAMAmazonMediationHints *mediationHints;
    NSString *mediationHintsCacheId = [self mediationHintsCacheId: encodedBidId adFormat: adFormat];
    
    @synchronized ( ALMediationHintsCacheLock )
    {
        mediationHints = ALMediationHintsCache[mediationHintsCacheId];
        [ALMediationHintsCache removeObjectForKey: mediationHintsCacheId];
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
    
    NSString *mediationHintsCacheId = [self mediationHintsCacheId: encodedBidId adFormat: MAAdFormat.interstitial];
    
    BOOL success = [self loadFullscreenAd: mediationHintsCacheId withInterstitialDispatcher: self.interstitialDispatcher];
    if ( !success )
    {
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.invalidLoadState];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self d: @"Showing interstitial ad..."];
    
    BOOL success = [self showFullscreenAd: self.interstitialDispatcher forParameters: parameters];
    if ( !success )
    {
        [self e: @"Interstitial ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205
                                                                             errorString: @"Ad Display Failed"
                                                                  thirdPartySdkErrorCode: 0
                                                               thirdPartySdkErrorMessage: @"Interstitial ad not ready"]];
#pragma clang diagnostic pop
    }
}

#pragma mark - MARewardedAdapter Adapter

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *encodedBidId = parameters.serverParameters[@"encoded_bid_id"];
    [self d: @"Loading rewarded ad for encoded bid id: %@...", encodedBidId];
    
    if ( ![encodedBidId al_isValidString] )
    {
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.invalidConfiguration];
        return;
    }
    
    self.rewardedAdapterDelegate = [[ALAmazonAdMarketplaceMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedDispatcher = [[DTBAdInterstitialDispatcher alloc] initWithDelegate: self.rewardedAdapterDelegate];
    
    NSString *mediationHintsCacheId = [self mediationHintsCacheId: encodedBidId adFormat: MAAdFormat.rewarded];
    
    BOOL success = [self loadFullscreenAd: mediationHintsCacheId withInterstitialDispatcher: self.rewardedDispatcher];
    if ( !success )
    {
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.invalidLoadState];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self d: @"Showing rewarded ad..."];
    
    // Configure reward from server.
    [self configureRewardForParameters: parameters];
    
    BOOL success = [self showFullscreenAd: self.rewardedDispatcher forParameters: parameters];
    if ( !success )
    {
        [self e: @"Rewarded ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithCode: -4205
                                                                         errorString: @"Ad Display Failed"
                                                              thirdPartySdkErrorCode: 0
                                                           thirdPartySdkErrorMessage: @"Rewarded ad not ready"]];
#pragma clang diagnostic pop
    }
}

#pragma mark - Utility Methods

- (BOOL)loadFullscreenAd:(NSString *)mediationHintsCacheId withInterstitialDispatcher:(DTBAdInterstitialDispatcher *)interstitialDispatcher
{
    ALTAMAmazonMediationHints *mediationHints;
    @synchronized ( ALMediationHintsCacheLock )
    {
        mediationHints = ALMediationHintsCache[mediationHintsCacheId];
        [ALMediationHintsCache removeObjectForKey: mediationHintsCacheId];
    }
    
    // Paranoia
    if ( !mediationHints )
    {
        [self e: @"Unable to find mediation hints"];
        return NO;
    }
    
    [interstitialDispatcher fetchAdWithParameters: mediationHints.value];
    
    return YES;
}

- (BOOL)showFullscreenAd:(DTBAdInterstitialDispatcher *)interstitialDispatcher forParameters:(id<MAAdapterResponseParameters>)parameters
{
    if ( !interstitialDispatcher.interstitialLoaded )
    {
        return NO;
    }
    
    UIViewController *presentingViewController;
    if ( ALSdk.versionCode >= 11020199 )
    {
        presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    }
    else
    {
        presentingViewController = [ALUtils topViewControllerFromKeyWindow];
    }
    
    [interstitialDispatcher showFromController: presentingViewController];
    
    return YES;
}

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
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.code
                             errorString: adapterError.message
                  thirdPartySdkErrorCode: amazonErrorCode
               thirdPartySdkErrorMessage: @""];
#pragma clang diagnostic pop
}

+ (NSString *)stringFromDTBAdError:(DTBAdError)error
{
    switch ( error )
    {
        case NETWORK_ERROR:
            return @"NETWORK_ERROR";
        case NETWORK_TIMEOUT:
            return @"NETWORK_TIMEOUT";
        case NO_FILL:
            return @"NO_FILL";
        case INTERNAL_ERROR:
            return @"INTERNAL_ERROR";
        case REQUEST_ERROR:
            return @"REQUEST_ERROR";
    }
       
    return @"UNKNOWN_ERROR";
}

- (void)setCreativeIdentifier:(NSString *)creativeId forAdFormat:(MAAdFormat *)adFormat
{
    @synchronized ( ALAmazonCreativeIdentifiersLock )
    {
        ALAmazonCreativeIdentifiers[adFormat] = creativeId;
    }
}

- (void)setHashedBidderIdentifier:(NSString *)hashedBidderId forAdFormat:(MAAdFormat *)adFormat
{
    @synchronized ( ALAmazonHashedBidderIdentifiersLock )
    {
        ALAmazonHashedBidderIdentifiers[adFormat] = hashedBidderId;
    }
}

- (nullable NSDictionary *)extraInfoForAdFormat:(MAAdFormat *)adFormat
{
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithCapacity: 2];
    
    @synchronized ( ALAmazonCreativeIdentifiersLock )
    {
        NSString *creativeId = ALAmazonCreativeIdentifiers[adFormat];
        if ( [creativeId al_isValidString] )
        {
            extraInfo[@"creative_id" ] = creativeId;
        }
    }
    
    @synchronized ( ALAmazonHashedBidderIdentifiersLock )
    {
        NSString *hashedBidderId = ALAmazonHashedBidderIdentifiers[adFormat];
        if ( [hashedBidderId al_isValidString] )
        {
            extraInfo[@"ad_values"] = @{@"amazon_hashed_bidder_id" : hashedBidderId};
        }
    }
    
    return extraInfo;
}

- (NSString *)mediationHintsCacheId:(NSString *)encodedBidId adFormat:(MAAdFormat *)adFormat
{
    // Treat banners and leaders as the same ad format
    NSString *adFormatLabel = ( adFormat == MAAdFormat.leader ) ? MAAdFormat.banner.label : adFormat.label;
    
    return [NSString stringWithFormat: @"%@_%@", encodedBidId, adFormatLabel];
}

@end

@implementation ALTAMAmazonMediationHints

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
    ALTAMAmazonMediationHints *copy = [[[self class] allocWithZone: zone] init];
    copy.value                   = self.value;
    copy.identifier              = self.identifier;
    
    return copy;
}

- (BOOL)isEqual:(ALTAMAmazonMediationHints *)other
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
    return [NSString stringWithFormat: @"[ALTAMAmazonMediationHints: identifier=%@, value=%@]", self.identifier, self.value];
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

- (void)onSuccess:(DTBAdResponse *)adResponse
{
    // Store ad loader for future ad refresh token collection
    ALAmazonAdLoaders[self.adFormat] = adResponse.dtbAdLoader;
    
    [ALUsedAmazonAdLoaderHashes addObject: @(adResponse.dtbAdLoader.hash)];
    
    [self.parentAdapter d: @"Signal collected for ad loader: %@", adResponse.dtbAdLoader];
    
    [self.parentAdapter processAdResponseWithParameters: self.parameters
                                             adResponse: adResponse
                                               adFormat: self.adFormat
                                              andNotify: self.delegate];
}

- (void)onFailure:(DTBAdError)error dtbAdErrorInfo:(DTBAdErrorInfo *)dtbAdErrorInfo
{
    // Store ad loader for future ad refresh token collection
    ALAmazonAdLoaders[self.adFormat] = dtbAdErrorInfo.dtbAdLoader;
    
    [ALUsedAmazonAdLoaderHashes addObject: @(dtbAdErrorInfo.dtbAdLoader.hash)];
    
    // Note: `dtbAdErrorInfo.dtbAdError` also contains a `DTBAdError` object but it's always 0. Use `DTBAdError` directly from Amazon's callback to get a valid error code.
    NSString *dtbAdErrorString = [ALAmazonAdMarketplaceMediationAdapter stringFromDTBAdError: error];
    
    [self.parentAdapter d: @"Signal failed to collect for ad loader: %@ with error: %@", dtbAdErrorInfo.dtbAdLoader, dtbAdErrorString];
    
    [self.parentAdapter failSignalCollectionWithErrorMessage: dtbAdErrorString andNotify: self.delegate];
}

@end

@implementation ALAmazonAdMarketplaceMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adformat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.adFormat = adformat;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidLoad:(UIView *)adView
{
    [self.parentAdapter d: @"AdView ad loaded"];
    
    NSDictionary *extraInfo = [self.parentAdapter extraInfoForAdFormat: self.adFormat];
    [self.delegate didLoadAdForAdView: adView withExtraInfo: extraInfo];
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

- (void)adClicked
{
    [self.parentAdapter d: @"AdView clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)bannerWillLeaveApplication:(UIView *)adView
{
    [self.parentAdapter d: @"AdView will leave application"];
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
    [self.parentAdapter d: @"Interstitial loaded"];
    
    NSDictionary *extraInfo = [self.parentAdapter extraInfoForAdFormat: MAAdFormat.interstitial];
    [self.delegate didLoadInterstitialAdWithExtraInfo: extraInfo];
}

- (void)interstitial:(nullable DTBAdInterstitialDispatcher *)interstitial didFailToLoadAdWithErrorCode:(DTBAdErrorCode)errorCode
{
    [self.parentAdapter e: @"Interstitial failed to load with error: %ld", errorCode];
    
    MAAdapterError *adapterError = [ALAmazonAdMarketplaceMediationAdapter toMaxError: errorCode];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)showFromRootViewController:(UIViewController *)controller
{
    [self.parentAdapter d: @"Show interstitial from root view controller: %@", controller];
}

- (void)interstitialWillPresentScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter d: @"Interstitial will present screen"];
}

- (void)interstitialDidPresentScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter d: @"Interstitial did present screen"];
}

- (void)impressionFired
{
    [self.parentAdapter d: @"Interstitial impression fired"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)adClicked
{
    [self.parentAdapter d: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialWillLeaveApplication:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter d: @"Interstitial will leave application"];
}

- (void)videoPlaybackCompleted:(DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter d: @"Interstitial ad video playback completed"];
}

- (void)interstitialWillDismissScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter d: @"Interstitial will dismiss screen"];
}

- (void)interstitialDidDismissScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter d: @"Interstitial did dismiss screen"];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALAmazonAdMarketplaceMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALAmazonAdMarketplaceMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
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
    [self.parentAdapter d: @"Rewarded ad loaded"];
    
    NSDictionary *extraInfo = [self.parentAdapter extraInfoForAdFormat: MAAdFormat.rewarded];
    [self.delegate didLoadRewardedAdWithExtraInfo: extraInfo];
    
}

- (void)interstitial:(nullable DTBAdInterstitialDispatcher *)interstitial didFailToLoadAdWithErrorCode:(DTBAdErrorCode)errorCode
{
    [self.parentAdapter e: @"Rewarded ad failed to load with error: %ld", errorCode];
    
    MAAdapterError *adapterError = [ALAmazonAdMarketplaceMediationAdapter toMaxError: errorCode];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)showFromRootViewController:(UIViewController *)controller
{
    [self.parentAdapter d: @"Show rewarded ad from root view controller: %@", controller];
}

- (void)interstitialWillPresentScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter d: @"Rewarded ad will present screen"];
}

- (void)interstitialDidPresentScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter d: @"Rewarded ad did present screen"];
}

- (void)impressionFired
{
    [self.parentAdapter d: @"Rewarded ad impression fired"];
    [self.delegate didDisplayRewardedAd];
}

- (void)adClicked
{
    [self.parentAdapter d: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)interstitialWillLeaveApplication:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter d: @"Rewarded ad will leave application"];
}

- (void)videoPlaybackCompleted:(DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter d: @"Rewarded ad video playback completed"];
    
    self.grantedReward = YES;
}

- (void)interstitialWillDismissScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    [self.parentAdapter d: @"Rewarded ad will dismiss screen"];
}

- (void)interstitialDidDismissScreen:(nullable DTBAdInterstitialDispatcher *)interstitial
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter d: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter d: @"Rewarded ad hidden"];
    [self.delegate didHideRewardedAd];
}

@end
