//
//  ALNendMediationAdapter.m
//  AppLovinSDK
//
//  Created by Lorenzo Gentile on 7/5/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALNendMediationAdapter.h"
#import <NendAd/NendAd.h>
#import <NendAd/NADLogger.h>

#define ADAPTER_VERSION @"7.2.0.1"
#define NSSTRING(_X) ( (_X != NULL) ? [NSString stringWithCString: _X encoding: NSStringEncodingConversionAllowLossy] : nil)

@interface ALNendMediationAdapterInterstitialAdDelegate : NSObject<NADInterstitialVideoDelegate>
@property (nonatomic,   weak) ALNendMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALNendMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALNendMediationAdapterRewardedAdDelegate : NSObject<NADRewardedVideoDelegate>
@property (nonatomic,   weak) ALNendMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALNendMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALNendMediationAdapterAdViewDelegate : NSObject<NADViewDelegate>
@property (nonatomic,   weak) ALNendMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALNendMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALNendMediationAdapter()

@property (nonatomic, strong) NADInterstitialVideo *interstitialVideo;
@property (nonatomic, strong) NADRewardedVideo *rewardedVideo;
@property (nonatomic, strong) NADView *adView;

@property (nonatomic, strong) ALNendMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALNendMediationAdapterRewardedAdDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) ALNendMediationAdapterAdViewDelegate *adViewAdapterDelegate;

@end

@implementation ALNendMediationAdapter

static NSString *const kMAConfigKeyApiKey = @"api_key";
static NSString *const kMAConfigKeySetMediationId = @"set_mediation_identifier";
static NSString *const kMAConfigKeyUserId = @"user_id";

#pragma mark - MAAdapter Methods

