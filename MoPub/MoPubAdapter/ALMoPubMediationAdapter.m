//
//  ALMoPubMediationAdapter.m
//  AppLovinSDK
//
//  Created by Chris Cong on 1/26/21.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMoPubMediationAdapter.h"

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MoPub.h" // For raw integrations
#endif

#import "ALUtils.h"
#import "NSDictionary+ALUtils.h"
#import "NSString+ALUtils.h"

#define ADAPTER_VERSION @"5.16.2.0"

@interface ALMoPubMediationAdapterInterstitialAdDelegate : NSObject<MPInterstitialAdControllerDelegate>
@property (nonatomic,   weak) ALMoPubMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMoPubMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALMoPubMediationAdapterRewardedAdsDelegate : NSObject<MPRewardedAdsDelegate>
@property (nonatomic,   weak) ALMoPubMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALMoPubMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALMoPubMediationAdapterAdViewDelegate : NSObject<MPAdViewDelegate>
@property (nonatomic,   weak) ALMoPubMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMoPubMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALMoPubMediationAdapter()

@property (nonatomic, strong) MPInterstitialAdController *interstitial;
@property (nonatomic, strong) MPAdView *adView;

@property (nonatomic, strong) ALMoPubMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALMoPubMediationAdapterRewardedAdsDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) ALMoPubMediationAdapterAdViewDelegate *adViewAdapterDelegate;

@end

@implementation ALMoPubMediationAdapter
static ALAtomicBoolean *ALMoPubInitialized;

+ (void)initialize
{
    [super initialize];
    
    ALMoPubInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [ALMoPubInitialized compareAndSet: NO update: YES] )
    {
        NSString *adUnitIdentifier = [parameters.serverParameters al_stringForKey: @"init_ad_unit_id"];
        
        [self log: @"Initializing MoPub SDK with adUnitId: %@...", adUnitIdentifier];
        
        MPMoPubConfiguration *sdkConfiguration = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization: adUnitIdentifier];
        sdkConfiguration.loggingLevel = [parameters isTesting] ? MPBLogLevelDebug : MPBLogLevelInfo;
        
        [[MoPub sharedInstance] initializeSdkWithConfiguration: sdkConfiguration completion:^{
            
            [self log: @"MoPub SDK initialized"];
            
            [self updateMoPubConsent: parameters];

            completionHandler(MAAdapterInitializationStatusInitializedUnknown, nil);
        }];
    }
    else
    {
        if ( [[MoPub sharedInstance] isSdkInitialized] )
        {
            [self log: @"MoPub SDK already initialized"];
            completionHandler(MAAdapterInitializationStatusInitializedUnknown, nil);
        }
        else
        {
            [self log: @"MoPub SDK still initializing"];
            completionHandler(MAAdapterInitializationStatusInitializing, nil);
        }
    }
}

