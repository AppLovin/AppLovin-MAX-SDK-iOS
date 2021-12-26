//
//  ALChartboostMediationAdapter.m
//  Adapters
//
//  Created by Thomas So on 1/8/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

#import "ALChartboostMediationAdapter.h"
#import <Chartboost/Chartboost.h>
#import <Chartboost/Chartboost+Mediation.h>
#import "ALUtils.h"
#import "NSDictionary+ALUtils.h"
#import "NSString+ALUtils.h"
#import "ALAtomicBoolean.h"
#import "MAAdFormat+Internal.h"

#define ADAPTER_VERSION @"8.5.0.2"

@interface ALChartboostInterstitialDelegate : NSObject<CHBInterstitialDelegate>
@property (nonatomic,   weak) ALChartboostMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALChartboostMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALChartboostRewardedDelegate : NSObject<CHBRewardedDelegate>
@property (nonatomic,   weak) ALChartboostMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALChartboostMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALChartboostAdViewDelegate : NSObject<CHBBannerDelegate>
@property (nonatomic,   weak) ALChartboostMediationAdapter *parentAdapter;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALChartboostMediationAdapter *)parentAdapter format:(MAAdFormat *)format andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALChartboostMediationAdapter()
@property (nonatomic, strong) CHBInterstitial *interstitialAd;
@property (nonatomic, strong) CHBRewarded *rewardedAd;
@property (nonatomic, strong) CHBBanner *adView;

@property (nonatomic, strong) ALChartboostInterstitialDelegate *interstitialDelegate;
@property (nonatomic, strong) ALChartboostRewardedDelegate *rewardedDelegate;
@property (nonatomic, strong) ALChartboostAdViewDelegate *adViewDelegate;

@property (nonatomic, strong) CHBMediation *mediationInfo;
@end

@implementation ALChartboostMediationAdapter

