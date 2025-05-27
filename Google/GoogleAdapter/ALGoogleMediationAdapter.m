//
//  ALGoogleMediationAdapter.m
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Santosh Bagadi on 8/31/18.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALGoogleMediationAdapter.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "ALGoogleInterstitialDelegate.h"
#import "ALGoogleAppOpenDelegate.h"
#import "ALGoogleRewardedDelegate.h"
#import "ALGoogleAdViewDelegate.h"
#import "ALGoogleNativeAdViewDelegate.h"
#import "ALGoogleNativeAdDelegate.h"

#define ADAPTER_VERSION @"12.5.0.0"

@interface ALGoogleMediationAdapter ()

@property (nonatomic, strong) GADInterstitialAd *interstitialAd;
@property (nonatomic, strong) GADAppOpenAd *appOpenAd;
@property (nonatomic, strong) GADRewardedAd *rewardedAd;
@property (nonatomic, strong) GADBannerView *adView;
@property (nonatomic, strong) GADNativeAdView *nativeAdView;
@property (nonatomic, strong) GADAdLoader *nativeAdLoader;
@property (nonatomic, strong) GADNativeAd *nativeAd;

@property (nonatomic, strong) ALGoogleInterstitialDelegate *interstitialDelegate;
@property (nonatomic, strong) ALGoogleAppOpenDelegate *appOpenDelegate;
@property (nonatomic, strong) ALGoogleRewardedDelegate *rewardedDelegate;
@property (nonatomic, strong) ALGoogleAdViewDelegate *adViewDelegate;
@property (nonatomic, strong) ALGoogleNativeAdViewDelegate *nativeAdViewDelegate;
@property (nonatomic, strong) ALGoogleNativeAdDelegate *nativeAdDelegate;

@end

@implementation ALGoogleMediationAdapter
static NSString *const kAdaptiveBannerTypeInline = @"inline";

