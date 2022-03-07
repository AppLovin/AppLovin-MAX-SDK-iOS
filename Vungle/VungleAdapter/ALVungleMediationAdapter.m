//
//  ALVungleMediationAdapter.m
//  Adapters
//
//  Created by Christopher Cong on 10/19/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

#import "ALVungleMediationAdapter.h"
#import <VungleSDK/VungleSDKHeaderBidding.h>
#import <VungleSDK/VungleSDKCreativeTracking.h>
#import <VungleSDK/VungleSDK.h>

#define ADAPTER_VERSION @"6.10.6.2"

@interface ALVungleMediationAdapterRouter : ALMediationAdapterRouter<VungleSDKDelegate, VungleSDKCreativeTracking, VungleSDKHBDelegate>
@property (nonatomic, copy, nullable) void(^oldCompletionHandler)(void);
@property (nonatomic, copy, nullable) void(^completionBlock)(MAAdapterInitializationStatus, NSString * _Nullable);
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *creativeIdentifiers;

- (void)updateUserPrivacySettingsForParameters:(id<MAAdapterParameters>)parameters consentDialogState:(ALConsentDialogState)consentDialogState;
@end

@interface ALVungleMediationAdapter()
@property (nonatomic, strong, readonly) ALVungleMediationAdapterRouter *router;
@property (nonatomic, copy) NSString *placementIdentifier;
@property (nonatomic, strong) UIView *adView;
@end

@implementation ALVungleMediationAdapter
@dynamic router;