static ALAtomicBoolean              *ALChartboostInitialized;
static MAAdapterInitializationStatus ALChartboostInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALChartboostInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [ALChartboostInitialized compareAndSet: NO update: YES] )
    {
        ALChartboostInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
        NSString *appID = [serverParameters al_stringForKey: @"app_id"];
        [self log: @"Initializing Chartboost SDK with app id: %@...", appID];
        
        // We must update consent _before_ calling `startWithAppId:appSignature:delegate`
        // (https://answers.chartboost.com/en-us/child_article/ios)
        [self updateUserConsentForParameters: parameters];
        
        NSString *appSignature = [serverParameters al_stringForKey: @"app_signature"];
        
        [Chartboost startWithAppId: appID appSignature: appSignature completion:^(BOOL success) {
            if ( success )
            {
                [self log: @"Chartboost SDK initialized"];
                ALChartboostInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            }
            else
            {
                [self log: @"Chartboost SDK failed to initialize"];
                ALChartboostInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
            }
            
            completionHandler(ALChartboostInitializationStatus, nil);
        }];
        
        self.mediationInfo = [[CHBMediation alloc] initWithType: CBMediationMAX libraryVersion: ALSdk.version adapterVersion: ADAPTER_VERSION];
        
        // Real test mode should be enabled from UI (https://answers.chartboost.com/en-us/articles/200780549)
        if ( [parameters isTesting] )
        {
            [Chartboost setLoggingLevel: CBLoggingLevelVerbose];
        }
        
        if ( [serverParameters al_containsValueForKey: @"prefetch_video_content"] )
        {
            BOOL prefetchVideoContent = [serverParameters al_numberForKey: @"prefetch_video_content"].boolValue;
            [Chartboost setShouldPrefetchVideoContent: prefetchVideoContent];
        }
    }
    else
    {
        [self log: @"Chartboost SDK already initialized"];
        completionHandler(ALChartboostInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [Chartboost getSDKVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.interstitialAd = nil;
    self.rewardedAd = nil;
    self.adView = nil;
    
    self.interstitialDelegate = nil;
    self.rewardedDelegate = nil;
    self.adViewDelegate = nil;
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    // Determine placement
    NSString *location = [self locationFromParameters: parameters];
    
    [self log: @"Loading interstitial ad for location \"%@\"...", location];
    
    [self updateUserConsentForParameters: parameters];
    
    self.interstitialDelegate = [[ALChartboostInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [[CHBInterstitial alloc] initWithLocation: location mediation: self.mediationInfo delegate: self.interstitialDelegate];
    
    [self.interstitialAd cache];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad for location \"%@\"...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( [self.interstitialAd isCached] )
    {
        [self.interstitialAd showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
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
    NSString *location = [self locationFromParameters: parameters];
    [self log: @"Loading rewarded ad for location \"%@\"...", location];
    
    [self updateUserConsentForParameters: parameters];
    
    self.rewardedDelegate = [[ALChartboostRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd = [[CHBRewarded alloc] initWithLocation: location mediation: self.mediationInfo delegate: self.rewardedDelegate];
    
    [self.rewardedAd cache];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad for location \"%@\"...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( [self.rewardedAd isCached] )
    {
        // Configure reward from server.
        [self configureRewardForParameters: parameters];
        [self.rewardedAd showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
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
    NSString *location = [self locationFromParameters: parameters];
    [self log: @"Loading %@ ad for location \"%@\"...", adFormat.label, location];
    
    [self updateUserConsentForParameters: parameters];
    
    self.adViewDelegate = [[ALChartboostAdViewDelegate alloc] initWithParentAdapter: self format: adFormat andNotify: delegate];
    self.adView = [[CHBBanner alloc] initWithSize: [self sizeFromAdFormat: adFormat]
                                         location: location
                                        mediation: self.mediationInfo
                                         delegate: self.adViewDelegate];
    self.adView.automaticallyRefreshesContent = NO;
    
    [self.adView cache];
}

#pragma mark - GDPR

- (void)updateUserConsentForParameters:(id<MAAdapterParameters>)parameters
{
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
        if ( hasUserConsent )
        {
            CHBGDPRConsent gdprConsent = hasUserConsent.boolValue ? CHBGDPRConsentBehavioral : CHBGDPRConsentNonBehavioral;
            [Chartboost addDataUseConsent: [CHBGDPRDataUseConsent gdprConsent: gdprConsent]];
        }
    }
    
    if ( ALSdk.versionCode >= 61100 )
    {
        NSNumber *isDoNotSell = [self privacySettingForSelector: @selector(isDoNotSell) fromParameters: parameters];
        if ( isDoNotSell )
        {
            CHBCCPAConsent ccpaConsent = isDoNotSell.boolValue ? CHBCCPAConsentOptOutSale : CHBCCPAConsentOptInSale;
            [Chartboost addDataUseConsent: [CHBCCPADataUseConsent ccpaConsent: ccpaConsent]];
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

#pragma mark - Helper Methods

- (NSString *)locationFromParameters:(id<MAAdapterResponseParameters>)parameters
{
    if ( [parameters.thirdPartyAdPlacementIdentifier al_isValidString] )
    {
        return parameters.thirdPartyAdPlacementIdentifier;
    }
    else
    {
        return CBLocationDefault;
    }
}

- (MAAdapterError *)toMaxErrorFromCHBCacheError:(CHBCacheError *)chartBoostCacheError
{
    CHBCacheErrorCode chartBoostCacheErrorCode = chartBoostCacheError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( chartBoostCacheErrorCode )
    {
        case CHBCacheErrorCodeInternal:
            adapterError = MAAdapterError.internalError;
            break;
        case CHBCacheErrorCodeInternetUnavailable:
        case CHBCacheErrorCodeNetworkFailure:
            adapterError = MAAdapterError.noConnection;
            break;
        case CHBCacheErrorCodeNoAdFound:
            adapterError = MAAdapterError.noFill;
            break;
        case CHBCacheErrorCodeSessionNotStarted:
            adapterError = MAAdapterError.notInitialized;
            break;
        case CHBCacheErrorCodeAssetDownloadFailure:
            adapterError = MAAdapterError.badRequest;
            break;
        case CHBCacheErrorCodePublisherDisabled:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
    }
    
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: chartBoostCacheErrorCode
               thirdPartySdkErrorMessage: chartBoostCacheError.description];
    
}

- (MAAdapterError *)toMaxErrorFromCHBShowError:(CHBShowError *)chartBoostShowError
{
    CHBShowErrorCode chartBoostShowErrorCode = chartBoostShowError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( chartBoostShowErrorCode )
    {
        case CHBShowErrorCodeInternal:
        case CHBShowErrorCodePresentationFailure:
            adapterError = MAAdapterError.internalError;
            break;
        case CHBShowErrorCodeAdAlreadyVisible:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case CHBShowErrorCodeSessionNotStarted:
            adapterError = MAAdapterError.notInitialized;
            break;
        case CHBShowErrorCodeInternetUnavailable:
            adapterError = MAAdapterError.noConnection;
            break;
        case CHBShowErrorCodeNoCachedAd:
            adapterError = MAAdapterError.adNotReady;
            break;
    }
    
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: chartBoostShowErrorCode
               thirdPartySdkErrorMessage: chartBoostShowError.description];
}

- (CHBBannerSize)sizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return CHBBannerSizeStandard;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return CHBBannerSizeLeaderboard;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return CHBBannerSizeMedium;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat ];
        return CHBBannerSizeStandard;
    }
}

@end

#pragma mark - CHBInterstitialDelegate

@implementation ALChartboostInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALChartboostMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)didCacheAd:(CHBCacheEvent *)event error:(CHBCacheError *)error
{
    if ( error )
    {
        MAAdapterError *adapterError = [self.parentAdapter toMaxErrorFromCHBCacheError: error];
        
        [self.parentAdapter log: @"Interstitial failed \"%@\" to load with error: %@", event.ad.location, error];
        [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"Interstitial loaded: %@", event.ad.location];
        
        // Passing extra info such as creative id supported in 6.15.0+
        if ( ALSdk.versionCode >= 6150000 && [event.adID al_isValidString] )
        {
            [self.delegate performSelector: @selector(didLoadInterstitialAdWithExtraInfo:)
                                withObject: @{@"creative_id" : event.adID}];
        }
        else
        {
            [self.delegate didLoadInterstitialAd];
        }
    }
}

- (void)willShowAd:(CHBShowEvent *)event
{
    [self.parentAdapter log: @"Interstitial will show: %@", event.ad.location];
}

- (void)didShowAd:(CHBShowEvent *)event error:(CHBShowError *)error
{
    if ( error )
    {
        MAAdapterError *adapterError = [self.parentAdapter toMaxErrorFromCHBShowError: error];
        
        [self.parentAdapter log: @"Interstitial failed \"%@\" to show with error: %@", event.ad.location, error];
        [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"Interstitial shown: %@", event.ad.location];
        [self.delegate didDisplayInterstitialAd];
    }
}

// This is a way to add custom handling for clicks. We return NO to indicate the click isn't handled.
- (BOOL)shouldConfirmClick:(CHBClickEvent *)event confirmationHandler:(void(^)(BOOL))confirmationHandler
{
    [self.parentAdapter log: @"Interstitial should confirm click: %@", event.ad.location];
    return NO;
}

- (void)didClickAd:(CHBClickEvent *)event error:(CHBClickError *)error
{
    if ( error )
    {
        [self.parentAdapter log: @"Failed to record click on \"%@\" because of error: %@", event.ad.location, error];
    }
    else
    {
        [self.parentAdapter log: @"Interstitial clicked: %@", event.ad.location];
        [self.delegate didClickInterstitialAd];
    }
}

- (void)didFinishHandlingClick:(CHBClickEvent *)event error:(nullable CHBClickError *)error
{
    [self.parentAdapter log: @"Interstitial did finish handling click: %@", event.ad.location];
}

- (void)didDismissAd:(CHBDismissEvent *)event
{
    [self.parentAdapter log: @"Interstitial hidden: %@", event.ad.location];
    [self.delegate didHideInterstitialAd];
}

@end

#pragma mark - CHBRewardedDelegate

@implementation ALChartboostRewardedDelegate

- (instancetype)initWithParentAdapter:(ALChartboostMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)didCacheAd:(CHBCacheEvent *)event error:(CHBCacheError *)error
{
    if ( error )
    {
        MAAdapterError *adapterError = [self.parentAdapter toMaxErrorFromCHBCacheError: error];
        
        [self.parentAdapter log: @"Rewarded failed \"%@\" to load with error: %@", event.ad.location, error];
        [self.delegate didFailToLoadRewardedAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"Rewarded loaded: %@", event.ad.location];
        
        // Passing extra info such as creative id supported in 6.15.0+
        if ( ALSdk.versionCode >= 6150000 && [event.adID al_isValidString] )
        {
            [self.delegate performSelector: @selector(didLoadRewardedAdWithExtraInfo:)
                                withObject: @{@"creative_id" : event.adID}];
        }
        else
        {
            [self.delegate didLoadRewardedAd];
        }
    }
}

- (void)willShowAd:(CHBShowEvent *)event
{
    [self.parentAdapter log: @"Rewarded will show: %@", event.ad.location];
}

- (void)didShowAd:(CHBShowEvent *)event error:(CHBShowError *)error
{
    if ( error )
    {
        MAAdapterError *adapterError = [self.parentAdapter toMaxErrorFromCHBShowError: error];
        
        [self.parentAdapter log: @"Rewarded failed \"%@\" to show with error: %@", event.ad.location, error];
        [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"Rewarded shown: %@", event.ad.location];
        
        [self.delegate didDisplayRewardedAd];
        [self.delegate didStartRewardedAdVideo];
    }
}

// This is a way to add custom handling for clicks. We return NO to indicate the click isn't handled.
- (BOOL)shouldConfirmClick:(CHBClickEvent *)event confirmationHandler:(void(^)(BOOL))confirmationHandler
{
    [self.parentAdapter log: @"Rewarded should confirm click: %@", event.ad.location];
    return NO;
}

- (void)didClickAd:(CHBClickEvent *)event error:(CHBClickError *)error
{
    if ( error )
    {
        [self.parentAdapter log: @"Failed to record click on \"%@\" because of error: %@", event.ad.location, error];
    }
    else
    {
        [self.parentAdapter log: @"Rewarded clicked: %@", event.ad.location];
        [self.delegate didClickRewardedAd];
    }
}

- (void)didFinishHandlingClick:(CHBClickEvent *)event error:(nullable CHBClickError *)error
{
    [self.parentAdapter log: @"Rewarded did finish handling click: %@", event.ad.location];
}

// This is called when the video has completed and has earned the reward.
- (void)didEarnReward:(CHBRewardEvent *)event
{
    [self.parentAdapter log: @"Rewarded complete \"%@\" with reward: %d", event.ad.location, event.reward];
    [self.delegate didCompleteRewardedAdVideo];
    
    self.grantedReward = YES;
}

- (void)didDismissAd:(CHBDismissEvent *)event
{
    [self.parentAdapter log: @"Rewarded dismissed: %@", event.ad.location];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = self.parentAdapter.reward;
        
        [self.parentAdapter log: @"Rewarded ad user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
        
        self.grantedReward = NO;
    }
    
    [self.delegate didHideRewardedAd];
}

@end

#pragma mark - CHBRewardedDelegate

@implementation ALChartboostAdViewDelegate

- (instancetype)initWithParentAdapter:(ALChartboostMediationAdapter *)parentAdapter format:(MAAdFormat *)format andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.adFormat = format;
        self.delegate = delegate;
    }
    return self;
}

- (void)didCacheAd:(CHBCacheEvent *)event error:(CHBCacheError *)error
{
    if ( error )
    {
        MAAdapterError *adapterError = [self.parentAdapter toMaxErrorFromCHBCacheError: error];
        
        [self.parentAdapter log: @"%@ ad failed \"%@\" to load with error: %@", self.adFormat.label, event.ad.location, error];
        [self.delegate didFailToLoadAdViewAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"%@ ad loaded: %@", self.adFormat.label, event.ad.location];
        CHBBanner *adView = (CHBBanner *)event.ad;
        
        // Passing extra info such as creative id supported in 6.15.0+
        if ( ALSdk.versionCode >= 6150000 && [event.adID al_isValidString] )
        {
            [self.delegate performSelector: @selector(didLoadAdForAdView:withExtraInfo:)
                                withObject: adView
                                withObject: @{@"creative_id" : event.adID}];
        }
        else
        {
            [self.delegate didLoadAdForAdView: adView];
        }
        
        [event.ad showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
    }
}

-(void)willShowAd:(CHBShowEvent *)event
{
    [self.parentAdapter log: @"%@ ad will show: %@", self.adFormat.label, event.ad.location];
}

- (void)didShowAd:(CHBShowEvent *)event error:(CHBShowError *)error
{
    if ( error )
    {
        MAAdapterError *adapterError = [self.parentAdapter toMaxErrorFromCHBShowError: error];
        
        [self.parentAdapter log: @"%@ ad failed \"%@\" to show with error: %@", self.adFormat.label, event.ad.location, error];
        [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"%@ ad shown: %@", self.adFormat.label, event.ad.location];
        [self.delegate didDisplayAdViewAd];
    }
}

// This is a way to add custom handling for clicks. We return NO to indicate the click isn't handled.
- (BOOL)shouldConfirmClick:(CHBClickEvent *)event confirmationHandler:(void (^)(BOOL))confirmationHandler
{
    [self.parentAdapter log: @"%@ ad should confirm click: %@", self.adFormat.label, event.ad.location];
    return NO;
}

- (void)didClickAd:(CHBClickEvent *)event error:(CHBClickError *)error
{
    if ( error )
    {
        [self.parentAdapter log: @"Failed to record click on \"%@\" because of error: %@", event.ad.location, error];
    }
    else
    {
        [self.parentAdapter log: @"%@ ad clicked: %@", self.adFormat.label, event.ad.location];
        [self.delegate didClickAdViewAd];
    }
}

- (void)didFinishHandlingClick:(CHBClickEvent *)event error:(CHBClickError *)error
{
    [self.parentAdapter log: @"%@ ad did finish handling click: %@", self.adFormat.label, event.ad.location];
}

@end
