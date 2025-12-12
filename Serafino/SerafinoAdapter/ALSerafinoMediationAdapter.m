//
//  ALSerafinoMediationAdapter.m
//  ALSerafinoMediationAdapter
//
//  Created by katie on 2025/4/23.
//

#import "ALSerafinoMediationAdapter.h"
#import <ODCSDK/ODCSDK.h>
#define ADAPTER_VERSION @"1.4.0"
#define TITLE_LABEL_TAG          1
#define MEDIA_VIEW_CONTAINER_TAG 2
#define ICON_VIEW_TAG            3
#define BODY_VIEW_TAG            4
#define CALL_TO_ACTION_VIEW_TAG  5

@interface ALODCRewardedDelegate : NSObject <ODCRewardedAdDelegate>
@property (nonatomic, weak) ALSerafinoMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALSerafinoMediationAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALODCInterstitialDelegate : NSObject <ODCInterstitialAdDelegate>
@property (nonatomic, weak) ALSerafinoMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
@property (nonatomic, copy) NSString *placementId;
- (instancetype)initWithParentAdapter:(ALSerafinoMediationAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALODCAdViewDelegate : NSObject <ODCBannerAdDelegate>
@property (nonatomic, weak) ALSerafinoMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@property (nonatomic, copy) NSString *placementId;
- (instancetype)initWithParentAdapter:(ALSerafinoMediationAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALODCNativeDelegate : NSObject <ODCNativeAdDelegate>
@property (nonatomic, weak) ALSerafinoMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, copy) NSString *placementId;
- (instancetype)initWithParentAdapter:(ALSerafinoMediationAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAODCAdManagerNativeAd : MANativeAd
@property (nonatomic, weak) ALSerafinoMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALSerafinoMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
@end

@interface ALSerafinoMediationAdapter ()

@property (nonatomic, strong) ODCRewardedAd *rewardedAd;
@property (nonatomic, strong) ALODCRewardedDelegate *rewardedDelegate;
@property (nonatomic, strong) ODCInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALODCInterstitialDelegate *interstitialDelegate;
@property (nonatomic, strong) ODCBannerAdView *adView;
@property (nonatomic, strong) ODCNativeAd *nativeAd;
@property (nonatomic, strong) ODCNativeAdView *nativeAdView;
@property (nonatomic, strong) ALODCNativeDelegate *nativeDelegate;
@property (nonatomic, strong) ALODCAdViewDelegate *adViewDelegate;

@end

@implementation ALSerafinoMediationAdapter

static ALAtomicBoolean *ALODCInitialized;
static MAAdapterInitializationStatus ALODCInitializationStatus = NSIntegerMin;

+ (void)initialize {
    [super initialize];
    ALODCInitialized = [[ALAtomicBoolean alloc] init];
}

- (NSString *)SDKVersion {
    return [ODCAdSdkVersion copy];
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
    [ODCPrivacyConfiguration configuration].doNotSell = [parameters isDoNotSell];
    [ODCPrivacyConfiguration configuration].userConsent = [parameters hasUserConsent];
    ODCSDKConfig *configuration = [[ODCSDKConfig alloc] init];
    configuration.appId = [parameters.serverParameters al_stringForKey: @"app_id"];
    [self log: @"Initializing SerafinoSDK with app id: %@...", configuration.appId];
    [[ODCAdSdk shared] initializeWithConfig:configuration completionHandler:^(BOOL success, ODCError * _Nullable error) {
        if (success) {
            ALODCInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            [self log: @"SerafinoSDK initialized"];
        } else {
            ALODCInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
            [self log: @"SerafinoSDK failed to initialize with error: %@", error];
        }
        completionHandler(ALODCInitializationStatus, error ? error.message : nil);
    }];
}

- (void)loadRewardedAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MARewardedAdapterDelegate>)delegate { 
    
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    
    self.rewardedAd = [[ODCRewardedAd alloc] initWithAdUnitIdentifier:placementId];
    self.rewardedDelegate = [[ALODCRewardedDelegate alloc] initWithParentAdapter:self placementId:placementId andNotify:delegate];
    self.rewardedAd.delegate = self.rewardedDelegate;
    ODCAdConfig *adConfig = [ODCAdConfig configWithAdFormat:ODCAdFormat.rewarded];
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

+ (MAAdapterError *)toMaxError:(ODCError *)odcError {
    ODCErrorCode odcErrorCode = odcError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch (odcErrorCode) {
        case ODCErrorCodeNoFill:
            adapterError = MAAdapterError.noFill;
            break;
        case ODCErrorCodeNetworkError:
            if ([odcError.message rangeOfString:@"timed out"].location != NSNotFound) {
                adapterError = MAAdapterError.timeout;
            } else {
                adapterError = MAAdapterError.noConnection;
            }
            break;
        case ODCErrorCodeServerError:
            adapterError = MAAdapterError.serverError;
            break;
        case ODCErrorCodeInternalError:
            adapterError = MAAdapterError.internalError;
            break;
        case ODCErrorCodeDisplayError:
            adapterError = MAAdapterError.adDisplayFailedError;
            break;
        case ODCErrorCodeComplienceError:
            adapterError = MAAdapterError.internalError;
            break;
        default:
            break;
    }
    return adapterError;
}

- (void)loadInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    
    self.interstitialAd = [[ODCInterstitialAd alloc] initWithAdUnitIdentifier:placementId];
    self.interstitialDelegate = [[ALODCInterstitialDelegate alloc] initWithParentAdapter:self placementId:placementId andNotify:delegate];
    self.interstitialAd.delegate = self.interstitialDelegate;
    ODCAdConfig *adConfig = [ODCAdConfig configWithAdFormat:ODCAdFormat.interstitial];
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
    
    self.adView = [[ODCBannerAdView alloc] initWithAdUnitIdentifier:placementId];
    self.adViewDelegate = [[ALODCAdViewDelegate alloc] initWithParentAdapter:self placementId:placementId andNotify:delegate];
    self.adView.delegate = self.adViewDelegate;
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    self.adView.viewController = presentingViewController;

    ODCAdConfig *adConfig = [ODCAdConfig configWithAdFormat:ODCAdFormat.banner];
    [self.adView loadAd:adConfig];
}

- (void)loadNativeAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MANativeAdAdapterDelegate>)delegate {
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    self.nativeAd = [[ODCNativeAd alloc] initWithAdUnitIdentifier:placementId];
    self.nativeAdView = [[ODCNativeAdView alloc] init];
    self.nativeDelegate = [[ALODCNativeDelegate alloc] initWithParentAdapter:self placementId:placementId andNotify:delegate];
    self.nativeAd.delegate = self.nativeDelegate;
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    self.nativeAd.viewController = presentingViewController;
    ODCAdConfig *adConfig = [ODCAdConfig configWithAdFormat:ODCAdFormat.native];
    adConfig.autoPlay = YES;
    adConfig.mute = NO;
    [self.nativeAd loadAd:adConfig];
    
}

