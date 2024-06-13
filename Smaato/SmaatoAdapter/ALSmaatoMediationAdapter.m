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

#define ADAPTER_VERSION @"22.8.4.0"

/**
 * Router for interstitial/rewarded ad events.
 * Ads are removed on ad displayed/expired, as Smaato will allow a new ad load for the same adSpaceId.
 */
@interface ALSmaatoMediationAdapterRouter : ALMediationAdapterRouter <SMAInterstitialDelegate, SMARewardedInterstitialDelegate>
- (nullable SMAInterstitial *)interstitialAdForPlacementIdentifier:(NSString *)placementIdentifier;
- (nullable SMARewardedInterstitial *)rewardedAdForPlacementIdentifier:(NSString *)placementIdentifier;
@end

/**
 * Smaato banners are instance-based.
 */
@interface ALSmaatoMediationAdapterAdViewDelegate : NSObject <SMABannerViewDelegate>
@property (nonatomic,   weak) ALSmaatoMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

/**
 * Smaato native ad views are instance-based.
 */
@interface ALSmaatoMediationAdapterNativeAdViewDelegate : NSObject <SMANativeAdDelegate>
@property (nonatomic,   weak) ALSmaatoMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *placementIdentifier;
@property (nonatomic, strong) MAAdFormat *format;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

/**
 * Smaato native ads are instance-based.
 */
@interface ALSmaatoMediationAdapterNativeDelegate : NSObject <SMANativeAdDelegate>
@property (nonatomic,   weak) ALSmaatoMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *placementIdentifier;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MASmaatoNativeAd : MANativeAd
@property (nonatomic, weak) ALSmaatoMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)format
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALSmaatoMediationAdapter ()
// Used by the mediation adapter router
@property (nonatomic, copy, nullable) NSString *placementIdentifier;

// AdView Properties
@property (nonatomic, strong) SMABannerView *adView;
@property (nonatomic, strong) ALSmaatoMediationAdapterAdViewDelegate *adViewAdapterDelegate;

// Native Ad Properties
@property (nonatomic, strong) SMANativeAd *nativeAd;
@property (nonatomic, strong) SMANativeAdRenderer *nativeAdRenderer;
@property (nonatomic, strong) ALSmaatoMediationAdapterNativeDelegate *nativeAdapterDelegate;

// Native Ad View Properties
@property (nonatomic, strong) ALSmaatoMediationAdapterNativeAdViewDelegate *nativeAdViewAdapterDelegate;

// Interstitial/Rewarded ad delegate router
@property (nonatomic, strong, readonly) ALSmaatoMediationAdapterRouter *router;

@property (nonatomic, strong, nullable) SMAInterstitial *interstitialAd;
@property (nonatomic, strong, nullable) SMARewardedInterstitial *rewardedAd;

+ (NSArray<UIView *> *)clickableViewsForNativeAd:(MANativeAd *)maxNativeAd nativeAdView:(MANativeAdView *)maxNativeAdView;
@end

