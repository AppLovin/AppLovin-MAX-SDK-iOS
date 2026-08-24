//
//  ALChartboostMediationAdapter.m
//  Adapters
//
//  Created by Thomas So on 1/8/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

#import "ALChartboostMediationAdapter.h"
#import <ChartboostSDK/ChartboostSDK.h>

#define ADAPTER_VERSION @"9.14.0.1"

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

// Chartboost expires a cached ad that is not shown within its expiration interval. MAX has no
// adapter callback for expiry, so we record it and fail the show attempt instead.
@property (nonatomic, assign, getter=isInterstitialAdExpired) BOOL interstitialAdExpired;
@property (nonatomic, assign, getter=isRewardedAdExpired) BOOL rewardedAdExpired;

@property (nonatomic, weak) UIViewController *adViewPresentingViewController;
@end

@implementation ALChartboostMediationAdapter

static ALAtomicBoolean              *ALChartboostInitialized;
static MAAdapterInitializationStatus ALChartboostInitializationStatus = NSIntegerMin;
static CHBMediation                 *ALChartboostMediation;

+ (void)initialize
{
    [super initialize];
    
    ALChartboostInitialized = [[ALAtomicBoolean alloc] init];
    ALChartboostMediation = [[CHBMediation alloc] initWithName: @"MAX" libraryVersion: ALSdk.version adapterVersion: ADAPTER_VERSION];
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
    if ( ![signal al_isValidString] )
    {
        [self log: @"Failed to collect signal"];
        [delegate didFailToCollectSignalWithErrorMessage: @"Chartboost bidder token is unavailable"];
        return;
    }
    
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
    self.interstitialAd = [[CHBInterstitial alloc] initWithLocation: location mediation: ALChartboostMediation delegate: self.interstitialDelegate];
    
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
    
    if ( [self isInterstitialAdExpired] )
    {
        [self log: @"Interstitial ad expired"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                        mediatedNetworkErrorCode: MAAdapterError.adExpiredError.code
                                                                     mediatedNetworkErrorMessage: MAAdapterError.adExpiredError.message]];
        return;
    }
    
    // NOTE: Do not use `isCached:` since it does not reliably indicate ad readiness.
    if ( self.interstitialAd )
    {
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.interstitialAd showFromViewController: presentingViewController];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                        mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                     mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
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
    self.rewardedAd = [[CHBRewarded alloc] initWithLocation: location mediation: ALChartboostMediation delegate: self.rewardedDelegate];
    
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
    
    if ( [self isRewardedAdExpired] )
    {
        [self log: @"Rewarded ad expired"];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                    mediatedNetworkErrorCode: MAAdapterError.adExpiredError.code
                                                                 mediatedNetworkErrorMessage: MAAdapterError.adExpiredError.message]];
        return;
    }
    
    // NOTE: Do not use `isCached:` since it does not reliably indicate ad readiness.
    if ( self.rewardedAd )
    {
        // Configure reward from server.
        [self configureRewardForParameters: parameters];
        
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.rewardedAd showFromViewController: presentingViewController];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                    mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                 mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
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
    
    self.adViewPresentingViewController = parameters.presentingViewController;
    self.adViewDelegate = [[ALChartboostAdViewDelegate alloc] initWithParentAdapter: self format: adFormat andNotify: delegate];
    self.adView = [[CHBBanner alloc] initWithSize: [self sizeFromAdFormat: adFormat]
                                         location: location
                                        mediation: ALChartboostMediation
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

// Maps a Chartboost SDK 9.10.0+ error code. These codes are ad-lifecycle-agnostic: the value
// itself identifies the phase (1XX initialization, 2XX connectivity, 3XX load, 4XX show,
// 5XX render, 9XX other), so cache and show failures share this mapping.
- (MAAdapterError *)maxErrorFromChartboostErrorCode:(NSInteger)chartBoostErrorCode
{
    switch ( chartBoostErrorCode )
    {
        // MARK: Initialization (1XX)
        case CHBErrorCodeInitializationUnknownError:
        case CHBErrorCodeInitializationNoContext: // Android only
            return MAAdapterError.notInitialized;
        case CHBErrorCodeInitializationDisabled:
        case CHBErrorCodeInitializationInvalidCredentials:
        case CHBErrorCodeInitializationInvalidConfiguration:
        case CHBErrorCodeInitializationOSVersionNotSupported:
        case CHBErrorCodeInitializationPermissionsNotSet: // Android only
            return MAAdapterError.invalidConfiguration;
        case CHBErrorCodeInitializationInternalError:
            return MAAdapterError.internalError;

        // MARK: Connectivity (2XX)
        case CHBErrorCodeConnectivityUnknownError:
        case CHBErrorCodeConnectivityNoInternet:
        case CHBErrorCodeConnectivityNetworkError:
            return MAAdapterError.noConnection;
        case CHBErrorCodeConnectivityServerError:
            return MAAdapterError.serverError;
        case CHBErrorCodeConnectivityTimedOut:
            return MAAdapterError.timeout;
        case CHBErrorCodeConnectivityInternalError:
            return MAAdapterError.internalError;
        case CHBErrorCodeConnectivityInvalidRequest:
            return MAAdapterError.badRequest;

        // MARK: Load (3XX)
        case CHBErrorCodeLoadNoAd:
            return MAAdapterError.noFill;
        case CHBErrorCodeLoadDisabled:
        case CHBErrorCodeLoadInvalidPlacement:
            return MAAdapterError.invalidConfiguration;
        case CHBErrorCodeLoadNotInitialized:
            return MAAdapterError.notInitialized;
        case CHBErrorCodeLoadInProgress:
        case CHBErrorCodeLoadAlreadyLoaded:
            return MAAdapterError.invalidLoadState;
        case CHBErrorCodeLoadNoContext: // Android only
            return MAAdapterError.missingViewController;
        // Chartboost is throttling us; frequency capping is the closest MAX signal that also
        // tells MAX to back off rather than immediately retrying this network.
        case CHBErrorCodeLoadRateLimited:
            return MAAdapterError.adFrequencyCappedError;
        case CHBErrorCodeLoadInvalidRequest:
        case CHBErrorCodeLoadInvalidADM:
            return MAAdapterError.badRequest;
        case CHBErrorCodeLoadInvalidResponse:
        case CHBErrorCodeLoadInvalidAssetURL:
            return MAAdapterError.serverError;
        case CHBErrorCodeLoadWebViewFailed:
        case CHBErrorCodeLoadWebViewCrashed:
            return MAAdapterError.webViewError;
        case CHBErrorCodeLoadTimedOut:
        case CHBErrorCodeLoadProgressiveBufferingFailed:
            return MAAdapterError.timeout;
        case CHBErrorCodeLoadInternalError:
        case CHBErrorCodeLoadNoStorage:
        case CHBErrorCodeLoadNoMRAIDJS:
        case CHBErrorCodeLoadInvalidHTML:
        case CHBErrorCodeLoadVASTError:
        case CHBErrorCodeLoadAssetUnavailable:
        case CHBErrorCodeLoadUnsupportedCodec:
            return MAAdapterError.internalError;

        // MARK: Show (4XX)
        case CHBErrorCodeShowNoAd:
            return MAAdapterError.adNotReady;
        // An ad that expired or was invalidated after caching is no longer showable.
        case CHBErrorCodeShowAdExpired:
        case CHBErrorCodeShowAdInvalidated:
            return MAAdapterError.adExpiredError;
        case CHBErrorCodeShowNoContext:
            return MAAdapterError.missingViewController;
        case CHBErrorCodeShowTimedOut:
            return MAAdapterError.timeout;
        case CHBErrorCodeShowDisabled:
            return MAAdapterError.invalidConfiguration;
        case CHBErrorCodeShowNotInitialized:
            return MAAdapterError.notInitialized;
        case CHBErrorCodeShowAssetUnavailable:
            return MAAdapterError.internalError;
        case CHBErrorCodeShowUnknownError:
        case CHBErrorCodeShowFullscreenAlreadyShowing:
            return MAAdapterError.adDisplayFailedError;

        // MARK: Render (5XX)
        case CHBErrorCodeRenderWebViewMRAIDUnload:
        case CHBErrorCodeRenderWebViewTerminated:
            return MAAdapterError.webViewError;
        case CHBErrorCodeRenderInternalError:
        case CHBErrorCodeRenderMissingSKANParameters:
        case CHBErrorCodeRenderLoadSKProductFailed:
            return MAAdapterError.internalError;
        case CHBErrorCodeRenderUnknown:
        case CHBErrorCodeRenderVideoPlaybackError:
        case CHBErrorCodeRenderInvalidClickthroughURL:
        case CHBErrorCodeRenderAssetUnavailable:
        case CHBErrorCodeRenderUnexpectedDismiss:
            return MAAdapterError.adDisplayFailedError;
        // Click-path only, and MAX has no click-failure callback to surface these through.
        case CHBErrorCodeRenderClickIgnoredNoGesture:
        case CHBErrorCodeRenderClickIgnoredBusy:
            return MAAdapterError.unspecified;

        // MARK: Unknown (deliberately unspecified rather than guessed)
        case CHBErrorCodeLoadUnknownError:
        case CHBErrorCodeOtherUnknownError:
            return MAAdapterError.unspecified;

        default:
            [self log: @"Unmapped Chartboost error code: %ld", (long) chartBoostErrorCode];
            return MAAdapterError.unspecified;
    }
}

// NOTE: `CHBCacheError.code` carries a legacy `CHBCacheErrorCode` (0-11) when the failure comes
// from the Chartboost SDK's legacy rendering pipeline, or a `CHBErrorCode` (100-900) when it
// comes from the current one. Both pipelines are live and reach this delegate, and the two
// ranges do not overlap, so a single switch over the raw code handles both.
- (MAAdapterError *)toMaxErrorFromCHBCacheError:(CHBCacheError *)chartBoostCacheError
{
    NSInteger chartBoostCacheErrorCode = chartBoostCacheError.code;
    MAAdapterError *adapterError;
    switch ( chartBoostCacheErrorCode )
    {
        case CHBCacheErrorCodeNoAdFound:
            adapterError = MAAdapterError.noFill;
            break;
        case CHBCacheErrorCodeInternetUnavailable:
        case CHBCacheErrorCodeNetworkFailure:
            adapterError = MAAdapterError.noConnection;
            break;
        case CHBCacheErrorCodeSessionNotStarted:
            adapterError = MAAdapterError.notInitialized;
            break;
        case CHBCacheErrorCodePublisherDisabled:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case CHBCacheErrorCodeServerError:
            adapterError = MAAdapterError.serverError;
            break;
        case CHBCacheErrorCodeWebViewFailed:
            adapterError = MAAdapterError.webViewError;
            break;
        case CHBCacheErrorCodeInvalidADM:
            adapterError = MAAdapterError.badRequest;
            break;
        case CHBCacheErrorCodeInternalError:
        case CHBCacheErrorCodeAssetDownloadFailure:
        case CHBCacheErrorCodeAssetUnavailable:
        case CHBCacheErrorCodeVastError:
            adapterError = MAAdapterError.internalError;
            break;
        default:
            adapterError = [self maxErrorFromChartboostErrorCode: chartBoostCacheErrorCode];
            break;
    }

    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: chartBoostCacheErrorCode
                     mediatedNetworkErrorMessage: chartBoostCacheError.localizedDescription];
}

