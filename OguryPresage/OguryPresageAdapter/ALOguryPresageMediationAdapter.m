//
//  ALOguryPresageMediationAdapter.m
//  AppLovinSDK
//
//  Created by Ritam Sarmah on 1/14/21.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALOguryPresageMediationAdapter.h"
#import <OgurySdk/Ogury.h>
#import <OguryAds/OguryAds.h>
#import <OguryChoiceManager/OguryChoiceManager.h>

#define ADAPTER_VERSION @"4.4.0.1"

@interface ALOguryPresageMediationAdapterInterstitialDelegate : NSObject <OguryInterstitialAdDelegate>
@property (nonatomic,   weak) ALOguryPresageMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *placementIdentifier;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter placementIdentifier:(NSString *)placementIdentifier andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALOguryPresageMediationAdapterRewardedAdDelegate : NSObject <OguryOptinVideoAdDelegate>
@property (nonatomic,   weak) ALOguryPresageMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *placementIdentifier;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter placementIdentifier:(NSString *)placementIdentifier andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALOguryPresageMediationAdapterAdViewDelegate : NSObject <OguryBannerAdDelegate>
@property (nonatomic,   weak) ALOguryPresageMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *placementIdentifier;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter placementIdentifier:(NSString *)placementIdentifier andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALOguryPresageMediationAdapter ()

// Interstitial
@property (nonatomic, strong) OguryInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALOguryPresageMediationAdapterInterstitialDelegate *interstitialDelegate;

// Rewarded
@property (nonatomic, strong) OguryOptinVideoAd *rewardedAd;
@property (nonatomic, strong) ALOguryPresageMediationAdapterRewardedAdDelegate *rewardedAdDelegate;

// Ad View
@property (nonatomic, strong) OguryBannerAd *adView;
@property (nonatomic, strong) ALOguryPresageMediationAdapterAdViewDelegate *adViewDelegate;

// State to track if ad load finished. Unfortunately, Ogury's SDK's onAdError(...) callback is invoked on ad load and ad display errors (including ad expiration)
@property (nonatomic, assign, getter=isFinishedLoading) BOOL finishedLoading;

@end

@implementation ALOguryPresageMediationAdapter
static ALAtomicBoolean *ALOguryPresageInitialized;
static MAAdapterInitializationStatus ALOguryPresageInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALOguryPresageInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALOguryPresageInitialized compareAndSet: NO update: YES] )
    {
        ALOguryPresageInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *assetKey = [parameters.serverParameters al_stringForKey: @"asset_key"];
        [self log: @"Initializing Ogury with asset key: %@...", assetKey];
        
        OguryConfigurationBuilder *configurationBuilder = [[OguryConfigurationBuilder alloc] initWithAssetKey: assetKey];
        [Ogury startWithConfiguration: [configurationBuilder build]];
        
        [self log: @"Ogury setup successful"];
        
        ALOguryPresageInitializationStatus = MAAdapterInitializationStatusInitializedUnknown;
    }
    
    completionHandler(ALOguryPresageInitializationStatus, nil);
}