static ALAtomicBoolean              *ALVungleInitialized;
static MAAdapterInitializationStatus ALVungleIntializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALVungleInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    [self.router updateUserPrivacySettingsForParameters: parameters consentDialogState: self.sdk.configuration.consentDialogState];
    
    [[VungleSDK sharedSDK] setLoggingEnabled: [parameters isTesting]];
    
    if ( [ALVungleInitialized compareAndSet: NO update: YES] )
    {
        ALVungleIntializationStatus = MAAdapterInitializationStatusInitializing;
        self.router.completionBlock = completionHandler;
        
        NSString *appID = [parameters.serverParameters al_stringForKey: @"app_id"];
        [self log: @"Initializing Vungle SDK with app id: %@...", appID];
        
        [VungleSDK sharedSDK].delegate = self.router;
        [VungleSDK sharedSDK].creativeTrackingDelegate = self.router;
        [VungleSDK sharedSDK].sdkHBDelegate = self.router;
        self.router.creativeIdentifiers = [NSMutableDictionary dictionary];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [[VungleSDK sharedSDK] performSelector: @selector(setPluginName:version:)
                                    withObject: @"max"
                                    withObject: ADAPTER_VERSION];
#pragma clang diagnostic pop
        
        NSError *error;
        [[VungleSDK sharedSDK] startWithAppId: appID error: &error];
        
        if ( error )
        {
            [self log: @"Vungle SDK failed to initialize with error: %@", error];
            
            ALVungleIntializationStatus = MAAdapterInitializationStatusInitializedFailure;
            NSString *errorString = [NSString stringWithFormat: @"%ld:%@", (long) error.code, error.localizedDescription];
            
            completionHandler(ALVungleIntializationStatus, errorString);
            self.router.completionBlock = nil;
        }
    }
    else
    {
        completionHandler(ALVungleIntializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return VungleSDKVersion;
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    if ( self.adView )
    {
        // Note: Not calling this for now because it clears pre-loaded/cached ad view ads as well.
        // [[VungleSDK sharedSDK] finishedDisplayingAd];
        self.adView = nil;
    }
    
    [self.router removeAdapter: self forPlacementIdentifier: self.placementIdentifier];
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *signal = [[VungleSDK sharedSDK] currentSuperToken];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    self.placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@interstitial ad for placement: %@...", ( isBiddingAd ? @"bidding " : @"" ), self.placementIdentifier];
    
    if ( ![[VungleSDK sharedSDK] isInitialized] )
    {
        [self log: @"Vungle SDK not successfully initialized: failing interstitial ad load..."];
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self.router addInterstitialAdapter: self
                               delegate: delegate
                 forPlacementIdentifier: self.placementIdentifier];
    
    if ( isBiddingAd )
    {
        if ( [[VungleSDK sharedSDK] isAdCachedForPlacementID: self.placementIdentifier adMarkup: bidResponse] )
        {
            [self log: @"Interstitial ad loaded"];
            [delegate didLoadInterstitialAd];
            
            return;
        }
    }
    else if ( [[VungleSDK sharedSDK] isAdCachedForPlacementID: self.placementIdentifier] )
    {
        [self log: @"Interstitial ad loaded"];
        [delegate didLoadInterstitialAd];
        
        return;
    }
    
    NSError *error;
    BOOL isLoaded = [self loadAdForParameters: parameters
                                     adFormat: MAAdFormat.interstitial
                                        error: &error];
    
    // The `error` parameter may be populated with a return value of `true`
    if ( !isLoaded || error )
    {
        MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error];
        [self log: @"Interstitial failed to load with error: %@", adapterError];
        [delegate didFailToLoadInterstitialAdWithError: adapterError];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing %@interstitial ad for placement: %@...", ( isBiddingAd ? @"bidding " : @"" ), placementIdentifier];
    
    [self.router addShowingAdapter: self];
    
    NSError *error;
    BOOL willShow = NO;
    if ( isBiddingAd )
    {
        if ( [[VungleSDK sharedSDK] isAdCachedForPlacementID: placementIdentifier adMarkup: bidResponse] )
        {
            willShow = [self showFullscreenAdForParameters: parameters error: &error];
        }
    }
    else if ( [[VungleSDK sharedSDK] isAdCachedForPlacementID: placementIdentifier] )
    {
        willShow = [self showFullscreenAdForParameters: parameters error: &error];
    }
    
    if ( !willShow || error )
    {
        MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error];
        [self log: @"Interstitial ad failed to display with error: %@", adapterError];
        [self.router didFailToDisplayAdForPlacementIdentifier: placementIdentifier error: adapterError];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    self.placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@rewarded ad for placement: %@...", ( isBiddingAd ? @"bidding " : @"" ), self.placementIdentifier];
    
    if ( ![[VungleSDK sharedSDK] isInitialized] )
    {
        [self log: @"Vungle SDK not successfully initialized: failing rewarded ad load..."];
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self.router addRewardedAdapter: self
                           delegate: delegate
             forPlacementIdentifier: self.placementIdentifier];
    
    if ( isBiddingAd )
    {
        if ( [[VungleSDK sharedSDK] isAdCachedForPlacementID: self.placementIdentifier adMarkup: bidResponse] )
        {
            [self log: @"Rewarded ad loaded"];
            [delegate didLoadRewardedAd];
            
            return;
        }
    }
    else if ( [[VungleSDK sharedSDK] isAdCachedForPlacementID: self.placementIdentifier] )
    {
        [self log: @"Rewarded ad loaded"];
        [delegate didLoadRewardedAd];
        
        return;
    }
    
    NSError *error;
    BOOL isLoaded = [self loadAdForParameters: parameters
                                     adFormat: MAAdFormat.rewarded
                                        error: &error];
    
    // The `error` parameter may be populated with a return value of `true`
    if ( !isLoaded || error )
    {
        MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error];
        [self log: @"Rewarded failed to load with error: %@", adapterError];
        [delegate didFailToLoadRewardedAdWithError: adapterError];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing %@rewarded ad for placement: %@...", ( isBiddingAd ? @"bidding " : @"" ), placementIdentifier];
    
    [self.router addShowingAdapter: self];
    
    NSError *error;
    BOOL willShow = NO;
    if ( isBiddingAd )
    {
        if ( [[VungleSDK sharedSDK] isAdCachedForPlacementID: placementIdentifier adMarkup: bidResponse] )
        {
            [self configureRewardForParameters: parameters];
            willShow = [self showFullscreenAdForParameters: parameters error: &error];
        }
    }
    else if ( [[VungleSDK sharedSDK] isAdCachedForPlacementID: placementIdentifier] )
    {
        [self configureRewardForParameters: parameters];
        willShow = [self showFullscreenAdForParameters: parameters error: &error];
    }
    
    if ( !willShow || error )
    {
        MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error];
        [self log: @"Rewarded ad failed to display with error: %@", adapterError];
        [self.router didFailToDisplayAdForPlacementIdentifier: placementIdentifier error: adapterError];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    NSString *adFormatLabel = adFormat.label;
    self.placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@%@ ad for placement: %@...", ( isBiddingAd ? @"bidding " : @"" ), adFormatLabel, self.placementIdentifier];
    
    if ( ![[VungleSDK sharedSDK] isInitialized] )
    {
        [self log: @"Vungle SDK not successfully initialized: failing %@ ad load...", adFormatLabel];
        [delegate didFailToLoadAdViewAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self.router addAdViewAdapter: self
                         delegate: delegate
           forPlacementIdentifier: self.placementIdentifier
                           adView: nil];
    
    [[VungleSDK sharedSDK] disableBannerRefresh];
    
    VungleAdSize adSize = [ALVungleMediationAdapter vungleBannerAdSizeFromFormat: adFormat];
    if ( isBiddingAd )
    {
        if ( [[VungleSDK sharedSDK] isAdCachedForPlacementID: self.placementIdentifier adMarkup: bidResponse] ||
            [[VungleSDK sharedSDK] isAdCachedForPlacementID: self.placementIdentifier adMarkup: bidResponse withSize: adSize] )
        {
            [self showAdViewAdForParameters: parameters
                                   adFormat: adFormat
                                  andNotify: delegate];
            return;
        }
    }
    else if ( [[VungleSDK sharedSDK] isAdCachedForPlacementID: self.placementIdentifier] ||
             [[VungleSDK sharedSDK] isAdCachedForPlacementID: self.placementIdentifier withSize: adSize] )
    {
        [self showAdViewAdForParameters: parameters
                               adFormat: adFormat
                              andNotify: delegate];
        return;
    }
    
    NSError *error;
    BOOL isLoaded = [self loadAdForParameters: parameters
                                     adFormat: adFormat
                                        error: &error];
    
    if ( !isLoaded || error )
    {
        MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error];
        [self log: @"%@ ad failed to load with error: %@", adFormatLabel, error];
        [delegate didFailToLoadAdViewAdWithError: adapterError];
    }
    else
    {
        [self showAdViewAdForParameters: parameters
                               adFormat: adFormat
                              andNotify: delegate];
    }
}

- (void)showAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    NSString *adFormatLabel = adFormat.label;
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing %@%@ ad for placement: %@...", ( isBiddingAd ? @"bidding " : @"" ), adFormatLabel, placementIdentifier];
    
    if ( MAAdFormat.banner == adFormat )
    {
        self.adView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
    }
    else if ( MAAdFormat.leader == adFormat )
    {
        self.adView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 728, 90)];
    }
    else if ( MAAdFormat.mrec == adFormat )
    {
        self.adView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 250)];
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format: %@", adFormatLabel];
    }
    
    [self.router updateAdView: self.adView forPlacementIdentifier: placementIdentifier];
    [self.router addShowingAdapter: self];
    
    NSMutableDictionary *adOptions = [self adOptionsForServerParameters: parameters.serverParameters isFullscreenAd: NO];
    NSError *error;
    
    // Note: Vungle ad view ads require an additional step to load. A failed [addAdViewToView:] would be considered a failed load.
    BOOL willShow;
    if ( isBiddingAd )
    {
        willShow = [[VungleSDK sharedSDK] addAdViewToView: self.adView
                                              withOptions: adOptions
                                              placementID: placementIdentifier
                                                 adMarkup: bidResponse
                                                    error: &error];
    }
    else
    {
        willShow = [[VungleSDK sharedSDK] addAdViewToView: self.adView
                                              withOptions: adOptions
                                              placementID: placementIdentifier
                                                    error: &error];
    }
    
    if ( !willShow || error )
    {
        MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error];
        [self log: @"%@ ad failed to display with error: %@", adFormatLabel, adapterError];
        [self.router didFailToDisplayAdForPlacementIdentifier: placementIdentifier error: adapterError];
    }
    else
    {
        [delegate didLoadAdForAdView: self.adView];
    }
}

