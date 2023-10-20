//
//  ALYandexMediationAdapter.m
//  AppLovinSDK
//
//  Created by Andrew Tian on 9/17/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

#import "ALYandexMediationAdapter.h"
#import <YandexMobileAds/YandexMobileAds.h>

#define ADAPTER_VERSION @"6.1.0.0"

/**
 * Dedicated delegate object for Yandex interstitial ads.
 */
@interface ALYandexMediationAdapterInterstitialAdDelegate : NSObject <YMAInterstitialAdLoaderDelegate, YMAInterstitialAdDelegate>

@property (nonatomic,   weak) ALYandexMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdapterResponseParameters> parameters;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(ALYandexMediationAdapter *)parentAdapter withParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate;

@end

/**
 * Dedicated delegate object for Yandex rewarded ads.
 */
@interface ALYandexMediationAdapterRewardedAdDelegate : NSObject <YMARewardedAdLoaderDelegate, YMARewardedAdDelegate>

@property (nonatomic,   weak) ALYandexMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdapterResponseParameters> parameters;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;

- (instancetype)initWithParentAdapter:(ALYandexMediationAdapter *)parentAdapter withParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate;

@end

/**
 * Dedicated delegate object for Yandex AdView ads.
 */
@interface ALYandexMediationAdapterAdViewDelegate : NSObject <YMAAdViewDelegate>

@property (nonatomic,   weak) ALYandexMediationAdapter *parentAdapter;
@property (nonatomic,   weak) NSString *adFormatLabel;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(ALYandexMediationAdapter *)parentAdapter
                        adFormatLabel:(NSString *)adFormatLabel
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;

@end

@interface ALYandexMediationAdapter ()

// Interstitial
@property (nonatomic, strong) YMAInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALYandexMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) YMAInterstitialAdLoader *interstitialAdLoader;

// Rewarded
@property (nonatomic, strong) YMARewardedAd *rewardedAd;
@property (nonatomic, strong) ALYandexMediationAdapterRewardedAdDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) YMARewardedAdLoader *rewardedAdLoader;

// AdView
@property (nonatomic, strong) YMAAdView *adView;
@property (nonatomic, strong) ALYandexMediationAdapterAdViewDelegate *adViewAdapterDelegate;

@end

@implementation ALYandexMediationAdapter

static YMABidderTokenLoader *ALYandexBidderTokenLoader;

+ (void)initialize
{
    [super initialize];
    
    ALYandexBidderTokenLoader = [[YMABidderTokenLoader alloc] init];
}

#pragma mark - MAAdapter Methods