@end


@implementation ALODCRewardedDelegate

- (instancetype)initWithParentAdapter:(ALSerafinoMediationAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MARewardedAdapterDelegate>)delegate {
    self = [super init];
    if (self) {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}

- (void)didClickAd:(ODCAd *)ad { 
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)didDisplayAd:(ODCAd *)ad withError:(ODCError *)error { 
    [self.parentAdapter log: @"Rewarded ad display, error:%@", error.message];
    MAAdapterError *adapterError = [ALSerafinoMediationAdapter toMaxError:error];
    if (error) {
        [self.delegate didFailToDisplayRewardedAdWithError:adapterError];
    }
}

- (void)didHideAd:(ODCAd *)ad {
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    [self.parentAdapter log: @"Rewarded ad hidden"];
    [self.delegate didHideRewardedAd];
}

- (void)didRewardUserForAd:(ODCAd *)ad withReward:(ODCReward *)reward { 
    [self.parentAdapter log: @"Rewarded ad did reward user"];
    self.grantedReward = YES;
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(ODCError *)error { 
    [self.parentAdapter log: @"Rewarded ad fail load，error: %@", error.message];
    MAAdapterError *adapterError = [ALSerafinoMediationAdapter toMaxError:error];
    [self.delegate didFailToLoadRewardedAdWithError:adapterError];
}


- (void)didLoadAd:(ODCAd *)ad { 
    [self.parentAdapter log: @"Rewarded ad load"];
    NSString *creativeId = ad.creativeId;
    if ( [creativeId al_isValidString] ) {
        [self.delegate didLoadRewardedAdWithExtraInfo:@{@"creative_id" : creativeId}];
    }else {
        [self.delegate didLoadRewardedAd];
    }
}


- (void)didPayRevenueForAd:(ODCAd *)ad { 
    [self.parentAdapter log: @"Rewarded ad did Pay Revenue"];
    [self.delegate didDisplayRewardedAd];
}


@end


@implementation ALODCInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALSerafinoMediationAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MAInterstitialAdapterDelegate>)delegate {
    self = [super init];
    if (self) {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}


- (void)didClickAd:(ODCAd *)ad { 
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)didDisplayAd:(ODCAd *)ad withError:(ODCError *)error { 
    [self.parentAdapter log: @"Interstitial ad display, error:%@", error.message];
    MAAdapterError *adapterError = [ALSerafinoMediationAdapter toMaxError:error];
    if (error) {
        [self.delegate didFailToDisplayInterstitialAdWithError:adapterError];
    }
}

- (void)didHideAd:(ODCAd *)ad { 
    [self.parentAdapter log: @"Interstitial ad hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)didLoadAd:(ODCAd *)ad { 
    [self.parentAdapter log: @"Interstitial ad load"];
    NSString *creativeId = ad.creativeId;
    if ( [creativeId al_isValidString] ) {
        [self.delegate didLoadInterstitialAdWithExtraInfo:@{@"creative_id" : creativeId}];
    }else {
        [self.delegate didLoadInterstitialAd];
    }
    
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(ODCError *)error { 
    [self.parentAdapter log: @"Interstitial ad fail load, error:%@", error.message];
    MAAdapterError *adapterError = [ALSerafinoMediationAdapter toMaxError:error];
    [self.delegate didFailToLoadInterstitialAdWithError:adapterError];
}

- (void)didPayRevenueForAd:(ODCAd *)ad {
    [self.parentAdapter log: @"Interstitial ad did Pay Revenue"];
    [self.delegate didDisplayInterstitialAd];
}

@end

@implementation ALODCAdViewDelegate

- (instancetype)initWithParentAdapter:(ALSerafinoMediationAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MAAdViewAdapterDelegate>)delegate {
    self = [super init];
    if (self) {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}

- (void)didLoadAd:(ODCAd *)ad {
    [self.parentAdapter log: @"Loaded banner ad"];
    NSString *creativeId = ad.creativeId;
    if ( [creativeId al_isValidString] ) {
        [self.delegate didLoadAdForAdView:self.parentAdapter.adView withExtraInfo:@{@"creative_id" : creativeId}];
    }else {
        [self.delegate didLoadAdForAdView:self.parentAdapter.adView];
    }

}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(ODCError *)error {
    [self.parentAdapter log: @"Failed to load banner ad, error: %@", error.message];
    MAAdapterError *adapterError = [ALSerafinoMediationAdapter toMaxError:error];
    [self.delegate didFailToLoadAdViewAdWithError:adapterError];
}

- (void)didClickAd:(ODCAd *)ad {
    [self.parentAdapter log: @"Banner ad clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)didHideAd:(ODCAd *)ad {
    [self.parentAdapter log: @"Banner ad hidden"];
    [self.delegate didHideAdViewAd];
}

- (void)didPayRevenueForAd:(ODCAd *)ad {
    [self.parentAdapter log: @"Banner ad did pay revenue"];
    [self.delegate didDisplayAdViewAd];
}

@end

@implementation ALODCNativeDelegate

- (instancetype)initWithParentAdapter:(ALSerafinoMediationAdapter *)parentAdapter placementId:(NSString *)placementId andNotify:(id<MANativeAdAdapterDelegate>)delegate {
    self = [super init];
    if (self) {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}

- (void)didLoadAd:(ODCAd *)ad {
    [self.parentAdapter log: @"Loaded Native ad"];
    ODCNativeAd *myNativeAd = self.parentAdapter.nativeAd;
    NSString *iconUrlStr = myNativeAd.iconInfo.iconUrl;
    NSURL *iconURL = [NSURL URLWithString:iconUrlStr];
    UIView *mediaView = [[UIView alloc] init];
    MANativeAd * nativeAd = [[MAODCAdManagerNativeAd alloc] initWithParentAdapter:self.parentAdapter builderBlock:^(MANativeAdBuilder *binder) {
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

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(ODCError *)error {
    [self.parentAdapter log: @"Failed to load Native ad, error: %@", error.message];
    MAAdapterError *adapterError = [ALSerafinoMediationAdapter toMaxError:error];
    [self.delegate didFailToLoadNativeAdWithError:adapterError];
}

- (void)didClickAd:(ODCAd *)ad {
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)didDisplayAd:(ODCAd *)ad withError:(ODCError *)error {
    [self.parentAdapter log: @"Native ad display, error:%@", error.message]; //max的display没有withFail方法
}

- (void)didPayRevenueForAd:(ODCAd *)ad {
    [self.parentAdapter log: @"Native ad did pay revenue"];
    [self.delegate didDisplayNativeAdWithExtraInfo:nil];
}

@end

@implementation MAODCAdManagerNativeAd

- (instancetype)initWithParentAdapter:(ALSerafinoMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock {
    self = [super initWithFormat:MAAdFormat.native builderBlock:builderBlock];
    if(self) {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container {
    ODCNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if(!nativeAd) {
        [self.parentAdapter log:@"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    ODCNativeAdView * nativeAdView = [[ODCNativeAdView alloc] init];
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
