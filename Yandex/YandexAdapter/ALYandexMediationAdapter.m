//
//  ALYandexMediationAdapter.m
//  AppLovinSDK
//
//  Created by Andrew Tian on 9/17/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

#import "ALYandexMediationAdapter.h"
#import <YandexMobileAds/YandexMobileAds.h>

#define ADAPTER_VERSION @"5.1.0.0"

/**
 * Dedicated delegate object for Yandex interstitial ads.
 */
@interface ALYandexMediationAdapterInterstitialAdDelegate : NSObject<YMAInterstitialAdDelegate>

@property (nonatomic,   weak) ALYandexMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdapterResponseParameters> parameters;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(ALYandexMediationAdapter *)parentAdapter withParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate;

@end

/**
 * Dedicated delegate object for Yandex rewarded ads.
 */
@interface ALYandexMediationAdapterRewardedAdDelegate : NSObject<YMARewardedAdDelegate>

@property (nonatomic,   weak) ALYandexMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdapterResponseParameters> parameters;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;

- (instancetype)initWithParentAdapter:(ALYandexMediationAdapter *)parentAdapter withParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate;

@end

/**
 * Dedicated delegate object for Yandex AdView ads.
 */
@interface ALYandexMediationAdapterAdViewDelegate : NSObject<YMAAdViewDelegate>

@property (nonatomic,   weak) ALYandexMediationAdapter *parentAdapter;
@property (nonatomic,   weak) NSString *adFormatLabel;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(ALYandexMediationAdapter *)parentAdapter
                        adFormatLabel:(NSString *)adFormatLabel
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;

@end

@interface ALYandexMediationAdapter()

// Interstitial
@property (nonatomic, strong) YMAInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALYandexMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;

// Rewarded
@property (nonatomic, strong) YMARewardedAd *rewardedAd;
@property (nonatomic, strong) ALYandexMediationAdapterRewardedAdDelegate *rewardedAdapterDelegate;

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

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
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
    
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
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
    
    self.interstitialAd = [[YMAInterstitialAd alloc] initWithAdUnitID: placementId];
    self.interstitialAdapterDelegate = [[ALYandexMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self
                                                                                                      withParameters: parameters
                                                                                                           andNotify: delegate];
    self.interstitialAd.delegate = self.interstitialAdapterDelegate;
    
    // This feature doesn't work yet when set to YES
    // Default is NO
    NSDictionary<NSString *, id> *serverParameters = [parameters serverParameters];
    if ( [serverParameters al_containsValueForKey: @"should_open_links_in_app"] )
    {
        self.interstitialAd.shouldOpenLinksInApp = [serverParameters al_numberForKey: @"should_open_links_in_app"].boolValue;
    }
    
    [self.interstitialAd loadWithRequest: [self createAdRequestWithParameters: parameters]];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( !self.interstitialAd || ![self.interstitialAd loaded] )
    {
        [self log: @"Interstitial ad failed to show - ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205 errorString: @"Ad Display Failed"]];
        
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
    
    [self.interstitialAd presentFromViewController: presentingViewController];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@rewarded ad for placement id: %@...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @"" ), placementId];
    
    [self updateUserConsent: parameters];
    
    self.rewardedAd = [[YMARewardedAd alloc] initWithAdUnitID: placementId];
    self.rewardedAdapterDelegate = [[ALYandexMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self
                                                                                              withParameters: parameters
                                                                                                   andNotify: delegate];
    self.rewardedAd.delegate = self.rewardedAdapterDelegate;
    
    // This feature doesn't work yet when set to YES
    // Default is NO
    NSDictionary<NSString *, id> *serverParameters = [parameters serverParameters];
    if ( [serverParameters al_containsValueForKey: @"should_open_links_in_app"] )
    {
        self.rewardedAd.shouldOpenLinksInApp = [serverParameters al_numberForKey: @"should_open_links_in_app"].boolValue;
    }
    
    [self.rewardedAd loadWithRequest: [self createAdRequestWithParameters: parameters]];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( !self.rewardedAd || ![self.rewardedAd loaded] )
    {
        [self log: @"Rewarded ad failed to show - ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithCode: -4205 errorString: @"Ad Display Failed"]];
        
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
    
    [self.rewardedAd presentFromViewController: presentingViewController];
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
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
        if ( hasUserConsent )
        {
            [YMAMobileAds setUserConsent: hasUserConsent.boolValue];
        }
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

- (YMAAdSize *)adSizeFromAdFormat:(MAAdFormat *)adFormat
{
    return [YMAAdSize flexibleSizeWithCGSize: adFormat.size];
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

- (void)interstitialAdDidLoad:(YMAInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitialAdDidFailToLoad:(YMAInterstitialAd *)interstitial error:(NSError *)error
{
    [self.parentAdapter log: @"Interstitial ad failed to load with error code %ld and description: %@", error.code, error.description];
    
    MAAdapterError *adapterError = [ALYandexMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialAdWillAppear:(YMAInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad will show"];
}

- (void)interstitialAdDidAppear:(YMAInterstitialAd *)interstitial
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

- (void)interstitialAdDidFailToPresent:(YMAInterstitialAd *)interstitial error:(NSError *)error
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

- (void)interstitialAd:(YMAInterstitialAd *)interstitialAd willPresentScreen:(nullable UIViewController *)webBrowser
{
    // This callback and interstitialWillLeaveApplication are mutually exclusive
    // Ad either opens in-app or redirects to another app
    [self.parentAdapter log: @"Interstitial ad clicked and in-app browser opened"];
}

- (void)interstitialAdWillLeaveApplication:(YMAInterstitialAd *)interstitial
{
    // This callback and interstitialWillPresentScreen are mutually exclusive
    // Ad either opens in-app or redirects to another app
    [self.parentAdapter log: @"Interstitial ad clicked and left application"];
}

- (void)interstitialAdWillDisappear:(YMAInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad will be hidden"];
}

- (void)interstitialAdDidDisappear:(YMAInterstitialAd *)interstitial
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

- (void)rewardedAdDidLoad:(YMARewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)rewardedAdDidFailToLoad:(YMARewardedAd *)rewardedAd error:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded ad failed to display with error code %ld and description: %@", error.code, error.description];
    
    MAAdapterError *adapterError = [ALYandexMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedAdWillAppear:(YMARewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad will show"];
}

- (void)rewardedAdDidAppear:(YMARewardedAd *)rewardedAd
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

- (void)rewardedAdDidFailToPresent:(YMARewardedAd *)rewardedAd error:(NSError *)error
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

- (void)rewardedAd:(YMARewardedAd *)rewardedAd willPresentScreen:(UIViewController *)viewController
{
    // This callback and rewardedAdWillLeaveApplication are mutually exclusive
    // Ad either opens in-app or redirects to another app
    [self.parentAdapter log: @"Rewarded ad clicked and in-app browser opened"];
}

- (void)rewardedAdWillLeaveApplication:(YMARewardedAd *)rewardedAd
{
    // This callback and willPresentScreen are mutually exclusive
    // Ad either opens in-app or redirects to another app
    [self.parentAdapter log: @"Rewarded ad clicked and left application"];
}

- (void)rewardedAd:(YMARewardedAd *)rewardedAd didReward:(id<YMAReward>)reward
{
    [self.parentAdapter log: @"Rewarded ad user with reward: %@", reward];
    self.grantedReward = YES;
}

- (void)rewardedAdWillDisappear:(YMARewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad will be hidden"];
}

- (void)rewardedAdDidDisappear:(YMARewardedAd *)rewardedAd
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