- (NSString *)SDKVersion
{
    return [YMAMobileAds SDKVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [self log: @"Initializing Yandex SDK%@...", [parameters isTesting] ? @" in test mode" : @""];
    
    [self updateUserConsent: parameters];
    
    if ( [parameters isTesting] )
    {
        [YMAMobileAds enableLogging];
    }
    
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (void)destroy
{
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdapterDelegate.delegate = nil;
    self.interstitialAdapterDelegate = nil;
    self.interstitialAdLoader.delegate = nil;
    self.interstitialAdLoader = nil;
    
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;
    self.rewardedAdLoader.delegate = nil;
    self.rewardedAdLoader = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [ALYandexBidderTokenLoader loadBidderTokenWithCompletionHandler:^(NSString *bidderToken) {
        [self log: @"Collected signal"];
        [delegate didCollectSignal: bidderToken];
    }];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@interstitial ad for placement id: %@...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @"" ), placementId];
    
    [self updateUserConsent: parameters];
    
    self.interstitialAdLoader = [[YMAInterstitialAdLoader alloc] init];
    self.interstitialAdapterDelegate = [[ALYandexMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self
                                                                                                      withParameters: parameters
                                                                                                           andNotify: delegate];
    self.interstitialAdLoader.delegate = self.interstitialAdapterDelegate;
    
    YMAMutableAdRequestConfiguration *configuration = [self createAdRequestConfigurationForPlacementId: placementId parameters: parameters];
    [self.interstitialAdLoader loadAdWithRequestConfiguration: configuration];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( !self.interstitialAd )
    {
        [self log: @"Interstitial ad failed to show - ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205
                                                                             errorString: @"Ad Display Failed"
                                                                  thirdPartySdkErrorCode: 0
                                                               thirdPartySdkErrorMessage: @"Interstitial ad not ready"]];
#pragma clang diagnostic pop
        
        return;
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
    
    [self.interstitialAd showFromViewController: presentingViewController];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@rewarded ad for placement id: %@...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @"" ), placementId];
    
    [self updateUserConsent: parameters];
    
    self.rewardedAdLoader = [[YMARewardedAdLoader alloc] init];
    self.rewardedAdapterDelegate = [[ALYandexMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self
                                                                                              withParameters: parameters
                                                                                                   andNotify: delegate];
    self.rewardedAdLoader.delegate = self.rewardedAdapterDelegate;
    
    YMAMutableAdRequestConfiguration *configuration = [self createAdRequestConfigurationForPlacementId: placementId parameters: parameters];
    [self.rewardedAdLoader loadAdWithRequestConfiguration: configuration];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( !self.rewardedAd )
    {
        [self log: @"Rewarded ad failed to show - ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithCode: -4205
                                                                         errorString: @"Ad Display Failed"
                                                              thirdPartySdkErrorCode: 0
                                                           thirdPartySdkErrorMessage: @"Rewarded ad not ready"]];
#pragma clang diagnostic pop
        
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
    
    [self.rewardedAd showFromViewController: presentingViewController];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@%@ ad for placement id: %@...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @"" ), adFormat.label, placementId];
    
    [self updateUserConsent: parameters];
    
    self.adViewAdapterDelegate = [[ALYandexMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self adFormatLabel: adFormat.label andNotify: delegate];
    // NOTE: iOS banner ads do not auto-refresh by default
    self.adView = [[YMAAdView alloc] initWithAdUnitID: placementId
                                               adSize: [self adSizeFromAdFormat: adFormat]];
    self.adView.delegate = self.adViewAdapterDelegate;
    [self.adView loadAdWithRequest: [self createAdRequestWithParameters: parameters]];
}

#pragma mark - Helper Methods

- (void)updateUserConsent:(id<MAAdapterParameters>)parameters
{
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent )
    {
        [YMAMobileAds setUserConsent: hasUserConsent.boolValue];
    }
}

- (YMAMutableAdRequest *)createAdRequestWithParameters:(id<MAAdapterResponseParameters>)parameters
{
    // MAX specific
    NSDictionary *adRequestParameters = @{@"adapter_network_name" : @"applovin",
                                          @"adapter_version" : ADAPTER_VERSION,
                                          @"adapter_network_sdk_version" : ALSdk.version};
    
    YMAMutableAdRequest *adRequest = [[YMAMutableAdRequest alloc] init];
    adRequest.parameters = adRequestParameters;
    
    adRequest.biddingData = parameters.bidResponse;
    
    return adRequest;
}

- (YMAMutableAdRequestConfiguration *)createAdRequestConfigurationForPlacementId:(NSString *)placementId parameters:(id<MAAdapterResponseParameters>)parameters
{
    NSDictionary *adRequestParameters = @{@"adapter_network_name" : @"applovin",
                                          @"adapter_version" : ADAPTER_VERSION,
                                          @"adapter_network_sdk_version" : ALSdk.version};
    
    YMAMutableAdRequestConfiguration *configuration = [[YMAMutableAdRequestConfiguration alloc] initWithAdUnitID: placementId];
    configuration.parameters = adRequestParameters;
    
    configuration.biddingData = parameters.bidResponse;
    
    return configuration;
}

- (YMABannerAdSize *)adSizeFromAdFormat:(MAAdFormat *)adFormat
{
    return [YMABannerAdSize fixedSizeWithWidth: adFormat.size.width height: adFormat.size.height];
}

