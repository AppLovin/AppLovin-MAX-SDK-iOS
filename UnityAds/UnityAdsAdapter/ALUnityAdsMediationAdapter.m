//
//  ALUnityAdsMediationAdapter.m
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 9/2/18.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALUnityAdsMediationAdapter.h"
#import <UnityAds/UnityAds.h>

#define ADAPTER_VERSION @"4.19.0.1"

// Unity Ads public error codes. The SDK does not expose named symbols for these;
// names mirror `PublicErrorCode` in the Unity Ads SDK (UnityAdsError.swift), the source of truth.
typedef NS_ENUM(NSInteger, ALUnityAdsErrorCode)
{
    ALUnityAdsErrorCodeTimeout                 = 2,
    ALUnityAdsErrorCodeInitUnknown             = 52000,
    ALUnityAdsErrorCodeInitNotFound            = 52001,
    ALUnityAdsErrorCodeInitMismatchedPlatform  = 52002,
    ALUnityAdsErrorCodeInitProto               = 52003,
    ALUnityAdsErrorCodeInitInternalSystem      = 52004,
    ALUnityAdsErrorCodeInitNetwork             = 52005,
    ALUnityAdsErrorCodeInitFileSystem          = 52006,
    ALUnityAdsErrorCodeLoadNoFill              = 52100,
    ALUnityAdsErrorCodeLoadNotInitialized      = 52101,
    ALUnityAdsErrorCodeLoadPlacementNotFound   = 52102,
    ALUnityAdsErrorCodeLoadProto               = 52103,
    ALUnityAdsErrorCodeLoadUnsupportedPlacement = 52104,
    ALUnityAdsErrorCodeLoadNetwork             = 52105,
    ALUnityAdsErrorCodeLoadFileSystem          = 52106,
    ALUnityAdsErrorCodeLoadAdviewer            = 52107,
    ALUnityAdsErrorCodeShowExpired             = 52200,
    ALUnityAdsErrorCodeShowAlreadyShowing      = 52201,
    ALUnityAdsErrorCodeShowInternal            = 52202,
};

@interface ALUnityAdsInterstitialShowDelegate : NSObject <UADSInterstitialShowDelegate>
@property (nonatomic,   weak) ALUnityAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALUnityAdsMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALUnityAdsRewardedShowDelegate : NSObject <UADSRewardedShowDelegate>
@property (nonatomic,   weak) ALUnityAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALUnityAdsMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALUnityAdsAdViewDelegate : NSObject <UADSBannerAdDelegate>
@property (nonatomic,   weak) ALUnityAdsMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *placementIdentifier;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALUnityAdsMediationAdapter *)parentAdapter placementIdentifier:(NSString *)placementIdentifier adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALUnityAdsMediationAdapter ()
@property (nonatomic, strong) UADSInterstitialAd *interstitialAd;
@property (nonatomic, strong) UADSRewardedAd *rewardedAd;
@property (nonatomic, strong) UADSBannerAd *bannerAd;
@property (nonatomic, strong) ALUnityAdsInterstitialShowDelegate *interstitialShowDelegate;
@property (nonatomic, strong) ALUnityAdsRewardedShowDelegate *rewardedShowDelegate;
@property (nonatomic, strong) ALUnityAdsAdViewDelegate *adViewDelegate;
@end

@implementation ALUnityAdsMediationAdapter
static MAAdapterInitializationStatus ALUnityAdsInitializationStatus = NSIntegerMin;

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [self updatePrivacyConsent: parameters];
    
    if ([UnityAds isInitialized]) {
        ALUnityAdsInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
        completionHandler(ALUnityAdsInitializationStatus, nil);
        return;
    }
    
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    NSString *gameId = [serverParameters al_stringForKey: @"game_id"];
    [self log: @"Initializing UnityAds SDK with game id: %@...", gameId];
    
    UADSInitializationConfigurationBuilder *builder = [[[UADSInitializationConfigurationBuilder alloc] initWithGameId: gameId]
                                                       withTestMode: [parameters isTesting]];
    builder = [builder withMediationInfo: self.mediationInfo];
    
    if ( [parameters isTesting] )
    {
        builder = [builder withLogLevel: UADSLogLevelDebug];
    }
    
    ALUnityAdsInitializationStatus = MAAdapterInitializationStatusInitializing;
    
    __weak typeof(self) weakSelf = self;
    [UnityAds initialize: [builder build] completion:^(id<UnityAdsError> error) {
        if ( error )
        {
            [weakSelf log: @"UnityAds SDK failed to initialize with error: %ld %@", (long) error.code, error.message];
            ALUnityAdsInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
            completionHandler(ALUnityAdsInitializationStatus, error.message);
        }
        else
        {
            [weakSelf log: @"UnityAds SDK initialized"];
            ALUnityAdsInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            completionHandler(ALUnityAdsInitializationStatus, nil);
        }
    }];
}