// Return version of the main Ogury SDK. Previous version of the adapater returned version of the Ogury Ads SDK.
- (NSString *)SDKVersion
{
    return [Ogury getSdkVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialDelegate.delegate = nil;
    self.interstitialDelegate = nil;
    
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdDelegate.delegate = nil;
    self.rewardedAdDelegate = nil;
    
    [self.adView destroy];
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewDelegate.delegate = nil;
    self.adViewDelegate = nil;
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *signal = [OguryTokenService getBidderToken];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@interstitial ad \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", placementIdentifier];
    
    self.interstitialAd = [[OguryInterstitialAd alloc] initWithAdUnitId: placementIdentifier mediation: [[OguryMediation alloc] initWithName: @"AppLovin MAX" version: ALSdk.version]];
    self.interstitialDelegate = [[ALOguryPresageMediationAdapterInterstitialDelegate alloc] initWithParentAdapter: self placementIdentifier: placementIdentifier andNotify: delegate];
    self.interstitialAd.delegate = self.interstitialDelegate;
    
    if ( [self.interstitialAd isLoaded] )
    {
        [self log: @"Ad is available already"];
        [delegate didLoadInterstitialAd];
    }
    else
    {
        if ( [bidResponse al_isValidString] )
        {
            [self.interstitialAd loadWithAdMarkup: bidResponse];
        }
        else
        {
            [self.interstitialAd load];
        }
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad: %@...", placementIdentifier];
    
    if ( [self.interstitialAd isLoaded] )
    {
        self.finishedLoading = YES;
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [self.interstitialAd showAdInViewController: presentingViewController];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205
                                                                             errorString: @"Ad Display Failed"
                                                                  thirdPartySdkErrorCode: 0
                                                               thirdPartySdkErrorMessage: @"Interstitial ad not ready"]];
#pragma clang diagnostic pop
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@rewarded ad: %@...", [bidResponse al_isValidString] ? @"bidding " : @"", placementIdentifier];
    
    self.rewardedAd = [[OguryOptinVideoAd alloc] initWithAdUnitId: placementIdentifier mediation: [[OguryMediation alloc] initWithName: @"AppLovin MAX" version: ALSdk.version]];
    self.rewardedAdDelegate = [[ALOguryPresageMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self placementIdentifier: placementIdentifier andNotify: delegate];
    self.rewardedAd.delegate = self.rewardedAdDelegate;
    
    if ( [self.rewardedAd isLoaded] )
    {
        [self log: @"Ad is available already"];
        [delegate didLoadRewardedAd];
    }
    else
    {
        if ( [bidResponse al_isValidString] )
        {
            [self.rewardedAd loadWithAdMarkup: bidResponse];
        }
        else
        {
            [self.rewardedAd load];
        }
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad: %@...", placementIdentifier];
    
    if ( [self.rewardedAd isLoaded] )
    {
        // Configure userReward from server
        [self configureRewardForParameters: parameters];
        
        self.finishedLoading = YES;
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [self.rewardedAd showAdInViewController: presentingViewController];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithCode: -4205
                                                                         errorString: @"Ad Display Failed"
                                                              thirdPartySdkErrorCode: 0
                                                           thirdPartySdkErrorMessage: @"Rewarded ad not ready"]];
#pragma clang diagnostic pop
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@%@ ad: %@...", [bidResponse al_isValidString] ? @"bidding " : @"", adFormat.label, placementIdentifier];
    
    self.adView = [[OguryBannerAd alloc] initWithAdUnitId: placementIdentifier mediation: [[OguryMediation alloc] initWithName: @"AppLovin MAX" version: ALSdk.version]];
    self.adViewDelegate = [[ALOguryPresageMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self placementIdentifier: placementIdentifier andNotify: delegate];
    self.adView.delegate = self.adViewDelegate;
    
    if ( [self.adView isLoaded] )
    {
        [self log: @"Ad is available already"];
        [delegate didLoadAdForAdView: self.adView];
    }
    else
    {
        if ( [bidResponse al_isValidString] )
        {
            [self.adView loadWithAdMarkup: bidResponse size: [self sizeFromAdFormat: adFormat]];
        }
        else
        {
            [self.adView loadWithSize: [self sizeFromAdFormat: adFormat]];
        }
    }
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(OguryError *)oguryError
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    // Ogury iOS SDK currently does not provide error messages, so we're setting them manually
    // NOTE: SDK has no error code for noFill, instead has respective adNotAvailable delegate method
    
    // Error messages copied from https://ogury-ltd.gitbook.io/ios/ad-formats/interstitial-ad#error-codes
    switch ( oguryError.code )
    {
        case OguryAdsNotLoadedError:
            // We are not sure what kind of load error it is - may be misconfigured ad unit id, et al...
            adapterError = MAAdapterError.unspecified;
            break;
        case OguryCoreErrorTypeNoInternetConnection:
            adapterError = MAAdapterError.noConnection;
            break;
        case OguryAdsAdDisabledError:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case OguryAdsProfigNotSyncedError:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case OguryAdsAdExpiredError:
            adapterError = MAAdapterError.adExpiredError;
            break;
        case OguryAdsSdkInitNotCalledError:
            adapterError = MAAdapterError.notInitialized;
            break;
        case OguryAdsAnotherAdAlreadyDisplayedError:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case OguryAdsCantShowAdsInPresentingViewControllerError:
            adapterError = MAAdapterError.internalError;
            break;
        case OguryAdsAssetKeyNotValidError:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case OguryAdsNotAvailableError:
            adapterError = MAAdapterError.noFill;
            break;
        case OguryAdsUnknownError:
            adapterError = MAAdapterError.unspecified;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: oguryError.code
               thirdPartySdkErrorMessage: oguryError.localizedDescription];
#pragma clang diagnostic pop
}

- (OguryAdsBannerSize *)sizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader )
    {
        return OguryAdsBannerSize.small_banner_320x50;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return OguryAdsBannerSize.mpu_300x250;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format: %@", adFormat];
        return OguryAdsBannerSize.small_banner_320x50;
    }
}

@end

#pragma mark - Interstitial Delegate

@implementation ALOguryPresageMediationAdapterInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter placementIdentifier:(NSString *)placementIdentifier andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementIdentifier = placementIdentifier;
        self.delegate = delegate;
    }
    return self;
}

