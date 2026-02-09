//
//  ALAdSurgeMediationAdapter.m
//  ALAdSurgeMediationAdapter
//
//  Created by katie on 2025/4/23.
//

#import "ALAdSurgeMediationAdapter.h"
#import <AdSurgeSDK/AdSurgeSDK.h>
#define ADAPTER_VERSION @"1.6.0"
#define TITLE_LABEL_TAG          1
#define MEDIA_VIEW_CONTAINER_TAG 2
#define ICON_VIEW_TAG            3
#define BODY_VIEW_TAG            4
#define CALL_TO_ACTION_VIEW_TAG  5

@interface ALAdSurgeRewardedDelegate : NSObject <AdSurgeRewardedAdDelegate>
@property (nonatomic, weak) ALAdSurgeAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALAdSurgeAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALAdSurgeInterstitialDelegate : NSObject <AdSurgeInterstitialAdDelegate>
@property (nonatomic, weak) ALAdSurgeAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
@property (nonatomic, copy) NSString *placementId;
- (instancetype)initWithParentAdapter:(ALAdSurgeAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALAdSurgeAdViewDelegate : NSObject <AdSurgeBannerAdDelegate>
@property (nonatomic, weak) ALAdSurgeAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@property (nonatomic, copy) NSString *placementId;
- (instancetype)initWithParentAdapter:(ALAdSurgeAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALAdSurgeNativeDelegate : NSObject <AdSurgeNativeAdDelegate>
@property (nonatomic, weak) ALAdSurgeAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, copy) NSString *placementId;
- (instancetype)initWithParentAdapter:(ALAdSurgeAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAAdSurgeAdManagerNativeAd : MANativeAd
@property (nonatomic, weak) ALAdSurgeAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALAdSurgeAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
@end

@interface ALAdSurgeAdapter ()

@property (nonatomic, strong) AdSurgeRewardedAd *rewardedAd;
@property (nonatomic, strong) ALAdSurgeRewardedDelegate *rewardedDelegate;
@property (nonatomic, strong) AdSurgeInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALAdSurgeInterstitialDelegate *interstitialDelegate;
@property (nonatomic, strong) AdSurgeBannerAdView *adView;
@property (nonatomic, strong) AdSurgeNativeAd *nativeAd;
@property (nonatomic, strong) AdSurgeNativeAdView *nativeAdView;
@property (nonatomic, strong) ALAdSurgeNativeDelegate *nativeDelegate;
@property (nonatomic, strong) ALAdSurgeAdViewDelegate *adViewDelegate;

@end

@implementation ALAdSurgeAdapter

static ALAtomicBoolean *ALODCInitialized;
static MAAdapterInitializationStatus ALODCInitializationStatus = NSIntegerMin;

+ (void)initialize {
    [super initialize];
    ALODCInitialized = [[ALAtomicBoolean alloc] init];
}

- (NSString *)SDKVersion {
    return [AdSurgeAdSdkVersion copy];
}

- (NSString *)adapterVersion {
    return ADAPTER_VERSION;
}

- (void)collectSignalWithParameters:(nonnull id<MASignalCollectionParameters>)parameters andNotify:(nonnull id<MASignalCollectionDelegate>)delegate {
    [self log: @"Collecting signal..."];

}

- (void)destroy {
    [self log: @"Destroying..."];
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedDelegate.delegate = nil;
    self.rewardedDelegate = nil;

    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialDelegate.delegate = nil;
    self.interstitialDelegate = nil;

    self.nativeAd = nil;
    self.nativeAdView = nil;
    self.nativeDelegate.delegate = nil;
    self.nativeDelegate = nil;

    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewDelegate.delegate = nil;
    self.adViewDelegate = nil;
}

- (void)initializeWithParameters:(nonnull id<MAAdapterInitializationParameters>)parameters
              completionHandler:(nonnull void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    ALODCInitializationStatus = MAAdapterInitializationStatusInitializing;
    [AdSurgePrivacyConfiguration configuration].doNotSell = [parameters isDoNotSell];
    [AdSurgePrivacyConfiguration configuration].userConsent = [parameters hasUserConsent];
    AdSurgeSDKConfig *configuration = [[AdSurgeSDKConfig alloc] init];
    configuration.appId = [parameters.serverParameters al_stringForKey: @"app_id"];
    [self log: @"Initializing AdSurgeSDK with app id: %@...", configuration.appId];
    [[AdSurgeAdSdk shared] initializeWithConfig:configuration completionHandler:^(BOOL success, AdSurgeError * _Nullable error) {
        if (success) {
            ALODCInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            [self log: @"AdSurgeSDK initialized"];
        } else {
            ALODCInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
            [self log: @"AdSurgeSDK failed to initialize with error: %@", error];
        }
        completionHandler(ALODCInitializationStatus, error ? error.message : nil);
    }];
}

- (void)loadRewardedAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MARewardedAdapterDelegate>)delegate {

    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;

    self.rewardedAd = [[AdSurgeRewardedAd alloc] initWithAdUnitIdentifier:placementId];
    self.rewardedDelegate = [[ALAdSurgeRewardedDelegate alloc] initWithParentAdapter:self placementId:placementId andNotify:delegate];
    self.rewardedAd.delegate = self.rewardedDelegate;
    AdSurgeAdConfig *adConfig = [AdSurgeAdConfig configWithAdFormat:AdSurgeAdFormat.rewarded];
    [self.rewardedAd loadAd:adConfig];

}

- (void)showRewardedAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MARewardedAdapterDelegate>)delegate {
    [self log: @"Showing rewarded ad with localExtraParameters:%@",parameters.localExtraParameters];
    [self configureRewardForParameters:parameters];
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    if ([parameters.localExtraParameters isKindOfClass:[NSDictionary class]]) {
        [self.rewardedAd showAdFromRootViewController:presentingViewController customData:parameters.localExtraParameters];
    } else {
        [self.rewardedAd showAdFromRootViewController:presentingViewController];
    }

}