- (NSString *)SDKVersion
{
    return [UnityAds getVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.interstitialAd = nil;
    self.rewardedAd = nil;
    self.bannerAd = nil;
    
    self.interstitialShowDelegate.delegate = nil;
    self.rewardedShowDelegate.delegate = nil;
    self.adViewDelegate.delegate = nil;
    
    self.interstitialShowDelegate = nil;
    self.rewardedShowDelegate = nil;
    self.adViewDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updatePrivacyConsent: parameters];
    
    UADSAdFormat adFormat = [self adFormatFromParameters: parameters];
    
    UADSTokenConfigurationBuilder *builder = [[[UADSTokenConfigurationBuilder alloc] initWithAdFormat: adFormat]
                                              withMediationInfo: self.mediationInfo];
    
    if ( adFormat == UADSAdFormatBanner )
    {
        // Server parameters are not reliably populated with placement-level settings during signal
        // collection, so the adaptive banner flag is read from local extra parameters here
        MAAdFormat *maxAdFormat = parameters.adFormat;
        BOOL isAdaptiveBannerEnabled = [parameters.localExtraParameters al_boolForKey: @"adaptive_banner"];
        builder = [builder withBannerSize: [self bannerSizeForAdFormat: maxAdFormat isAdaptiveBannerEnabled: isAdaptiveBannerEnabled parameters: parameters]];
    }
    
    [UnityAds getToken: [builder build] completion:^(NSString *signal) {
        [self log: @"Signal collected"];
        [delegate didCollectSignal: signal];
    }];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@interstitial ad for placement \"%@\"...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @"" ), placementIdentifier];
    
    [self updatePrivacyConsent: parameters];
    
    self.interstitialShowDelegate = [[ALUnityAdsInterstitialShowDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    UADSLoadConfigurationBuilder *builder = [[[UADSLoadConfigurationBuilder alloc] initWithPlacementId: placementIdentifier]
                                             withMediationInfo: self.mediationInfo];
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        builder = [builder withAdMarkup: bidResponse];
    }
    
    __weak typeof(self) weakSelf = self;
    [UADSInterstitialAd load: [builder build] completion:^(UADSInterstitialAd *ad, id<UnityAdsError> error) {
        if ( error )
        {
            [weakSelf log: @"Interstitial placement \"%@\" failed to load with error: %ld: %@", placementIdentifier, (long) error.code, error.message];
            MAAdapterError *adapterError = [ALUnityAdsMediationAdapter toMaxErrorWithUnityAdsError: error];
            [delegate didFailToLoadInterstitialAdWithError: adapterError];
        }
        else
        {
            [weakSelf log: @"Interstitial placement \"%@\" loaded", placementIdentifier];
            weakSelf.interstitialAd = ad;
            
            [delegate didLoadInterstitialAd];
        }
    }];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad for placement \"%@\"...", placementIdentifier];
    
    if ( !self.interstitialAd )
    {
        [self log: @"Interstitial ad not ready for placement \"%@\"", placementIdentifier];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adNotReady
                                                                        mediatedNetworkErrorCode: 0
                                                                     mediatedNetworkErrorMessage: @"Ad not ready"]];
        return;
    }
    
    if ( !self.interstitialShowDelegate )
    {
        self.interstitialShowDelegate = [[ALUnityAdsInterstitialShowDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    }
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    
    UADSShowConfigurationBuilder *showConfig = [[[UADSShowConfigurationBuilder alloc] init] withViewController: presentingViewController];
    
    [self.interstitialAd show: [showConfig build] delegate: self.interstitialShowDelegate];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@rewarded ad for placement \"%@\"...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @"" ), placementIdentifier];
    
    [self updatePrivacyConsent: parameters];
    
    self.rewardedShowDelegate = [[ALUnityAdsRewardedShowDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    UADSLoadConfigurationBuilder *builder = [[[UADSLoadConfigurationBuilder alloc] initWithPlacementId: placementIdentifier]
                                             withMediationInfo: self.mediationInfo];
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        builder = [builder withAdMarkup: bidResponse];
    }
    
    __weak typeof(self) weakSelf = self;
    [UADSRewardedAd load: [builder build] completion:^(UADSRewardedAd *ad, id<UnityAdsError> error) {
        if ( error )
        {
            [weakSelf log: @"Rewarded ad placement \"%@\" failed to load with error: %ld: %@", placementIdentifier, (long) error.code, error.message];
            MAAdapterError *adapterError = [ALUnityAdsMediationAdapter toMaxErrorWithUnityAdsError: error];
            [delegate didFailToLoadRewardedAdWithError: adapterError];
        }
        else
        {
            [weakSelf log: @"Rewarded ad placement \"%@\" loaded", placementIdentifier];
            weakSelf.rewardedAd = ad;
            
            [delegate didLoadRewardedAd];
        }
    }];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad for placement \"%@\"...", placementIdentifier];
    
    if ( !self.rewardedAd )
    {
        [self log: @"Rewarded ad not ready for placement \"%@\"", placementIdentifier];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adNotReady
                                                                    mediatedNetworkErrorCode: 0
                                                                 mediatedNetworkErrorMessage: @"Ad not ready"]];
        return;
    }
    
    if ( !self.rewardedShowDelegate )
    {
        self.rewardedShowDelegate = [[ALUnityAdsRewardedShowDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    }
    
    [self configureRewardForParameters: parameters];
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    
    UADSShowConfigurationBuilder *showConfig = [[[UADSShowConfigurationBuilder alloc] init] withViewController: presentingViewController];
    
    [self.rewardedAd show: [showConfig build] delegate: self.rewardedShowDelegate];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@%@ ad for placement \"%@\"...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @"" ), adFormat.label, placementIdentifier];
    
    [self updatePrivacyConsent: parameters];
    
    self.adViewDelegate = [[ALUnityAdsAdViewDelegate alloc] initWithParentAdapter: self placementIdentifier: placementIdentifier adFormat: adFormat andNotify: delegate];
    
    BOOL isAdaptiveBannerEnabled = [parameters.serverParameters al_boolForKey: @"adaptive_banner"];
    CGSize bannerSize = [self bannerSizeForAdFormat: adFormat isAdaptiveBannerEnabled: isAdaptiveBannerEnabled parameters: parameters];
    
    UADSBannerLoadConfigurationBuilder *builder = [[[UADSBannerLoadConfigurationBuilder alloc] initWithPlacementId: placementIdentifier
                                                                                                        bannerSize: bannerSize
                                                                                                          delegate: self.adViewDelegate] withMediationInfo: self.mediationInfo];
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        builder = [builder withAdMarkup: bidResponse];
    }
    
    __weak typeof(self) weakSelf = self;
    [UADSBannerAd load: [builder build] completion:^(UADSBannerAd *ad, id<UnityAdsError> error) {
        if ( error )
        {
            [weakSelf log: @"%@ ad placement \"%@\" failed to load with error: %ld: %@", adFormat.label, placementIdentifier, (long) error.code, error.message];
            MAAdapterError *adapterError = [ALUnityAdsMediationAdapter toMaxErrorWithUnityAdsError: error];
            [delegate didFailToLoadAdViewAdWithError: adapterError];
        }
        else
        {
            [weakSelf log: @"%@ ad placement \"%@\" loaded", adFormat.label, placementIdentifier];
            weakSelf.bannerAd = ad;
            [delegate didLoadAdForAdView: ad.view];
        }
    }];
}