static ALAtomicBoolean              *ALGoogleInitialized;
static MAAdapterInitializationStatus ALGoogleInitializatationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALGoogleInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [self log: @"Initializing Google SDK..."];
    
    if ( [ALGoogleInitialized compareAndSet: NO update: YES] )
    {
        ALGoogleInitializatationStatus = MAAdapterInitializationStatusInitializing;
        
        // Prevent AdMob SDK from auto-initing its adapters in AB testing environments.
        // NOTE: If MAX makes an ad request to AdMob, and the AdMob account has AL enabled (e.g. AppLovin Bidding) _and_ detects the AdMob<->AppLovin adapter, AdMob will still attempt to initialize AppLovin
        [GADMobileAds.sharedInstance disableMediationInitialization];
        
        [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status) {
            
            GADAdapterStatus *googleAdsStatus = [status adapterStatusesByClassName][@"GADMobileAds"];
            [self log: @"Initialization complete with status %@", googleAdsStatus];
            
            // NOTE: We were able to load ads even when SDK is in "not ready" init state...
            // AdMob SDK when status "not ready": "The mediation adapter is LESS likely to fill ad requests."
            ALGoogleInitializatationStatus = ( googleAdsStatus.state == GADAdapterInitializationStateReady ) ? MAAdapterInitializationStatusInitializedSuccess : MAAdapterInitializationStatusInitializedUnknown;
            completionHandler(ALGoogleInitializatationStatus, nil);
        }];
    }
    else
    {
        completionHandler(ALGoogleInitializatationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return GADGetStringFromVersionNumber([GADMobileAds sharedInstance].versionNumber);
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for adapter %@", self];
    
    self.interstitialAd.fullScreenContentDelegate = nil;
    self.interstitialAd = nil;
    self.interstitialDelegate = nil;
    
    self.appOpenAd.fullScreenContentDelegate = nil;
    self.appOpenAd = nil;
    self.appOpenDelegate = nil;
    
    self.rewardedAd.fullScreenContentDelegate = nil;
    self.rewardedAd = nil;
    self.rewardedDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewDelegate = nil;
    
    self.nativeAdLoader.delegate = nil;
    self.nativeAdLoader = nil;
    
    [self.nativeAd unregisterAdView];
    self.nativeAd = nil;
    
    // Remove the view from MANativeAdView in case the publisher decides to re-use the native ad view.
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nil;
    
    self.nativeAdViewDelegate = nil;
    self.nativeAdDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    GADSignalRequest *signalRequest = [self createSignalRequestForAdFormat: parameters.adFormat withParameters: parameters];
    [GADMobileAds generateSignal: signalRequest completionHandler:^(GADSignal *_Nullable signal, NSError *_Nullable error) {
        
        if ( error )
        {
            [self log: @"Signal collection failed with error: %@", error];
            [delegate didFailToCollectSignalWithErrorMessage: error.description];
            
            return;
        }
        
        [self log: @"Signal collection successful"];
        [delegate didCollectSignal: signal.signalString];
    }];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    [self log: @"Loading %@interstitial ad: %@...", (isBiddingAd ? @"bidding " : @""), placementId];
    
    [self updateMuteStateFromServerParameters: parameters.serverParameters];
    
    GADInterstitialAdLoadCompletionHandler loadHandler = ^(GADInterstitialAd *_Nullable interstitialAd, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleMediationAdapter toMaxError: error];
            [self log: @"Interstitial ad (%@) failed to load with error: %@", placementId, adapterError];
            [delegate didFailToLoadInterstitialAdWithError: adapterError];
            
            return;
        }
        
        if ( !interstitialAd )
        {
            [self log: @"Interstitial ad (%@) failed to load: ad is nil", placementId];
            [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        [self log: @"Interstitial ad loaded: %@", placementId];
        
        self.interstitialAd = interstitialAd;
        self.interstitialDelegate = [[ALGoogleInterstitialDelegate alloc] initWithParentAdapter: self
                                                                            placementIdentifier: placementId
                                                                                      andNotify: delegate];
        self.interstitialAd.fullScreenContentDelegate = self.interstitialDelegate;
        
        NSString *responseId = self.interstitialAd.responseInfo.responseIdentifier;
        if ( [responseId al_isValidString] )
        {
            [delegate didLoadInterstitialAdWithExtraInfo: @{@"creative_id" : responseId}];
        }
        else
        {
            [delegate didLoadInterstitialAd];
        }
    };
    
    if ( isBiddingAd )
    {
        [GADInterstitialAd loadWithAdResponseString: parameters.bidResponse completionHandler: loadHandler];
    }
    else
    {
        GADRequest *request = [self createAdRequestForAdFormat: MAAdFormat.interstitial withParameters: parameters];
        [GADInterstitialAd loadWithAdUnitID: placementId
                                    request: request
                          completionHandler: loadHandler];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad: %@...", placementId];
    
    if ( self.interstitialAd )
    {
        UIViewController *presentingViewController = [self presentingViewControllerForParameters: parameters];
        [self.interstitialAd presentFromRootViewController: presentingViewController];
    }
    else
    {
        [self log: @"Interstitial ad failed to show: %@", placementId];
        
        MAAdapterError *error = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                             mediatedNetworkErrorCode: 0
                                          mediatedNetworkErrorMessage: @"Interstitial ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: error];
    }
}

#pragma mark - MAAppOpenAdapter Methods

- (void)loadAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegateTemp>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    [self log: @"Loading %@app open ad: %@...", (isBiddingAd ? @"bidding " : @""), placementId];
    
    [self updateMuteStateFromServerParameters: parameters.serverParameters];
    
    GADAppOpenAdLoadCompletionHandler loadHandler = ^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleMediationAdapter toMaxError: error];
            [self log: @"App open ad (%@) failed to load with error: %@", placementId, adapterError];
            [delegate didFailToLoadAppOpenAdWithError: adapterError];
            
            return;
        }
        
        if ( !appOpenAd )
        {
            [self log: @"App open ad (%@) failed to load: ad is nil", placementId];
            [delegate didFailToLoadAppOpenAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        [self log: @"App open ad loaded: %@", placementId];
        
        self.appOpenAd = appOpenAd;
        self.appOpenDelegate = [[ALGoogleAppOpenDelegate alloc] initWithParentAdapter: self
                                                                  placementIdentifier: placementId
                                                                            andNotify: delegate];
        self.appOpenAd.fullScreenContentDelegate = self.appOpenDelegate;
        
        NSString *responseId = self.appOpenAd.responseInfo.responseIdentifier;
        if ( [responseId al_isValidString] )
        {
            [delegate didLoadAppOpenAdWithExtraInfo: @{@"creative_id" : responseId}];
        }
        else
        {
            [delegate didLoadAppOpenAd];
        }
    };
    
    if ( isBiddingAd )
    {
        [GADAppOpenAd loadWithAdResponseString: parameters.bidResponse completionHandler: loadHandler];
    }
    else
    {
        GADRequest *request = [self createAdRequestForAdFormat: MAAdFormat.appOpen withParameters: parameters];
        [GADAppOpenAd loadWithAdUnitID: placementId
                               request: request
                     completionHandler: loadHandler];
    }
}