+ (MAAdapterError *)toMaxError:(AdSurgeError *)adSurgeError {
    AdSurgeErrorCode AdSurgeErrorCode = adSurgeError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch (AdSurgeErrorCode) {
        case AdSurgeErrorCodeNoFill:
            adapterError = MAAdapterError.noFill;
            break;
        case AdSurgeErrorCodeNetworkError:
            if ([adSurgeError.message rangeOfString:@"timed out"].location != NSNotFound) {
                adapterError = MAAdapterError.timeout;
            } else {
                adapterError = MAAdapterError.noConnection;
            }
            break;
        case AdSurgeErrorCodeServerError:
            adapterError = MAAdapterError.serverError;
            break;
        case AdSurgeErrorCodeInternalError:
            adapterError = MAAdapterError.internalError;
            break;
        case AdSurgeErrorCodeDisplayError:
            adapterError = MAAdapterError.adDisplayFailedError;
            break;
        case AdSurgeErrorCodeComplienceError:
            adapterError = MAAdapterError.internalError;
            break;
        default:
            break;
    }
    return adapterError;
}

- (void)loadInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {

    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;

    self.interstitialAd = [[AdSurgeInterstitialAd alloc] initWithAdUnitIdentifier:placementId];
    self.interstitialDelegate = [[ALAdSurgeInterstitialDelegate alloc] initWithParentAdapter:self placementId:placementId andNotify:delegate];
    self.interstitialAd.delegate = self.interstitialDelegate;
    AdSurgeAdConfig *adConfig = [AdSurgeAdConfig configWithAdFormat:AdSurgeAdFormat.interstitial];
    [self.interstitialAd loadAd:adConfig];
}

- (void)showInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    [self log: @"Showing rewarded ad..."];
    [self configureRewardForParameters:parameters];
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self.interstitialAd showAdFromRootViewController:presentingViewController];
}

- (void)loadAdViewAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters adFormat:(nonnull MAAdFormat *)adFormat andNotify:(nonnull id<MAAdViewAdapterDelegate>)delegate {
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;

    self.adView = [[AdSurgeBannerAdView alloc] initWithAdUnitIdentifier:placementId];
    self.adViewDelegate = [[ALAdSurgeAdViewDelegate alloc] initWithParentAdapter:self placementId:placementId andNotify:delegate];
    self.adView.delegate = self.adViewDelegate;
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    self.adView.viewController = presentingViewController;

    AdSurgeAdConfig *adConfig = [AdSurgeAdConfig configWithAdFormat:AdSurgeAdFormat.banner];
    [self.adView loadAd:adConfig];
}

- (void)loadNativeAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MANativeAdAdapterDelegate>)delegate {
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    self.nativeAd = [[AdSurgeNativeAd alloc] initWithAdUnitIdentifier:placementId];
    self.nativeAdView = [[AdSurgeNativeAdView alloc] init];
    self.nativeDelegate = [[ALAdSurgeNativeDelegate alloc] initWithParentAdapter:self placementId:placementId andNotify:delegate];
    self.nativeAd.delegate = self.nativeDelegate;
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    self.nativeAd.viewController = presentingViewController;
    AdSurgeAdConfig *adConfig = [AdSurgeAdConfig configWithAdFormat:AdSurgeAdFormat.native];
    adConfig.autoPlay = YES;
    adConfig.mute = NO;
    [self.nativeAd loadAd:adConfig];

}

