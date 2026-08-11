//
//  ALUnityAdsMediationAdapter.m
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 9/2/18.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALUnityAdsMediationAdapter.h"
#import <UnityAds/UnityAds.h>

#define ADAPTER_VERSION @"4.19.0.2"

@interface ALUnityAdsInitializationDelegate : NSObject
@property (nonatomic, weak) ALUnityAdsMediationAdapter *parentAdapter;
@property (nonatomic, copy, nullable) void(^completionHandler)(MAAdapterInitializationStatus, NSString *_Nullable);
- (instancetype)initWithParentAdapter:(ALUnityAdsMediationAdapter *)parentAdapter andCompletionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler;
- (void)initializationComplete;
- (void)initializationFailedWithError:(id<UnityAdsError>)error;
@end

@interface ALUnityAdsInterstitialDelegate : NSObject <UADSInterstitialShowDelegate>
@property (nonatomic,   weak) ALUnityAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALUnityAdsMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALUnityAdsRewardedDelegate : NSObject <UADSRewardedShowDelegate>
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
@property (nonatomic, strong) ALUnityAdsInterstitialDelegate *interstitialDelegate;
@property (nonatomic, strong) ALUnityAdsRewardedDelegate *rewardedDelegate;
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
    
    if ( [ALUnityAdsInitialized compareAndSet: NO update: YES] )
    {
        NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
        NSString *gameId = [serverParameters al_stringForKey: @"game_id"];
        [self log: @"Initializing UnityAds SDK with game id: %@...", gameId];
        
        ALUnityAdsInitializationDelegate *initializationDelegate = [[ALUnityAdsInitializationDelegate alloc] initWithParentAdapter: self andCompletionHandler: completionHandler];
        ALUnityAdsInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        UADSInitializationConfigurationBuilder *builder = [[UADSInitializationConfigurationBuilder alloc] initWithGameId: gameId];
        builder = [builder withTestMode: [parameters isTesting]];
        builder = [builder withMediationInfo: [self mediationInfo]];
        builder = [builder withLogLevel: [parameters isTesting] ? UADSLogLevelDebug : UADSLogLevelError];
        
        [UnityAds initialize: [builder build] completion:^(id<UnityAdsError> error) {
            if ( error )
            {
                [initializationDelegate initializationFailedWithError: error];
            }
            else
            {
                [initializationDelegate initializationComplete];
            }
        }];
    }
    else
    {
        completionHandler(ALUnityAdsInitializationStatus, nil);
    }
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
    self.interstitialDelegate.delegate = nil;
    self.interstitialDelegate = nil;
    
    self.rewardedAd = nil;
    self.rewardedDelegate.delegate = nil;
    self.rewardedDelegate = nil;
    
    self.bannerAd = nil;
    self.adViewDelegate.delegate = nil;
    self.adViewDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updatePrivacyConsent: parameters];
    
    UADSAdFormat unityAdFormat = [self adFormatFromParameters: parameters];
    UADSTokenConfigurationBuilder *builder = [[UADSTokenConfigurationBuilder alloc] initWithAdFormat: unityAdFormat];
    builder = [builder withMediationInfo: [self mediationInfo]];
    if ( [parameters.adFormat isAdViewAd] )
    {
        // NOTE: Server parameters are not reliably populated with placement-level settings during signal collection, so the adaptive banner flag is read from local extra parameters here
        BOOL isAdaptiveAdViewEnabled = [parameters.localExtraParameters al_boolForKey: @"adaptive_banner"];
        builder = [builder withBannerSize: [self bannerSizeFromAdFormat: parameters.adFormat
                                                isAdaptiveAdViewEnabled: isAdaptiveAdViewEnabled
                                                             parameters: parameters]];
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
    
    UADSLoadConfigurationBuilder *builder = [[UADSLoadConfigurationBuilder alloc] initWithPlacementId: placementIdentifier];
    builder = [builder withMediationInfo: [self mediationInfo]];
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        builder = [builder withAdMarkup: bidResponse];
    }
    
    [UADSInterstitialAd load: [builder build] completion:^(UADSInterstitialAd *ad, id<UnityAdsError> error) {
        if ( error )
        {
            [self log: @"Interstitial placement \"%@\" failed to load with error: %ld: %@", placementIdentifier, (long) error.code, error.message];
            [delegate didFailToLoadInterstitialAdWithError: [ALUnityAdsMediationAdapter toMaxError: error]];
        }
        else
        {
            [self log: @"Interstitial placement \"%@\" loaded", placementIdentifier];
            self.interstitialAd = ad;
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
        [self log: @"Interstitial ad failed to display for placement \"%@\" - ad not ready", placementIdentifier];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                        mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                     mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
        return;
    }
    
    self.interstitialDelegate = [[ALUnityAdsInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    
    UADSShowConfigurationBuilder *builder = [[UADSShowConfigurationBuilder alloc] init];
    builder = [builder withViewController: presentingViewController];
    
    [self.interstitialAd show: [builder build] delegate: self.interstitialDelegate];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@rewarded ad for placement \"%@\"...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @"" ), placementIdentifier];
    
    [self updatePrivacyConsent: parameters];
    
    UADSLoadConfigurationBuilder *builder = [[UADSLoadConfigurationBuilder alloc] initWithPlacementId: placementIdentifier];
    builder = [builder withMediationInfo: [self mediationInfo]];
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        builder = [builder withAdMarkup: bidResponse];
    }
    
    [UADSRewardedAd load: [builder build] completion:^(UADSRewardedAd *ad, id<UnityAdsError> error) {
        if ( error )
        {
            [self log: @"Rewarded ad placement \"%@\" failed to load with error: %ld: %@", placementIdentifier, (long) error.code, error.message];
            [delegate didFailToLoadRewardedAdWithError: [ALUnityAdsMediationAdapter toMaxError: error]];
        }
        else
        {
            [self log: @"Rewarded ad placement \"%@\" loaded", placementIdentifier];
            self.rewardedAd = ad;
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
        [self log: @"Rewarded ad failed to display for placement \"%@\" - ad not ready", placementIdentifier];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                    mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                 mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
        return;
    }
    
    self.rewardedDelegate = [[ALUnityAdsRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    // Configure reward from server.
    [self configureRewardForParameters: parameters];
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    
    UADSShowConfigurationBuilder *builder = [[UADSShowConfigurationBuilder alloc] init];
    builder = [builder withViewController: presentingViewController];
    
    [self.rewardedAd show: [builder build] delegate: self.rewardedDelegate];
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
    
    // Check if adaptive ad view sizes should be used
    BOOL isAdaptiveAdViewEnabled = [parameters.serverParameters al_boolForKey: @"adaptive_banner"];
    CGSize bannerSize = [self bannerSizeFromAdFormat: adFormat
                             isAdaptiveAdViewEnabled: isAdaptiveAdViewEnabled
                                          parameters: parameters];
    
    UADSBannerLoadConfigurationBuilder *builder = [[UADSBannerLoadConfigurationBuilder alloc] initWithPlacementId: placementIdentifier
                                                                                                       bannerSize: bannerSize
                                                                                                         delegate: self.adViewDelegate];
    builder = [builder withMediationInfo: [self mediationInfo]];
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        builder = [builder withAdMarkup: bidResponse];
    }
    
    [UADSBannerAd load: [builder build] completion:^(UADSBannerAd *ad, id<UnityAdsError> error) {
        if ( error )
        {
            [self log: @"%@ ad placement \"%@\" failed to load: %ld: %@", adFormat.label, placementIdentifier, (long) error.code, error.message];
            [delegate didFailToLoadAdViewAdWithError: [ALUnityAdsMediationAdapter toMaxError: error]];
        }
        else
        {
            [self log: @"%@ ad placement \"%@\" loaded", adFormat.label, placementIdentifier];
            self.bannerAd = ad;
            
            NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithCapacity: 2];
            extraInfo[@"ad_width"] = @(bannerSize.width);
            extraInfo[@"ad_height"] = @(bannerSize.height);
            
            [delegate didLoadAdForAdView: ad.view withExtraInfo: extraInfo];
        }
    }];
}

#pragma mark - Shared Methods

- (UADSMediationInfo *)mediationInfo
{
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
         isAdaptiveAdViewEnabled:(BOOL)isAdaptiveAdViewEnabled
                      parameters:(id<MAAdapterParameters>)parameters
{
    if ( isAdaptiveAdViewEnabled && ALSdk.versionCode < 13020099 )
    {
        [self userError: @"Please update AppLovin MAX SDK to version 13.2.0 or higher in order to use Unity Ads adaptive ads"];
        isAdaptiveAdViewEnabled = NO;
    }
    
    // NOTE: Unity Ads does not support adaptive MRECs
    if ( isAdaptiveAdViewEnabled && adFormat != MAAdFormat.mrec && [self isAdaptiveAdViewFormat: adFormat forParameters: parameters] )
    {
        return [self adaptiveBannerSizeFromParameters: parameters];
    }
    
    return [self bannerSizeFromAdFormat: adFormat];
}

- (CGSize)adaptiveBannerSizeFromParameters:(id<MAAdapterParameters>)parameters
{
    CGFloat adaptiveAdWidth = [self adaptiveAdViewWidthFromParameters: parameters];
    
    // NOTE: Unity Ads banner sizes are fixed - the requested size is the size that gets rendered, with no notion of a maximum height. An unspecified inline maximum height therefore falls back to the anchored size below instead of the screen height, which would ask Unity Ads for a screen-height banner.
    if ( [self isInlineAdaptiveAdViewForParameters: parameters] )
    {
        CGFloat inlineMaximumHeight = [self inlineAdaptiveAdViewMaximumHeightFromParameters: parameters];
        if ( inlineMaximumHeight > 0 )
        {
            return CGSizeMake(adaptiveAdWidth, inlineMaximumHeight);
        }
    }
    
    // Return anchored size by default
    CGFloat anchoredHeight = [MAAdFormat.banner adaptiveSizeForWidth: adaptiveAdWidth].height;
    return CGSizeMake(adaptiveAdWidth, anchoredHeight);
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

+ (MAAdapterError *)toMaxError:(id<UnityAdsError>)unityAdsError
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    NSInteger unityAdsErrorCode = unityAdsError.code;
    
    switch ( unityAdsErrorCode )
    {
        case 2: // Timeout
            adapterError = MAAdapterError.timeout;
            break;
            
        case 52000: // Init Unknown
            adapterError = MAAdapterError.unspecified;
            break;
        case 52001: // Init Not Found
        case 52002: // Init Mismatched Platform
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 52003: // Init Proto
        case 52004: // Init Internal System
        case 52006: // Init File System
            adapterError = MAAdapterError.internalError;
            break;
        case 52005: // Init Network
            adapterError = MAAdapterError.noConnection;
            break;
            
        case 52100: // Load No Fill
            adapterError = MAAdapterError.noFill;
            break;
        case 52101: // Load Not Initialized
            adapterError = MAAdapterError.notInitialized;
            break;
        case 52102: // Load Placement Not Found
        case 52104: // Load Unsupported Placement
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 52103: // Load Proto
        case 52106: // Load File System
        case 52107: // Load Ad Viewer
            adapterError = MAAdapterError.internalError;
            break;
        case 52105: // Load Network
            adapterError = MAAdapterError.noConnection;
            break;
            
        case 52200: // Show Expired
            adapterError = MAAdapterError.adExpiredError;
            break;
        case 52201: // Show Already Showing
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case 52202: // Show Internal
            adapterError = MAAdapterError.internalError;
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: unityAdsErrorCode
                     mediatedNetworkErrorMessage: unityAdsError.message ?: @""];
}

#pragma mark - GDPR

- (void)updatePrivacyConsent:(id<MAAdapterParameters>)parameters
{
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent != nil )
    {
        [UnityAds setUserConsent: hasUserConsent.boolValue];
    }
    
    // CCPA compliance - https://unityads.unity3d.com/help/legal/gdpr
    NSNumber *isDoNotSell = [parameters isDoNotSell];
    if ( isDoNotSell != nil )
    {
        [UnityAds setUserOptOut: isDoNotSell.boolValue];
    }
    
    [UnityAds setNonBehavioral: NO];
}

@end

@implementation ALUnityAdsInterstitialDelegate

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
    [self.parentAdapter log: @"Interstitial ad hidden with completion state: %ld", (long) finishState];
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

@implementation ALUnityAdsRewardedDelegate

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

- (void)showDidReceiveReward:(UADSRewardedAd *)unityAd
{
    [self.parentAdapter log: @"Rewarded ad granted reward"];
    
    if ( ![self.parentAdapter shouldAlwaysRewardUser] )
    {
        [self.delegate didRewardUserWithReward: [self.parentAdapter reward]];
    }
}

- (void)showDidComplete:(UADSRewardedAd *)unityAd with:(UADSShowFinishState)finishState
{
    [self.parentAdapter log: @"Rewarded ad hidden with completion state: %ld", (long) finishState];
    
    if ( [self.parentAdapter shouldAlwaysRewardUser] )
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
    [self.parentAdapter log: @"%@ ad placement \"%@\" shown", self.adFormat.label, self.placementIdentifier];
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
    [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
}

@end

@implementation ALUnityAdsInitializationDelegate

- (instancetype)initWithParentAdapter:(ALUnityAdsMediationAdapter *)parentAdapter andCompletionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.completionHandler = completionHandler;
    }
    return self;
}

#pragma mark - Initialization Methods

- (void)initializationComplete
{
    [self.parentAdapter log: @"UnityAds SDK initialized"];
    
    ALUnityAdsInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
    
    if ( self.completionHandler )
    {
        self.completionHandler(ALUnityAdsInitializationStatus, nil);
        self.completionHandler = nil;
    }
}

- (void)initializationFailedWithError:(id<UnityAdsError>)error
{
    [self.parentAdapter log: @"UnityAds SDK failed to initialize with error: %@", error.message];
    
    ALUnityAdsInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
    
    if ( self.completionHandler )
    {
        self.completionHandler(ALUnityAdsInitializationStatus, error.message);
        self.completionHandler = nil;
    }
}

@end