@implementation ALSmaatoMediationAdapter
@dynamic router;

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
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
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
    
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdRenderer = nil;
    self.nativeAdapterDelegate.delegate = nil;
    self.nativeAdapterDelegate = nil;
    
    self.nativeAdViewAdapterDelegate.delegate = nil;
    self.nativeAdViewAdapterDelegate = nil;
    
    self.interstitialAd = nil;
    self.rewardedAd = nil;
    
    [self.router removeAdapter: self forPlacementIdentifier: self.placementIdentifier];
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updateAgeRestrictedUser: parameters];
    [self updateLocationCollectionEnabled: parameters];
    
    NSString *signal = [SmaatoSDK collectSignals];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    self.placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@%@%@ ad: %@...", ( isBiddingAd ? @"bidding " : @"" ), ( isNative ? @"native " : @"" ), adFormat.label, self.placementIdentifier];
    
    [self updateAgeRestrictedUser: parameters];
    [self updateLocationCollectionEnabled: parameters];
    
    if ( isNative )
    {
        self.nativeAd = [[SMANativeAd alloc] init];
        self.nativeAdViewAdapterDelegate = [[ALSmaatoMediationAdapterNativeAdViewDelegate alloc] initWithParentAdapter: self
                                                                                                                format: adFormat
                                                                                                            parameters: parameters
                                                                                                             andNotify: delegate];
        self.nativeAd.delegate = self.nativeAdViewAdapterDelegate;
        
        SMANativeAdRequest *nativeAdViewAdRequest = [[SMANativeAdRequest alloc] initWithAdSpaceId: self.placementIdentifier];
        nativeAdViewAdRequest.returnUrlsForImageAssets = NO;
        
        if ( isBiddingAd )
        {
            SMAAdRequestParams *adRequestParams = [self createBiddingAdRequestParamsFromBidResponse: bidResponse];
            if ( adRequestParams && adRequestParams.ubUniqueId ) // Smaato suggests nil checking the ID
            {
                [self.nativeAd loadWithAdRequest: nativeAdViewAdRequest requestParams: adRequestParams];
            }
            else
            {
                [self log: @"Native %@ ad load failed: ad request nil with valid bid response", adFormat.label];
                [delegate didFailToLoadAdViewAdWithError: MAAdapterError.invalidConfiguration];
            }
        }
        else
        {
            [self.nativeAd loadWithAdRequest: nativeAdViewAdRequest];
        }
    }
    else
    {
        self.adView = [[SMABannerView alloc] init];
        self.adView.autoreloadInterval = kSMABannerAutoreloadIntervalDisabled;
        
        self.adViewAdapterDelegate = [[ALSmaatoMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        self.adView.delegate = self.adViewAdapterDelegate;
        
        if ( isBiddingAd )
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
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [self.interstitialAd showFromViewController: presentingViewController];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.router didFailToDisplayAdForPlacementIdentifier: placementIdentifier error: [MAAdapterError errorWithCode: -4205
                                                                                                            errorString: @"Ad Display Failed"
                                                                                                 thirdPartySdkErrorCode: 0
                                                                                              thirdPartySdkErrorMessage: @"Interstitial ad not ready"]];
#pragma clang diagnostic pop
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
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [self.rewardedAd showFromViewController: presentingViewController];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.router didFailToDisplayAdForPlacementIdentifier: placementIdentifier error: [MAAdapterError errorWithCode: -4205
                                                                                                            errorString: @"Ad Display Failed"
                                                                                                 thirdPartySdkErrorCode: 0
                                                                                              thirdPartySdkErrorMessage: @"Rewarded ad not ready"]];
#pragma clang diagnostic pop
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@ad: %@...", ( [bidResponse al_isValidString] ? @"bidding " : @"" ), placementIdentifier];
    
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
        if ( isLocationCollectionEnabled != nil )
        {
            [self log: @"Setting location collection enabled: %@", isLocationCollectionEnabled];
            // NOTE: According to docs - this is disabled by default
            SmaatoSDK.gpsEnabled = isLocationCollectionEnabled.boolValue;
        }
    }
}