@end


@implementation ALAdSurgeRewardedDelegate

- (instancetype)initWithParentAdapter:(ALAdSurgeAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MARewardedAdapterDelegate>)delegate {
    self = [super init];
    if (self) {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}

- (void)didClickAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)didDisplayAd:(AdSurgeAd *)ad withError:(AdSurgeError *)error {
    [self.parentAdapter log: @"Rewarded ad display, error:%@", error.message];
    MAAdapterError *adapterError = [ALAdSurgeAdapter toMaxError:error];
    if (error) {
        [self.delegate didFailToDisplayRewardedAdWithError:adapterError];
    }
}

- (void)didHideAd:(AdSurgeAd *)ad {
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    [self.parentAdapter log: @"Rewarded ad hidden"];
    [self.delegate didHideRewardedAd];
}

- (void)didRewardUserForAd:(AdSurgeAd *)ad withReward:(AdSurgeReward *)reward {
    [self.parentAdapter log: @"Rewarded ad did reward user"];
    self.grantedReward = YES;
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(AdSurgeError *)error {
    [self.parentAdapter log: @"Rewarded ad fail load，error: %@", error.message];
    MAAdapterError *adapterError = [ALAdSurgeAdapter toMaxError:error];
    [self.delegate didFailToLoadRewardedAdWithError:adapterError];
}


- (void)didLoadAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Rewarded ad load"];
    NSString *creativeId = ad.creativeId;
    if ( [creativeId al_isValidString] ) {
        [self.delegate didLoadRewardedAdWithExtraInfo:@{@"creative_id" : creativeId}];
    }else {
        [self.delegate didLoadRewardedAd];
    }
}


- (void)didPayRevenueForAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Rewarded ad did Pay Revenue"];
    [self.delegate didDisplayRewardedAd];
}


@end


@implementation ALAdSurgeInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALAdSurgeAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MAInterstitialAdapterDelegate>)delegate {
    self = [super init];
    if (self) {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}


- (void)didClickAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)didDisplayAd:(AdSurgeAd *)ad withError:(AdSurgeError *)error {
    [self.parentAdapter log: @"Interstitial ad display, error:%@", error.message];
    MAAdapterError *adapterError = [ALAdSurgeAdapter toMaxError:error];
    if (error) {
        [self.delegate didFailToDisplayInterstitialAdWithError:adapterError];
    }
}

- (void)didHideAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Interstitial ad hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)didLoadAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Interstitial ad load"];
    NSString *creativeId = ad.creativeId;
    if ( [creativeId al_isValidString] ) {
        [self.delegate didLoadInterstitialAdWithExtraInfo:@{@"creative_id" : creativeId}];
    }else {
        [self.delegate didLoadInterstitialAd];
    }

}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(AdSurgeError *)error {
    [self.parentAdapter log: @"Interstitial ad fail load, error:%@", error.message];
    MAAdapterError *adapterError = [ALAdSurgeAdapter toMaxError:error];
    [self.delegate didFailToLoadInterstitialAdWithError:adapterError];
}

- (void)didPayRevenueForAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Interstitial ad did Pay Revenue"];
    [self.delegate didDisplayInterstitialAd];
}

@end

@implementation ALAdSurgeAdViewDelegate

- (instancetype)initWithParentAdapter:(ALAdSurgeAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MAAdViewAdapterDelegate>)delegate {
    self = [super init];
    if (self) {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}

- (void)didLoadAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Loaded banner ad"];
    NSString *creativeId = ad.creativeId;
    if ( [creativeId al_isValidString] ) {
        [self.delegate didLoadAdForAdView:self.parentAdapter.adView withExtraInfo:@{@"creative_id" : creativeId}];
    }else {
        [self.delegate didLoadAdForAdView:self.parentAdapter.adView];
    }

}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(AdSurgeError *)error {
    [self.parentAdapter log: @"Failed to load banner ad, error: %@", error.message];
    MAAdapterError *adapterError = [ALAdSurgeAdapter toMaxError:error];
    [self.delegate didFailToLoadAdViewAdWithError:adapterError];
}

- (void)didClickAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Banner ad clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)didHideAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Banner ad hidden"];
    [self.delegate didHideAdViewAd];
}

- (void)didPayRevenueForAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Banner ad did pay revenue"];
    [self.delegate didDisplayAdViewAd];
}

@end

@implementation ALAdSurgeNativeDelegate