#pragma mark - Shared Methods

- (BOOL)loadAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat error:(NSError **)error
{
    [self.router updateUserPrivacySettingsForParameters: parameters consentDialogState: self.sdk.configuration.consentDialogState];
    
    // [loadPlacementWithID:] only supports the withSize parameter for banners and leaders.
    // [vungleAdPlayabilityUpdate:] is the callback for the load.
    
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    
    if ( MAAdFormat.banner == adFormat || MAAdFormat.leader == adFormat )
    {
        VungleAdSize adSize = [ALVungleMediationAdapter vungleBannerAdSizeFromFormat: adFormat];
        if ( isBiddingAd )
        {
            return [[VungleSDK sharedSDK] loadPlacementWithID: placementIdentifier
                                                     adMarkup: bidResponse
                                                     withSize: adSize
                                                        error: error];
        }
        else
        {
            return [[VungleSDK sharedSDK] loadPlacementWithID: placementIdentifier
                                                     withSize: adSize
                                                        error: error];
        }
    }
    else
    {
        if ( isBiddingAd )
        {
            return [[VungleSDK sharedSDK] loadPlacementWithID: placementIdentifier
                                                     adMarkup: bidResponse
                                                        error: error];
        }
        else
        {
            return [[VungleSDK sharedSDK] loadPlacementWithID: placementIdentifier error: error];
        }
    }
}