- (void)updateAgeRestrictedUser:(id<MAAdapterParameters>)parameters
{
    NSNumber *isAgeRestrictedUser = [parameters isAgeRestrictedUser];
    if ( isAgeRestrictedUser != nil )
    {
        SmaatoSDK.requireCoppaCompliantAds = isAgeRestrictedUser.boolValue;
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

+ (NSArray<UIView *> *)clickableViewsForNativeAd:(MANativeAd *)maxNativeAd nativeAdView:(MANativeAdView *)maxNativeAdView
{
    NSMutableArray *clickableViews = [NSMutableArray array];
    if ( [maxNativeAd.title al_isValidString] && maxNativeAdView.titleLabel )
    {
        [clickableViews addObject: maxNativeAdView.titleLabel];
    }
    if ( [maxNativeAd.advertiser al_isValidString] && maxNativeAdView.advertiserLabel )
    {
        [clickableViews addObject: maxNativeAdView.advertiserLabel];
    }
    if ( [maxNativeAd.body al_isValidString] && maxNativeAdView.bodyLabel )
    {
        [clickableViews addObject: maxNativeAdView.bodyLabel];
    }
    if ( [maxNativeAd.callToAction al_isValidString] && maxNativeAdView.callToActionButton )
    {
        [clickableViews addObject: maxNativeAdView.callToActionButton];
    }
    if ( maxNativeAd.icon && maxNativeAdView.iconImageView )
    {
        [clickableViews addObject: maxNativeAdView.iconImageView];
    }
    if ( maxNativeAd.mediaView && maxNativeAdView.mediaContentView )
    {
        [clickableViews addObject: maxNativeAdView.mediaContentView];
    }
    
    return clickableViews;
}

#pragma mark - Dynamic Properties

- (ALSmaatoMediationAdapterRouter *)router
{
    return [ALSmaatoMediationAdapterRouter sharedInstance];
}

@end

#pragma mark - Smaato Interstitial/Rewarded Router

@interface ALSmaatoMediationAdapterRouter ()
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
    
    [self log: @"Interstitial ad loaded for placement: %@...", placementIdentifier];
    [self didLoadAdForCreativeIdentifier: interstitial.sci placementIdentifier: placementIdentifier];
}

- (void)interstitial:(nullable SMAInterstitial *)interstitial didFailWithError:(NSError *)error
{
    NSString *placementIdentifier = interstitial.adSpaceId;
    
    [self log: @"Interstitial ad failed to load for placement: %@...with error: %@", placementIdentifier, error];
    
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

- (void)interstitialWillAppear:(SMAInterstitial *)interstitial
{
    [self log: @"Interstitial ad will appear"];
}

- (void)interstitialDidAppear:(SMAInterstitial *)interstitial
{
    // Allow the next interstitial to load
    @synchronized ( self.interstitialAdsLock )
    {
        [self.interstitialAds removeObjectForKey: interstitial.adSpaceId];
    }
    
    [self log: @"Interstitial ad displayed"];
    [self didDisplayAdForPlacementIdentifier: interstitial.adSpaceId];
}

- (void)interstitialDidClick:(SMAInterstitial *)interstitial
{
    [self log: @"Interstitial ad clicked"];
    [self didClickAdForPlacementIdentifier: interstitial.adSpaceId];
}

- (void)interstitialWillLeaveApplication:(SMAInterstitial *)interstitial
{
    [self log: @"Interstitial ad will leave application"];
}

- (void)interstitialWillDisappear:(SMAInterstitial *)interstitial
{
    [self log: @"Interstitial ad will disappear"];
}

- (void)interstitialDidDisappear:(SMAInterstitial *)interstitial
{
    [self log: @"Interstitial ad hidden"];
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

- (void)rewardedInterstitialWillAppear:(SMARewardedInterstitial *)rewardedInterstitial
{
    [self log: @"Rewarded ad will appear"];
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
}

- (void)rewardedInterstitialDidClick:(SMARewardedInterstitial *)rewardedInterstitial
{
    [self log: @"Rewarded ad clicked"];
    [self didClickAdForPlacementIdentifier: rewardedInterstitial.adSpaceId];
}

- (void)rewardedInterstitialWillLeaveApplication:(SMARewardedInterstitial *)rewardedInterstitial
{
    [self log: @"Rewarded ad will leave application"];
}

- (void)rewardedInterstitialDidReward:(SMARewardedInterstitial *)rewardedInterstitial
{
    [self log: @"Rewarded ad video completed"];
    
    self.grantedReward = YES;
}

- (void)rewardedInterstitialWillDisappear:(SMARewardedInterstitial *)rewardedInterstitial
{
    [self log: @"Rewarded ad will disappear"];
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

@implementation ALSmaatoMediationAdapterNativeAdViewDelegate

- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.format = format;
        self.placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
        self.serverParameters = parameters.serverParameters;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeAd:(SMANativeAd *)nativeAd didLoadWithAdRenderer:(SMANativeAdRenderer *)renderer
{
    [self.parentAdapter log: @"Native %@ ad loaded: %@", self.format.label, self.placementIdentifier];
    
    // Save the renderer in order to register the native ad view later.
    self.parentAdapter.nativeAdRenderer = renderer;
    
    SMANativeAdAssets *assets = renderer.nativeAssets;
    if ( ![assets.title al_isValidString] )
    {
        [self.parentAdapter e: @"Native %@ ad (%@) does not have required assets.", self.format.label, nativeAd];
        [self.delegate didFailToLoadAdViewAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    dispatchOnMainQueue(^{
        MANativeAd *maxNativeAd = [[MASmaatoNativeAd alloc] initWithParentAdapter: self.parentAdapter adFormat: self.format builderBlock:^(MANativeAdBuilder *builder) {
            
            builder.title = assets.title;
            builder.advertiser = assets.sponsored;
            builder.body = assets.mainText;
            builder.callToAction = assets.cta;
            
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
        
        MANativeAdView *maxNativeAdView;
        NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
        if ( [templateName isEqualToString: @"vertical"] )
        {
            NSString *verticalTemplateName = ( self.format == MAAdFormat.leader ) ? @"vertical_leader_template" : @"vertical_media_banner_template";
            maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: verticalTemplateName];
        }
        else
        {
            NSString *adViewTemplateName = [templateName al_isValidString] ? templateName : @"media_banner_template";
            maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: adViewTemplateName];
        }
        
        NSArray<UIView *> *clickableViews = [ALSmaatoMediationAdapter clickableViewsForNativeAd: maxNativeAd nativeAdView: maxNativeAdView];
        [maxNativeAd prepareForInteractionClickableViews: clickableViews withContainer: maxNativeAdView];
        
        [self.delegate didLoadAdForAdView: maxNativeAdView withExtraInfo: nil];
    });
}

- (void)nativeAd:(SMANativeAd *)nativeAd didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALSmaatoMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native %@ ad (%@) failed to load with error: %@", self.format.label, self.placementIdentifier, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)nativeAdDidImpress:(SMANativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad shown", self.format.label];
    [self.delegate didDisplayAdViewAdWithExtraInfo: nil];
}

- (void)nativeAdDidClick:(SMANativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad clicked", self.format.label];
    [self.delegate didClickAdViewAd];
}

- (void)nativeAdDidTTLExpire:(SMANativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad expired", self.format.label];
}

- (UIViewController *)presentingViewControllerForNativeAd:(SMANativeAd *)nativeAd
{
    return [ALUtils topViewControllerFromKeyWindow];
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
        if ( isTemplateAd && ![assets.title al_isValidString] )
        {
            [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
            [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
            
            return;
        }
        
        MANativeAd *maxNativeAd = [[MASmaatoNativeAd alloc] initWithParentAdapter: self.parentAdapter adFormat: MAAdFormat.native builderBlock:^(MANativeAdBuilder *builder) {
            
            builder.title = assets.title;
            builder.body = assets.mainText;
            builder.callToAction = assets.cta;
            
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
                    if ( ALSdk.versionCode >= 11040299 )
                    {
                        MANativeAdImage *mainImage = [[MANativeAdImage alloc] initWithImage: image.image];
                        [builder performSelector: @selector(setMainImage:) withObject: mainImage];
                    }
                }
            }
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            // Introduced in 10.4.0
            if ( [builder respondsToSelector: @selector(setAdvertiser:)] )
            {
                [builder performSelector: @selector(setAdvertiser:) withObject: assets.sponsored];
            }
#pragma clang diagnostic pop
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

@end

@implementation MASmaatoNativeAd

- (instancetype)initWithParentAdapter:(ALSmaatoMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)format
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: format builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (void)prepareViewForInteraction:(MANativeAdView *)maxNativeAdView
{
    NSArray<UIView *> *clickableViews = [ALSmaatoMediationAdapter clickableViewsForNativeAd: self nativeAdView: maxNativeAdView];
    [self prepareForInteractionClickableViews: clickableViews withContainer: maxNativeAdView];
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container
{
    SMANativeAdRenderer *nativeAdRenderer = self.parentAdapter.nativeAdRenderer;
    if ( !nativeAdRenderer )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad renderer is nil."];
        return NO;
    }
    
    [self.parentAdapter d: @"Preparing views for interaction: %@ with container: %@", clickableViews, container];
    
    [self.parentAdapter.nativeAdRenderer registerViewForImpression: container];
    [self.parentAdapter.nativeAdRenderer registerViewsForClickAction: clickableViews];
    
    return YES;
}

@end
