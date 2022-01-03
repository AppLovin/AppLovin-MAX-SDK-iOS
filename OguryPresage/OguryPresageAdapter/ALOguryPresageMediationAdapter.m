//
//  ALOguryPresageMediationAdapter.m
//  AppLovinSDK
//
//  Created by Ritam Sarmah on 1/14/21.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALOguryPresageMediationAdapter.h"
#import <OguryAds/OguryAds.h>
#import <OguryChoiceManager/OguryChoiceManager.h>

#define ADAPTER_VERSION @"2.5.1.0"

@interface ALOguryPresageMediationAdapterInterstitialDelegate : NSObject<OguryAdsInterstitialDelegate>
@property (nonatomic,   weak) ALOguryPresageMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
@property (nonatomic,   copy) NSString *adUnitIdentifier;
- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate adUnitIdentifier:(NSString *)adUnitIdentifier;
@end

@interface ALOguryPresageMediationAdapterRewardedAdDelegate : NSObject<OguryAdsOptinVideoDelegate>
@property (nonatomic,   weak) ALOguryPresageMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic,   copy) NSString *adUnitIdentifier;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALOguryPresageMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate adUnitIdentifier:(NSString *)adUnitIdentifier;
@end

@interface ALOguryPresageMediationAdapter()

// Interstitial
@property (nonatomic, strong) OguryAdsInterstitial *interstitialAd;
@property (nonatomic, strong) ALOguryPresageMediationAdapterInterstitialDelegate *interstitialDelegate;