- (void)didLoadOguryInterstitialAd:(OguryInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial loaded: %@", self.placementIdentifier];
    [self.delegate didLoadInterstitialAd];
}

- (void)didDisplayOguryInterstitialAd:(OguryInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial shown: %@", self.placementIdentifier];
}

- (void)didTriggerImpressionOguryInterstitialAd:(OguryInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial triggered impression: %@", self.placementIdentifier];
    [self.delegate didDisplayInterstitialAd];
}

- (void)didClickOguryInterstitialAd:(OguryInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial clicked: %@", self.placementIdentifier];
    [self.delegate didClickInterstitialAd];
}

- (void)didCloseOguryInterstitialAd:(OguryInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial hidden: %@", self.placementIdentifier];
    [self.delegate didHideInterstitialAd];
}

- (void)didFailOguryInterstitialAdWithError:(OguryError *)error forAd:(OguryInterstitialAd *)interstitial
{
    if ( [self.parentAdapter isFinishedLoading] )
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        MAAdapterError *maxError = [MAAdapterError errorWithCode: -4205
                                                     errorString: @"Ad Display Failed"
                                          thirdPartySdkErrorCode: error.code
                                       thirdPartySdkErrorMessage: error.localizedDescription];
#pragma clang diagnostic pop
        
        [self.parentAdapter log: @"Interstitial (%@) failed to show with error: %@", self.placementIdentifier, maxError];
        [self.delegate didFailToDisplayInterstitialAdWithError: maxError];
    }
    else
    {
        MAAdapterError *maxError = [ALOguryPresageMediationAdapter toMaxError: error];
        [self.parentAdapter log: @"Interstitial (%@) failed to load with error: %@", self.placementIdentifier, maxError];
        [self.delegate didFailToLoadInterstitialAdWithError: maxError];
    }
}

@end

#pragma mark - Rewarded Delegate

@implementation ALOguryPresageMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter placementIdentifier:(NSString *)placementIdentifier andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementIdentifier = placementIdentifier;
        self.delegate = delegate;
    }
    return self;
}

- (void)didLoadOguryOptinVideoAd:(OguryOptinVideoAd *)optinVideo
{
    [self.parentAdapter log: @"Rewarded ad loaded: %@", self.placementIdentifier];
    [self.delegate didLoadRewardedAd];
}

- (void)didDisplayOguryOptinVideoAd:(OguryOptinVideoAd *)optinVideo
{
    [self.parentAdapter log: @"Rewarded ad shown: %@", self.placementIdentifier];
}

- (void)didTriggerImpressionOguryOptinVideoAd:(OguryOptinVideoAd *)optinVideo
{
    [self.parentAdapter log: @"Rewarded ad triggered impression: %@", self.placementIdentifier];
    [self.delegate didDisplayRewardedAd];
}

- (void)didClickOguryOptinVideoAd:(OguryOptinVideoAd *)optinVideo
{
    [self.parentAdapter log: @"Rewarded ad clicked: %@", self.placementIdentifier];
    [self.delegate didClickRewardedAd];
}

