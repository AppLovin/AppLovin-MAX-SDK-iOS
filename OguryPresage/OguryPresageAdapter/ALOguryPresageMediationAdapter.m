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

#define ADAPTER_VERSION @"2.6.1.0"

@interface ALOguryPresageMediationAdapterInterstitialDelegate : NSObject<OguryInterstitialAdDelegate>
@property (nonatomic,   weak) ALOguryPresageMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
@property (nonatomic,   copy) NSString *adUnitIdentifier;
- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate adUnitIdentifier:(NSString *)adUnitIdentifier;
@end

@interface ALOguryPresageMediationAdapterRewardedAdDelegate : NSObject<OguryOptinVideoAdDelegate>
@property (nonatomic,   weak) ALOguryPresageMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic,   copy) NSString *adUnitIdentifier;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate adUnitIdentifier:(NSString *)adUnitIdentifier;
@end

@interface ALOguryPresageMediationAdapter()

// Interstitial
@property (nonatomic, strong) OguryInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALOguryPresageMediationAdapterInterstitialDelegate *interstitialDelegate;

// Rewarded
@property (nonatomic, strong) OguryOptinVideoAd *rewardedAd;
@property (nonatomic, strong) ALOguryPresageMediationAdapterRewardedAdDelegate *rewardedAdDelegate;

