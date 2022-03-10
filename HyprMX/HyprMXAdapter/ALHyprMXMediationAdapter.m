//
//  ALHyprMXMediationAdapter.m
//  Adapters
//
//  Created by Varsha Hanji on 10/1/20.
//  Copyright © 2020 AppLovin. All rights reserved.
//

#import "ALHyprMXMediationAdapter.h"
#import <HyprMX/HyprMX.h>

#define ADAPTER_VERSION @"6.0.1.2"

/**
 * Dedicated delegate object for HyprMX initialization.
 */
@interface ALHyprMXMediationAdapterInitializationDelegate : NSObject<HyprMXInitializationDelegate>
@property (nonatomic, weak) ALHyprMXMediationAdapter *parentAdapter;
@property (nonatomic, copy, nullable) void(^completionBlock)(MAAdapterInitializationStatus, NSString * _Nullable);
- (instancetype)initWithParentAdapter:(ALHyprMXMediationAdapter *)parentAdapter completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler;
@end

/**
 * Dedicated delegate object for HyprMX AdView ads.
 */
@interface ALHyprMXMediationAdapterAdViewDelegate : NSObject<HyprMXBannerDelegate>
@property (nonatomic,   weak) ALHyprMXMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALHyprMXMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * Dedicated delegate object for HyprMX interstitial ads.
 */
@interface ALHyprMXMediationAdapterInterstitialAdDelegate : NSObject<HyprMXPlacementDelegate>
@property (nonatomic,   weak) ALHyprMXMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALHyprMXMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * Dedicated delegate object for HyprMX rewarded ads.
 */
@interface ALHyprMXMediationAdapterRewardedAdDelegate : NSObject<HyprMXPlacementDelegate>
@property (nonatomic,   weak) ALHyprMXMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALHyprMXMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

@interface ALHyprMXMediationAdapter()

// Initialization
@property (nonatomic, strong) ALHyprMXMediationAdapterInitializationDelegate *initializationDelegate;

// AdView
@property (nonatomic, strong) HyprMXBannerView *adView;
@property (nonatomic, strong) ALHyprMXMediationAdapterAdViewDelegate *adViewDelegate;

// Interstitial
@property (nonatomic, strong) HyprMXPlacement *interstitialAd;
@property (nonatomic, strong) ALHyprMXMediationAdapterInterstitialAdDelegate *interstitialAdDelegate;

// Rewarded
@property (nonatomic, strong) HyprMXPlacement *rewardedAd;
@property (nonatomic, strong) ALHyprMXMediationAdapterRewardedAdDelegate *rewardedAdDelegate;

@end

@implementation ALHyprMXMediationAdapter
static NSString *const kHyprMXRandomUserIdKey = @"com.applovin.sdk.mediation.random_hyprmx_user_id";

#pragma mark - MAAdapter Methods

- (NSString *)SDKVersion
{
    return [HyprMX versionString];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [HyprMX initializationStatus] == NOT_INITIALIZED )
    {
        NSString *distributorId = [parameters.serverParameters al_stringForKey: @"distributor_id"];
        
        // HyprMX requires userId to initialize -> generatie a random one
        NSString *userId = self.sdk.userIdentifier;
        if ( ![userId al_isValidString] )
        {
            userId = [[NSUserDefaults standardUserDefaults] stringForKey: kHyprMXRandomUserIdKey];
            if ( ![userId al_isValidString] )
            {
                userId = [NSUUID UUID].UUIDString.lowercaseString;
                [[NSUserDefaults standardUserDefaults] setObject: userId forKey: kHyprMXRandomUserIdKey];
            }
        }
        
        [self log: @"Initializing HyprMX SDK with distributor id: %@", distributorId];
        
        HYPRLogLevel logLevel = [parameters isTesting] ? HYPRLogLevelVerbose : HYPRLogLevelError;
        [HyprMX setLogLevel: logLevel];
        
        self.initializationDelegate = [[ALHyprMXMediationAdapterInitializationDelegate alloc] initWithParentAdapter: self completionHandler: completionHandler];
        
        // NOTE: HyprMX deals with CCPA via their UI
        [HyprMX initializeWithDistributorId: distributorId
                                     userId: userId
                     initializationDelegate: self.initializationDelegate];
    }
    else
    {
        if ( [HyprMX initializationStatus] == INITIALIZATION_COMPLETE )
        {
            completionHandler(MAAdapterInitializationStatusInitializedSuccess, nil);
        }
        else if ( [HyprMX initializationStatus] == INITIALIZATION_FAILED )
        {
            completionHandler(MAAdapterInitializationStatusInitializedFailure, nil);
        }
        else if ( [HyprMX initializationStatus] == INITIALIZING )
        {
            completionHandler(MAAdapterInitializationStatusInitializing, nil);
        }
        else
        {
            completionHandler(MAAdapterInitializationStatusInitializedUnknown, nil);
        }
    }
}

