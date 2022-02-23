//
//  ALSmaatoMediationAdapter.m
//  AppLovinSDK
//
//  Created by Christopher Cong on 3/1/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALSmaatoMediationAdapter.h"
#import <SmaatoSDKCore/SmaatoSDKCore.h>
#import <SmaatoSDKBanner/SmaatoSDKBanner.h>
#import <SmaatoSDKInterstitial/SmaatoSDKInterstitial.h>
#import <SmaatoSDKRewardedAds/SmaatoSDKRewardedAds.h>
#import <SmaatoSDKNative/SmaatoSDKNative.h>
#import <SmaatoSDKInAppBidding/SmaatoSDKInAppBidding.h>

#define ADAPTER_VERSION @"21.7.1.1"

/**
 * Router for interstitial/rewarded ad events.
 * Ads are removed on ad displayed/expired, as Smaato will allow a new ad load for the same adSpaceId.
 */
@interface ALSmaatoMediationAdapterRouter : ALMediationAdapterRouter<SMAInterstitialDelegate, SMARewardedInterstitialDelegate>
- (nullable SMAInterstitial *)interstitialAdForPlacementIdentifier:(NSString *)placementIdentifier;
- (nullable SMARewardedInterstitial *)rewardedAdForPlacementIdentifier:(NSString *)placementIdentifier;
@end

/**
 * Smaato banners are instance-based.
 */
@interface ALSmaatoMediationAdapterAdViewDelegate : NSObject<SMABannerViewDelegate>
@property (nonatomic,   weak) ALSmaatoMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

/**
 * Smaato native ads are instance-based.
 */
@interface ALSmaatoMediationAdapterNativeDelegate : NSObject<SMANativeAdDelegate>
@property (nonatomic,   weak) ALSmaatoMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MASmaatoNativeAd : MANativeAd
@property (nonatomic, weak) ALSmaatoMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALSmaatoMediationAdapter()
// Used by the mediation adapter router
@property (nonatomic, copy, nullable) NSString *placementIdentifier;

// AdView Properties
@property (nonatomic, strong) SMABannerView *adView;
@property (nonatomic, strong) ALSmaatoMediationAdapterAdViewDelegate *adViewAdapterDelegate;

// Native Ad Properties
@property (nonatomic, strong) SMANativeAd *nativeAd;
@property (nonatomic, strong) SMANativeAdRenderer *nativeAdRenderer;
@property (nonatomic, strong) ALSmaatoMediationAdapterNativeDelegate *nativeAdapterDelegate;

// Interstitial/Rewarded ad delegate router
@property (nonatomic, strong, readonly) ALSmaatoMediationAdapterRouter *router;

@property (nonatomic, strong, nullable) SMAInterstitial *interstitialAd;
@property (nonatomic, strong, nullable) SMARewardedInterstitial *rewardedAd;
@end