- (void)showAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegateTemp>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing app open ad: %@...", placementId];
    
    if ( self.appOpenAd )
    {
        UIViewController *presentingViewController = [self presentingViewControllerForParameters: parameters];
        [self.appOpenAd presentFromRootViewController: presentingViewController];
    }
    else
    {
        [self log: @"App open ad failed to show: %@", placementId];
        
        MAAdapterError *error = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                             mediatedNetworkErrorCode: 0
                                          mediatedNetworkErrorMessage: @"App open ad not ready"];
        [delegate didFailToDisplayAppOpenAdWithError: error];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    [self log: @"Loading %@rewarded ad: %@...", (isBiddingAd ? @"bidding " : @""), placementId];
    
    [self updateMuteStateFromServerParameters: parameters.serverParameters];
    
    GADRewardedAdLoadCompletionHandler loadHandler = ^(GADRewardedAd *_Nullable rewardedAd, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleMediationAdapter toMaxError: error];
            [self log: @"Rewarded ad (%@) failed to load with error: %@", placementId, adapterError];
            [delegate didFailToLoadRewardedAdWithError: adapterError];
            
            return;
        }
        
        if ( !rewardedAd )
        {
            [self log: @"Rewarded ad (%@) failed to load: ad is nil", placementId];
            [delegate didFailToLoadRewardedAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        [self log: @"Rewarded ad loaded: %@", placementId];
        
        self.rewardedAd = rewardedAd;
        self.rewardedDelegate = [[ALGoogleRewardedDelegate alloc] initWithParentAdapter: self
                                                                    placementIdentifier: placementId
                                                                              andNotify: delegate];
        self.rewardedAd.fullScreenContentDelegate = self.rewardedDelegate;
        
        NSString *responseId = self.rewardedAd.responseInfo.responseIdentifier;
        if ( [responseId al_isValidString] )
        {
            [delegate didLoadRewardedAdWithExtraInfo: @{@"creative_id" : responseId}];
        }
        else
        {
            [delegate didLoadRewardedAd];
        }
    };
    
    if ( isBiddingAd )
    {
        [GADRewardedAd loadWithAdResponseString: parameters.bidResponse completionHandler: loadHandler];
    }
    else
    {
        GADRequest *request = [self createAdRequestForAdFormat: MAAdFormat.rewarded withParameters: parameters];
        [GADRewardedAd loadWithAdUnitID: placementId
                                request: request
                      completionHandler: loadHandler];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad: %@...", placementId];
    
    if ( self.rewardedAd )
    {
        [self configureRewardForParameters: parameters];
        
        UIViewController *presentingViewController = [self presentingViewControllerForParameters: parameters];
        [self.rewardedAd presentFromRootViewController: presentingViewController userDidEarnRewardHandler:^{
            [self log: @"Rewarded ad user earned reward: %@", placementId];
            self.rewardedDelegate.grantedReward = YES;
        }];
    }
    else
    {
        [self log: @"Rewarded ad failed to show: %@", placementId];
        
        MAAdapterError *error = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                             mediatedNetworkErrorCode: 0
                                          mediatedNetworkErrorMessage: @"Rewarded ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: error];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    [self log: @"Loading %@%@%@ ad: %@...", (isBiddingAd ? @"bidding " : @""), (isNative ? @"native " : @""), adFormat.label, placementId];
    
    if ( isBiddingAd )
    {
        self.adView = [[GADBannerView alloc] init];
        self.adView.adUnitID = placementId;
        self.adView.rootViewController = [ALUtils topViewControllerFromKeyWindow];
        self.adViewDelegate = [[ALGoogleAdViewDelegate alloc] initWithParentAdapter: self
                                                                           adFormat: adFormat
                                                                          andNotify: delegate];
        self.adView.delegate = self.adViewDelegate;
        
        [self.adView loadWithAdResponseString: parameters.bidResponse];
    }
    else
    {
        GADRequest *request = [self createAdRequestForAdFormat: adFormat withParameters: parameters];
        
        if ( isNative )
        {
            GADNativeAdViewAdOptions *nativeAdViewOptions = [[GADNativeAdViewAdOptions alloc] init];
            nativeAdViewOptions.preferredAdChoicesPosition = [self adChoicesPlacementFromParameters: parameters];
            
            GADNativeAdImageAdLoaderOptions *nativeAdImageAdLoaderOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
            nativeAdImageAdLoaderOptions.shouldRequestMultipleImages = (adFormat == MAAdFormat.mrec); // MRECs can handle multiple images via AdMob's media view
            
            self.nativeAdViewDelegate = [[ALGoogleNativeAdViewDelegate alloc] initWithParentAdapter: self
                                                                                           adFormat: adFormat
                                                                                   serverParameters: parameters.serverParameters
                                                                                          andNotify: delegate];
            // Fetching the top view controller needs to be on the main queue
            dispatchOnMainQueue(^{
                self.nativeAdLoader = [[GADAdLoader alloc] initWithAdUnitID: placementId
                                                         rootViewController: [ALUtils topViewControllerFromKeyWindow]
                                                                    adTypes: @[GADAdLoaderAdTypeNative]
                                                                    options: @[nativeAdViewOptions, nativeAdImageAdLoaderOptions]];
                self.nativeAdLoader.delegate = self.nativeAdViewDelegate;
                
                [self.nativeAdLoader loadRequest: request];
            });
        }
        else
        {
            // Check if adaptive banner sizes should be used
            BOOL isAdaptiveBanner = [parameters.serverParameters al_boolForKey: @"adaptive_banner"];
            
            GADAdSize adSize = [self adSizeFromAdFormat: adFormat
                                       isAdaptiveBanner: isAdaptiveBanner
                                             parameters: parameters];
            self.adView = [[GADBannerView alloc] initWithAdSize: adSize];
            self.adView.frame = (CGRect) {.size = adSize.size};
            self.adView.adUnitID = placementId;
            self.adView.rootViewController = [ALUtils topViewControllerFromKeyWindow];
            self.adViewDelegate = [[ALGoogleAdViewDelegate alloc] initWithParentAdapter: self
                                                                               adFormat: adFormat
                                                                              andNotify: delegate];
            self.adView.delegate = self.adViewDelegate;
            
            [self.adView loadRequest: request];
        }
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    [self log: @"Loading %@native ad: %@...", (isBiddingAd ? @"bidding " : @""), placementId];
    
    self.nativeAdDelegate = [[ALGoogleNativeAdDelegate alloc] initWithParentAdapter: self
                                                                         parameters: parameters
                                                                          andNotify: delegate];
    
    if ( isBiddingAd )
    {
        // Fetching the top view controller needs to be on the main queue
        dispatchOnMainQueue(^{
            self.nativeAdLoader = [[GADAdLoader alloc] initWithRootViewController: [ALUtils topViewControllerFromKeyWindow]];
            self.nativeAdLoader.delegate = self.nativeAdDelegate;
            
            [self.nativeAdLoader loadWithAdResponseString: parameters.bidResponse];
        });
    }
    else
    {
        GADRequest *request = [self createAdRequestForAdFormat: MAAdFormat.native withParameters: parameters];
        
        GADNativeAdViewAdOptions *nativeAdViewOptions = [[GADNativeAdViewAdOptions alloc] init];
        nativeAdViewOptions.preferredAdChoicesPosition = [self adChoicesPlacementFromParameters: parameters];
        
        GADNativeAdImageAdLoaderOptions *nativeAdImageAdLoaderOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
        
        // Medium templates can handle multiple images via AdMob's media view
        NSString *templateName = [parameters.serverParameters al_stringForKey: @"template" defaultValue: @""];
        nativeAdImageAdLoaderOptions.shouldRequestMultipleImages = [templateName containsString: @"medium"];
        
        // Fetching the top view controller needs to be on the main queue
        dispatchOnMainQueue(^{
            self.nativeAdLoader = [[GADAdLoader alloc] initWithAdUnitID: placementId
                                                     rootViewController: [ALUtils topViewControllerFromKeyWindow]
                                                                adTypes: @[GADAdLoaderAdTypeNative]
                                                                options: @[nativeAdViewOptions, nativeAdImageAdLoaderOptions]];
            self.nativeAdLoader.delegate = self.nativeAdDelegate;
            
            [self.nativeAdLoader loadRequest: request];
        });
    }
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(NSError *)googleAdsError
{
    GADErrorCode googleAdsErrorCode = googleAdsError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( googleAdsErrorCode )
    {
        case GADErrorInvalidRequest:
        case GADErrorInvalidArgument:
            adapterError = MAAdapterError.badRequest;
            break;
        case GADErrorNoFill:
        case GADErrorMediationAdapterError: /* Considered no fill by AdMob, might be a bug */
            adapterError = MAAdapterError.noFill;
            break;
        case GADErrorNetworkError:
            adapterError = MAAdapterError.noConnection;
            break;
        case GADErrorServerError:
        case GADErrorMediationDataError:
        case GADErrorReceivedInvalidAdString:
            adapterError = MAAdapterError.serverError;
            break;
        case GADErrorOSVersionTooLow:
        case GADErrorApplicationIdentifierMissing:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case GADErrorTimeout:
            adapterError = MAAdapterError.timeout;
            break;
        case GADErrorMediationInvalidAdSize:
            adapterError = MAAdapterError.signalCollectionNotSupported;
            break;
        case GADErrorInternalError:
            adapterError = MAAdapterError.internalError;
            break;
        case GADErrorAdAlreadyUsed:
            adapterError = MAAdapterError.invalidLoadState;
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: googleAdsErrorCode
                     mediatedNetworkErrorMessage: googleAdsError.localizedDescription];
}

- (GADAdSize)adSizeFromAdFormat:(MAAdFormat *)adFormat
               isAdaptiveBanner:(BOOL)isAdaptiveBanner
                     parameters:(id<MAAdapterParameters>)parameters
{
    if ( isAdaptiveBanner && [self isAdaptiveAdFormat: adFormat parameters: parameters] )
    {
        return [self adaptiveAdSizeFromParameters: parameters];
    }
    
    if ( adFormat == MAAdFormat.banner )
    {
        return GADAdSizeBanner;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return GADAdSizeLeaderboard;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return GADAdSizeMediumRectangle;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return GADAdSizeBanner;
    }
}

- (GADAdSize)adaptiveAdSizeFromParameters:(id<MAAdapterParameters>)parameters
{
    CGFloat bannerWidth = [self adaptiveBannerWidthFromParameters: parameters];
    __block GADAdSize adSize;
    
    if ( [self isInlineAdaptiveBannerFromParameters: parameters] )
    {
        CGFloat inlineMaxHeight = [self inlineAdaptiveBannerMaxHeightFromParameters: parameters];
        if ( inlineMaxHeight > 0 )
        {
            dispatchSyncOnMainQueue(^{
                adSize = GADInlineAdaptiveBannerAdSizeWithWidthAndMaxHeight(bannerWidth, inlineMaxHeight);
            });
        }
        else
        {
            dispatchSyncOnMainQueue(^{
                adSize = GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(bannerWidth);
            });
        }
    }
    else // Return anchored size by default
    {
        dispatchSyncOnMainQueue(^{
            adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(bannerWidth);
        });
    }
    
    return adSize;
}

- (BOOL)isAdaptiveAdFormat:(MAAdFormat *)adFormat parameters:(id<MAAdapterParameters>)parameters
{
    // Adaptive banners must be inline for MRECs
    BOOL isInlineAdaptiveMRec = ( adFormat == MAAdFormat.mrec ) && [self isInlineAdaptiveBannerFromParameters: parameters];
    return isInlineAdaptiveMRec || adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader;
}

- (BOOL)isInlineAdaptiveBannerFromParameters:(id<MAAdapterParameters>)parameters
{
    NSString *adaptiveBannerType = [parameters.localExtraParameters al_stringForKey: @"adaptive_banner_type"];
    return [kAdaptiveBannerTypeInline al_isEqualToStringIgnoringCase: adaptiveBannerType];
}

- (CGFloat)inlineAdaptiveBannerMaxHeightFromParameters:(id<MAAdapterParameters>)parameters
{
    return [parameters.localExtraParameters al_numberForKey: @"inline_adaptive_banner_max_height" defaultValue: @(-1.0)].floatValue;
}

- (CGFloat)adaptiveBannerWidthFromParameters:(id<MAAdapterParameters>)parameters
{
    NSNumber *customWidth = [parameters.localExtraParameters al_numberForKey: @"adaptive_banner_width"];
    if ( customWidth != nil )
    {
        return customWidth.floatValue;
    }
    
    UIViewController *viewController = [ALUtils topViewControllerFromKeyWindow];
    UIWindow *window = viewController.view.window;
    CGRect frame = UIEdgeInsetsInsetRect(window.frame, window.safeAreaInsets);
    
    return CGRectGetWidth(frame);
}

- (GADAdFormat)adFormatFromParameters:(id<MASignalCollectionParameters>)parameters
{
    MAAdFormat *adFormat = parameters.adFormat;
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"] || adFormat == MAAdFormat.native;
    if ( isNative )
    {
        return GADAdFormatNative;
    }
    else if ( [adFormat isAdViewAd] )
    {
        return GADAdFormatBanner;
    }
    else if ( adFormat == MAAdFormat.interstitial )
    {
        return GADAdFormatInterstitial;
    }
    else if ( adFormat == MAAdFormat.rewarded )
    {
        return GADAdFormatRewarded;
    }
    // NOTE: App open ads were added in AppLovin v11.5.0 and must be checked after all the other ad formats to avoid throwing an exception
    else if ( adFormat == MAAdFormat.appOpen )
    {
        return GADAdFormatAppOpen;
    }
    
    [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
    
    return -1;
}

- (GADSignalRequest *)createSignalRequestForAdFormat:(MAAdFormat *)adFormat withParameters:(id<MASignalCollectionParameters>)parameters
{
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    
    NSString *bidderType = [serverParameters al_stringForKey: @"bidder" defaultValue: @""];
    BOOL isDv360Bidding = [@"dv360" al_isEqualToStringIgnoringCase: bidderType];
    NSString *signalType = isDv360Bidding ? @"requester_type_3" : @"requester_type_2";
    
    GADSignalRequest *request;
    NSMutableDictionary<NSString *, id> *extraParams = [NSMutableDictionary dictionary];
    
    if ( [adFormat isAdViewAd] )
    {
        request = [[GADBannerSignalRequest alloc] initWithSignalType: signalType];
        
        BOOL isAdaptiveBanner = [parameters.localExtraParameters al_boolForKey: @"adaptive_banner"];
        GADAdSize adSize = [self adSizeFromAdFormat: adFormat
                                   isAdaptiveBanner: isAdaptiveBanner
                                         parameters: parameters];
        ((GADBannerSignalRequest *) request).adSize = adSize;
    }
    else if ( adFormat == MAAdFormat.interstitial )
    {
        request = [[GADInterstitialSignalRequest alloc] initWithSignalType: signalType];
    }
    else if ( adFormat == MAAdFormat.rewarded )
    {
        request = [[GADRewardedSignalRequest alloc] initWithSignalType: signalType];
    }
    else if ( adFormat == MAAdFormat.native )
    {
        GADNativeSignalRequest *nativeSignalRequest = [[GADNativeSignalRequest alloc] initWithSignalType: signalType];
        nativeSignalRequest.preferredAdChoicesPosition = [self adChoicesPlacementFromParameters: parameters];
        nativeSignalRequest.adLoaderAdTypes = [NSSet setWithObject: GADAdLoaderAdTypeNative];
        
        // Medium templates can handle multiple images via AdMob's media view
        NSString *templateName = [parameters.serverParameters al_stringForKey: @"template" defaultValue: @""];
        nativeSignalRequest.shouldRequestMultipleImages = [templateName containsString: @"medium"];
        
        request = nativeSignalRequest;
    }
    // NOTE: App open ads were added in AppLovin v11.5.0 and must be checked after all the other ad formats to avoid throwing an exception
    else if ( adFormat == MAAdFormat.appOpen )
    {
        request = [[GADAppOpenSignalRequest alloc] initWithSignalType: signalType];
    }
    else
    {
        [NSException raise: NSInvalidArgumentException
                    format: @"Unable to generate signal request class due to unsupported ad format: %@", adFormat];
    }
    
    request.requestAgent = isDv360Bidding ? @"applovin_dv360" : @"applovin";
    
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent && !hasUserConsent.boolValue )
    {
        extraParams[@"npa"] = @"1"; // Non-personalized ads
    }
    
    NSNumber *isDoNotSell = [parameters isDoNotSell];
    if ( isDoNotSell && isDoNotSell.boolValue )
    {
        // Restrict data processing - https://developers.google.com/admob/ios/ccpa
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"gad_rdp"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"gad_rdp"];
    }
    
    NSDictionary<NSString *, id> *localExtraParameters = parameters.localExtraParameters;
    
    NSString *contentURL = [localExtraParameters al_stringForKey: @"google_content_url"];
    if ( [contentURL al_isValidString] )
    {
        request.contentURL = contentURL;
    }
    
    NSArray *neighbouringContentURLStrings = [localExtraParameters al_arrayForKey: @"google_neighbouring_content_url_strings"];
    if ( neighbouringContentURLStrings )
    {
        request.neighboringContentURLStrings = neighbouringContentURLStrings;
    }
    
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = extraParams;
    [request registerAdNetworkExtras: extras];
    
    return request;
}

- (GADRequest *)createAdRequestForAdFormat:(MAAdFormat *)adFormat withParameters:(id<MAAdapterParameters>)parameters
{
    GADRequest *request = [GADRequest request];
    [request setRequestAgent: @"applovin"];
    
    NSMutableDictionary<NSString *, id> *extraParameters = [NSMutableDictionary dictionary];
    
    NSString *eventId = [parameters.serverParameters al_stringForKey: @"event_id"];
    if ( [eventId al_isValidString] )
    {
        extraParameters[@"placement_req_id"] = eventId;
    }
    
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent && !hasUserConsent.boolValue )
    {
        extraParameters[@"npa"] = @"1"; // Non-personalized ads
    }
    
    NSNumber *isDoNotSell = [parameters isDoNotSell];
    if ( isDoNotSell && isDoNotSell.boolValue )
    {
        // Restrict data processing - https://developers.google.com/admob/ios/ccpa
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"gad_rdp"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"gad_rdp"];
    }
    
    NSDictionary<NSString *, id> *localExtraParameters = parameters.localExtraParameters;
    
    NSString *maxAdContentRating = [localExtraParameters al_stringForKey: @"google_max_ad_content_rating"];
    if ( [maxAdContentRating al_isValidString] )
    {
        extraParameters[@"max_ad_content_rating"] = maxAdContentRating;
    }
    
    NSString *contentURL = [localExtraParameters al_stringForKey: @"google_content_url"];
    if ( [contentURL al_isValidString] )
    {
        request.contentURL = contentURL;
    }
    
    NSArray *neighbouringContentURLStrings = [localExtraParameters al_arrayForKey: @"google_neighbouring_content_url_strings"];
    if ( neighbouringContentURLStrings )
    {
        request.neighboringContentURLStrings = neighbouringContentURLStrings;
    }
    
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = extraParameters;
    [request registerAdNetworkExtras: extras];
    
    return request;
}

/**
 * Update the global mute state for AdMob - must be done _before_ ad load to restrict inventory which requires playing with volume.
 */
- (void)updateMuteStateFromServerParameters:(NSDictionary<NSString *, id> *)serverParameters
{
    if ( [serverParameters al_containsValueForKey: @"is_muted"] )
    {
        BOOL muted = [serverParameters al_numberForKey: @"is_muted"].boolValue;
        [[GADMobileAds sharedInstance] setApplicationMuted: muted];
        [[GADMobileAds sharedInstance] setApplicationVolume: muted ? 0.0f : 1.0f];
    }
}

/**
 * This is a helper method that our SDK uses to get the adaptive banner size dynamically. Do NOT rename.
 */
+ (CGSize)currentOrientationAchoredAdaptiveBannerSizeWithWidth:(CGFloat)width
{
    GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width);
    return adSize.size;
}