- (void)didCloseOguryOptinVideoAd:(OguryOptinVideoAd *)optinVideo
{ 
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden: %@", self.placementIdentifier];
    [self.delegate didHideRewardedAd];
}

- (void)didRewardOguryOptinVideoAdWithItem:(OGARewardItem *)item forAd:(OguryOptinVideoAd *)optinVideo
{
    [self.parentAdapter log: @"Rewarded ad (%@) granted reward with rewardName: %@, rewardValue: %@", self.placementIdentifier, item.rewardName, item.rewardValue];
    self.grantedReward = YES;
}

- (void)didFailOguryOptinVideoAdWithError:(OguryError *)error forAd:(OguryOptinVideoAd *)optinVideo
{
    if ( [self.parentAdapter isFinishedLoading] )
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        MAAdapterError *maxError = [MAAdapterError errorWithCode: -4205
                                                     errorString: @"Ad Display Failed"
                                          thirdPartySdkErrorCode: error.code
                                       thirdPartySdkErrorMessage: error.localizedDescription];
#pragma clang diagnostic pop
        
        [self.parentAdapter log: @"Rewarded ad (%@) failed to show with error: %@", self.placementIdentifier, maxError];
        [self.delegate didFailToDisplayRewardedAdWithError: maxError];
    }
    else
    {
        MAAdapterError *maxError = [ALOguryPresageMediationAdapter toMaxError: error];
        [self.parentAdapter log: @"Rewarded ad (%@) failed to load with error: %@", self.placementIdentifier, maxError];
        [self.delegate didFailToLoadRewardedAdWithError: maxError];
    }
}

@end

@implementation ALOguryPresageMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter placementIdentifier:(NSString *)placementIdentifier andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementIdentifier = placementIdentifier;
        self.delegate = delegate;
    }
    return self;
}

- (void)didLoadOguryBannerAd:(OguryBannerAd *)banner
{
    [self.parentAdapter log: @"AdView loaded: %@", self.placementIdentifier];
    self.parentAdapter.finishedLoading = YES;
    [self.delegate didLoadAdForAdView: banner];
}

- (void)didDisplayOguryBannerAd:(OguryBannerAd *)banner
{
    [self.parentAdapter log: @"AdView shown: %@", self.placementIdentifier];
}

- (void)didTriggerImpressionOguryBannerAd:(OguryBannerAd *)banner
{
    [self.parentAdapter log: @"AdView triggered impression: %@", self.placementIdentifier];
    [self.delegate didDisplayAdViewAd];
}

- (void)didClickOguryBannerAd:(OguryBannerAd *)banner
{
    [self.parentAdapter log: @"AdView clicked: %@", self.placementIdentifier];
    [self.delegate didClickAdViewAd];
}

- (void)didCloseOguryBannerAd:(OguryBannerAd *)banner
{
    [self.parentAdapter log: @"AdView closed: %@", self.placementIdentifier];
}

- (void)didFailOguryBannerAdWithError:(OguryError *)error forAd:(OguryBannerAd *)banner
{
    if ( [self.parentAdapter isFinishedLoading] )
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        MAAdapterError *maxError = [MAAdapterError errorWithCode: -4205
                                                     errorString: @"Ad Display Failed"
                                          thirdPartySdkErrorCode: error.code
                                       thirdPartySdkErrorMessage: error.localizedDescription];
#pragma clang diagnostic pop
        
        [self.parentAdapter log: @"AdView (%@) failed to show with error: %@", self.placementIdentifier, maxError];
        [self.delegate didFailToDisplayAdViewAdWithError: maxError];
    }
    else
    {
        MAAdapterError *maxError = [ALOguryPresageMediationAdapter toMaxError: error];
        [self.parentAdapter log: @"AdView (%@) failed to load with error: %@", self.placementIdentifier, maxError];
        [self.delegate didFailToLoadAdViewAdWithError: maxError];
    }
}

// This allows clicks on banners using modal view controller (Ex: banner ads using mediation debugger)
// (https://ogury-ltd.gitbook.io/ios/ad-formats/banner-ad#using-modal-view-controller)
- (UIViewController *)presentingViewControllerForOguryAdsBannerAd:(OguryBannerAd *)banner
{
    return [ALUtils topViewControllerFromKeyWindow];
}

@end
