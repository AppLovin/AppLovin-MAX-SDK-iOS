//
//  ALTencentGDTMediationAdapter.m
//  AppLovinSDK
//
//  Created by Thomas So on 6/30/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALTencentGDTMediationAdapter.h"
#import "GDTSDKConfig.h"
#import "GDTUnifiedBannerView.h"
#import "GDTUnifiedInterstitialAd.h"
#import "GDTRewardVideoAd.h"

#define ADAPTER_VERSION @"4.12.4.3"

/**
 * Interstitial Delegate
 */
@interface ALTencentGDTInterstitialDelegate : NSObject<GDTUnifiedInterstitialAdDelegate>
@property (nonatomic,   weak) ALTencentGDTMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALTencentGDTMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

/**
 * Rewarded Delegate
 */
@interface ALTencentGDTRewardedVideoDelegate : NSObject<GDTRewardedVideoAdDelegate>
@property (nonatomic,   weak) ALTencentGDTMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALTencentGDTMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

/**
 * Banner Delegate
 */
@interface ALTencentGDTAdViewDelegate : NSObject<GDTUnifiedBannerViewDelegate>
@property (nonatomic,   weak) ALTencentGDTMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALTencentGDTMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALTencentGDTMediationAdapter()

// Interstitial Properties
@property (nonatomic, strong) GDTUnifiedInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALTencentGDTInterstitialDelegate *interstitialAdDelegate;

// Rewarded Properties
@property (nonatomic, strong) GDTRewardVideoAd *rewardedAd;
@property (nonatomic, strong) ALTencentGDTRewardedVideoDelegate *rewardedAdDelegate;

// Banner Properties
@property (nonatomic, strong) GDTUnifiedBannerView *adView;
@property (nonatomic, strong) ALTencentGDTAdViewDelegate *adViewDelegate;

@end

@implementation ALTencentGDTMediationAdapter

static ALAtomicBoolean *ALTencentGDTInitialized;

#pragma mark - Class Initialization