- (NSString *)SDKVersion
{
    NSString *sdkVersionString = NSSTRING((char *)NendAdVersionString);
    
    @try
    {
        // NendAdVersionString returns something like '@(#)PROGRAM:NendAd  PROJECT:NendAd-5.2.0\n' so we need to parse out the version
        NSArray *versionComponents = [sdkVersionString componentsSeparatedByString: @"NendAd-"];
        sdkVersionString = versionComponents[1];
        sdkVersionString = [sdkVersionString stringByTrimmingCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    }
    @catch ( NSException *ex )
    {
        // Do nothing (return original NendAdVersionString)
    }
    
    return sdkVersionString;
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void(^)(MAAdapterInitializationStatus initializationStatus, NSString *_Nullable errorMessage))completionHandler
{
    if ( [parameters isTesting] )
    {
        [NADLogger setLogLevel: NADLogLevelDebug];
    }
    
    // Nend SDK does not have any API for initialization.
    completionHandler( MAAdapterInitializationStatusDoesNotApply, nil );
}

- (void)destroy
{
    [self log: @"Destroy called for adapter: %@", self];
    
    [self.interstitialVideo releaseVideoAd];
    self.interstitialVideo.delegate = nil;
    self.interstitialVideo = nil;
    self.interstitialAdapterDelegate = nil;
    
    [self.rewardedVideo releaseVideoAd];
    self.rewardedVideo.delegate = nil;
    self.rewardedVideo = nil;
    self.rewardedAdapterDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewAdapterDelegate = nil;
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    NSString *apiKey = [serverParameters al_stringForKey: kMAConfigKeyApiKey];
    NSInteger spotID = [parameters.thirdPartyAdPlacementIdentifier integerValue];
    [self log: @"Loading interstitial ad for API key: %@ and spot ID: %ld...", apiKey, (long) spotID];
    
    self.interstitialAdapterDelegate = [[ALNendMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialVideo = [[NADInterstitialVideo alloc] initWithSpotID: spotID apiKey: apiKey];
    self.interstitialVideo.delegate = self.interstitialAdapterDelegate;
    
    if ( [serverParameters al_numberForKey: kMAConfigKeySetMediationId].boolValue )
    {
        [self.interstitialVideo setMediationName: self.mediationTag];
    }
    
    if ( [serverParameters al_containsValueForKey: kMAConfigKeyUserId] )
    {
        [self.interstitialVideo setUserId: [serverParameters al_stringForKey: kMAConfigKeyUserId]];
    }
    
    [self.interstitialVideo loadAd];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( [self.interstitialVideo isReady] )
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
        
        [self.interstitialVideo showAdFromViewController: presentingViewController];
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
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    NSString *apiKey = [serverParameters al_stringForKey: kMAConfigKeyApiKey];
    NSInteger spotID = [parameters.thirdPartyAdPlacementIdentifier integerValue];
    [self log: @"Loading rewarded ad for API key: %@ and spot ID: %ld...", apiKey, (long) spotID];
    
    self.rewardedAdapterDelegate = [[ALNendMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedVideo = [[NADRewardedVideo alloc] initWithSpotID: spotID apiKey: apiKey];
    self.rewardedVideo.delegate = self.rewardedAdapterDelegate;
    
    if ( [serverParameters al_numberForKey: kMAConfigKeySetMediationId].boolValue )
    {
        [self.rewardedVideo setMediationName: self.mediationTag];
    }
    
    if ( [serverParameters al_containsValueForKey: kMAConfigKeyUserId] )
    {
        [self.rewardedVideo setUserId: [serverParameters al_stringForKey: kMAConfigKeyUserId]];
    }
    
    [self.rewardedVideo loadAd];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( [self.rewardedVideo isReady] )
    {
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
        
        [self.rewardedVideo showAdFromViewController: presentingViewController];
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
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    NSString *apiKey = [serverParameters al_stringForKey: kMAConfigKeyApiKey];
    NSInteger spotID = [parameters.thirdPartyAdPlacementIdentifier integerValue];
    [self log: @"Loading ad view for API key: %@ and spot ID: %ld...", apiKey, (long) spotID];
    
    self.adViewAdapterDelegate = [[ALNendMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    CGRect adViewFrame = [ALNendMediationAdapter adViewFrameForAdFormat: adFormat];
    self.adView = [[NADView alloc] initWithFrame: adViewFrame];
    [self.adView setNendID: spotID apiKey: apiKey];
    [self.adView setDelegate: self.adViewAdapterDelegate];
    [self.adView load];
}

#pragma mark - Helper Methods

/**
 * Translated from https://github.com/fan-ADN/nendSDK-iOS/wiki/Implementation-for-Interstitial-Video-ads#loading-of-ad-is-failed
 */
+ (MAAdapterError *)toMaxError:(NSError *)nendError
{
    NSInteger nendErrorCode = nendError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( nendErrorCode )
    {
        case 204:
            adapterError = MAAdapterError.noFill;
            break;
        case 400:
            adapterError = MAAdapterError.badRequest;
            break;
        case 500 ... 599:
            adapterError = MAAdapterError.serverError;
            break;
        case 600: // From the developer: "Error in SDK"
        case 601: // From the developer: "Ad download failed"
        case 602: // From the developer: "Fallback fullscreen ad failed"
            adapterError = MAAdapterError.internalError;
            break;
        case 603: // From the developer: "Invalid network"
            adapterError = MAAdapterError.noConnection;
            break;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: nendErrorCode
               thirdPartySdkErrorMessage: nendError.localizedDescription];
#pragma clang diagnostic pop
}

/**
 * Translated from https://github.com/fan-ADN/nendSDK-iOS/wiki/Implementation-for-banner-ads#optionalad-reception-error-notification
 */
+ (MAAdapterError *)toMaxErrorFromNendAdViewError:(NSError *)nendError
{
    NADViewErrorCode nendErrorCode = (NADViewErrorCode)nendError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( nendErrorCode )
    {
        case NADVIEW_AD_SIZE_TOO_LARGE:
        case NADVIEW_INVALID_RESPONSE_TYPE:
        case NADVIEW_AD_SIZE_DIFFERENCES:
            adapterError = MAAdapterError.internalError;
            break;
        case NADVIEW_FAILED_AD_REQUEST:
        case NADVIEW_FAILED_AD_DOWNLOAD:
            adapterError = MAAdapterError.badRequest;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: nendErrorCode
               thirdPartySdkErrorMessage: nendError.localizedDescription];
#pragma clang diagnostic pop
}

+ (CGRect)adViewFrameForAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return (CGRect) { CGPointZero, NAD_ADVIEW_SIZE_320x50 };
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return (CGRect) { CGPointZero, NAD_ADVIEW_SIZE_300x250 };
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return (CGRect) { CGPointZero, NAD_ADVIEW_SIZE_728x90 };
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return (CGRect) { CGPointZero, NAD_ADVIEW_SIZE_320x50 };
    }
}

@end

#pragma mark - ALNendMediationAdapterInterstitialAdDelegate

@implementation ALNendMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALNendMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nadInterstitialVideoAdDidReceiveAd:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    [self.parentAdapter log: @"Interstitial video loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)nadInterstitialVideoAd:(NADInterstitialVideo *)nadInterstitialVideoAd didFailToLoadWithError:(NSError *)error
{
    [self.parentAdapter log: @"Interstitial video failed to load with error: %@", error];
    [self.delegate didFailToLoadInterstitialAdWithError: [ALNendMediationAdapter toMaxError: error]];
}

- (void)nadInterstitialVideoAdDidFailedToPlay:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    [self.parentAdapter log: @"Interstitial video failed to play"];
    [self.delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.unspecified];
}

- (void)nadInterstitialVideoAdDidOpen:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    [self.parentAdapter log: @"Interstitial video displayed"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)nadInterstitialVideoAdDidClose:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    [self.parentAdapter log: @"Interstitial video hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)nadInterstitialVideoAdDidStartPlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    [self.parentAdapter log: @"Interstitial video started playing"];
}

- (void)nadInterstitialVideoAdDidStopPlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    [self.parentAdapter log: @"Interstitial video stopped playing"];
}

- (void)nadInterstitialVideoAdDidCompletePlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    [self.parentAdapter log: @"Interstitial video completed playing"];
}

- (void)nadInterstitialVideoAdDidClickAd:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    [self.parentAdapter log: @"Interstitial video ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)nadInterstitialVideoAdDidClickInformation:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    [self.parentAdapter log: @"Interstitial video information clicked"];
}

@end

#pragma mark - ALNendMediationAdapterRewardedAdDelegate

@implementation ALNendMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALNendMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didReward:(NADReward *)reward
{
    [self.parentAdapter log: @"Rewarded video granted reward"];
    self.grantedReward = YES;
}

- (void)nadRewardVideoAdDidReceiveAd:(NADRewardedVideo *)nadRewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded video loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didFailToLoadWithError:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded video failed to load with error: %@", error];
    [self.delegate didFailToLoadRewardedAdWithError: [ALNendMediationAdapter toMaxError: error]];
}

- (void)nadRewardVideoAdDidFailedToPlay:(NADRewardedVideo *)nadRewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded video failed to play"];
    [self.delegate didFailToDisplayRewardedAdWithError: MAAdapterError.unspecified];
}

- (void)nadRewardVideoAdDidOpen:(NADRewardedVideo *)nadRewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded video displayed"];
    [self.delegate didDisplayRewardedAd];
}

- (void)nadRewardVideoAdDidClose:(NADRewardedVideo *)nadRewardedVideoAd
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded video hidden"];
    [self.delegate didHideRewardedAd];
}