#pragma mark - Shared Methods

- (UADSMediationInfo *)mediationInfo {
    return [[UADSMediationInfo alloc] initWithName: @"MAX"
                                           version: [ALSdk version]
                                    adapterVersion: ADAPTER_VERSION];
}

- (UADSAdFormat)adFormatFromParameters:(id<MASignalCollectionParameters>)parameters
{
    MAAdFormat *adFormat = parameters.adFormat;
    
    if ( [adFormat isAdViewAd] )
    {
        return UADSAdFormatBanner;
    }
    else if ( adFormat == MAAdFormat.interstitial )
    {
        return UADSAdFormatInterstitial;
    }
    else if ( adFormat == MAAdFormat.rewarded )
    {
        return UADSAdFormatRewarded;
    }
    
    [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
    
    return UADSAdFormatUnspecified;
}

- (CGSize)bannerSizeForAdFormat:(MAAdFormat *)adFormat
        isAdaptiveBannerEnabled:(BOOL)isAdaptiveBannerEnabled
                     parameters:(id<MAAdapterParameters>)parameters
{
    if ( adFormat == MAAdFormat.mrec )
    {
        return CGSizeMake(300, 250);
    }

    if ( isAdaptiveBannerEnabled )
    {
        CGFloat width = [self adaptiveAdViewWidthFromParameters: parameters];
        if ( width <= 0 )
        {
            width = adFormat.size.width;
        }

        if ( [self isInlineAdaptiveAdViewForParameters: parameters] )
        {
            CGFloat maxHeight = [self inlineAdaptiveAdViewMaximumHeightFromParameters: parameters];
            if ( maxHeight > 0 )
            {
                return CGSizeMake(width, maxHeight);
            }

            CGFloat screenHeight = CGRectGetHeight(UIScreen.mainScreen.bounds);
            return CGSizeMake(width, screenHeight);
        }

        CGFloat anchoredHeight = [MAAdFormat.banner adaptiveSizeForWidth: width].height;
        return CGSizeMake(width, anchoredHeight);
    }

    return [self bannerSizeFromAdFormat: adFormat];
}

- (CGSize)bannerSizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return CGSizeMake(320, 50);
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return CGSizeMake(728, 90);
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return CGSizeMake(300, 250);
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return CGSizeMake(320, 50);
    }
}