- (void)destroy
{
    self.initializationDelegate = nil;
    
    self.adView = nil;
    self.adViewDelegate = nil;
    
    self.interstitialAd = nil;
    self.interstitialAdDelegate = nil;
    
    self.rewardedAd = nil;
    self.rewardedAdDelegate = nil;
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    NSString *signal = [HyprMX sessionToken];
    [delegate didCollectSignal: signal];
}

#pragma mark - AdView Adapter

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@ AdView ad for placement: %@...", adFormat.label, placementId];
    
    [self updateConsentWithParameters: parameters];
    
    self.adViewDelegate = [[ALHyprMXMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.adView = [[HyprMXBannerView alloc] initWithPlacementName: placementId adSize: [self adSizeForAdFormat: adFormat]];
    self.adView.placementDelegate = self.adViewDelegate;
    
    [self.adView loadAd];
}

#pragma mark - Interstitial Adapter

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad for placement: %@", placementId];
    
    [self updateConsentWithParameters: parameters];
    
    self.interstitialAdDelegate = [[ALHyprMXMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [self loadFullscreenAdForPlacementId: placementId
                                                    parameters: parameters
                                                     andNotify: self.interstitialAdDelegate];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( [self.interstitialAd isAdAvailable] )
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
        
        [self.interstitialAd showAdFromViewController: presentingViewController];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - Rewarded Adapter

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad for placement: %@", placementId];
    
    [self updateConsentWithParameters: parameters];
    
    self.rewardedAdDelegate = [[ALHyprMXMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd = [self loadFullscreenAdForPlacementId: placementId
                                                parameters: parameters
                                                 andNotify: self.rewardedAdDelegate];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( [self.rewardedAd isAdAvailable] )
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
        
        [self.rewardedAd showAdFromViewController: presentingViewController];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - Shared Methods

- (void)updateConsentWithParameters:(id<MAAdapterParameters>)parameters
{
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = parameters.hasUserConsent;
        if ( hasUserConsent )
        {
            [HyprMX setConsentStatus: hasUserConsent.boolValue ? CONSENT_GIVEN : CONSENT_DECLINED];
        }
        else
        {
            [HyprMX setConsentStatus: CONSENT_STATUS_UNKNOWN];
        }
    }
}

#pragma mark - Helper Methods

- (HyprMXPlacement *)loadFullscreenAdForPlacementId:(NSString *)placementId parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<HyprMXPlacementDelegate>)delegate
{
    HyprMXPlacement *fullScreenPlacement = [HyprMX getPlacement: placementId];
    fullScreenPlacement.placementDelegate = delegate;
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        [fullScreenPlacement loadAdWithBidResponse: bidResponse];
    }
    else
    {
        [fullScreenPlacement loadAd];
    }
    
    return fullScreenPlacement;
}

- (CGSize)adSizeForAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return kHyprMXAdSizeBanner;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return kHyprMXAdSizeMediumRectangle;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return kHyprMXAdSizeLeaderBoard;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return kHyprMXAdSizeBanner;
    }
}

+ (MAAdapterError *)toMaxError:(NSError *)hyprMXError
{
    return [self toMaxError: hyprMXError.code message: nil];
}

+ (MAAdapterError *)toMaxError:(NSInteger)hyprMXErrorCode message:(nullable NSString *)hyprMXMessage
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
    if ( [HyprMX initializationStatus] != INITIALIZATION_COMPLETE )
    {
        return MAAdapterError.notInitialized;
    }
    
    switch ( hyprMXErrorCode )
    {
        case NO_FILL:
            adapterError = MAAdapterError.noFill;
            break;
        case DISPLAY_ERROR:
            adapterError = MAAdapterError.internalError;
            break;
        case PLACEMENT_DOES_NOT_EXIST:
        case AD_SIZE_NOT_SET:
        case PLACEMENT_NAME_NOT_SET:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case SDK_NOT_INITIALIZED:
            adapterError = MAAdapterError.notInitialized;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: hyprMXErrorCode
               thirdPartySdkErrorMessage: hyprMXMessage];
#pragma clang diagnostic pop
}

@end

@implementation ALHyprMXMediationAdapterInitializationDelegate

- (instancetype)initWithParentAdapter:(ALHyprMXMediationAdapter *)parentAdapter completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler;
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.completionBlock = completionHandler;
    }
    return self;
}

- (void)initializationDidComplete
{
    [self.parentAdapter log: @"HyprMX SDK Initialized"];
    
    if ( self.completionBlock )
    {
        self.completionBlock(MAAdapterInitializationStatusInitializedSuccess, nil);
        self.completionBlock = nil;
        
        self.parentAdapter.initializationDelegate = nil;
    }
}

- (void)initializationFailed
{
    [self.parentAdapter log: @"HyprMX SDK failed to initialize"];
    
    if ( self.completionBlock )
    {
        self.completionBlock(MAAdapterInitializationStatusInitializedFailure, nil);
        self.completionBlock = nil;
        
        self.parentAdapter.initializationDelegate = nil;
    }
}