- (void)nadRewardVideoAdDidStartPlaying:(NADRewardedVideo *)nadRewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded video started playing"];
    [self.delegate didStartRewardedAdVideo];
}

- (void)nadRewardVideoAdDidStopPlaying:(NADRewardedVideo *)nadRewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded video stopped playing"];
}

- (void)nadRewardVideoAdDidCompletePlaying:(NADRewardedVideo *)nadRewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded video completed playing"];
    [self.delegate didCompleteRewardedAdVideo];
}

- (void)nadRewardVideoAdDidClickAd:(NADRewardedVideo *)nadRewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded video ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)nadRewardVideoAdDidClickInformation:(NADRewardedVideo *)nadRewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded video information clicked"];
}

@end

#pragma mark - ALNendMediationAdapterAdViewDelegate

@implementation ALNendMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALNendMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nadViewDidReceiveAd:(NADView *)adView
{
    // Nend ads auto-refresh by default so we should stop it (so MAX can control refreshing and track it).
    [adView pause];
    
    [self.parentAdapter log: @"Ad view received with API key: %@ and spot id: %ld", adView.nendApiKey, adView.nendSpotId];
    [self.delegate didLoadAdForAdView: adView];
}

- (void)nadViewDidFailToReceiveAd:(NADView *)adView
{
    // Nend ads auto-refresh by default so we should stop it (so MAX can control refreshing and track it).
    [adView pause];
    
    NSError *error = adView.error;
    [self.parentAdapter log: @"Ad view failed to receive with API key: %@ and spot id: %ld: %@", adView.nendApiKey, adView.nendSpotId, error];
    [self.delegate didFailToLoadAdViewAdWithError: [ALNendMediationAdapter toMaxErrorFromNendAdViewError: error]];
}

- (void)nadViewDidClickAd:(NADView *)adView
{
    [self.parentAdapter log: @"Ad view clicked with API key: %@ and spot id: %ld", adView.nendApiKey, adView.nendSpotId];
    [self.delegate didClickAdViewAd];
}

- (void)nadViewDidClickInformation:(NADView *)adView
{
    [self.parentAdapter log: @"Ad view information clicked with API key: %@ and spot id: %ld", adView.nendApiKey, adView.nendSpotId];
}

@end