+ (MAAdapterError *)toMaxErrorWithUnityAdsError:(id<UnityAdsError>)error
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    NSInteger errorCode = error.code;
    
    switch ( errorCode )
    {
        case ALUnityAdsErrorCodeTimeout:
            adapterError = MAAdapterError.timeout;
            break;

        case ALUnityAdsErrorCodeInitUnknown:
            adapterError = MAAdapterError.unspecified;
            break;
        case ALUnityAdsErrorCodeInitNotFound:
        case ALUnityAdsErrorCodeInitMismatchedPlatform:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case ALUnityAdsErrorCodeInitProto:
        case ALUnityAdsErrorCodeInitInternalSystem:
        case ALUnityAdsErrorCodeInitFileSystem:
            adapterError = MAAdapterError.internalError;
            break;
        case ALUnityAdsErrorCodeInitNetwork:
            adapterError = MAAdapterError.noConnection;
            break;

        case ALUnityAdsErrorCodeLoadNoFill:
            adapterError = MAAdapterError.noFill;
            break;
        case ALUnityAdsErrorCodeLoadNotInitialized:
            adapterError = MAAdapterError.notInitialized;
            break;
        case ALUnityAdsErrorCodeLoadPlacementNotFound:
        case ALUnityAdsErrorCodeLoadUnsupportedPlacement:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case ALUnityAdsErrorCodeLoadProto:
        case ALUnityAdsErrorCodeLoadAdviewer:
        case ALUnityAdsErrorCodeLoadFileSystem:
            adapterError = MAAdapterError.internalError;
            break;
        case ALUnityAdsErrorCodeLoadNetwork:
            adapterError = MAAdapterError.noConnection;
            break;

        case ALUnityAdsErrorCodeShowExpired:
            adapterError = MAAdapterError.adExpiredError;
            break;
        case ALUnityAdsErrorCodeShowAlreadyShowing:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case ALUnityAdsErrorCodeShowInternal:
            adapterError = MAAdapterError.internalError;
            break;

        default:
            adapterError = MAAdapterError.unspecified;
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: errorCode
                     mediatedNetworkErrorMessage: error.message ?: @""];
}