- (instancetype)initWithParentAdapter:(ALAdSurgeAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MANativeAdAdapterDelegate>)delegate {
    self = [super init];
    if (self) {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}

- (void)didLoadAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Loaded Native ad"];
    AdSurgeNativeAd *myNativeAd = self.parentAdapter.nativeAd;
    NSString *iconUrlStr = myNativeAd.iconInfo.iconUrl;
    NSURL *iconURL = [NSURL URLWithString:iconUrlStr];
    UIView *mediaView = [[UIView alloc] init];
    MANativeAd * nativeAd = [[MAAdSurgeAdManagerNativeAd alloc] initWithParentAdapter:self.parentAdapter builderBlock:^(MANativeAdBuilder *binder) {
        binder.title = myNativeAd.headLine;
        binder.body = myNativeAd.body;
        binder.callToAction = myNativeAd.callToAction;
        binder.mediaView = mediaView;
        binder.mediaContentAspectRatio = myNativeAd.mediaContent.aspectRatio;
        binder.optionsView = myNativeAd.adChoicesView;
        binder.icon = [[MANativeAdImage alloc] initWithURL:iconURL];
    }];
    NSString *creativeId = ad.creativeId;
    if ( [creativeId al_isValidString] ) {
        [self.delegate didLoadAdForNativeAd:nativeAd withExtraInfo:@{@"creative_id" : creativeId}];
    }else {
        [self.delegate didLoadAdForNativeAd:nativeAd withExtraInfo:nil];
    }

}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(AdSurgeError *)error {
    [self.parentAdapter log: @"Failed to load Native ad, error: %@", error.message];
    MAAdapterError *adapterError = [ALAdSurgeAdapter toMaxError:error];
    [self.delegate didFailToLoadNativeAdWithError:adapterError];
}

- (void)didClickAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)didDisplayAd:(AdSurgeAd *)ad withError:(AdSurgeError *)error {
    [self.parentAdapter log: @"Native ad display, error:%@", error.message]; //max的display没有withFail方法
}

- (void)didPayRevenueForAd:(AdSurgeAd *)ad {
    [self.parentAdapter log: @"Native ad did pay revenue"];
    [self.delegate didDisplayNativeAdWithExtraInfo:nil];
}

@end

@implementation MAAdSurgeAdManagerNativeAd

- (instancetype)initWithParentAdapter:(ALAdSurgeAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock {
    self = [super initWithFormat:MAAdFormat.native builderBlock:builderBlock];
    if(self) {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container {
    AdSurgeNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if(!nativeAd) {
        [self.parentAdapter log:@"Failed to register native ad views: native ad is nil."];
        return NO;
    }

    AdSurgeNativeAdView * nativeAdView = [[AdSurgeNativeAdView alloc] init];
    [container addSubview:nativeAdView];
    [nativeAdView al_pinToSuperview];
    if ([container isKindOfClass:[MANativeAdView class]]) {
        MANativeAdView *maxNativeAdView = (MANativeAdView *)container;
        [nativeAdView setHeadlineView:maxNativeAdView.titleLabel];
        [nativeAdView setIconView:maxNativeAdView.iconImageView];
        [nativeAdView setBodyView:maxNativeAdView.bodyLabel];
        [nativeAdView setCallToActionView:maxNativeAdView.callToActionButton];
        [nativeAdView setMediaView:self.mediaView];
        [nativeAdView addSubview:maxNativeAdView.iconImageView];
        [nativeAdView addSubview:maxNativeAdView.titleLabel];
        [nativeAdView addSubview:maxNativeAdView.bodyLabel];
        [nativeAdView addSubview:self.mediaView];
        [nativeAdView addSubview:maxNativeAdView.callToActionButton];
        [nativeAdView addSubview:maxNativeAdView.optionsContentView];
        maxNativeAdView.mediaContentView = self.mediaView;

    }else {
        for ( UIView *clickableView in clickableViews ) {
            if ( clickableView.tag == TITLE_LABEL_TAG ) {
                [nativeAdView setHeadlineView:clickableView];
            }else if ( clickableView.tag == ICON_VIEW_TAG ) {
                [nativeAdView setIconView:clickableView];
            }else if ( clickableView.tag == MEDIA_VIEW_CONTAINER_TAG ) {
                // `self.mediaView` is created when ad is loaded
                [nativeAdView setMediaView:self.mediaView];
                [nativeAdView addSubview:self.mediaView];
                continue;
            }else if ( clickableView.tag == BODY_VIEW_TAG ) {
                [nativeAdView setBodyView:clickableView];
            }else if ( clickableView.tag == CALL_TO_ACTION_VIEW_TAG ) {
                [nativeAdView setCallToActionView:clickableView];
            }
            [nativeAdView addSubview:clickableView];
        }

    }
    self.parentAdapter.nativeAdView = nativeAdView;
    // 执行注册
    [nativeAd registerViewForInteraction:nativeAdView
                              clickViews:clickableViews];

    return YES;
}

@end