// State to track if we are currently showing an ad. Unfortunately, Ogury's SDK's onAdError(...) callback is invoked on ad load and ad display errors (including ad expiration)
@property (nonatomic, assign, getter=isShowing) BOOL showing;

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

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [ALOguryPresageInitialized compareAndSet: NO update: YES] )
    {
        ALOguryPresageInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *assetKey = [parameters.serverParameters al_stringForKey: @"asset_key"];
        [self log: @"Initializing Ogury with asset key: %@...", assetKey];
        
        // Must pass the user consent before initializing SDK for personalized ads
        [self updateUserConsent: parameters];
        
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
    self.interstitialAd = nil;
    self.interstitialDelegate = nil;
    
    self.rewardedAd = nil;
    self.rewardedAdDelegate = nil;
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
    NSString *adUnitId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@interstitial ad \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", adUnitId];
    
    self.interstitialAd = [[OguryInterstitialAd alloc] initWithAdUnitId: adUnitId];
    self.interstitialDelegate = [[ALOguryPresageMediationAdapterInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate adUnitIdentifier: adUnitId];
    self.interstitialAd.delegate = self.interstitialDelegate;
    
    // Update user consent before loading
    [self updateUserConsent: parameters];
    
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
    NSString *adUnitId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad: %@...", adUnitId];
    
    if ( [self.interstitialAd isLoaded] )
    {
        self.showing = YES;
        
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
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *adUnitId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad for ad unit id: %@", adUnitId];
    
    self.rewardedAd = [[OguryOptinVideoAd alloc] initWithAdUnitId: adUnitId];
    self.rewardedAdDelegate = [[ALOguryPresageMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate adUnitIdentifier: adUnitId];
    self.rewardedAd.delegate = self.rewardedAdDelegate;
    
    // Update user consent before loading
    [self updateUserConsent: parameters];
    
    if ( [self.rewardedAd isLoaded] )
    {
        [self log: @"Ad is available already"];
        [delegate didLoadRewardedAd];
    }
    else
    {
        [self.rewardedAd load];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *adUnitId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad: %@...", adUnitId];
    
    if ( [self.rewardedAd isLoaded] )
    {
        // Configure userReward from server
        [self configureRewardForParameters: parameters];
        
        self.showing = YES;
        
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
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - Shared Methods

- (void)updateUserConsent:(id<MAAdapterParameters>)parameters
{
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
        if ( hasUserConsent )
        {
            NSString *assetKey = [parameters.serverParameters al_stringForKey: @"asset_key"];
            [OguryChoiceManagerExternal setTransparencyAndConsentStatus: hasUserConsent.boolValue origin: @"CUSTOM" assetKey: assetKey];
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

+ (OguryAdsBannerSize *)sizeFromAdFormat:(MAAdFormat *)adFormat
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

- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate adUnitIdentifier:(NSString *)adUnitIdentifier
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.adUnitIdentifier = adUnitIdentifier;
    }
    return self;
}

- (void)didLoadOguryInterstitialAd:(OguryInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial loaded: %@", self.adUnitIdentifier];
    [self.delegate didLoadInterstitialAd];
}

- (void)didDisplayOguryInterstitialAd:(OguryInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial shown: %@", self.adUnitIdentifier];
}

- (void)didTriggerImpressionOguryInterstitialAd:(OguryInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial triggered impression: %@", self.adUnitIdentifier];
    [self.delegate didDisplayInterstitialAd];
}

- (void)didClickOguryInterstitialAd:(OguryInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial clicked: %@", self.adUnitIdentifier];
    [self.delegate didClickInterstitialAd];
}

- (void)didCloseOguryInterstitialAd:(OguryInterstitialAd *)interstitial
{
    [self.parentAdapter log: @"Interstitial hidden: %@", self.adUnitIdentifier];
    [self.delegate didHideInterstitialAd];
}

- (void)didFailOguryInterstitialAdWithError:(OguryError *)error forAd:(OguryInterstitialAd *)interstitial
{
    MAAdapterError *maxError = [ALOguryPresageMediationAdapter toMaxError: error];
    if ( [self.parentAdapter isShowing] )
    {
        [self.parentAdapter log: @"Interstitial (%@) failed to show with error: %@", self.adUnitIdentifier, maxError];
        [self.delegate didFailToDisplayInterstitialAdWithError: maxError];
    }
    else
    {
        [self.parentAdapter log: @"Interstitial (%@) failed to load with error: %@", self.adUnitIdentifier, maxError];
        [self.delegate didFailToLoadInterstitialAdWithError: maxError];
    }
}

@end

#pragma mark - Rewarded Delegate

@implementation ALOguryPresageMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate adUnitIdentifier:(NSString *)adUnitIdentifier
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.adUnitIdentifier = adUnitIdentifier;
    }
    return self;
}

- (void)didLoadOguryOptinVideoAd:(OguryOptinVideoAd *)optinVideo
{
    [self.parentAdapter log: @"Rewarded ad loaded: %@", self.adUnitIdentifier];
    [self.delegate didLoadRewardedAd];
}

- (void)didDisplayOguryOptinVideoAd:(OguryOptinVideoAd *)optinVideo
{
    [self.parentAdapter log: @"Rewarded ad shown: %@", self.adUnitIdentifier];
}

- (void)didTriggerImpressionOguryOptinVideoAd:(OguryOptinVideoAd *)optinVideo
{
    [self.parentAdapter log: @"Rewarded ad triggered impression: %@", self.adUnitIdentifier];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)didClickOguryOptinVideoAd:(OguryOptinVideoAd *)optinVideo
{
    [self.parentAdapter log: @"Rewarded ad clicked: %@", self.adUnitIdentifier];
    [self.delegate didClickRewardedAd];
}

- (void)didCloseOguryOptinVideoAd:(OguryOptinVideoAd *)optinVideo
{
    [self.delegate didCompleteRewardedAdVideo];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden: %@", self.adUnitIdentifier];
    [self.delegate didHideRewardedAd];
}

- (void)didRewardOguryOptinVideoAdWithItem:(OGARewardItem *)item forAd:(OguryOptinVideoAd *)optinVideo
{
    [self.parentAdapter log: @"Rewarded ad (%@) granted reward with rewardName: %@, rewardValue: %@", self.adUnitIdentifier, item.rewardName, item.rewardValue];
    self.grantedReward = YES;
}

- (void)didFailOguryOptinVideoAdWithError:(OguryError *)error forAd:(OguryOptinVideoAd *)optinVideo
{
    MAAdapterError *maxError = [ALOguryPresageMediationAdapter toMaxError: error];
    if ( [self.parentAdapter isShowing] )
    {
        [self.parentAdapter log: @"Rewarded ad (%@) failed to show with error: %@", self.adUnitIdentifier, maxError];
        [self.delegate didFailToDisplayRewardedAdWithError: maxError];
    }
    else
    {
        [self.parentAdapter log: @"Rewarded ad (%@) failed to load with error: %@", self.adUnitIdentifier, maxError];
        [self.delegate didFailToLoadRewardedAdWithError: maxError];
    }
}

@end