#pragma mark - Privacy

- (void)updatePrivacyConsent:(id<MAAdapterParameters>)parameters
{
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent != nil )
    {
        [UnityAds setUserConsent: hasUserConsent.boolValue];
    }
    
    NSNumber *isDoNotSell = [parameters isDoNotSell];
    if ( isDoNotSell != nil )
    {
        [UnityAds setUserOptOut: isDoNotSell.boolValue];
    }
}

@end

@implementation ALUnityAdsInterstitialShowDelegate

- (instancetype)initWithParentAdapter:(ALUnityAdsMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - UADSInterstitialShowDelegate Methods

- (void)showDidStart:(UADSInterstitialAd *)unityAd
{
    [self.parentAdapter log: @"Interstitial ad displayed"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)showDidClick:(UADSInterstitialAd *)unityAd
{
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)showDidComplete:(UADSInterstitialAd *)unityAd with:(UADSShowFinishState)finishState
{
    [self.parentAdapter log: @"Interstitial ad hidden with finish state: %ld", (long)finishState];
    [self.delegate didHideInterstitialAd];
}

- (void)showDidFail:(UADSInterstitialAd *)unityAd error:(id<UnityAdsError>)error
{
    [self.parentAdapter log: @"Interstitial ad failed to display with error: %ld: %@", (long) error.code, error.message];
    
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.message ?: @""];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

@end

@implementation ALUnityAdsRewardedShowDelegate

- (instancetype)initWithParentAdapter:(ALUnityAdsMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - UADSRewardedShowDelegate Methods

- (void)showDidStart:(UADSRewardedAd *)unityAd
{
    [self.parentAdapter log: @"Rewarded ad displayed"];
    [self.delegate didDisplayRewardedAd];
}

- (void)showDidClick:(UADSRewardedAd *)unityAd
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)showDidComplete:(UADSRewardedAd *)unityAd with:(UADSShowFinishState)finishState
{
    [self.parentAdapter log: @"Rewarded ad hidden with finish state: %ld", (long)finishState];
    
    if ( finishState == UADSShowFinishStateCompleted || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        [self.delegate didRewardUserWithReward: [self.parentAdapter reward]];
    }
    
    [self.delegate didHideRewardedAd];
}

- (void)showDidFail:(UADSRewardedAd *)unityAd error:(id<UnityAdsError>)error
{
    [self.parentAdapter log: @"Rewarded ad failed to display with error: %ld: %@", (long) error.code, error.message];
    
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.message ?: @""];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)showDidReceiveReward:(UADSRewardedAd *)unityAd
{
    // The reward is granted in showDidComplete: based on the finish state (and MAX's
    // shouldAlwaysRewardUser override), so this callback only logs to avoid a double grant.
    [self.parentAdapter log: @"Rewarded ad received reward callback"];
}

@end

@implementation ALUnityAdsAdViewDelegate

- (instancetype)initWithParentAdapter:(ALUnityAdsMediationAdapter *)parentAdapter placementIdentifier:(NSString *)placementIdentifier adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementIdentifier = placementIdentifier;
        self.adFormat = adFormat;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - UADSBannerAdDelegate Methods

- (void)bannerImpression:(UADSBannerAd *)banner
{
    [self.parentAdapter log: @"%@ ad placement \"%@\" displayed", self.adFormat.label, self.placementIdentifier];
    [self.delegate didDisplayAdViewAd];
}

- (void)bannerDidClick:(UADSBannerAd *)banner
{
    [self.parentAdapter log: @"%@ ad placement \"%@\" clicked", self.adFormat.label, self.placementIdentifier];
    [self.delegate didClickAdViewAd];
}

- (void)bannerDidFailShow:(UADSBannerAd *)banner error:(id<UnityAdsError>)error
{
    [self.parentAdapter log: @"%@ ad placement \"%@\" failed to show: %ld: %@", self.adFormat.label, self.placementIdentifier, (long) error.code, error.message];
    
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.message ?: @""];
    
    [self.delegate didFailToDisplayAdViewAdWithError:adapterError];
}

@end