// See the note on -toMaxErrorFromCHBCacheError: - `CHBShowError.code` carries either a legacy
// `CHBShowErrorCode` (0-9) or a `CHBErrorCode` (100-900). Note the legacy cache and show codes
// overlap numerically but mean different things, so they must not share a switch.
- (MAAdapterError *)toMaxErrorFromCHBShowError:(CHBShowError *)chartBoostShowError
{
    NSInteger chartBoostShowErrorCode = chartBoostShowError.code;
    MAAdapterError *adapterError;
    switch ( chartBoostShowErrorCode )
    {
        case CHBShowErrorCodeNoCachedAd:
            adapterError = MAAdapterError.adNotReady;
            break;
        case CHBShowErrorCodeSessionNotStarted:
            adapterError = MAAdapterError.notInitialized;
            break;
        case CHBShowErrorCodeInternetUnavailable:
            adapterError = MAAdapterError.noConnection;
            break;
        case CHBShowErrorCodeNoViewController:
            adapterError = MAAdapterError.missingViewController;
            break;
        case CHBShowErrorCodeNoAdInstance:
        case CHBShowErrorCodePublisherDisabled:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case CHBShowErrorCodeInternalError:
        case CHBShowErrorCodeAssetsFailure:
            adapterError = MAAdapterError.internalError;
            break;
        // Both are display failures. `MAAdapterError.invalidLoadState` is arguably a closer fit
        // for AdAlreadyVisible, but this preserves the adapter's existing behavior.
        case CHBShowErrorCodePresentationFailure:
        case CHBShowErrorCodeAdAlreadyVisible:
            adapterError = MAAdapterError.adDisplayFailedError;
            break;
        default:
            adapterError = [self maxErrorFromChartboostErrorCode: chartBoostShowErrorCode];
            break;
    }

    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: chartBoostShowErrorCode
                     mediatedNetworkErrorMessage: chartBoostShowError.localizedDescription];
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
        MAAdapterError *adapterError = [self.parentAdapter toMaxErrorFromCHBShowError: error];
        
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