+ (MAAdapterError *)toMaxError:(NSError *)yandexError
{
    YMAAdErrorCode yandexErrorCode = yandexError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( yandexErrorCode )
    {
        case YMAAdErrorCodeEmptyAdUnitID:
        case YMAAdErrorCodeInvalidUUID:
        case YMAAdErrorCodeNoSuchAdUnitID:
        case YMAAdErrorCodeAdTypeMismatch:
        case YMAAdErrorCodeAdSizeMismatch:
        case YMAAdErrorCodeInvalidSDKConfiguration:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case YMAAdErrorCodeNoFill:
            adapterError = MAAdapterError.noFill;
            break;
        case YMAAdErrorCodeBadServerResponse:
            adapterError = MAAdapterError.serverError;
            break;
        case YMAAdErrorCodeServiceTemporarilyNotAvailable:
            adapterError = MAAdapterError.timeout;
            break;
        case YMAAdErrorCodeAdHasAlreadyBeenPresented:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case YMAAdErrorCodeNilPresentingViewController:
        case YMAAdErrorCodeIncorrectFullscreenView:
            adapterError = MAAdapterError.internalError;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: yandexErrorCode
               thirdPartySdkErrorMessage: yandexError.localizedDescription];
#pragma clang diagnostic pop
}

@end

#pragma mark - ALYandexMediationAdapterInterstitialAdDelegate