// Rewarded
@property (nonatomic, strong) OguryAdsOptinVideo *rewardedAd;
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
        
        // Note: Ogury has initialization callback, but they do not accurately provide errors for failure (e.g., invalid asset key), so we won't use it for now
        [[OguryAds shared] setupWithAssetKey: assetKey andCompletionHandler:^(NSError *_Nullable error)
         {
            if ( error )
            {
                [self log: @"Ogury setup failed with error: %@", error];
                
                ALOguryPresageInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALOguryPresageInitializationStatus, error.localizedDescription);
                
                return;
            }
            
            [self log: @"Ogury setup successful"];
            
            ALOguryPresageInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            completionHandler(ALOguryPresageInitializationStatus, nil);
        }];
    }
    else
    {
        completionHandler(ALOguryPresageInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [[OguryAds shared] sdkVersion];
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

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *adUnitId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial for ad unit id: %@", adUnitId];
    
    self.interstitialAd = [[OguryAdsInterstitial alloc] initWithAdUnitID: adUnitId];
    self.interstitialDelegate = [[ALOguryPresageMediationAdapterInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate adUnitIdentifier: adUnitId];
    self.interstitialAd.interstitialDelegate = self.interstitialDelegate;
    
    // Update user consent before loading
    [self updateUserConsent: parameters];
    
    if ( [self.interstitialAd isLoaded] )
    {
        [self log: @"Ad is available already"];
        [delegate didLoadInterstitialAd];
    }
    else
    {
        [self.interstitialAd load];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *adUnitId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad: %@...", adUnitId];
    
    if ( [self.interstitialAd isLoaded] )
    {
        self.showing = YES;
        [self.interstitialAd showAdInViewController: [ALUtils topViewControllerFromKeyWindow]];
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
    
    self.rewardedAd = [[OguryAdsOptinVideo alloc] initWithAdUnitID: adUnitId];
    self.rewardedAdDelegate = [[ALOguryPresageMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate adUnitIdentifier: adUnitId];
    self.rewardedAd.optInVideoDelegate = self.rewardedAdDelegate;
    
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
        [self.rewardedAd showAdInViewController: [ALUtils topViewControllerFromKeyWindow]];
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

+ (MAAdapterError *)toMaxError:(OguryAdsErrorType)oguryError
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    // Ogury iOS SDK currently does not provide error messages, so we're setting them manually
    // NOTE: SDK has no error code for noFill, instead has respective adNotAvailable delegate method
    
    // Error messages copied from https://ogury-ltd.gitbook.io/ios/ad-formats/interstitial-ad#error-codes
    NSString *thirdPartySdkErrorMessage;
    switch ( oguryError )
    {
        case OguryAdsErrorLoadFailed:
            // We are not sure what kind of load error it is - may be misconfigured ad unit id, et al...
            adapterError = MAAdapterError.unspecified;
            thirdPartySdkErrorMessage = @"The ad failed to load for an unknown reason.";
            break;
        case OguryAdsErrorNoInternetConnection:
            adapterError = MAAdapterError.noConnection;
            thirdPartySdkErrorMessage = @"The device has no Internet connection. Try again when the device is connected to Internet again.";
            break;
        case OguryAdsErrorAdDisable:
            adapterError = MAAdapterError.invalidConfiguration;
            thirdPartySdkErrorMessage = @"Ad serving has been disabled for this placement/application.";
            break;
        case OguryAdsErrorProfigNotSynced:
            adapterError = MAAdapterError.invalidConfiguration;
            thirdPartySdkErrorMessage = @"An internal SDK error occurred.";
            break;
        case OguryAdsErrorAdExpired:
            adapterError = MAAdapterError.adExpiredError;
            thirdPartySdkErrorMessage = @"The loaded ad is expired. You must call the show method within 4 hours after the load.";
            break;
        case OguryAdsErrorSdkInitNotCalled:
            adapterError = MAAdapterError.notInitialized;
            thirdPartySdkErrorMessage = @"The setup method has not been called before a call to the load or show methods.";
            break;
        case OguryAdsErrorAnotherAdAlreadyDisplayed:
            adapterError = MAAdapterError.invalidLoadState;
            thirdPartySdkErrorMessage = @"Another ad is already displayed on the screen.";
            break;
        case OguryAdsErrorCantShowAdsInPresentingViewController:
            adapterError = MAAdapterError.internalError;
            thirdPartySdkErrorMessage = @"Currently a ViewController is being presented and it is preventing the ad from displaying.";
            break;
        case OguryAdsErrorUnknown:
            adapterError = MAAdapterError.unspecified;
            thirdPartySdkErrorMessage = @"Unknown error type.";
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: oguryError
               thirdPartySdkErrorMessage: thirdPartySdkErrorMessage];
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

- (void)oguryAdsInterstitialAdLoaded
{
    [self.parentAdapter log: @"Interstitial loaded: %@", self.adUnitIdentifier];
    [self.delegate didLoadInterstitialAd];
}

- (void)oguryAdsInterstitialAdNotAvailable
{
    [self.parentAdapter log: @"Interstitial ad NO FILL'd: %@", self.adUnitIdentifier];
    [self.delegate didFailToLoadInterstitialAdWithError: MAAdapterError.noFill];
}

- (void)oguryAdsInterstitialAdDisplayed
{
    [self.parentAdapter log: @"Interstitial shown: %@", self.adUnitIdentifier];
}

- (void)oguryAdsInterstitialAdOnAdImpression
{
    [self.parentAdapter log: @"Interstitial triggered impression: %@", self.adUnitIdentifier];
    [self.delegate didDisplayInterstitialAd];
}

- (void)oguryAdsInterstitialAdClicked
{
    [self.parentAdapter log: @"Interstitial clicked: %@", self.adUnitIdentifier];
    [self.delegate didClickInterstitialAd];
}

- (void)oguryAdsInterstitialAdClosed
{
    [self.parentAdapter log: @"Interstitial hidden: %@", self.adUnitIdentifier];
    [self.delegate didHideInterstitialAd];
}

- (void)oguryAdsInterstitialAdError:(OguryAdsErrorType)errorType
{
    MAAdapterError *maxError = [ALOguryPresageMediationAdapter toMaxError: errorType];
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

- (void)oguryAdsOptinVideoAdLoaded
{
    [self.parentAdapter log: @"Rewarded ad loaded: %@", self.adUnitIdentifier];
    [self.delegate didLoadRewardedAd];
}

- (void)oguryAdsOptinVideoAdNotAvailable
{
    [self.parentAdapter log: @"Rewarded ad NO FILL'd: %@", self.adUnitIdentifier];
    [self.delegate didFailToLoadRewardedAdWithError: MAAdapterError.noFill];
}

- (void)oguryAdsOptinVideoAdDisplayed
{
    [self.parentAdapter log: @"Rewarded ad shown: %@", self.adUnitIdentifier];
}

- (void)oguryAdsOptinVideoAdOnAdImpression
{
    [self.parentAdapter log: @"Rewarded ad triggered impression: %@", self.adUnitIdentifier];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)oguryAdsOptinVideoAdClicked
{
    [self.parentAdapter log: @"Rewarded ad clicked: %@", self.adUnitIdentifier];
    [self.delegate didClickRewardedAd];
}

- (void)oguryAdsOptinVideoAdClosed
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

- (void)oguryAdsOptinVideoAdRewarded:(OGARewardItem *)item
{
    [self.parentAdapter log: @"Rewarded ad (%@) granted reward with rewardName: %@, rewardValue: %@", self.adUnitIdentifier, item.rewardName, item.rewardValue];
    self.grantedReward = YES;
}

- (void)oguryAdsOptinVideoAdError:(OguryAdsErrorType)errorType
{
    MAAdapterError *maxError = [ALOguryPresageMediationAdapter toMaxError: errorType];
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