@implementation ALSmaatoMediationAdapter
@dynamic router;

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *pubID = [parameters.serverParameters al_stringForKey: @"pub_id" defaultValue: @""];
        [self log: @"Initializing Smaato SDK with publisher id: %@...", pubID];
        
        [self removeUnsupportedUserConsent];
        [self updateAgeRestrictedUser: parameters];
        
        // NOTE: This does not work atm
        [self updateLocationCollectionEnabled: parameters];
        
        SMAConfiguration *config = [[SMAConfiguration alloc] initWithPublisherId: pubID];
        config.logLevel = [parameters isTesting] ? kSMALogLevelVerbose : kSMALogLevelError;
        config.httpsOnly = [parameters.serverParameters al_numberForKey: @"https_only"].boolValue;
        
        [SmaatoSDK initSDKWithConfig: config];
    });
    
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (NSString *)SDKVersion
{
    return [SmaatoSDK sdkVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.adView = nil;
    self.adViewAdapterDelegate = nil;
    
    self.nativeAd = nil;
    self.nativeAdRenderer = nil;
    self.nativeAdapterDelegate = nil;
    
    self.interstitialAd = nil;
    self.rewardedAd = nil;
    
    [self.router removeAdapter: self forPlacementIdentifier: self.placementIdentifier];
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *signal = [SmaatoSDK collectSignals];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    self.placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@%@ ad view ad for placement: %@...", ( [bidResponse al_isValidString] ? @"bidding " : @"" ), adFormat.label, self.placementIdentifier];
    
    [self updateAgeRestrictedUser: parameters];
    [self updateLocationCollectionEnabled: parameters];
    
    self.adView = [[SMABannerView alloc] init];
    self.adView.autoreloadInterval = kSMABannerAutoreloadIntervalDisabled;
    
    self.adViewAdapterDelegate = [[ALSmaatoMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.adView.delegate = self.adViewAdapterDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        SMAAdRequestParams *adRequestParams = [self createBiddingAdRequestParamsFromBidResponse: bidResponse];
        if ( adRequestParams && adRequestParams.ubUniqueId ) // Smaato suggests nil checking the ID
        {
            [self.adView loadWithAdSpaceId: self.placementIdentifier
                                    adSize: [self adSizeForAdFormat: adFormat]
                             requestParams: adRequestParams];
        }
        else
        {
            [self log: @"%@ ad load failed: ad request nil with valid bid response", adFormat.label];
            [delegate didFailToLoadAdViewAdWithError: MAAdapterError.invalidConfiguration];
        }
    }
    else
    {
        [self.adView loadWithAdSpaceId: self.placementIdentifier adSize: [self adSizeForAdFormat: adFormat]];
    }
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    self.placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@interstitial ad for placement: %@...", ( [bidResponse al_isValidString] ? @"bidding " : @"" ), self.placementIdentifier];
    
    [self updateAgeRestrictedUser: parameters];
    [self updateLocationCollectionEnabled: parameters];
    
    [self.router addInterstitialAdapter: self
                               delegate: delegate
                 forPlacementIdentifier: self.placementIdentifier];
    
    if ( [[self.router interstitialAdForPlacementIdentifier: self.placementIdentifier] availableForPresentation] )
    {
        [self log: @"Interstitial ad already loaded for placement: %@...", self.placementIdentifier];
        [delegate didLoadInterstitialAd];
        
        return;
    }
    
    if ( [bidResponse al_isValidString] )
    {
        SMAAdRequestParams *adRequestParams = [self createBiddingAdRequestParamsFromBidResponse: bidResponse];
        if ( adRequestParams && adRequestParams.ubUniqueId ) // Smaato suggests nil checking the ID
        {
            [SmaatoSDK loadInterstitialForAdSpaceId: self.placementIdentifier
                                           delegate: self.router
                                      requestParams: adRequestParams];
        }
        else
        {
            [self log: @"Interstitial ad load failed: ad request nil with valid bid response"];
            [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.invalidConfiguration];
        }
    }
    else
    {
        [SmaatoSDK loadInterstitialForAdSpaceId: self.placementIdentifier delegate: self.router];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad for placement: %@...", placementIdentifier];
    
    [self.router addShowingAdapter: self];
    
    self.interstitialAd = [self.router interstitialAdForPlacementIdentifier: placementIdentifier];
    if ( [self.interstitialAd availableForPresentation] )
    {
        [self.interstitialAd showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        [self.router didFailToDisplayAdForPlacementIdentifier: placementIdentifier error: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    self.placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@rewarded ad for placement: %@...", ( [bidResponse al_isValidString] ? @"bidding " : @"" ), self.placementIdentifier];
    
    [self updateAgeRestrictedUser: parameters];
    [self updateLocationCollectionEnabled: parameters];
    
    [self.router addRewardedAdapter: self
                           delegate: delegate
             forPlacementIdentifier: self.placementIdentifier];
    
    if ( [[self.router rewardedAdForPlacementIdentifier: self.placementIdentifier] availableForPresentation] )
    {
        [self log: @"Rewarded ad already loaded for placement: %@...", self.placementIdentifier];
        [delegate didLoadRewardedAd];
        
        return;
    }
    
    if ( [bidResponse al_isValidString] )
    {
        SMAAdRequestParams *adRequestParams = [self createBiddingAdRequestParamsFromBidResponse: bidResponse];
        if ( adRequestParams && adRequestParams.ubUniqueId ) // Smaato suggests nil checking the ID
        {
            [SmaatoSDK loadRewardedInterstitialForAdSpaceId: self.placementIdentifier
                                                   delegate: self.router
                                              requestParams: adRequestParams];
        }
        else
        {
            [self log: @"Rewarded ad load failed: ad request nil with valid bid response"];
            [delegate didFailToLoadRewardedAdWithError: MAAdapterError.invalidConfiguration];
        }
    }
    else
    {
        [SmaatoSDK loadRewardedInterstitialForAdSpaceId: self.placementIdentifier delegate: self.router];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad for placement: %@...", placementIdentifier];
    
    [self.router addShowingAdapter: self];
    
    self.rewardedAd = [self.router rewardedAdForPlacementIdentifier: placementIdentifier];
    if ( [self.rewardedAd availableForPresentation] )
    {
        // Configure reward from server.
        [self configureRewardForParameters: parameters];
        
        [self.rewardedAd showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];
        [self.router didFailToDisplayAdForPlacementIdentifier: placementIdentifier error: MAAdapterError.adNotReady];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@ad: %@...", ( [bidResponse al_isValidString] ? @"bidding " : @""), placementIdentifier];
    
    [self updateAgeRestrictedUser: parameters];
    [self updateLocationCollectionEnabled: parameters];
    
    SMANativeAdRequest *nativeAdRequest = [[SMANativeAdRequest alloc] initWithAdSpaceId: placementIdentifier];
    nativeAdRequest.returnUrlsForImageAssets = NO;
    
    self.nativeAd = [[SMANativeAd alloc] init];
    self.nativeAdapterDelegate = [[ALSmaatoMediationAdapterNativeDelegate alloc] initWithParentAdapter: self
                                                                                            parameters: parameters
                                                                                             andNotify: delegate];
    self.nativeAd.delegate = self.nativeAdapterDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        SMAAdRequestParams *adRequestParams = [self createBiddingAdRequestParamsFromBidResponse: bidResponse];
        if ( adRequestParams && adRequestParams.ubUniqueId ) // Smaato suggests nil checking the ID
        {
            [self.nativeAd loadWithAdRequest: nativeAdRequest requestParams: adRequestParams];
        }
        else
        {
            [self log: @"Native ad load failed: ad request nil with valid bid response"];
            [delegate didFailToLoadNativeAdWithError: MAAdapterError.invalidConfiguration];
        }
    }
    else
    {
        [self.nativeAd loadWithAdRequest: nativeAdRequest];
    }
}

#pragma mark - GDPR

- (void)removeUnsupportedUserConsent
{
    // For more GDPR info: https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md#cmp-internal-structure-defined-api-
    
    //
    // Previous version of adapters could have set the values for IAB Consent, which are no longer supported. Remove them:
    // https://app.asana.com/0/615971567602282/1189834741836833
    //
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey: @"IABConsent_SubjectToGDPR"];
    [userDefaults removeObjectForKey: @"IABConsent_ConsentString"];
}

#pragma mark - Helper Methods

// TODO: Add local params support on init
- (void)updateLocationCollectionEnabled:(id<MAAdapterParameters>)parameters
{
    if ( ALSdk.versionCode >= 11000000 )
    {
        NSDictionary<NSString *, id> *localExtraParameters = parameters.localExtraParameters;
        NSNumber *isLocationCollectionEnabled = [localExtraParameters al_numberForKey: @"is_location_collection_enabled"];
        if ( isLocationCollectionEnabled )
        {
            // NOTE: According to docs - this is disabled by default
            SmaatoSDK.gpsEnabled = isLocationCollectionEnabled.boolValue;
        }
    }
}

- (void)updateAgeRestrictedUser:(id<MAAdapterParameters>)parameters
{
    NSNumber *isAgeRestrictedUser = [self privacySettingForSelector: @selector(isAgeRestrictedUser) fromParameters: parameters];
    if ( isAgeRestrictedUser )
    {
        SmaatoSDK.requireCoppaCompliantAds = isAgeRestrictedUser.boolValue;
    }
}

- (nullable NSNumber *)privacySettingForSelector:(SEL)selector fromParameters:(id<MAAdapterParameters>)parameters
{
    // Use reflection because compiled adapters have trouble fetching `BOOL` from old SDKs and `NSNumber` from new SDKs (above 6.14.0)
    NSMethodSignature *signature = [[parameters class] instanceMethodSignatureForSelector: selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: signature];
    [invocation setSelector: selector];
    [invocation setTarget: parameters];
    [invocation invoke];
    
    // Privacy parameters return nullable `NSNumber` on newer SDKs
    if ( ALSdk.versionCode >= 6140000 )
    {
        NSNumber *__unsafe_unretained value;
        [invocation getReturnValue: &value];
        
        return value;
    }
    // Privacy parameters return BOOL on older SDKs
    else
    {
        BOOL rawValue;
        [invocation getReturnValue: &rawValue];
        
        return @(rawValue);
    }
}

- (SMABannerAdSize)adSizeForAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return kSMABannerAdSizeXXLarge_320x50;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return kSMABannerAdSizeMediumRectangle_300x250;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return kSMABannerAdSizeLeaderboard_728x90;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return kSMABannerAdSizeAny;
    }
}

+ (MAAdapterError *)toMaxError:(NSError *)smaatoError
{
    // Note: They do not use their own codes listed in SMAError.h, nor are they using the old codes they used in 9.x.x.
    NSInteger smaatoErrorCode = smaatoError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( smaatoErrorCode )
    {
        case 1:
        case 204:
            adapterError = MAAdapterError.noFill;
            break;
        case 100:
            adapterError = MAAdapterError.noConnection;
            break;
        case 203:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: smaatoErrorCode
               thirdPartySdkErrorMessage: smaatoError.localizedDescription];
#pragma clang diagnostic pop
}

- (nullable SMAAdRequestParams *)createBiddingAdRequestParamsFromBidResponse:(NSString *)bidResponse
{
    NSError *error = nil;
    SMAInAppBid *bid = [SMAInAppBid bidWithResponseData: [bidResponse dataUsingEncoding: NSUTF8StringEncoding]];
    NSString *token = [SMAInAppBidding saveBid: bid error: &error];
    if ( error )
    {
        [self log: @"Error occurred in saving pre-bid: %@", error.description];
        return nil;
    }
    
    SMAAdRequestParams *params = [[SMAAdRequestParams alloc] init];
    params.ubUniqueId = token;
    
    return params;
}

#pragma mark - Dynamic Properties

- (ALSmaatoMediationAdapterRouter *)router
{
    return [ALSmaatoMediationAdapterRouter sharedInstance];
}

@end

#pragma mark - Smaato Interstitial/Rewarded Router

@interface ALSmaatoMediationAdapterRouter()
// Interstitial
@property (nonatomic, strong) NSMutableDictionary<NSString *, SMAInterstitial *> *interstitialAds;
@property (nonatomic, strong) NSObject *interstitialAdsLock;

// Rewarded
@property (nonatomic, strong) NSMutableDictionary<NSString *, SMARewardedInterstitial *> *rewardedAds;
@property (nonatomic, strong) NSObject *rewardedAdsLock;

@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
@end

@implementation ALSmaatoMediationAdapterRouter

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.interstitialAdsLock = [[NSObject alloc] init];
        self.interstitialAds = [NSMutableDictionary dictionary];
        
        self.rewardedAdsLock = [[NSObject alloc] init];
        self.rewardedAds = [NSMutableDictionary dictionary];
    }
    return self;
}

- (nullable SMAInterstitial *)interstitialAdForPlacementIdentifier:(NSString *)placementIdentifier
{
    @synchronized ( self.interstitialAdsLock )
    {
        return self.interstitialAds[placementIdentifier];
    }
}

- (nullable SMARewardedInterstitial *)rewardedAdForPlacementIdentifier:(NSString *)placementIdentifier
{
    @synchronized ( self.rewardedAdsLock )
    {
        return self.rewardedAds[placementIdentifier];
    }
}

#pragma mark - Interstitial Delegate Methods

- (void)interstitialDidLoad:(SMAInterstitial *)interstitial
{
    NSString *placementIdentifier = interstitial.adSpaceId;
    
    @synchronized ( self.interstitialAdsLock )
    {
        self.interstitialAds[placementIdentifier] = interstitial;
    }
    
    [self log: @"Interstitial loaded for placement: %@...", placementIdentifier];
    [self didLoadAdForCreativeIdentifier: interstitial.sci placementIdentifier: placementIdentifier];
}

- (void)interstitial:(nullable SMAInterstitial *)interstitial didFailWithError:(NSError *)error
{
    NSString *placementIdentifier = interstitial.adSpaceId;
    
    [self log: @"Interstitial failed to load for placement: %@...with error: %@", placementIdentifier, error];
    
    MAAdapterError *adapterError = [ALSmaatoMediationAdapter toMaxError: error];
    [self didFailToLoadAdForPlacementIdentifier: placementIdentifier error: adapterError];
}

- (void)interstitialDidTTLExpire:(SMAInterstitial *)interstitial
{
    [self log: @"Interstitial ad expired"];
    
    @synchronized ( self.interstitialAdsLock )
    {
        [self.interstitialAds removeObjectForKey: interstitial.adSpaceId];
    }
}

- (void)interstitialDidAppear:(SMAInterstitial *)interstitial
{
    // Allow the next interstitial to load
    @synchronized ( self.interstitialAdsLock )
    {
        [self.interstitialAds removeObjectForKey: interstitial.adSpaceId];
    }
    
    [self log: @"Interstitial displayed"];
    [self didDisplayAdForPlacementIdentifier: interstitial.adSpaceId];
}

- (void)interstitialDidClick:(SMAInterstitial *)interstitial
{
    [self log: @"Interstitial clicked"];
    [self didClickAdForPlacementIdentifier: interstitial.adSpaceId];
}

- (void)interstitialDidDisappear:(SMAInterstitial *)interstitial
{
    [self log: @"Interstitial hidden"];
    [self didHideAdForPlacementIdentifier: interstitial.adSpaceId];
}

#pragma mark - Rewarded Delegate Methods

- (void)rewardedInterstitialDidLoad:(SMARewardedInterstitial *)rewardedInterstitial
{
    NSString *placementIdentifier = rewardedInterstitial.adSpaceId;
    
    @synchronized ( self.rewardedAdsLock )
    {
        self.rewardedAds[placementIdentifier] = rewardedInterstitial;
    }
    
    [self log: @"Rewarded ad loaded for placement: %@...", placementIdentifier];
    [self didLoadAdForCreativeIdentifier: rewardedInterstitial.sci placementIdentifier: placementIdentifier];
}

- (void)rewardedInterstitialDidFail:(nullable SMARewardedInterstitial *)rewardedInterstitial withError:(NSError *)error
{
    NSString *placementIdentifier = rewardedInterstitial.adSpaceId;
    
    [self log: @"Rewarded ad failed to load for placement: %@...with error: %@", placementIdentifier, error];
    
    MAAdapterError *adapterError = [ALSmaatoMediationAdapter toMaxError: error];
    [self didFailToLoadAdForPlacementIdentifier: placementIdentifier error: adapterError];
}

- (void)rewardedInterstitialDidTTLExpire:(SMARewardedInterstitial *)rewardedInterstitial
{
    [self log: @"Rewarded ad expired"];
    
    @synchronized ( self.rewardedAdsLock )
    {
        [self.rewardedAds removeObjectForKey: rewardedInterstitial.adSpaceId];
    }
}

- (void)rewardedInterstitialDidAppear:(SMARewardedInterstitial *)rewardedInterstitial
{
    // Allow the next rewarded ad to load
    @synchronized ( self.rewardedAdsLock )
    {
        [self.rewardedAds removeObjectForKey: rewardedInterstitial.adSpaceId];
    }
    
    [self log: @"Rewarded ad displayed"];
    [self didDisplayAdForPlacementIdentifier: rewardedInterstitial.adSpaceId];
}

- (void)rewardedInterstitialDidStart:(SMARewardedInterstitial *)rewardedInterstitial
{
    [self log: @"Reward ad video started"];
    [self didStartRewardedVideoForPlacementIdentifier: rewardedInterstitial.adSpaceId];
}

- (void)rewardedInterstitialDidClick:(SMARewardedInterstitial *)rewardedInterstitial
{
    [self log: @"Rewarded ad clicked"];
    [self didClickAdForPlacementIdentifier: rewardedInterstitial.adSpaceId];
}

- (void)rewardedInterstitialDidReward:(SMARewardedInterstitial *)rewardedInterstitial
{
    [self log: @"Reward ad video completed"];
    [self didCompleteRewardedVideoForPlacementIdentifier: rewardedInterstitial.adSpaceId];
    
    self.grantedReward = YES;
}

- (void)rewardedInterstitialDidDisappear:(SMARewardedInterstitial *)rewardedInterstitial
{
    NSString *placementIdentifier = rewardedInterstitial.adSpaceId;
    
    if ( [self hasGrantedReward] || [self shouldAlwaysRewardUserForPlacementIdentifier: placementIdentifier] )
    {
        MAReward *reward = [self rewardForPlacementIdentifier: placementIdentifier];
        [self log: @"Rewarded user with reward: %@", reward];
        [self didRewardUserForPlacementIdentifier: placementIdentifier withReward: reward];
    }
    
    [self log: @"Rewarded ad hidden"];
    [self didHideAdForPlacementIdentifier: placementIdentifier];
}

#pragma mark - Utility Methods

- (void)didLoadAdForCreativeIdentifier:(nullable NSString *)creativeIdentifier placementIdentifier:(NSString *)placementIdentifier
{
    // Passing extra info such as creative id supported in 6.15.0+
    if ( ALSdk.versionCode >= 6150000 && [creativeIdentifier al_isValidString] )
    {
        [self performSelector: @selector(didLoadAdForPlacementIdentifier:withExtraInfo:)
                   withObject: placementIdentifier
                   withObject: @{@"creative_id" : creativeIdentifier}];
    }
    else
    {
        [self didLoadAdForPlacementIdentifier: placementIdentifier];
    }
}

@end

#pragma mark - Smaato AdView Delegate

@implementation ALSmaatoMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (UIViewController *)presentingViewControllerForBannerView:(SMABannerView *)bannerView
{
    return [ALUtils topViewControllerFromKeyWindow];
}

- (void)bannerViewDidLoad:(SMABannerView *)bannerView
{
    [self.parentAdapter log: @"AdView loaded"];
    
    // Passing extra info such as creative id supported in 6.15.0+
    if ( ALSdk.versionCode >= 6150000 && [bannerView.sci al_isValidString] )
    {
        [self.delegate performSelector: @selector(didLoadAdForAdView:withExtraInfo:)
                            withObject: bannerView
                            withObject: @{@"creative_id" : bannerView.sci}];
    }
    else
    {
        [self.delegate didLoadAdForAdView: bannerView];
    }
}

- (void)bannerView:(SMABannerView *)bannerView didFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"AdView failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALSmaatoMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)bannerViewDidTTLExpire:(SMABannerView *)bannerView
{
    [self.parentAdapter log: @"AdView ad expired"];
}

- (void)bannerViewDidImpress:(SMABannerView *)bannerView
{
    [self.parentAdapter log: @"AdView displayed"];
    [self.delegate didDisplayAdViewAd];
}

- (void)bannerViewDidClick:(SMABannerView *)bannerView
{
    [self.parentAdapter log: @"AdView clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)bannerViewDidPresentModalContent:(SMABannerView *)bannerView
{
    [self.parentAdapter log: @"AdView expanded"];
    [self.delegate didExpandAdViewAd];
}

- (void)bannerViewDidDismissModalContent:(SMABannerView *)bannerView
{
    // Note: Smaato will remove the rendered ad before to this method is called.
    // On Android, Smaato will remove the rendered ad and attempt to render a new one.
    [self.parentAdapter log: @"AdView collapsed"];
    [self.delegate didCollapseAdViewAd];
}

@end

@implementation ALSmaatoMediationAdapterNativeDelegate

- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
        self.serverParameters = parameters.serverParameters;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeAd:(SMANativeAd *)nativeAd didLoadWithAdRenderer:(SMANativeAdRenderer *)renderer
{
    [self.parentAdapter log: @"Native ad loaded: %@", self.placementIdentifier];
    
    // Save the renderer in order to register the native ad view later.
    self.parentAdapter.nativeAdRenderer = renderer;
    
    dispatchOnMainQueue(^{
        
        SMANativeAdAssets *assets = renderer.nativeAssets;
        NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
        BOOL isTemplateAd = [templateName al_isValidString];
        
        if ( ![self hasRequiredAssetsInNativeAd: isTemplateAd nativeAdAssets: assets] )
        {
            [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
            [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
            
            return;
        }
        
        MANativeAd *maxNativeAd = [[MASmaatoNativeAd alloc] initWithParentAdapter: self.parentAdapter builderBlock:^(MANativeAdBuilder *builder) {
            
            builder.title = assets.title;
            builder.body = assets.mainText;
            builder.callToAction = assets.cta;
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            // Introduced in 10.4.0
            if ( [builder respondsToSelector: @selector(setAdvertiser:)] )
            {
                [builder performSelector: @selector(setAdvertiser:) withObject: assets.sponsored];
            }
#pragma clang diagnostic pop
            
            if ( assets.icon.image )
            {
                builder.icon = [[MANativeAdImage alloc] initWithImage: assets.icon.image];
            }
            
            if ( assets.images.count > 0 )
            {
                SMANativeImage *image = assets.images.firstObject;
                if ( image.image )
                {
                    UIImageView *mediaImageView = [[UIImageView alloc] initWithImage: image.image];
                    mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
                    builder.mediaView = mediaImageView;
                }
            }
        }];
        
        [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
    });
}

- (void)nativeAd:(SMANativeAd * )nativeAd didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALSmaatoMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad (%@) failed to load with error: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeAdDidImpress:(SMANativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad shown"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeAdDidClick:(SMANativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)nativeAdDidTTLExpire:(SMANativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad expired"];
}

- (UIViewController *)presentingViewControllerForNativeAd:(SMANativeAd *)nativeAd
{
    return [ALUtils topViewControllerFromKeyWindow];
}

- (BOOL)hasRequiredAssetsInNativeAd:(BOOL)isTemplateAd nativeAdAssets:(SMANativeAdAssets *)assets
{
    if ( isTemplateAd )
    {
        return [assets.title al_isValidString];
    }
    else
    {
        return [assets.title al_isValidString]
        && [assets.cta al_isValidString]
        && assets.images.count > 0
        && assets.images.firstObject.image;
    }
}

@end

@implementation MASmaatoNativeAd

- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (void)prepareViewForInteraction:(MANativeAdView *)maxNativeAdView
{
    if ( !self.parentAdapter.nativeAdRenderer )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad renderer is nil."];
        return;
    }
    
    NSMutableArray *clickableViews = [NSMutableArray array];
    if ( [self.title al_isValidString] && maxNativeAdView.titleLabel )
    {
        [clickableViews addObject: maxNativeAdView.titleLabel];
    }
    if ( [self.body al_isValidString] && maxNativeAdView.bodyLabel )
    {
        [clickableViews addObject: maxNativeAdView.bodyLabel];
    }
    if ( [self.callToAction al_isValidString] && maxNativeAdView.callToActionButton )
    {
        [clickableViews addObject: maxNativeAdView.callToActionButton];
    }
    if ( self.icon && maxNativeAdView.iconImageView )
    {
        [clickableViews addObject: maxNativeAdView.iconImageView];
    }
    if ( self.mediaView && maxNativeAdView.mediaContentView )
    {
        [clickableViews addObject: maxNativeAdView.mediaContentView];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // Introduced in 10.4.0
    if ( [maxNativeAdView respondsToSelector: @selector(advertiserLabel)] && [self respondsToSelector: @selector(advertiser)] )
    {
        id advertiserLabel = [maxNativeAdView performSelector: @selector(advertiserLabel)];
        id advertiser = [self performSelector: @selector(advertiser)];
        if ( [advertiser al_isValidString] && advertiserLabel )
        {
            [clickableViews addObject: advertiserLabel];
        }
    }
#pragma clang diagnostic pop
    
    [self.parentAdapter.nativeAdRenderer registerViewForImpression: maxNativeAdView];
    [self.parentAdapter.nativeAdRenderer registerViewsForClickAction: clickableViews];
}

@end