@end

@implementation ALHyprMXMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALHyprMXMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidLoad:(HyprMXBannerView *)bannerView
{
    [self.parentAdapter log: @"AdView loaded"];
    [self.delegate didLoadAdForAdView: bannerView];
    [self.delegate didDisplayAdViewAd];
}

- (void)adFailedToLoad:(HyprMXBannerView *)bannerView error:(NSError *)error
{
    [self.parentAdapter log: @"AdView failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALHyprMXMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)adWasClicked:(HyprMXBannerView *)bannerView
{
    [self.parentAdapter log: @"AdView clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)adDidOpen:(HyprMXBannerView *)bannerView
{
    [self.parentAdapter log: @"AdView expanded"]; // Pretty much StoreKit presented
    [self.delegate didExpandAdViewAd];
}

- (void)adDidClose:(HyprMXBannerView *)bannerView
{
    [self.parentAdapter log: @"AdView collapse"]; // Pretty much StoreKit dismissed
    [self.delegate didCollapseAdViewAd];
}

- (void)adWillLeaveApplication:(HyprMXBannerView *)bannerView
{
    [self.parentAdapter log: @"AdView will leave application"];
}

@end

@implementation ALHyprMXMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALHyprMXMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adAvailableForPlacement:(HyprMXPlacement *)placement
{
    [self.parentAdapter log: @"Interstitial ad loaded: %@", placement.placementName];
    [self.delegate didLoadInterstitialAd];
}

- (void)adNotAvailableForPlacement:(HyprMXPlacement *)placement
{
    [self.parentAdapter log: @"Interstitial failed to load: %@", placement.placementName];
    
    MAAdapterError *adapterError = [ALHyprMXMediationAdapter toMaxError: NO_FILL message: nil];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)adExpiredForPlacement:(HyprMXPlacement *)placement
{
    [self.parentAdapter log: @"Interstitial expired: %@", placement.placementName];
}

- (void)adWillStartForPlacement:(HyprMXPlacement *)placement
{
    [self.parentAdapter log: @"Interstitial did show: %@", placement.placementName];
    [self.delegate didDisplayInterstitialAd];
}

- (void)adDidCloseForPlacement:(HyprMXPlacement *)placement didFinishAd:(BOOL)finished
{
    [self.parentAdapter log: @"Interstitial ad hidden with finshed state: %d for placement: %@", finished, placement.placementName];
    [self.delegate didHideInterstitialAd];
}

- (void)adDisplayErrorForPlacement:(HyprMXPlacement *)placement error:(HyprMXError)hyprMXError
{
    [self.parentAdapter log: @"Interstitial failed to display with error: %d for placement: %@", hyprMXError, placement.placementName];
    
    MAAdapterError *adapterError = [ALHyprMXMediationAdapter toMaxError: hyprMXError message: nil];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

@end

@implementation ALHyprMXMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALHyprMXMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adAvailableForPlacement:(HyprMXPlacement *)placement
{
    [self.parentAdapter log: @"Rewarded ad loaded: %@", placement.placementName];
    [self.delegate didLoadRewardedAd];
}

- (void)adNotAvailableForPlacement:(HyprMXPlacement *)placement
{
    [self.parentAdapter log: @"Rewarded ad failed to load: %@", placement.placementName];
    
    MAAdapterError *adapterError = [ALHyprMXMediationAdapter toMaxError: NO_FILL message: nil];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)adExpiredForPlacement:(HyprMXPlacement *)placement
{
    [self.parentAdapter log: @"Rewarded ad expired: %@", placement.placementName];
}

- (void)adWillStartForPlacement:(HyprMXPlacement *)placement
{
    [self.parentAdapter log: @"Rewarded ad did show: %@", placement.placementName];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)adDidCloseForPlacement:(HyprMXPlacement *)placement didFinishAd:(BOOL)finished
{
    [self.delegate didCompleteRewardedAdVideo];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden with finshed state: %d for placement: %@", finished, placement.placementName];
    [self.delegate didHideRewardedAd];
}

- (void)adDisplayErrorForPlacement:(HyprMXPlacement *)placement error:(HyprMXError)hyprMXError
{
    [self.parentAdapter log: @"Rewarded ad failed to display with error: %d, for placement: %@", hyprMXError, placement.placementName];
    
    MAAdapterError *adapterError = [ALHyprMXMediationAdapter toMaxError: hyprMXError message: nil];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)adDidRewardForPlacement:(HyprMXPlacement *)placement rewardName:(NSString *)rewardName rewardValue:(NSInteger)rewardValue
{
    [self.parentAdapter log: @"Rewarded ad for placement: %@ granted reward with rewardName: %@, rewardValue: %ld", placement.placementName, rewardName, (long)rewardValue];
    self.grantedReward = YES;
}

@end
