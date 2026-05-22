//
//  ALUnityAdsMediationAdapter.m
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 9/2/18.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALUnityAdsMediationAdapter.h"
#import <UnityAds/UnityAds.h>

#define ADAPTER_VERSION @"4.19.0.0"

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
static ALAtomicBoolean *ALUnityAdsInitialized;
static MAAdapterInitializationStatus ALUnityAdsInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    ALUnityAdsInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [self updatePrivacyConsent: parameters];
    
    if ([UnityAds isInitialized]) {
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
            [weakSelf log: @"UnityAds SDK failed to initialize with error: %d %@", error.code, error.message];
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
        MAAdFormat *maxAdFormat = parameters.adFormat;
        builder = [builder withBannerSize: [self bannerSizeFromAdFormat: maxAdFormat]];
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
            [weakSelf log: @"Interstitial placement \"%@\" failed to load with error: %d: %@", placementIdentifier, error.code, error.message];
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
            [weakSelf log: @"Rewarded ad placement \"%@\" failed to load with error: %d: %@", placementIdentifier, error.code, error.message];
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
    
    CGSize bannerSize = [self bannerSizeFromAdFormat: adFormat];
    
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
            [weakSelf log: @"%@ ad placement \"%@\" failed to load with error: %d: %@", adFormat.label, placementIdentifier, error.code, error.message];
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
            // Shared timeout error
        case 2:
            adapterError = MAAdapterError.timeout;
            break;
            
            // Initialization errors (52000-52006)
        case 52000: // Unknown error
            adapterError = MAAdapterError.unspecified;
            break;
        case 52001: // Invalid Game ID
        case 52002: // Game ID mismatch
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 52003: // Internal protocol error
        case 52004: // System error
            adapterError = MAAdapterError.internalError;
            break;
        case 52005: // Network error
            adapterError = MAAdapterError.noConnection;
            break;
        case 52006: // Insufficient storage
            adapterError = MAAdapterError.internalError;
            break;
            
            // Load errors (52100-52107)
        case 52100: // No fill
            adapterError = MAAdapterError.noFill;
            break;
        case 52101: // SDK not initialized
            adapterError = MAAdapterError.notInitialized;
            break;
        case 52102: // Placement not found
        case 52104: // Placement/format mismatch
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 52103: // Internal protocol error
        case 52107: // Internal parsing error
            adapterError = MAAdapterError.internalError;
            break;
        case 52105: // Network error
            adapterError = MAAdapterError.noConnection;
            break;
        case 52106: // Insufficient storage
            adapterError = MAAdapterError.internalError;
            break;
            
            // Show errors (52200-52202)
        case 52200: // Ad expired
            adapterError = MAAdapterError.adExpiredError;
            break;
        case 52201: // Already showing
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case 52202: // Internal error
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
    [self.parentAdapter log: @"Interstitial ad failed to display with error: %d: %@", error.code, error.message];
    
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
    [self.parentAdapter log: @"Rewarded ad failed to display with error: %d: %@", error.code, error.message];
    
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.message ?: @""];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)showDidReceiveReward:(UADSRewardedAd *)unityAd
{
    [self.parentAdapter log: @"Rewarded ad received reward callback"];
    
    [self.delegate didRewardUserWithReward:nil];
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
    [self.parentAdapter log: @"%@ ad placement \"%@\" failed to show: %d: %@", self.adFormat.label, self.placementIdentifier, error.code, error.message];
    
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.message ?: @""];
    
    [self.delegate didFailToDisplayAdViewAdWithError:adapterError];
}

@end