@implementation ALYandexMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALYandexMediationAdapter *)parentAdapter withParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parameters = parameters;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialAdLoader:(YMAInterstitialAdLoader *)adLoader didLoad:(YMAInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    self.parentAdapter.interstitialAd = interstitialAd;
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitialAdLoader:(YMAInterstitialAdLoader *)adLoader didFailToLoadWithError:(YMAAdRequestError *)yandexError
{
    NSError *error = yandexError.error;
    [self.parentAdapter log: @"Interstitial ad failed to load with error code %ld and description: %@", error.code, error.description];
    
    MAAdapterError *adapterError = [ALYandexMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialAdDidShow:(YMAInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad shown"];
    
    // Fire callbacks here for test mode ads since onAdapterImpressionTracked() doesn't get called for them
    if ( [self.parameters isTesting] )
    {
        [self.delegate didDisplayInterstitialAd];
    }
}

// Note: This method is generally called with a 3 second delay after the ad has been displayed.
//       This method is not called for test mode ads.
- (void)interstitialAd:(YMAInterstitialAd *)interstitialAd didTrackImpressionWithData:(nullable id<YMAImpressionData>)impressionData
{
    [self.parentAdapter log: @"Interstitial ad impression tracked"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialAd:(YMAInterstitialAd *)interstitialAd didFailToShowWithError:(NSError *)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *adapterError = [MAAdapterError errorWithCode: -4205
                                                     errorString: @"Ad Display Failed"
                                          thirdPartySdkErrorCode: error.code
                                       thirdPartySdkErrorMessage: error.localizedDescription];
#pragma clang diagnostic pop
    
    [self.parentAdapter log: @"Interstitial ad failed to display with error: %@", adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)interstitialAdDidClick:(YMAInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialAdDidDismiss:(YMAInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad hidden"];
    [self.delegate didHideInterstitialAd];
}

@end

#pragma mark - ALYandexMediationAdapterRewardedAdDelegate

@implementation ALYandexMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALYandexMediationAdapter *)parentAdapter withParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parameters = parameters;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedAdLoader:(YMARewardedAdLoader *)adLoader didLoad:(YMARewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    self.parentAdapter.rewardedAd = rewardedAd;
    [self.delegate didLoadRewardedAd];
}

- (void)rewardedAdLoader:(YMARewardedAdLoader *)adLoader didFailToLoadWithError:(YMAAdRequestError *)yandexError
{
    NSError *error = yandexError.error;
    [self.parentAdapter log: @"Rewarded ad failed to load with error code %ld and description: %@", error.code, error.description];
    
    MAAdapterError *adapterError = [ALYandexMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedAdDidShow:(YMARewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad shown"];
    
    // Fire callbacks here for test mode ads since onAdapterImpressionTracked() doesn't get called for them
    if ( [self.parameters isTesting] )
    {
        [self.delegate didDisplayRewardedAd];
        [self.delegate didStartRewardedAdVideo];
    }
}

// Note: This method is generally called with a 3 second delay after the ad has been displayed.
//       This method is not called for test mode ads.
- (void)rewardedAd:(YMARewardedAd *)rewardedAd didTrackImpressionWithData:(nullable id<YMAImpressionData>)impressionData
{
    [self.parentAdapter log: @"Rewarded ad impression tracked"];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)rewardedAd:(YMARewardedAd *)rewardedAd didFailToShowWithError:(NSError *)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *adapterError = [MAAdapterError errorWithCode: -4205
                                                     errorString: @"Ad Display Failed"
                                          thirdPartySdkErrorCode: error.code
                                       thirdPartySdkErrorMessage: error.localizedDescription];
#pragma clang diagnostic pop
    
    [self.parentAdapter log: @"Rewarded ad failed to display with error: %@", adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)rewardedAdDidClick:(YMARewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)rewardedAd:(YMARewardedAd *)rewardedAd didReward:(id<YMAReward>)reward
{
    [self.parentAdapter log: @"Rewarded ad user with reward: %@", reward];
    self.grantedReward = YES;
}

- (void)rewardedAdDidDismiss:(YMARewardedAd *)rewardedAd
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

@end

#pragma mark - ALYandexMediationAdapterAdViewDelegate

@implementation ALYandexMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALYandexMediationAdapter *)parentAdapter
                        adFormatLabel:(NSString *)adFormatLabel
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.adFormatLabel = adFormatLabel;
        self.delegate = delegate;
    }
    return self;
}

- (void)adViewDidLoad:(YMAAdView *)adView
{
    [self.parentAdapter log: @"%@ ad loaded", self.adFormatLabel];
    [self.delegate didLoadAdForAdView: adView];
}

- (void)adViewDidFailLoading:(YMAAdView *)adView error:(NSError *)error
{
    [self.parentAdapter log: @"%@ ad failed to display with error code %ld and description: %@", self.adFormatLabel, error.code, error.description];
    
    MAAdapterError *adapterError = [ALYandexMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)adViewDidClick:(YMAAdView *)adView
{
    [self.parentAdapter log: @"%@ ad clicked", self.adFormatLabel];
    [self.delegate didClickAdViewAd];
}

- (void)adView:(YMAAdView *)adView willPresentScreen:(nullable UIViewController *)viewController
{
    // This callback and adViewWillLeaveApplication are mutually exclusive
    // Ad either opens in-app or redirects to another app
    [self.parentAdapter log: @"%@ ad clicked and in-app browser opened", self.adFormatLabel];
    [self.delegate didExpandAdViewAd];
}

- (void)adViewWillLeaveApplication:(YMAAdView *)adView
{
    // This callback and adViewWillPresentScreen are mutually exclusive
    // Ad either opens in-app or redirects to another app
    [self.parentAdapter log: @"%@ ad clicked and left application", self.adFormatLabel];
}

- (void)adView:(YMAAdView *)adView didDismissScreen:(nullable UIViewController *)viewController
{
    [self.parentAdapter log: @"%@ ad in-app browser closed", self.adFormatLabel];
    [self.delegate didCollapseAdViewAd];
}

- (void)adView:(YMAAdView *)adView didTrackImpressionWithData:(nullable id<YMAImpressionData>)impressionData
{
    [self.parentAdapter log: @"AdView ad impression tracked"];
    [self.delegate didDisplayAdViewAd];
}

@end
