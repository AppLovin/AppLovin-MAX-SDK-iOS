//
//  ALMintegralMediationAdapter.m
//  AppLovinSDK
//

#import "ALMintegralMediationAdapter.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDK/MTGErrorCodeConstant.h>
#import <MTGSDKBidding/MTGBiddingSDK.h>
#import <MTGSDKInterstitialVideo/MTGBidInterstitialVideoAdManager.h>
#import <MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>
#import <MTGSDKReward/MTGRewardAdManager.h>
#import <MTGSDKReward/MTGBidRewardAdManager.h>
#import <MTGSDKBanner/MTGBannerAdView.h>
#import <MTGSDKBanner/MTGBannerAdViewDelegate.h>

#define ADAPTER_VERSION @"7.1.2.0.0"

// List of Mintegral error codes not defined in API, but in their docs
//
// http://cdn-adn.rayjump.com/cdn-adn/v2/markdown_v2/index.html?file=sdk-m_sdk-ios&lang=en#faqs
//
#define EXCEPTION_RETURN_EMPTY -1 // ads no fill
#define EXCEPTION_TIMEOUT -9 // request timeout
#define EXCEPTION_IV_RECALLNET_INVALIDATE -1904 // The network status at the time of the request is incorrect. Generally， because of the SDK initialization is not completed yet when the request has been sent.
#define EXCEPTION_SIGN_ERROR -10 // AppID and appKey do not match correctly
#define EXCEPTION_UNIT_NOT_FOUND -1201 // Can not find the unitID in dashboard
#define EXCEPTION_UNIT_ID_EMPTY -1202 // unitID is empty
#define EXCEPTION_UNIT_NOT_FOUND_IN_APP -1203 // Can not find the unitID of the appID
#define EXCEPTION_UNIT_ADTYPE_ERROR -1205 // The adtype of the unitID is wrong
#define EXCEPTION_APP_ID_EMPTY -1301 // appID is empty
#define EXCEPTION_APP_NOT_FOUND -1302 // Can not find the appId

@interface ALMintegralMediationAdapterInterstitialDelegate : NSObject<MTGInterstitialVideoDelegate, MTGBidInterstitialVideoDelegate>
@property (nonatomic,   weak) ALMintegralMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMintegralMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALMintegralMediationAdapterRewardedDelegate : NSObject<MTGRewardAdLoadDelegate, MTGRewardAdShowDelegate>
@property (nonatomic,   weak) ALMintegralMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALMintegralMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALMintegralMediationAdapterBannerViewDelegate : NSObject<MTGBannerAdViewDelegate>
@property (nonatomic,   weak) ALMintegralMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMintegralMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALMintegralMediationAdapterNativeAdDelegate : NSObject<MTGNativeAdManagerDelegate, MTGBidNativeAdManagerDelegate, MTGMediaViewDelegate>
@property (nonatomic,   weak) ALMintegralMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) NSString *unitId;
@property (nonatomic, strong) NSString *placementId;
- (instancetype)initWithParentAdapter:(ALMintegralMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAMintegralNativeAd : MANativeAd
@property (nonatomic, weak) ALMintegralMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALMintegralMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALMintegralMediationAdapter()

@property (nonatomic, strong) MTGBidInterstitialVideoAdManager *bidInterstitialVideoManager;
@property (nonatomic, strong) MTGInterstitialVideoAdManager *interstitialVideoManager;
@property (nonatomic, strong) MTGBannerAdView *bannerAdView;
@property (nonatomic, strong) MTGBidNativeAdManager *bidNativeAdManager;
@property (nonatomic, strong) MTGCampaign *nativeAdCampaign;
@property (nonatomic,   weak) MANativeAdView *maxNativeAdView;
@property (nonatomic, strong) NSArray<UIView *> *clickableViews;

@property (nonatomic, strong) ALMintegralMediationAdapterInterstitialDelegate *interstitialDelegate;
@property (nonatomic, strong) ALMintegralMediationAdapterRewardedDelegate *rewardedDelegate;
@property (nonatomic, strong) ALMintegralMediationAdapterBannerViewDelegate *bannerDelegate;
@property (nonatomic, strong) ALMintegralMediationAdapterNativeAdDelegate *nativeAdDelegate;

@end

@implementation ALMintegralMediationAdapter
static NSTimeInterval const kDefaultImageTaskTimeoutSeconds = 5.0; // Mintegral ad load timeout is 10s, so this is 5s.

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *appId = [parameters.serverParameters al_stringForKey: @"app_id"];
        NSString *appKey = [parameters.serverParameters al_stringForKey: @"app_key"];
        [self log: @"Initializing Mintegral SDK with app id: %@ and app key: %@...", appId, appKey];
        
        MTGSDK *mtgSDK = [MTGSDK sharedInstance];
        
        // Must be called before -[MTGSDK setAppID:ApiKey:] - GDPR status can only be set before SDK initialization
        NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
        if ( hasUserConsent )
        {
            mtgSDK.consentStatus = hasUserConsent.boolValue;
        }
        
        if ( ALSdk.versionCode >= 61100 )
        {
            // Has to be _before_ their SDK init as well
            NSNumber *isDoNotSell = [self privacySettingForSelector: @selector(isDoNotSell) fromParameters: parameters];
            if ( isDoNotSell && isDoNotSell.boolValue )
            {
                mtgSDK.doNotTrackStatus = YES;
            }
        }
        
        [mtgSDK setAppID: appId ApiKey: appKey];
    });
    
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
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