- (NSInteger)adChoicesPlacementFromParameters:(id<MAAdapterParameters>)parameters
{
    // Publishers can set via nativeAdLoader.setLocalExtraParameterForKey("admob_ad_choices_placement", value: Int)
    NSDictionary<NSString *, id> *localExtraParams = parameters.localExtraParameters;
    id adChoicesPlacementObj = localExtraParams ? localExtraParams[@"admob_ad_choices_placement"] : nil;
    
    return [self isValidAdChoicesPlacement: adChoicesPlacementObj] ? ((NSNumber *) adChoicesPlacementObj).integerValue : GADAdChoicesPositionTopRightCorner;
}

- (BOOL)isValidAdChoicesPlacement:(id)placementObj
{
    if ( [placementObj isKindOfClass: [NSNumber class]] )
    {
        GADAdChoicesPosition rawValue = ((NSNumber *) placementObj).integerValue;
        
        return rawValue == GADAdChoicesPositionTopRightCorner
        || rawValue == GADAdChoicesPositionTopLeftCorner
        || rawValue == GADAdChoicesPositionBottomRightCorner
        || rawValue == GADAdChoicesPositionBottomLeftCorner;
    }
    
    return NO;
}

- (UIViewController *)presentingViewControllerForParameters:(id<MAAdapterResponseParameters>)parameters
{
    return parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
}

@end