- (void)didExpireAd:(CHBExpirationEvent *)event
{
    [self.parentAdapter log: @"Interstitial ad expired: %@", event.ad.location];
    
    // MAX has no adapter callback for an ad expiring while cached, so flag it and fail the next
    // show attempt with `MAAdapterError.adExpiredError` rather than presenting a dead ad.
    self.parentAdapter.interstitialAdExpired = YES;
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
        MAAdapterError *adapterError = [self.parentAdapter toMaxErrorFromCHBShowError: error];
        
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
    [self.parentAdapter log: @"Rewarded complete \"%@\" with reward: %ld", event.ad.location, (long) event.reward];
    
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

- (void)didExpireAd:(CHBExpirationEvent *)event
{
    [self.parentAdapter log: @"Rewarded ad expired: %@", event.ad.location];
    
    // See the note in ALChartboostInterstitialDelegate -didExpireAd:.
    self.parentAdapter.rewardedAdExpired = YES;
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
        
        UIViewController *presentingViewController = self.parentAdapter.adViewPresentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [event.ad showFromViewController: presentingViewController];
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
        MAAdapterError *adapterError = [self.parentAdapter toMaxErrorFromCHBShowError: error];
        
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

- (void)didExpireAd:(CHBExpirationEvent *)event
{
    // Unlike the fullscreen formats, there is no show entry point for an ad view: MAAdViewAdapter
    // declares only a load method, and -didCacheAd:error: hands the view to MAX and calls
    // -showFromViewController: in the same runloop turn. An ad view therefore cannot expire
    // between load and show, so any expiry here arrives after the ad was rendered and its
    // impression recorded, where no MAX failure callback would be correct.
    [self.parentAdapter log: @"%@ ad expired: %@", self.adFormat.label, event.ad.location];
}

@end