- (BOOL)showFullscreenAdForParameters:(id<MAAdapterResponseParameters>)parameters error:(NSError **)error
{
    NSMutableDictionary *adOptions = [self adOptionsForServerParameters: parameters.serverParameters isFullscreenAd: YES];
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    
    UIViewController *presentingViewController;
    if ( ALSdk.versionCode >= 11020199 )
    {
        presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    }
    else
    {
        presentingViewController = [ALUtils topViewControllerFromKeyWindow];
    }
    
    if ( [bidResponse al_isValidString] )
    {
        return [[VungleSDK sharedSDK] playAd: presentingViewController
                                     options: adOptions
                                 placementID: placementIdentifier
                                    adMarkup: bidResponse
                                       error: error];
    }
    else
    {
        return [[VungleSDK sharedSDK] playAd: presentingViewController
                                     options: adOptions
                                 placementID: placementIdentifier
                                       error: error];
    }
}

- (NSMutableDictionary *)adOptionsForServerParameters:(NSDictionary<NSString *, id> *)serverParameters isFullscreenAd:(BOOL)isFullscreenAd
{
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    // Overwritten by `mute_state` setting, unless `mute_state` is disabled
    if ( [serverParameters al_containsValueForKey: @"is_muted"] ) // Introduced in 6.10.0
    {
        BOOL muted = [serverParameters al_numberForKey: @"is_muted"].boolValue;
        [VungleSDK sharedSDK].muted = muted;
        
        options[VunglePlayAdOptionKeyStartMuted] = @(muted);
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_id"] )
    {
        options[VunglePlayAdOptionKeyUser] = [serverParameters al_stringForKey: @"user_id"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"ordinal"] )
    {
        options[VunglePlayAdOptionKeyOrdinal] = [serverParameters al_numberForKey: @"ordinal"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"flex_view_auto_dismiss_seconds"] )
    {
        options[VunglePlayAdOptionKeyFlexViewAutoDismissSeconds] = [serverParameters al_numberForKey: @"flex_view_auto_dismiss_seconds"];
    }
    
    // If the app is currently in landscape, lock the ad to landscape. This was an iOS-only bug where Vungle would quickly show an ad in portrait, then
    // landscape which is poor UX and caused issues in a pub app. Note that we can't set it for AdView ads as Vungle's SDK will rotate the publisher's app.
    // https://app.asana.com/0/inbox/20387143076904
    if ( isFullscreenAd && ([ALUtils currentOrientationMask] & UIInterfaceOrientationMaskLandscape) )
    {
        options[VunglePlayAdOptionKeyOrientations] = @(UIInterfaceOrientationMaskLandscape);
    }
    
    return options;
}

+ (VungleAdSize)vungleBannerAdSizeFromFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return VungleAdSizeBanner;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return VungleAdSizeBannerLeaderboard;
    }
    else
    {
        return VungleAdSizeUnknown;
    }
}

+ (MAAdapterError *)toMaxError:(nullable NSError *)vungleError
{
    if ( !vungleError ) return MAAdapterError.unspecified;
    
    VungleSDKErrorCode vungleErrorCode = (VungleSDKErrorCode)vungleError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( vungleErrorCode )
    {
        case VungleSDKErrorInvalidPlayAdOption:
        case VungleSDKErrorInvalidPlayAdExtraKey:
        case VungleSDKErrorUnknownPlacementID:
        case InvalidPlacementsArray:
        case VungleSDKErrorNoAppID:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case VungleSDKErrorCannotPlayAd:
        case VungleSDKErrorCannotPlayAdAlreadyPlaying:
        case VungleSDKErrorInvalidiOSVersion:
        case VungleSDKErrorTopMostViewControllerMismatch:
            adapterError = MAAdapterError.internalError;
            break;
        case VungleSDKErrorCannotPlayAdWaiting:
            adapterError = MAAdapterError.adNotReady;
            break;
        case VungleSDKErrorSDKNotInitialized:
            adapterError = MAAdapterError.notInitialized;
            break;
        case VungleSDKErrorNoAdsAvailable:
            adapterError = MAAdapterError.noFill;
            break;
        case VungleSDKErrorSleepingPlacement:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case VungleSDKErrorInvalidAdTypeForFeedBasedAdExperience:
        case VungleSDKErrorFlexFeedContainerViewSizeError:
        case VungleSDKErrorFlexFeedContainerViewSizeRatioError:
        case VungleSDKErrorNotEnoughFileSystemSize:
        case VungleDiscSpaceProviderErrorNoFileSystemAttributes:
        case VungleSDKErrorUnknownBannerSize:
        case VungleSDKResetPlacementForDifferentAdSize:
        case VungleSDKErrorSDKAlreadyInitializing:
            adapterError = MAAdapterError.unspecified;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: vungleErrorCode
               thirdPartySdkErrorMessage: vungleError.localizedDescription];
#pragma clang diagnostic pop
}