- (NSString *)SDKVersion
{
    return [MTGSDK sdkVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.bidInterstitialVideoManager.delegate = nil;
    self.bidInterstitialVideoManager = nil;
    
    self.interstitialVideoManager.delegate = nil;
    self.interstitialVideoManager = nil;
    
    [self.bannerAdView destroyBannerAdView];
    self.bannerAdView.delegate = nil;
    self.bannerAdView = nil;
    
    [self.bidNativeAdManager unregisterView: self.maxNativeAdView clickableViews: self.clickableViews];
    self.bidNativeAdManager.delegate = nil;
    self.bidNativeAdManager = nil;
    
    self.nativeAdCampaign = nil;
    
    self.interstitialDelegate = nil;
    self.rewardedDelegate = nil;
    self.bannerDelegate = nil;
    self.nativeAdDelegate = nil;
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *signal = [MTGBiddingSDK buyerUID];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    // Overwritten by `mute_state` setting, unless `mute_state` is disabled
    BOOL shouldUpdateMuteState = [parameters.serverParameters al_containsValueForKey: @"is_muted"]; // Introduced in 6.10.0
    BOOL muted = [parameters.serverParameters al_numberForKey: @"is_muted"].boolValue;
    
    self.interstitialDelegate = [[ALMintegralMediationAdapterInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    NSString *unitId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *placementId = [parameters.serverParameters al_stringForKey: @"placement_id"];
    
    if ( [parameters.bidResponse al_isValidString] )
    {
        [self log: @"Loading bidding interstitial for unit id: %@ and placement id: %@...", unitId, placementId];
        
        self.bidInterstitialVideoManager = [[MTGBidInterstitialVideoAdManager alloc] initWithPlacementId: placementId
                                                                                                  unitId: unitId
                                                                                                delegate: self.interstitialDelegate];
        
        if ( [self.bidInterstitialVideoManager isVideoReadyToPlayWithPlacementId: placementId unitId: unitId] )
        {
            [self log: @"A bidding interstitial ad is ready already"];
            [delegate didLoadInterstitialAd];
        }
        else
        {
            // Update mute state if configured by backend
            if ( shouldUpdateMuteState ) self.bidInterstitialVideoManager.playVideoMute = muted;
            
            [self.bidInterstitialVideoManager loadAdWithBidToken: parameters.bidResponse];
        }
    }
    else
    {
        [self log: @"Loading mediated interstitial ad for unit id: %@ and placement id: %@...", unitId, placementId];
        
        self.interstitialVideoManager = [[MTGInterstitialVideoAdManager alloc] initWithPlacementId: placementId
                                                                                            unitId: unitId
                                                                                          delegate: self.interstitialDelegate];
        
        if ( [self.interstitialVideoManager isVideoReadyToPlayWithPlacementId: placementId unitId: unitId] )
        {
            [self log: @"A mediated interstitial ad is ready already"];
            [delegate didLoadInterstitialAd];
        }
        else
        {
            // Update mute state if configured by backend
            if ( shouldUpdateMuteState ) self.interstitialVideoManager.playVideoMute = muted;
            
            [self.interstitialVideoManager loadAd];
        }
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *unitId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *placementId = [parameters.serverParameters al_stringForKey: @"placement_id"];
    
    if ( [self.bidInterstitialVideoManager isVideoReadyToPlayWithPlacementId: placementId unitId: unitId] )
    {
        [self log: @"Showing bidding interstitial..."];
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [self.bidInterstitialVideoManager showFromViewController: presentingViewController];
    }
    else if ( [self.interstitialVideoManager isVideoReadyToPlayWithPlacementId: placementId unitId: unitId] )
    {
        [self log: @"Showing mediated interstitial..."];
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [self.interstitialVideoManager showFromViewController: presentingViewController];
    }
    else
    {
        [self log: @"Unable to show interstitial - no ad loaded..."];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    // Overwritten by `mute_state` setting, unless `mute_state` is disabled
    BOOL shouldUpdateMuteState = [parameters.serverParameters al_containsValueForKey: @"is_muted"]; // Introduced in 6.10.0
    BOOL muted = [parameters.serverParameters al_numberForKey: @"is_muted"].boolValue;
    
    self.rewardedDelegate = [[ALMintegralMediationAdapterRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    NSString *unitId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *placementId = [parameters.serverParameters al_stringForKey: @"placement_id"];
    
    if ( [parameters.bidResponse al_isValidString] )
    {
        [self log: @"Loading bidding rewarded ad for unit id: %@ and placement id: %@...", unitId, placementId];
        
        if ( [[MTGBidRewardAdManager sharedInstance] isVideoReadyToPlayWithPlacementId: placementId unitId: unitId] )
        {
            [self log: @"A bidding rewarded ad is ready already"];
            [delegate didLoadRewardedAd];
        }
        else
        {
            if ( shouldUpdateMuteState ) [MTGBidRewardAdManager sharedInstance].playVideoMute = muted;
            
            [[MTGBidRewardAdManager sharedInstance] loadVideoWithBidToken: parameters.bidResponse
                                                              placementId: placementId
                                                                   unitId: unitId
                                                                 delegate: self.rewardedDelegate];
        }
    }
    else
    {
        [self log: @"Loading mediated rewarded ad for unit id: %@ and placement id: %@...", unitId, placementId];
        
        if ( [[MTGRewardAdManager sharedInstance] isVideoReadyToPlayWithPlacementId: placementId unitId: unitId] )
        {
            [self log: @"A mediated rewarded ad is ready already"];
            [delegate didLoadRewardedAd];
        }
        else
        {
            if ( shouldUpdateMuteState ) [MTGRewardAdManager sharedInstance].playVideoMute = muted;
            
            [[MTGRewardAdManager sharedInstance] loadVideoWithPlacementId: placementId
                                                                   unitId: unitId
                                                                 delegate: self.rewardedDelegate];
        }
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    // Configure reward from server.
    [self configureRewardForParameters: parameters];
    
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    NSString *rewardId = serverParameters[@"reward_id"];
    NSString *userId = serverParameters[@"user_id"];
    
    NSString *unitId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *placementId = [serverParameters al_stringForKey: @"placement_id"];
    
    if ( [[MTGBidRewardAdManager sharedInstance] isVideoReadyToPlayWithPlacementId: placementId unitId: unitId] )
    {
        [self log: @"Showing bidding rewarded ad..."];
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [[MTGBidRewardAdManager sharedInstance] showVideoWithPlacementId: placementId
                                                                  unitId: unitId
                                                            withRewardId: rewardId
                                                                  userId: userId
                                                                delegate: self.rewardedDelegate
                                                          viewController: presentingViewController];
    }
    else if ( [[MTGRewardAdManager sharedInstance] isVideoReadyToPlayWithPlacementId: placementId unitId: unitId] )
    {
        [self log: @"Showing mediated rewarded ad..."];
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [[MTGRewardAdManager sharedInstance] showVideoWithPlacementId: placementId
                                                               unitId: unitId
                                                         withRewardId: rewardId
                                                               userId: userId
                                                             delegate: self.rewardedDelegate
                                                       viewController: presentingViewController];
    }
    else
    {
        [self log: @"Unable to show rewarded ad - no ad loaded..."];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    MTGBannerSizeType sizeType = [self sizeTypeFromAdFormat: adFormat];
    
    NSString *unitId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *placementId = [parameters.serverParameters al_stringForKey: @"placement_id"];
    
    self.bannerAdView = [[MTGBannerAdView alloc] initBannerAdViewWithBannerSizeType: sizeType
                                                                        placementId: placementId
                                                                             unitId: unitId
                                                                 rootViewController: [ALUtils topViewControllerFromKeyWindow]];
    
    self.bannerDelegate = [[ALMintegralMediationAdapterBannerViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.bannerAdView.delegate = self.bannerDelegate;
    
    self.bannerAdView.autoRefreshTime = 0;
    self.bannerAdView.showCloseButton = MTGBoolNo;
    
    if ( [parameters.bidResponse al_isValidString] )
    {
        [self log: @"Loading bidding banner ad for unit id: %@ and placement id: %@...", unitId, placementId];
        [self.bannerAdView loadBannerAdWithBidToken: parameters.bidResponse];
    }
    else
    {
        [self log: @"Loading mediated banner ad for unit id: %@ and placement id: %@...", unitId, placementId];
        [self.bannerAdView loadBannerAd];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *unitId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *placementId = [parameters.serverParameters al_stringForKey: @"placement_id"];
    
    [self log: @"Loading bidding native ad for unit id: %@ and placement id: %@...", unitId, placementId];
    
    self.nativeAdDelegate = [[ALMintegralMediationAdapterNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                            parameters: parameters
                                                                                             andNotify: delegate];
    
    // NOTE: Mintegral's demo and MoPub's adapter does not enable `autoCacheImage` - may not guarantee that the image is cached
    self.bidNativeAdManager = [[MTGBidNativeAdManager alloc] initWithPlacementId: placementId
                                                                          unitID: unitId
                                                                  autoCacheImage: NO
                                                        presentingViewController: nil];
    
    self.bidNativeAdManager.delegate = self.nativeAdDelegate;
    [self.bidNativeAdManager loadWithBidToken: parameters.bidResponse];
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(NSError *)mintegralError
{
    MTGErrorCode mintegralErrorCode = mintegralError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( mintegralErrorCode )
    {
        case KMTGErrorCodeEmptyUnitId:
        case EXCEPTION_SIGN_ERROR:
        case EXCEPTION_UNIT_NOT_FOUND:
        case EXCEPTION_UNIT_ID_EMPTY:
        case EXCEPTION_UNIT_NOT_FOUND_IN_APP:
        case EXCEPTION_UNIT_ADTYPE_ERROR:
        case EXCEPTION_APP_ID_EMPTY:
        case EXCEPTION_APP_NOT_FOUND:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case kMTGErrorCodeNoAds:
        case kMTGErrorCodeNoAdsAvailableToPlay:
        case EXCEPTION_RETURN_EMPTY:
            adapterError = MAAdapterError.noFill;
            break;
        case kMTGErrorCodeConnectionLost:
            adapterError = MAAdapterError.noConnection;
            break;
        case kMTGErrorCodeDailyLimit:
            adapterError = MAAdapterError.adFrequencyCappedError;
            break;
        case kMTGErrorCodeLoadAdsTimeOut:
        case EXCEPTION_TIMEOUT:
            adapterError = MAAdapterError.timeout;
            break;
        case kMTGErrorCodeOfferExpired:
            adapterError = MAAdapterError.adExpiredError;
            break;
        case EXCEPTION_IV_RECALLNET_INVALIDATE:
            adapterError = MAAdapterError.notInitialized;
            break;
        case kMTGErrorCodeUnknownError:
        case kMTGErrorCodeRewardVideoFailedToLoadVideoData:
        case kMTGErrorCodeRewardVideoFailedToLoadPlayable:
        case kMTGErrorCodeRewardVideoFailedToLoadTemplateImage:
        case kMTGErrorCodeRewardVideoFailedToLoadPlayableURLFailed:
        case kMTGErrorCodeRewardVideoFailedToLoadPlayableURLReadyTimeOut:
        case kMTGErrorCodeRewardVideoFailedToLoadPlayableURLReadyNO:
        case kMTGErrorCodeRewardVideoFailedToLoadPlayableURLInvalid:
        case kMTGErrorCodeRewardVideoFailedToLoadMd5Invalid:
        case kMTGErrorCodeRewardVideoFailedToSettingInvalid:
        case KMTGErrorCodeEmptyBidToken:
        case kMTGErrorCodeURLisEmpty:
        case kMTGErrorCodeFailedToPlay:
        case kMTGErrorCodeFailedToLoad:
        case kMTGErrorCodeFailedToShow:
        case kMTGErrorCodeFailedToShowCbp:
        case kMTGErrorCodeMaterialLoadFailed:
        case kMTGErrorCodeNoSupportPopupWindow:
        case kMTGErrorCodeFailedDiskIO:
            adapterError = MAAdapterError.internalError;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: mintegralErrorCode
               thirdPartySdkErrorMessage: mintegralError.localizedDescription];
#pragma clang diagnostic pop
}

- (MTGBannerSizeType)sizeTypeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader )
    {
        return MTGSmartBannerType;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return MTGMediumRectangularBanner300x250;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        
        return MTGSmartBannerType;
    }
}

@end

#pragma mark - MTGInterstitialDelegate Methods

@implementation ALMintegralMediationAdapterInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALMintegralMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *)adManager
{
    // Ad has loaded and video has been downloaded
    [self.parentAdapter log: @"Interstitial successfully loaded and video has been downloaded"];
    
    // Passing extra info such as creative id supported in 6.15.0+
    NSString *requestId = [adManager getRequestIdWithUnitId: adManager.currentUnitId];
    if ( ALSdk.versionCode >= 6150000 && [requestId al_isValidString] )
    {
        [self.delegate performSelector: @selector(didLoadInterstitialAdWithExtraInfo:)
                            withObject: @{@"creative_id" : requestId}];
    }
    else
    {
        [self.delegate didLoadInterstitialAd];
    }
}

- (void)onInterstitialAdLoadSuccess:(MTGInterstitialVideoAdManager *)adManager
{
    // Ad has loaded but video still needs to be downloaded
    [self.parentAdapter log: @"Interstitial successfully loaded but video still needs to be downloaded"];
}

- (void)onInterstitialVideoLoadFail:(NSError *)error adManager:(MTGInterstitialVideoAdManager *)adManager
{
    [self.parentAdapter log: @"Interstitial failed to load: %@", error];
    
    MAAdapterError *adapterError = [ALMintegralMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)onInterstitialVideoShowSuccess:(MTGInterstitialVideoAdManager *)adManager
{
    [self.parentAdapter log: @"Interstitial displayed"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)onInterstitialVideoShowFail:(NSError *)error adManager:(MTGInterstitialVideoAdManager *)adManager
{
    [self.parentAdapter log: @"Interstitial failed to show: %@", error];
    
    MAAdapterError *adapterError = [ALMintegralMediationAdapter toMaxError: error];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)onInterstitialVideoAdClick:(MTGInterstitialVideoAdManager *)adManager
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(MTGInterstitialVideoAdManager *)adManager
{
    [self.parentAdapter log: @"Interstitial hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)onInterstitialVideoAdDidClosed:(MTGInterstitialVideoAdManager *)adManager
{
    [self.parentAdapter log: @"Interstitial video completed"];
}

- (void)onInterstitialVideoEndCardShowSuccess:(MTGInterstitialVideoAdManager *)adManager
{
    [self.parentAdapter log: @"Interstitial endcard shown"];
}

@end

#pragma mark - MTGRewardedDelegate Methods

@implementation ALMintegralMediationAdapterRewardedDelegate

- (instancetype)initWithParentAdapter:(ALMintegralMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)onVideoAdLoadSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
    // Ad has loaded and video has been downloaded
    [self.parentAdapter log: @"Rewarded ad successfully loaded and video has been downloaded"];
    
    // Attempt to get request/creative id from bid manager first
    NSString *requestId = [[MTGBidRewardAdManager sharedInstance] getRequestIdWithUnitId: unitId];
    if ( ![requestId al_isValidString] ) // ... then placement manager if not found from bid manager
    {
        requestId = [[MTGRewardAdManager sharedInstance] getRequestIdWithUnitId: unitId];
    }
    
    // Passing extra info such as creative id supported in 6.15.0+
    if ( ALSdk.versionCode >= 6150000 && [requestId al_isValidString] )
    {
        [self.delegate performSelector: @selector(didLoadRewardedAdWithExtraInfo:)
                            withObject: @{@"creative_id" : requestId}];
    }
    else
    {
        [self.delegate didLoadRewardedAd];
    }
}

- (void)onAdLoadSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
    // Ad has loaded but video still needs to be downloaded
    [self.parentAdapter log: @"Rewarded ad successfully loaded but video still needs to be downloaded"];
}

- (void)onVideoAdLoadFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId error:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded ad failed to load: %@", error];
    
    MAAdapterError *adapterError = [ALMintegralMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)onVideoAdShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
    [self.parentAdapter log: @"Rewarded ad displayed"];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)onVideoAdShowFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withError:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded ad failed to show: %@", error];
    
    MAAdapterError *adapterError = [ALMintegralMediationAdapter toMaxError: error];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)onVideoAdClicked:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)onVideoAdDismissed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(nullable MTGRewardAdInfo *)rewardInfo
{
    [self.parentAdapter log: @"Rewarded ad granted reward"];
    self.grantedReward = converted;
}

- (void)onVideoAdDidClosed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
    [self.parentAdapter log: @"Rewarded ad hidden"];
    
    [self.delegate didCompleteRewardedAdVideo];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.delegate didHideRewardedAd];
}

- (void)onVideoPlayCompleted:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
    [self.parentAdapter log: @"Rewarded ad video completed"];
}

- (void)onVideoEndCardShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
    [self.parentAdapter log: @"Rewarded ad endcard shown"];
}

@end

#pragma mark MTGAdViewDelegate Methods

@implementation  ALMintegralMediationAdapterBannerViewDelegate

- (instancetype)initWithParentAdapter:(ALMintegralMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adViewLoadSuccess:(MTGBannerAdView *)adView
{
    [self.parentAdapter log: @"Banner ad loaded"];
    
    // Passing extra info such as creative id supported in 6.15.0+
    if ( ALSdk.versionCode >= 6150000 && [adView.requestId al_isValidString] )
    {
        [self.delegate performSelector: @selector(didLoadAdForAdView:withExtraInfo:)
                            withObject: adView
                            withObject: @{@"creative_id" : adView.requestId}];
    }
    else
    {
        [self.delegate didLoadAdForAdView: adView];
    }
}

- (void)adViewLoadFailedWithError:(NSError *)error adView:(MTGBannerAdView *)adView
{
    [self.parentAdapter log: @"Banner ad failed to load: %@", error];
    
    MAAdapterError *adapterError = [ALMintegralMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)adViewWillLogImpression:(MTGBannerAdView *)adView
{
    [self.parentAdapter log: @"Banner ad displayed"];
    [self.delegate didDisplayAdViewAd];
}

- (void)adViewDidClicked:(MTGBannerAdView *)adView
{
    [self.parentAdapter log: @"Banner ad clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)adViewWillLeaveApplication:(MTGBannerAdView *)adView
{
    [self.parentAdapter log: @"Banner ad will leave application"];
}

- (void)adViewWillOpenFullScreen:(MTGBannerAdView *)adView
{
    [self.parentAdapter log: @"Banner ad expanded"];
    [self.delegate didExpandAdViewAd];
}

- (void)adViewCloseFullScreen:(MTGBannerAdView *)adView
{
    [self.parentAdapter log: @"Banner ad collapsed"];
    [self.delegate didCollapseAdViewAd];
}

- (void)adViewClosed:(MTGBannerAdView *)adView
{
    [self.parentAdapter log: @"Banner ad closed"];
    [self.delegate didHideAdViewAd];
}

@end

#pragma mark MTGNativeAdDelegate Methods

@implementation ALMintegralMediationAdapterNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALMintegralMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.serverParameters = parameters.serverParameters;
        self.delegate = delegate;
        
        self.unitId = parameters.thirdPartyAdPlacementIdentifier;
        self.placementId = [self.serverParameters al_stringForKey: @"placement_id"];
    }
    return self;
}

- (void)nativeAdsLoaded:(NSArray *)nativeAds bidNativeManager:(MTGBidNativeAdManager *)bidNativeManager
{
    if ( nativeAds.count == 0 )
    {
        [self.parentAdapter log: @"Native ad failed to load for unit id: %@ placement id: %@ with error: no fill", self.unitId, self.placementId];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
        return;
    }
    
    MTGCampaign *campaign = nativeAds[0];
    NSString *templateName = [self.serverParameters al_stringForKey: @"template"];
    BOOL isTemplateAd = [templateName al_isValidString];
    
    if ( [self hasRequiredAssets: campaign isTemplateAd: isTemplateAd] )
    {
        self.parentAdapter.nativeAdCampaign = campaign;
        
        [self.parentAdapter log: @"Native ad loaded for unit id: %@ placement id: %@", self.unitId, self.placementId];
        [self processNativeAd: campaign unitId: self.unitId];
    }
    else
    {
        [self.parentAdapter log: @"Native ad failed to load for unit id: %@ placement id: %@ with error: missing required assets", self.unitId, self.placementId];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
    }
}

- (void)nativeAdsFailedToLoadWithError:(NSError *)error bidNativeManager:(MTGBidNativeAdManager *)bidNativeManager
{
    MAAdapterError *adapterError = [ALMintegralMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad failed to load for unit id: %@ placement id: %@ with error: %@", self.unitId, self.placementId, adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeAdImpressionWithType:(MTGAdSourceType)type bidNativeManager:(MTGBidNativeAdManager *)bidNativeManager
{
    [self.parentAdapter log: @"Native ad shown for unit id: %@ placement id: %@", self.unitId, self.placementId];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeAdDidClick:(MTGCampaign *)nativeAd bidNativeManager:(MTGBidNativeAdManager *)bidNativeManager
{
    [self.parentAdapter log: @"Native ad clicked for unit id: %@ placement id: %@", self.unitId, self.placementId];
    [self.delegate didClickNativeAd];
}

- (void)nativeAdClickUrlWillStartToJump:(NSURL *)clickUrl bidNativeManager:(MTGBidNativeAdManager *)bidNativeManager
{
    [self.parentAdapter log: @"Native ad click will start jump for unit id: %@ placement id: %@", self.unitId, self.placementId];
}

- (void)nativeAdClickUrlDidJumpToUrl:(NSURL *)jumpUrl bidNativeManager:(MTGBidNativeAdManager *)bidNativeManager
{
    [self.parentAdapter log: @"Native ad click did jump for unit id: %@ placement id: %@", self.unitId, self.placementId];
}

- (void)nativeAdClickUrlDidEndJump:(NSURL *)finalUrl error:(NSError *)error bidNativeManager:(MTGBidNativeAdManager *)bidNativeManager
{
    [self.parentAdapter log: @"Native ad click did end jump for unit id: %@ placement id: %@", self.unitId, self.placementId];
}

- (void)processNativeAd:(MTGCampaign *)campaign unitId:(NSString *)unitId
{
    // Run image fetching tasks asynchronously in the background
    dispatch_group_t group = dispatch_group_create();
    
    __block MANativeAdImage *iconImage = nil;
    NSString *iconURL = campaign.iconUrl;
    if ( [iconURL al_isValidURL] )
    {
        [self.parentAdapter log: @"Fetching native ad icon: %@", iconURL];
        [self loadImageForURLString: iconURL group: group successHandler:^(UIImage *image) {
            iconImage = [[MANativeAdImage alloc] initWithImage: image];
        }];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Timeout tasks if incomplete within the given time
        NSTimeInterval imageTaskTimeoutSeconds = [[self.serverParameters al_numberForKey: @"image_task_timeout_seconds" defaultValue: @(kDefaultImageTaskTimeoutSeconds)] doubleValue];
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(imageTaskTimeoutSeconds * NSEC_PER_SEC)));
        
        dispatchOnMainQueue(^{
            MTGMediaView *mediaView = [[MTGMediaView alloc] initWithFrame: CGRectZero];
            [mediaView setMediaSourceWithCampaign: campaign unitId: unitId];
            mediaView.delegate = self;
            
            MTGAdChoicesView *adChoicesView = [[MTGAdChoicesView alloc] initWithFrame: CGRectZero];
            adChoicesView.campaign = campaign;
            
            MANativeAd *maxNativeAd = [[MAMintegralNativeAd alloc] initWithParentAdapter: self.parentAdapter builderBlock:^(MANativeAdBuilder *builder) {
                builder.title = campaign.appName;
                builder.body = campaign.appDesc;
                builder.callToAction = campaign.adCall;
                builder.icon = iconImage;
                builder.mediaView = mediaView;
                builder.optionsView = adChoicesView;
            }];
            
            // To compile SOURCE code with < 11.0.0 before SDK is merged so we can push adapter
            if ( [self.delegate respondsToSelector: @selector(didLoadAdForNativeAd:withExtraInfo:)] )
            {
                [self.delegate performSelector: @selector(didLoadAdForNativeAd:withExtraInfo:)
                                    withObject: maxNativeAd
                                    withObject: @{}];
            }
        });
    });
}

- (void)loadImageForURLString:(NSString *)urlString group:(dispatch_group_t)group successHandler:(void (^)(UIImage *image))successHandler;
{
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        dispatch_group_enter(group);
        
        [[[NSURLSession sharedSession] dataTaskWithURL: [NSURL URLWithString: urlString]
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if ( error )
            {
                [self.parentAdapter log: @"Failed to fetch native ad image with error: %@", error];
            }
            else if ( data )
            {
                [self.parentAdapter log: @"Native ad image data retrieved"];
                
                UIImage *image = [UIImage imageWithData: data];
                if ( image )
                {
                    successHandler(image);
                }
            }
            
            // Don't consider the block done until this task is complete
            dispatch_group_leave(group);
        }] resume];
    });
}

- (BOOL)hasRequiredAssets:(MTGCampaign *)campaign isTemplateAd:(BOOL)isTemplateAd
{
    if ( isTemplateAd )
    {
        return [campaign.appName al_isValidString];
    }
    else
    {
        return [campaign.appName al_isValidString] &&
        [campaign.adCall al_isValidString] &&
        [campaign.imageUrl al_isValidURL];
    }
}

#pragma mark MTGMediaViewDelegate methods

- (void)MTGMediaViewWillEnterFullscreen:(MTGMediaView *)mediaView
{
    [self.parentAdapter log: @"Media view will enter fullscreen"];
}

- (void)MTGMediaViewDidExitFullscreen:(MTGMediaView *)mediaView
{
    [self.parentAdapter log: @"Media view did exit fullscreen"];
}

- (void)MTGMediaViewVideoDidStart:(MTGMediaView *)mediaView
{
    [self.parentAdapter log: @"Media view video did start"];
}

- (void)MTGMediaViewVideoPlayCompleted:(MTGMediaView *)mediaView
{
    [self.parentAdapter log: @"Media view video did complete"];
}

- (void)nativeAdDidClick:(MTGCampaign *)nativeAd mediaView:(MTGMediaView *)mediaView
{
    [self.parentAdapter log: @"Media view clicked for unit id: %@ placement id: %@", self.unitId, self.placementId];
    [self.delegate didClickNativeAd];
}

- (void)nativeAdClickUrlWillStartToJump:(NSURL *)clickURL mediaView:(MTGMediaView *)mediaView
{
    [self.parentAdapter log: @"Media view click will start jump to: %@", clickURL];
}

- (void)nativeAdClickUrlDidJumpToUrl:(NSURL *)jumpURL mediaView:(MTGMediaView *)mediaView
{
    [self.parentAdapter log: @"Media view click did jump to: %@", jumpURL];
}

- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalURL error:(nullable NSError *)error mediaView:(MTGMediaView *)mediaView
{
    NSString *errorString = [NSString stringWithFormat: @" with error: %@", error.localizedDescription];
    [self.parentAdapter log: @"Media view click did end jump to: %@%@", finalURL, error ? errorString: @""];
}

- (void)nativeAdImpressionWithType:(MTGAdSourceType)type mediaView:(MTGMediaView *)mediaView;
{
    [self.parentAdapter log: @"Media view impression did start"];
}

@end

@implementation MAMintegralNativeAd

- (instancetype)initWithParentAdapter:(ALMintegralMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
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
    
    [self.parentAdapter.bidNativeAdManager registerViewForInteraction: maxNativeAdView
                                                   withClickableViews: clickableViews
                                                         withCampaign: self.parentAdapter.nativeAdCampaign];

    self.parentAdapter.maxNativeAdView = maxNativeAdView;
    self.parentAdapter.clickableViews = clickableViews;
}

@end