- (NSString *)SDKVersion
{
    if ( [ALMoPubInitialized get] )
    {
        return [MoPub sharedInstance].version;
    }
    else
    {
        // NOTE: Do not invoke `[MoPub sharedInstance].version` when detecting installed adapters as that will trigger crash if MoPub is not initialized after a while
        return MP_SDK_VERSION;
    }
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.interstitial.delegate = nil;
    self.interstitial = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    
    self.interstitialAdapterDelegate = nil;
    self.rewardedAdapterDelegate = nil;
    self.adViewAdapterDelegate = nil;
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *adUnitIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad: %@...", adUnitIdentifier];
    
    if ( ![[MoPub sharedInstance] isSdkInitialized] )
    {
        [self log: @"MoPub SDK is not initialized"];
        
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.notInitialized];
        return;
    }
    
    [self updateMoPubConsent: parameters];
    
    self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId: adUnitIdentifier];
    self.interstitialAdapterDelegate = [[ALMoPubMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitial.delegate = self.interstitialAdapterDelegate;
    
    [self.interstitial loadAd];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad: %@...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( [self.interstitial ready] )
    {
        [self.interstitial showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
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
    NSString *adUnitIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad: %@...", adUnitIdentifier];
    
    if ( ![[MoPub sharedInstance] isSdkInitialized] )
    {
        [self log: @"MoPub SDK is not initialized"];
        
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.notInitialized];
        return;
    }
    
    [self updateMoPubConsent: parameters];
    
    self.rewardedAdapterDelegate = [[ALMoPubMediationAdapterRewardedAdsDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    [MPRewardedAds setDelegate: self.rewardedAdapterDelegate forAdUnitId: adUnitIdentifier];
    
    if ( [MPRewardedAds hasAdAvailableForAdUnitID: adUnitIdentifier] )
    {
        [self log: @"Rewarded ad already available"];
        [delegate didLoadRewardedAd];
    }
    else
    {
        [MPRewardedAds loadRewardedAdWithAdUnitID: adUnitIdentifier withMediationSettings: nil];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *adUnitIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad: %@...", adUnitIdentifier];
    
    if ( [MPRewardedAds hasAdAvailableForAdUnitID: adUnitIdentifier] )
    {
        // Configure reward from server.
        [self configureRewardForParameters: parameters];
        
        MPReward *reward = [MPRewardedAds selectedRewardForAdUnitID: adUnitIdentifier];
        [MPRewardedAds presentRewardedAdForAdUnitID: adUnitIdentifier
                                 fromViewController: [ALUtils topViewControllerFromKeyWindow]
                                         withReward: reward];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *adUnitIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading AdView ad: %@...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( ![[MoPub sharedInstance] isSdkInitialized] )
    {
        [self log: @"MoPub SDK is not initialized"];
        
        [delegate didFailToLoadAdViewAdWithError: MAAdapterError.notInitialized];
        return;
    }
    
    [self updateMoPubConsent: parameters];
    
    self.adView = [[MPAdView alloc] initWithAdUnitId: adUnitIdentifier];
    self.adView.frame = CGRectMake(0, 0, adFormat.size.width, adFormat.size.height); // this requires a specific width/size per their docs
    
    // Set delegate
    self.adViewAdapterDelegate = [[ALMoPubMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.adView.delegate = self.adViewAdapterDelegate;
    [self.adView stopAutomaticallyRefreshingContents];
    
    // Load ad
    [self.adView loadAdWithMaxAdSize: [self CGSizeFromAdFormat: adFormat]];
}

#pragma mark - Shared Methods

- (void)updateMoPubConsent:(id<MAAdapterParameters>)parameters
{
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
        if ( hasUserConsent )
        {
            if ( hasUserConsent.boolValue )
            {
                [[MoPub sharedInstance] grantConsent];
            }
            else
            {
                [[MoPub sharedInstance] revokeConsent];
            }
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

- (CGSize)CGSizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return kMPPresetMaxAdSize50Height;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return  kMPPresetMaxAdSize90Height;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return kMPPresetMaxAdSize250Height;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        
        return kMPPresetMaxAdSizeMatchFrame;
    }
}

+ (MAAdapterError *)toMaxError:(NSError *)moPubError
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    // Rewarded errors
    if ( [moPubError.domain isEqualToString: MoPubRewardedAdsSDKDomain] )
    {
        MPRewardedAdsErrorCode errorCode = (MPRewardedAdsErrorCode)moPubError.code;
        switch ( errorCode )
        {
            case MPRewardedAdErrorUnknown:
                adapterError = MAAdapterError.internalError;
                break;
            case MPRewardedAdErrorTimeout:
                adapterError = MAAdapterError.timeout;
                break;
            case MPRewardedAdErrorAdUnitWarmingUp:
            case MPRewardedAdErrorNoAdReady:
                adapterError = MAAdapterError.adNotReady;
                break;
            case MPRewardedAdErrorNoAdsAvailable:
                adapterError = MAAdapterError.noFill;
                break;
            case MPRewardedAdErrorInvalidCustomEvent:
            case MPRewardedAdErrorInvalidAdUnitID:
                adapterError = MAAdapterError.invalidConfiguration;
                break;
            case MPRewardedAdErrorMismatchingAdTypes:
                adapterError = MAAdapterError.signalCollectionNotSupported;
                break;
            case MPRewardedAdErrorAdAlreadyPlayed:
                adapterError = MAAdapterError.invalidLoadState;
                break;
            case MPRewardedAdErrorInvalidReward:
            case MPRewardedAdErrorNoRewardSelected:
                adapterError = MAAdapterError.unspecified;
                break;
        }
    }
    else // MOPUBErrorCode
    {
        MOPUBErrorCode errorCode = (MOPUBErrorCode)moPubError.code;
        switch ( errorCode )
        {
            case MOPUBErrorNoInventory:
            case MOPUBErrorAdapterHasNoInventory:
                adapterError = MAAdapterError.noFill;
                break;
            case MOPUBErrorAdUnitWarmingUp:
            case MOPUBErrorAdLoadAlreadyInProgress:
            case MOPUBErrorFullScreenAdAlreadyOnScreen:
                adapterError = MAAdapterError.invalidLoadState;
                break;
            case MOPUBErrorNetworkTimedOut:
            case MOPUBErrorAdRequestTimedOut:
                adapterError = MAAdapterError.timeout;
                break;
            case MOPUBErrorServerError:
                adapterError = MAAdapterError.serverError;
                break;
            case MOPUBErrorAdapterNotFound:
            case MOPUBErrorAdapterInvalid:
                adapterError = MAAdapterError.invalidConfiguration;
                break;
            case MOPUBErrorUnexpectedNetworkResponse:
                adapterError = MAAdapterError.badRequest;
                break;
            case MOPUBErrorHTTPResponseNot200:
                adapterError = MAAdapterError.serverError;
                break;
            case MOPUBErrorNoNetworkData:
                adapterError = MAAdapterError.noConnection;
                break;
            case MOPUBErrorSDKNotInitialized:
            case MOPUBErrorSDKInitializationInProgress:
                adapterError = MAAdapterError.notInitialized;
                break;
            case MOPUBErrorJSONSerializationFailed:
            case MOPUBErrorUnableToParseAdResponse:
            case MOPUBErrorUnableToParseJSONAdResponse:
            case MOPUBErrorVideoPlayerFailedToPlay:
            case MOPUBErrorFrameWidthNotSetForFlexibleSize:
            case MOPUBErrorFrameHeightNotSetForFlexibleSize:
            case MOPUBErrorNoHTMLToLoad:
            case MOPUBErrorNoHTMLUrlToLoad:
            case MOPUBErrorInlineNoViewGivenWhenAdLoaded:
            case MOPUBErrorViewabilityNoViewToTrack:
            case MOPUBErrorNoRenderer:
            case MOPUBErrorInvalidCustomEventClass:
            case MOPUBErrorConsentDialogAlreadyShowing:
            case MOPUBErrorNoConsentDialogLoaded:
            case MOPUBErrorAdapterFailedToLoadAd:
                adapterError = MAAdapterError.internalError;
                break;
            case MOPUBErrorTooManyRequests:
                adapterError = MAAdapterError.adFrequencyCappedError;
                break;
            case MOPUBErrorUnknown:
                adapterError = MAAdapterError.unspecified;
                break;
        }
    }
    
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: moPubError.code
               thirdPartySdkErrorMessage: moPubError.localizedDescription];
}

@end

#pragma mark - ALMoPubMediationAdapterInterstitialAdDelegate

@implementation ALMoPubMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALMoPubMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    [self.parentAdapter log: @"Interstitial loaded: %@", interstitial.adUnitId];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial withError:(NSError *)error
{
    [self.parentAdapter log: @"Interstitial (%@) failed to load with error: %@", interstitial.adUnitId, error];
    [self.delegate didFailToLoadInterstitialAdWithError: [ALMoPubMediationAdapter toMaxError: error]];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    [self.parentAdapter log: @"Interstitial expire: %@", interstitial.adUnitId];
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial
{
    [self.parentAdapter log: @"Interstitial shown: %@", interstitial.adUnitId];
}

- (void)mopubAd:(id<MPMoPubAd>)ad didTrackImpressionWithImpressionData:(MPImpressionData *)impressionData
{
    [self.parentAdapter log: @"Interstitial did track impression: %@", impressionData.adUnitID];
    
    // Passing extra info such as creative id supported in 6.15.0+
    // impressionData can be nil. The feature needs to be enabled by a MoPub account representative.
    NSString *creativeIdentifier = impressionData.impressionID;
    if ( ALSdk.versionCode >= 6150000 && [creativeIdentifier al_isValidString] )
    {
        [self.delegate performSelector: @selector(didDisplayInterstitialAdWithExtraInfo:)
                            withObject: @{@"creative_id" : creativeIdentifier}];
    }
    else
    {
        [self.delegate didDisplayInterstitialAd];
    }
}

- (void)interstitialDidDismiss:(MPInterstitialAdController *)interstitial
{
    [self.parentAdapter log: @"Interstitial hidden: %@", interstitial.adUnitId];
    [self.delegate didHideInterstitialAd];
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial
{
    [self.parentAdapter log: @"Interstitial clicked: %@", interstitial.adUnitId];
    [self.delegate didClickInterstitialAd];
}

@end

#pragma mark - ALMoPubMediationAdapterRewardedDelegate

@implementation ALMoPubMediationAdapterRewardedAdsDelegate

- (instancetype)initWithParentAdapter:(ALMoPubMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedAdDidLoadForAdUnitID:(NSString *)adUnitID
{
    [self.parentAdapter log: @"Rewarded ad loaded: %@", adUnitID];
    [self.delegate didLoadRewardedAd];
}

- (void)rewardedAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded ad (%@) failed to load with error: %@", adUnitID, error];
    [self.delegate didFailToLoadRewardedAdWithError: [ALMoPubMediationAdapter toMaxError: error]];
}

- (void)rewardedAdDidExpireForAdUnitID:(NSString *)adUnitID
{
    [self.parentAdapter log: @"Rewarded ad expired: %@", adUnitID];
}

- (void)rewardedAdDidPresentForAdUnitID:(NSString *)adUnitID
{
    [self.parentAdapter log: @"Rewarded ad shown: %@", adUnitID];
}

- (void)didTrackImpressionWithAdUnitID:(NSString *)adUnitID impressionData:(MPImpressionData *)impressionData
{
    [self.parentAdapter log: @"Rewarded ad did track impression: %@", adUnitID];
    
    // Passing extra info such as creative id supported in 6.15.0+
    // impressionData can be nil. The feature needs to be enabled by a MoPub account representative.
    NSString *creativeIdentifier = impressionData.impressionID;
    if ( ALSdk.versionCode >= 6150000 && [creativeIdentifier al_isValidString] )
    {
        [self.delegate performSelector: @selector(didDisplayRewardedAdWithExtraInfo:)
                            withObject: @{@"creative_id" : creativeIdentifier}];
    }
    else
    {
        [self.delegate didDisplayRewardedAd];
    }
}

- (void)rewardedAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded ad (%@) failed to show ad with error: %@", adUnitID, error];
    [self.delegate didFailToDisplayRewardedAdWithError: [ALMoPubMediationAdapter toMaxError: error]];
}

- (void)rewardedAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID
{
    [self.parentAdapter log: @"Rewarded ad clicked: %@", adUnitID];
    [self.delegate didClickRewardedAd];
}

- (void)rewardedAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPReward *)reward
{
    // For rewarded videos, MoPub rewards the user on video completed.
    // For rewarded playables, MoPub rewards the user when the close button will show or on ad clicked if the feature is enabled.
    [self.parentAdapter log: @"Rewarded ad video completed: %@", adUnitID];
    [self.delegate didCompleteRewardedAdVideo];
    
    self.grantedReward = YES;
}

- (void)rewardedAdDidDismissForAdUnitID:(NSString *)adUnitID
{
    [self.parentAdapter log: @"Rewarded ad video did disappear: %@", adUnitID];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden: %@", adUnitID];
    [self.delegate didHideRewardedAd];
}

@end

#pragma mark - ALMoPubMediationAdapterAdViewDelegate

@implementation ALMoPubMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALMoPubMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [ALUtils topViewControllerFromKeyWindow];
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize
{
    [self.parentAdapter log: @"AdView (%@) loaded: %@", NSStringFromCGSize(adSize), view.adUnitId];
    [self.delegate didLoadAdForAdView: view];
}

- (void)mopubAd:(id<MPMoPubAd>)ad didTrackImpressionWithImpressionData:(MPImpressionData *)impressionData
{
    [self.parentAdapter log: @"AdView did track impression: %@", impressionData.adUnitID];
    
    // Passing extra info such as creative id supported in 6.15.0+
    // impressionData can be nil. The feature needs to be enabled by a MoPub account representative.
    NSString *creativeIdentifier = impressionData.impressionID;
    if ( ALSdk.versionCode >= 6150000 && [creativeIdentifier al_isValidString] )
    {
        [self.delegate performSelector: @selector(didDisplayAdViewAdWithExtraInfo:)
                            withObject: @{@"creative_id" : creativeIdentifier}];
    }
    else
    {
        [self.delegate didDisplayAdViewAd];
    }
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error
{
    [self.parentAdapter log: @"AdView failed to load: %@", view.adUnitId];
    [self.delegate didFailToLoadAdViewAdWithError: [ALMoPubMediationAdapter toMaxError: error]];
}

- (void)willPresentModalViewForAd:(MPAdView *)view
{
    [self.parentAdapter log: @"AdView clicked and expanded: %@", view.adUnitId];
    [self.delegate didClickAdViewAd];
    [self.delegate didExpandAdViewAd];
}

- (void)didDismissModalViewForAd:(MPAdView *)view
{
    [self.parentAdapter log: @"AdView contracted: %@", view.adUnitId];
    [self.delegate didCollapseAdViewAd];
}

@end