#pragma mark - Dynamic Properties

- (ALVungleMediationAdapterRouter *)router
{
    return [ALVungleMediationAdapterRouter sharedInstance];
}

@end

@implementation ALVungleMediationAdapterRouter

#pragma mark - GDPR

- (void)updateUserPrivacySettingsForParameters:(id<MAAdapterParameters>)parameters consentDialogState:(ALConsentDialogState)consentDialogState
{
    if ( consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
        if ( hasUserConsent )
        {
            VungleConsentStatus contentStatus = hasUserConsent.boolValue ? VungleConsentAccepted : VungleConsentDenied;
            [[VungleSDK sharedSDK] updateConsentStatus: contentStatus consentMessageVersion: @""];
        }
    }
    
    if ( ALSdk.versionCode >= 61100 )
    {
        NSNumber *isDoNotSell = [self privacySettingForSelector: @selector(isDoNotSell) fromParameters: parameters];
        if ( isDoNotSell )
        {
            VungleCCPAStatus ccpaStatus = isDoNotSell.boolValue ? VungleCCPADenied : VungleCCPAAccepted;
            [[VungleSDK sharedSDK] updateCCPAStatus: ccpaStatus];
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

#pragma mark - VungleSDKDelegate

// This method is called when Vungle's SDK initializes to cache ads; it's also used as the load callback when [loadPlacementWithID:] is called
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(NSString *)placementID error:(NSError *)error
{
    if ( isAdPlayable )
    {
        [self log: @"Ad is playable and loaded for placement id: %@", placementID];
        
        // NOTE: Break thread context when we call `loadPlacementWithID:` for banners and this calls into SDK downstream without a loadedAdView
        deferToNextMainQueueRunloop(^{
            [self didLoadAdForPlacementIdentifier: placementID];
        });
        
        return;
    }
    
    if ( error )
    {
        MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error];
        [self log: @"Ad for placement id %@ failed to load with error: %@", placementID, adapterError];
        [self didFailToLoadAdForPlacementIdentifier: placementID error: adapterError];
    }
    else
    {
        [self log: @"Ad for placement id %@ received no fill", placementID];
        
        // When `isAdPlayable` is `NO` and `error` is `nil` => NO FILL
        // https://app.asana.com/0/573104092700345/1161396323081913
        [self didFailToLoadAdForPlacementIdentifier: placementID error: MAAdapterError.noFill];
    }
}

- (void)vungleWillShowAdForPlacementID:(NSString *)placementID
{
    [self log: @"Ad will show"];
}

- (void)vungleDidShowAdForPlacementID:(NSString *)placementID
{
    // Old CIMP location. Caused discrepancies with Vungle.
    [self log: @"Ad did show"];
}

- (void)vungleAdViewedForPlacement:(NSString *)placementID
{
    [self log: @"Ad viewed"];
    
    // Passing extra info such as creative id supported in 6.15.0+
    NSString *creativeIdentifier = self.creativeIdentifiers[placementID];
    if ( ALSdk.versionCode >= 6150000 && [creativeIdentifier al_isValidString] )
    {
        [self performSelector: @selector(didDisplayAdForPlacementIdentifier:withExtraInfo:)
                   withObject: placementID
                   withObject: @{@"creative_id" : creativeIdentifier}];
        [self.creativeIdentifiers removeObjectForKey: placementID];
    }
    else
    {
        [self didDisplayAdForPlacementIdentifier: placementID];
    }
    
    [self didStartRewardedVideoForPlacementIdentifier: placementID];
}

- (void)vungleTrackClickForPlacementID:(NSString *)placementID
{
    [self log: @"Ad clicked"];
    [self didClickAdForPlacementIdentifier: placementID];
}

- (void)vungleRewardUserForPlacementID:(NSString *)placementID
{
    [self log: @"Rewarded ad user did earn reward"];
    self.grantedReward = YES;
}

- (void)vungleWillCloseAdForPlacementID:(NSString *)placementID
{
    [self log: @"Ad will close"];
    
    [self didCompleteRewardedVideoForPlacementIdentifier: placementID];
    
    if ( self.grantedReward || [self shouldAlwaysRewardUserForPlacementIdentifier: placementID] )
    {
        [self didRewardUserForPlacementIdentifier: placementID withReward: [self rewardForPlacementIdentifier: placementID]];
        self.grantedReward = NO;
    }
}

- (void)vungleDidCloseAdForPlacementID:(NSString *)placementID
{
    [self log: @"Ad did close"];
    [self didHideAdForPlacementIdentifier: placementID];
}

- (void)vungleSDKDidInitialize
{
    [self log: @"Vungle SDK initialized"];
    
    if ( self.completionBlock )
    {
        ALVungleIntializationStatus = MAAdapterInitializationStatusInitializedSuccess;
        
        self.completionBlock(ALVungleIntializationStatus, nil);
        self.completionBlock = nil;
    }
    
    if ( self.oldCompletionHandler )
    {
        self.oldCompletionHandler();
        self.oldCompletionHandler = nil;
    }
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error
{
    [self log: @"Vungle SDK failed to initialize with error: %@", error];
    
    if ( self.completionBlock )
    {
        ALVungleIntializationStatus = MAAdapterInitializationStatusInitializedFailure;
        NSString *errorString = [NSString stringWithFormat: @"%ld:%@", (long) error.code, error.localizedDescription];
        
        self.completionBlock(ALVungleIntializationStatus, errorString);
        self.completionBlock = nil;
    }
    
    if ( self.oldCompletionHandler )
    {
        self.oldCompletionHandler();
        self.oldCompletionHandler = nil;
    }
}

#pragma mark - VungleSDKHBDelegate

// This method is called when Vungle's SDK initializes to cache ads; it's also used as the load callback when [loadPlacementWithID:] is called
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable
                      placementID:(nullable NSString *)placementID
                         adMarkup:(nullable NSString *)adMarkup
                            error:(nullable NSError *)error
{
    [self vungleAdPlayabilityUpdate: isAdPlayable
                        placementID: placementID
                              error: error];
}

- (void)vungleWillShowAdForPlacementID:(NSString *)placementID adMarkup:(nullable NSString *)adMarkup
{
    [self vungleWillShowAdForPlacementID: placementID];
}

- (void)vungleDidShowAdForPlacementID:(NSString *)placementID adMarkup:(nullable NSString *)adMarkup
{
    // Old CIMP location. Caused discrepancies with Vungle.
    [self vungleDidShowAdForPlacementID: placementID];
}

- (void)vungleAdViewedForPlacementID:(NSString *)placementID adMarkup:(NSString *)adMarkup
{
    [self vungleAdViewedForPlacement: placementID];
}

- (void)vungleTrackClickForPlacementID:(NSString *)placementID adMarkup:(nullable NSString *)adMarkup
{
    [self vungleTrackClickForPlacementID: placementID];
}

- (void)vungleRewardUserForPlacementID:(NSString *)placementID adMarkup:(nullable NSString *)adMarkup
{
    [self vungleRewardUserForPlacementID: placementID];
}

- (void)vungleWillCloseAdForPlacementID:(NSString *)placementID adMarkup:(nullable NSString *)adMarkup
{
    [self vungleWillCloseAdForPlacementID: placementID];
}

- (void)vungleDidCloseAdForPlacementID:(NSString *)placementID adMarkup:(nullable NSString *)adMarkup
{
    [self vungleDidCloseAdForPlacementID: placementID];
}

#pragma mark - VungleSDKCreativeTracking

- (void)vungleCreative:(nullable NSString *)creativeID readyForPlacement:(nullable NSString *)placementID
{
    [self log: @"Vungle creative with creativeID: %@ ready for placement: %@", creativeID, placementID];
    if ( [creativeID al_isValidString] && [placementID al_isValidString] )
    {
        self.creativeIdentifiers[placementID] = creativeID;
    }
}

@end
