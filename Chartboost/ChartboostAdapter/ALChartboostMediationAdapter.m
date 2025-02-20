//
//  ALChartboostMediationAdapter.m
//  Adapters
//
//  Created by Thomas So on 1/8/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

#import "ALChartboostMediationAdapter.h"
#import <ChartboostSDK/ChartboostSDK.h>

#define ADAPTER_VERSION @"9.8.1.0"

@interface ALChartboostInterstitialDelegate : NSObject <CHBInterstitialDelegate>
@property (nonatomic,   weak) ALChartboostMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALChartboostMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALChartboostRewardedDelegate : NSObject <CHBRewardedDelegate>
@property (nonatomic,   weak) ALChartboostMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALChartboostMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALChartboostAdViewDelegate : NSObject <CHBBannerDelegate>
@property (nonatomic,   weak) ALChartboostMediationAdapter *parentAdapter;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALChartboostMediationAdapter *)parentAdapter format:(MAAdFormat *)format andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALChartboostMediationAdapter ()
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

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
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
        
        [Chartboost startWithAppID: appID appSignature: appSignature completion:^(CHBStartError *error) {
            
            if ( error )
            {
                [self log: @"Chartboost SDK failed to initialize with error: %@", error];
                ALChartboostInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALChartboostInitializationStatus, error.localizedDescription);
                
                return;
            }
            
            [self log: @"Chartboost SDK initialized"];
            ALChartboostInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            completionHandler(ALChartboostInitializationStatus, nil);
        }];
        
        self.mediationInfo = [[CHBMediation alloc] initWithName: @"MAX" libraryVersion: ALSdk.version adapterVersion: ADAPTER_VERSION];
        
        // Real test mode should be enabled from UI (https://answers.chartboost.com/en-us/articles/200780549)
        if ( [parameters isTesting] )
        {
            [Chartboost setLoggingLevel: CBLoggingLevelVerbose];
        }
    }
    else
    {
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
    [self.interstitialAd clearCache];
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialDelegate.delegate = nil;
    self.interstitialDelegate = nil;
    
    [self.rewardedAd clearCache];
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedDelegate.delegate = nil;
    self.rewardedDelegate = nil;
    
    [self.adView clearCache];
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewDelegate.delegate = nil;
    self.adViewDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *signal = [Chartboost bidderToken];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    // Determine placement
    NSString *location = [self locationFromParameters: parameters];
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBidding = [bidResponse al_isValidString];
    [self log: @"Loading %@interstitial ad for location \"%@\"...", isBidding ? @"bidding " : @"", location];
    
    [self updateUserConsentForParameters: parameters];
    
    self.interstitialDelegate = [[ALChartboostInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [[CHBInterstitial alloc] initWithLocation: location mediation: self.mediationInfo delegate: self.interstitialDelegate];
    
    if ( isBidding )
    {
        [self.interstitialAd cacheBidResponse: bidResponse];
    }
    else
    {
        [self.interstitialAd cache];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad for location \"%@\"...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( [self.interstitialAd isCached] )
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
        
        [self.interstitialAd showFromViewController: presentingViewController];
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
    NSString *location = [self locationFromParameters: parameters];
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBidding = [bidResponse al_isValidString];
    [self log: @"Loading %@rewarded ad for location \"%@\"...", isBidding ? @"bidding " : @"", location];
    
    [self updateUserConsentForParameters: parameters];
    
    self.rewardedDelegate = [[ALChartboostRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd = [[CHBRewarded alloc] initWithLocation: location mediation: self.mediationInfo delegate: self.rewardedDelegate];
    
    if ( isBidding )
    {
        [self.rewardedAd cacheBidResponse: bidResponse];
    }
    else
    {
        [self.rewardedAd cache];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad for location \"%@\"...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( [self.rewardedAd isCached] )
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
        
        [self.rewardedAd showFromViewController: presentingViewController];
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

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *location = [self locationFromParameters: parameters];
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBidding = [bidResponse al_isValidString];
    [self log: @"Loading %@%@ ad for location \"%@\"...", isBidding ? @"bidding " : @"", adFormat.label, location];
    
    [self updateUserConsentForParameters: parameters];
    
    self.adViewDelegate = [[ALChartboostAdViewDelegate alloc] initWithParentAdapter: self format: adFormat andNotify: delegate];
    self.adView = [[CHBBanner alloc] initWithSize: [self sizeFromAdFormat: adFormat]
                                         location: location
                                        mediation: self.mediationInfo
                                         delegate: self.adViewDelegate];
    
    if ( isBidding )
    {
        [self.adView cacheBidResponse: bidResponse];
    }
    else
    {
        [self.adView cache];
    }
}

#pragma mark - GDPR

- (void)updateUserConsentForParameters:(id<MAAdapterParameters>)parameters
{
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent != nil )
    {
        CHBGDPRConsent gdprConsent = hasUserConsent.boolValue ? CHBGDPRConsentBehavioral : CHBGDPRConsentNonBehavioral;
        [Chartboost addDataUseConsent: [CHBGDPRDataUseConsent gdprConsent: gdprConsent]];
    }
    
    NSNumber *isDoNotSell = [parameters isDoNotSell];
    if ( isDoNotSell != nil )
    {
        CHBCCPAConsent ccpaConsent = isDoNotSell.boolValue ? CHBCCPAConsentOptOutSale : CHBCCPAConsentOptInSale;
        [Chartboost addDataUseConsent: [CHBCCPADataUseConsent ccpaConsent: ccpaConsent]];
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
        return @"Default";
    }
}

- (MAAdapterError *)toMaxErrorFromCHBCacheError:(CHBCacheError *)chartBoostCacheError
{
    CHBCacheErrorCode chartBoostCacheErrorCode = chartBoostCacheError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( chartBoostCacheErrorCode )
    {
        case CHBCacheErrorCodeInternalError:
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
        case CHBCacheErrorCodeServerError:
            adapterError = MAAdapterError.serverError;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: chartBoostCacheErrorCode
               thirdPartySdkErrorMessage: chartBoostCacheError.description];
#pragma clang diagnostic pop
}

- (MAAdapterError *)toMaxErrorFromCHBShowError:(CHBShowError *)chartBoostShowError
{
    CHBShowErrorCode chartBoostShowErrorCode = chartBoostShowError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( chartBoostShowErrorCode )
    {
        case CHBShowErrorCodeInternalError:
        case CHBShowErrorCodePresentationFailure:
        case CHBShowErrorCodeAssetsFailure:
            adapterError = MAAdapterError.internalError;
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
        case CHBShowErrorCodeNoViewController:
            adapterError = MAAdapterError.missingViewController;
            break;
        case CHBShowErrorCodeNoAdInstance:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: chartBoostShowErrorCode
               thirdPartySdkErrorMessage: chartBoostShowError.description];
#pragma clang diagnostic pop
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
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
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
        
        if ( [event.adID al_isValidString] )
        {
            [self.delegate didLoadInterstitialAdWithExtraInfo: @{@"creative_id" : event.adID}];
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        MAAdapterError *adapterError = [MAAdapterError errorWithCode: -4205
                                                         errorString: @"Ad Display Failed"
                                              thirdPartySdkErrorCode: error.code
                                           thirdPartySdkErrorMessage: error.description];
#pragma clang diagnostic pop
        
        [self.parentAdapter log: @"Interstitial failed \"%@\" to show with error: %@", event.ad.location, error];
        [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"Interstitial shown: %@", event.ad.location];
    }
}

- (void)didRecordImpression:(CHBImpressionEvent *)event
{
    [self.parentAdapter log: @"Interstitial impression tracked: %@", event.ad.location];

    NSString *creativeID = event.adID;
    if ( [creativeID al_isValidString] )
    {
        [self.delegate didDisplayInterstitialAdWithExtraInfo: @{@"creative_id" : creativeID}];
    }
    else
    {
        [self.delegate didDisplayInterstitialAd];
    }
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
        if ( [event.adID al_isValidString] )
        {
            [self.delegate didLoadRewardedAdWithExtraInfo: @{@"creative_id" : event.adID}];
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        MAAdapterError *adapterError = [MAAdapterError errorWithCode: -4205
                                                         errorString: @"Ad Display Failed"
                                              thirdPartySdkErrorCode: error.code
                                           thirdPartySdkErrorMessage: error.description];
#pragma clang diagnostic pop
        
        [self.parentAdapter log: @"Rewarded failed \"%@\" to show with error: %@", event.ad.location, error];
        [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"Rewarded shown: %@", event.ad.location];
    }
}

- (void)didRecordImpression:(CHBImpressionEvent *)event
{
    [self.parentAdapter log: @"Rewarded impression tracked: %@", event.ad.location];

    NSString *creativeID = event.adID;
    if ( [creativeID al_isValidString] )
    {
        [self.delegate didDisplayRewardedAdWithExtraInfo: @{@"creative_id" : creativeID}];
    }
    else
    {
        [self.delegate didDisplayRewardedAd];
    }
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

// This is called when the video has completed and has earned the reward.
- (void)didEarnReward:(CHBRewardEvent *)event
{
    [self.parentAdapter log: @"Rewarded complete \"%@\" with reward: %d", event.ad.location, event.reward];
    
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

#pragma mark - CHBBannerDelegate

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
        CHBBanner *adView = (CHBBanner *) event.ad;
        
        // Passing extra info such as creative id supported in 6.15.0+
        if ( [event.adID al_isValidString] )
        {
            [self.delegate didLoadAdForAdView: adView withExtraInfo:@{@"creative_id" : event.adID}];
        }
        else
        {
            [self.delegate didLoadAdForAdView: adView];
        }
        
        [event.ad showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
    }
}

- (void)willShowAd:(CHBShowEvent *)event
{
    [self.parentAdapter log: @"%@ ad will show: %@", self.adFormat.label, event.ad.location];
}

- (void)didShowAd:(CHBShowEvent *)event error:(CHBShowError *)error
{
    if ( error )
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        MAAdapterError *adapterError = [MAAdapterError errorWithCode: -4205
                                                         errorString: @"Ad Display Failed"
                                              thirdPartySdkErrorCode: error.code
                                           thirdPartySdkErrorMessage: error.description];
#pragma clang diagnostic pop
        
        [self.parentAdapter log: @"%@ ad failed \"%@\" to show with error: %@", self.adFormat.label, event.ad.location, error];
        [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"%@ ad shown: %@", self.adFormat.label, event.ad.location];
    }
}

- (void)didRecordImpression:(CHBImpressionEvent *)event
{
    [self.parentAdapter log: @"%@ ad impression tracked: %@", self.adFormat.label, event.ad.location];
    
    NSString *creativeID = event.adID;
    if ( [creativeID al_isValidString] )
    {
        [self.delegate didDisplayAdViewAdWithExtraInfo: @{@"creative_id" : creativeID}];
    }
    else
    {
        [self.delegate didDisplayAdViewAd];
    }
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

@end