+ (void)initialize
{
    [super initialize];
    
    ALTencentGDTInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (NSString *)SDKVersion
{
    return [GDTSDKConfig sdkVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for adapter %@", self];
    
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdDelegate = nil;
    
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewDelegate = nil;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [ALTencentGDTInitialized compareAndSet: NO update: YES] )
    {
        NSString *appId = [parameters.serverParameters al_stringForKey: @"app_id"];
        [GDTSDKConfig registerAppId: appId];
    }
    
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

#pragma mark - Interstitial Adapter

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad for placement id: %@...", placementId];
    
    self.interstitialAd = [[GDTUnifiedInterstitialAd alloc] initWithPlacementId: placementId];
    self.interstitialAdDelegate = [[ALTencentGDTInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd.delegate = self.interstitialAdDelegate;
    
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    // Overwritten by `mute_state` setting, unless `mute_state` is disabled
    if ( [serverParameters al_containsValueForKey: @"is_muted"] ) // Introduced in 6.10.0
    {
        // Tencent mutes by default
        self.interstitialAd.videoMuted = [serverParameters al_numberForKey: @"is_muted"].boolValue;
    }
    
    [self.interstitialAd loadAd];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial: %@...", parameters.thirdPartyAdPlacementIdentifier];
    
    UIViewController *presentingViewController;
    if ( ALSdk.versionCode >= 11020199 )
    {
        presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    }
    else
    {
        presentingViewController = [ALUtils topViewControllerFromKeyWindow];
    }
    
    // No need to check `isAdValid`
    [self.interstitialAd presentAdFromRootViewController: presentingViewController];
}

#pragma mark - Rewarded Adapter

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad for placement id: %@...", placementId];
    
    self.rewardedAd = [[GDTRewardVideoAd alloc] initWithPlacementId: placementId];
    self.rewardedAdDelegate = [[ALTencentGDTRewardedVideoDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd.delegate = self.rewardedAdDelegate;
    
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    // Overwritten by `mute_state` setting, unless `mute_state` is disabled
    if ( [serverParameters al_containsValueForKey: @"is_muted"] ) // Introduced in 6.10.0
    {
        // Tencent mutes by default
        self.rewardedAd.videoMuted = [serverParameters al_numberForKey: @"is_muted"].boolValue;
    }
    
    [self.rewardedAd loadAd];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad: %@...", parameters.thirdPartyAdPlacementIdentifier];
    
    // Rewarded ad expires in 30 minutes
    if ( self.rewardedAd.expiredTimestamp <= [NSDate al_timeIntervalNow] )
    {
        [self log: @"Rewarded ad is expired"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adExpiredError];
        
        return;
    }
    
    if ( ![self.rewardedAd isAdValid] )
    {
        [self log: @"Rewarded ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
        
        return;
    }
    
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
    
    [self.rewardedAd showAdFromRootViewController: presentingViewController];
}

#pragma mark - Banner Adapter

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading ad view ad for placement id: %@...", placementId];
    
    CGRect frame = {CGPointZero, (adFormat == MAAdFormat.banner) ? CGSizeMake(320, 50) : CGSizeMake(728, 90)};
    self.adView = [[GDTUnifiedBannerView alloc] initWithFrame: frame placementId: placementId viewController: [ALUtils topViewControllerFromKeyWindow]];
    self.adView.autoSwitchInterval = 0;
    self.adViewDelegate = [[ALTencentGDTAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.adView.delegate = self.adViewDelegate;
    
    [self.adView loadAdAndShow];
}

#pragma mark - Helper Methods

+ (MAAdapterError *)toMaxError:(NSError *)tencentGDTError
{
    NSInteger tencentErrorCode = tencentGDTError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( tencentErrorCode )
    {
        case 0: // `0` and `2` error code mappings are from their demo app
            adapterError = MAAdapterError.notInitialized; // From demo app
            break;
        case 2:
        case 4001: // Initialization error (which includes NO FILL, or invalid configuration)
        case 5004: // No fill - but do not request another ad or it will screw with internal SDK caching
            adapterError = MAAdapterError.noFill;
            break;
        case 3001: // All error codes from now on are from their docs (https://developers.adnet.qq.com/doc/ios/guide)
            adapterError = MAAdapterError.noConnection;
            break;
        case 4003: // Ad slot error
        case 4007: // Device not supported
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 4006: // Ad "unexposed" (曝光)
            adapterError = MAAdapterError.unspecified;
            break;
        case 4008: // The orientation of the app is not supported for this ad
        case 4009: // Ad skipped when not supposed to be skippable
        case 4015: // Ad shown already
        case 4016: // Orientation of app does not match that of the ad
            adapterError = MAAdapterError.internalError;
            break;
        case 4011: // Frequency capped
            adapterError = MAAdapterError.adFrequencyCappedError;
            break;
        case 4013:
        case 4014:
            adapterError = MAAdapterError.adNotReady;
            break;
        case 5001:
            adapterError = MAAdapterError.serverError;
            break;
        case 5002:
        case 5003: // Video download or playback error
            adapterError = MAAdapterError.unspecified;
            break;
        case 5005:
        case 5009: // Daily, and hourly frequency capped
            adapterError = MAAdapterError.adFrequencyCappedError;
            break;
        case 5012: // Expired
            adapterError = MAAdapterError.adExpiredError;
            break;
        case 5013: // Ad loaded too frequently
            adapterError = MAAdapterError.invalidLoadState;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: tencentErrorCode
               thirdPartySdkErrorMessage: tencentGDTError.localizedDescription];
#pragma clang diagnostic pop
}

@end

@implementation ALTencentGDTInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALTencentGDTMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    
    // NOTE: Tencent requires at least 2-3 seconds delay after this callback, before the ad _actually_ can show. SDK to fix that will be releasd in August.
    dispatchOnMainQueueAfter(2.5, ^{
        [self.delegate didLoadInterstitialAd];
    });
}

- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error
{
    [self.parentAdapter log: @"Interstitial ad failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALTencentGDTMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)unifiedInterstitialFailToPresent:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error
{
    [self.parentAdapter log: @"Interstitial ad failed to show with error: %@", error];
    
    MAAdapterError *adapterError = [ALTencentGDTMediationAdapter toMaxError: error];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)unifiedInterstitialWillPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    [self.parentAdapter log: @"Interstitial ad will present screen"];
}

- (void)unifiedInterstitialDidPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    [self.parentAdapter log: @"Interstitial ad did present screen"];
}

- (void)unifiedInterstitialWillExposure:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    [self.parentAdapter log: @"Interstitial ad will exposure"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)unifiedInterstitialDidDismissScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    [self.parentAdapter log: @"Interstitial ad did dismiss screen"];
    [self.delegate didHideInterstitialAd];
}

- (void)unifiedInterstitialWillLeaveApplication:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    [self.parentAdapter log: @"Interstitial ad will leave application"];
}

- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)unifiedInterstitialAdWillPresentFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    [self.parentAdapter log: @"Interstitial ad will present fullscreen modal"];
}

- (void)unifiedInterstitialAdDidPresentFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    [self.parentAdapter log: @"Interstitial ad did present fullscreen modal"];
}

- (void)unifiedInterstitialAdWillDismissFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    [self.parentAdapter log: @"Interstitial ad will dismiss fullscreen modal"];
}

- (void)unifiedInterstitialAdDidDismissFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    [self.parentAdapter log: @"Interstitial ad did dismiss fullscreen modal"];
}

- (void)unifiedInterstitialAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial playerStatusChanged:(GDTMediaPlayerStatus)status;
{
    [self.parentAdapter log: @"Interstitial ad player status changed: %ld", status];
}

@end

@implementation ALTencentGDTRewardedVideoDelegate

- (instancetype)initWithParentAdapter:(ALTencentGDTMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
}

- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad video loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded ad failed to load: %@", error];
    
    MAAdapterError *adapterError = [ALTencentGDTMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)gdt_rewardVideoAdWillVisible:(GDTRewardVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad will expose"];
}

- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad did expose"];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd info:(NSDictionary *)info;
{
    [self.parentAdapter log: @"Rewarded ad granted reward with info: %@", info];
    self.grantedReward = YES;
}

- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad video did finish"];
    [self.delegate didCompleteRewardedAdVideo];
}

- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad did close"];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.delegate didHideRewardedAd];
}

@end

@implementation ALTencentGDTAdViewDelegate

- (instancetype)initWithParentAdapter:(ALTencentGDTMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView
{
    [self.parentAdapter log: @"Banner loaded"];
    [self.delegate didLoadAdForAdView: self.parentAdapter.adView];
}

- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error
{
    [self.parentAdapter log: @"Banner failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALTencentGDTMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)unifiedBannerViewWillLeaveApplication:(GDTUnifiedBannerView *)unifiedBannerView
{
    [self.parentAdapter log: @"Banner will leave application"];
}

- (void)unifiedBannerViewWillClose:(GDTUnifiedBannerView *)unifiedBannerView
{
    [self.parentAdapter log: @"Banner will close"];
    [self.delegate didHideAdViewAd];
}

- (void)unifiedBannerViewWillExpose:(GDTUnifiedBannerView *)unifiedBannerView
{
    [self.parentAdapter log: @"Banner will exposure"];
    [self.delegate didDisplayAdViewAd];
}

- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView
{
    [self.parentAdapter log: @"Banner clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)unifiedBannerViewWillPresentFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    [self.parentAdapter log: @"Banner will present fullscreen modal"];
}

- (void)unifiedBannerViewDidPresentFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    [self.parentAdapter log: @"Banner did present fullscreen modal"];
    [self.delegate didExpandAdViewAd];
}

- (void)unifiedBannerViewWillDismissFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    [self.parentAdapter log: @"Banner will dismiss fullscreen modal"];
}

- (void)unifiedBannerViewDidDismissFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    [self.parentAdapter log: @"Banner did dismiss fullscreen modal"];
    [self.delegate didCollapseAdViewAd];
}

@end
