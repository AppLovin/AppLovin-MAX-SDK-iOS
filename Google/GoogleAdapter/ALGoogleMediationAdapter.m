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
#import "ALGoogleRewardedInterstitialDelegate.h"
#import "ALGoogleAdViewDelegate.h"
#import "ALGoogleNativeAdViewDelegate.h"
#import "ALGoogleNativeAdDelegate.h"

#define ADAPTER_VERSION @"11.6.0.0"

@interface ALGoogleMediationAdapter ()

@property (nonatomic, strong) GADInterstitialAd *interstitialAd;
@property (nonatomic, strong) GADAppOpenAd *appOpenAd;
@property (nonatomic, strong) GADInterstitialAd *appOpenInterstitialAd;
@property (nonatomic, strong) GADRewardedInterstitialAd *rewardedInterstitialAd;
@property (nonatomic, strong) GADRewardedAd *rewardedAd;
@property (nonatomic, strong) GADBannerView *adView;
@property (nonatomic, strong) GADNativeAdView *nativeAdView;
@property (nonatomic, strong) GADAdLoader *nativeAdLoader;
@property (nonatomic, strong) GADNativeAd *nativeAd;

@property (nonatomic, strong) ALGoogleInterstitialDelegate *interstitialDelegate;
@property (nonatomic, strong) ALGoogleAppOpenDelegate *appOpenDelegate;
@property (nonatomic, strong) ALGoogleAppOpenDelegate *appOpenInterstitialAdDelegate;
@property (nonatomic, strong) ALGoogleRewardedInterstitialDelegate *rewardedInterstitialDelegate;
@property (nonatomic, strong) ALGoogleRewardedDelegate *rewardedDelegate;
@property (nonatomic, strong) ALGoogleAdViewDelegate *adViewDelegate;
@property (nonatomic, strong) ALGoogleNativeAdViewDelegate *nativeAdViewDelegate;
@property (nonatomic, strong) ALGoogleNativeAdDelegate *nativeAdDelegate;

@end

@implementation ALGoogleMediationAdapter
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
        
        // Ads may be preloaded by the Mobile Ads SDK or mediation partner SDKs upon calling startWithCompletionHandler:. So set request configuration with parameters (like consent)
        [self setRequestConfigurationWithParameters: parameters];
        
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
    
    self.appOpenInterstitialAd.fullScreenContentDelegate = nil;
    self.appOpenInterstitialAd = nil;
    self.appOpenInterstitialAdDelegate = nil;
    
    self.rewardedInterstitialAd.fullScreenContentDelegate = nil;
    self.rewardedInterstitialAd = nil;
    self.rewardedInterstitialDelegate = nil;
    
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
    
    // Remove the view from MANativeAdView in case the publisher decies to re-use the native ad view.
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nil;
    
    self.nativeAdViewDelegate = nil;
    self.nativeAdDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self setRequestConfigurationWithParameters: parameters];
    GADRequest *adRequest = [self createAdRequestForBiddingAd: YES
                                                     adFormat: parameters.adFormat
                                               withParameters: parameters];
    
    [GADQueryInfo createQueryInfoWithRequest: adRequest
                                    adFormat: [self adFormatFromParameters: parameters]
                           completionHandler:^(GADQueryInfo *_Nullable queryInfo, NSError *_Nullable error) {
        
        if ( error )
        {
            [self log: @"Signal collection failed with error: %@", error];
            [delegate didFailToCollectSignalWithErrorMessage: error.description];
            
            return;
        }
        
        if ( !queryInfo )
        {
            NSString *errorMessage = @"Unexpected error - query info is nil";
            [self log: @"Signal collection failed with error: %@", errorMessage];
            [delegate didFailToCollectSignalWithErrorMessage: errorMessage];
            
            return;
        }
        
        [self log: @"Signal collection successful"];
        [delegate didCollectSignal: queryInfo.query];
    }];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    [self log: @"Loading %@interstitial ad: %@...", ( isBiddingAd ? @"bidding " : @"" ), placementIdentifier];
    
    [self updateMuteStateFromResponseParameters: parameters];
    [self setRequestConfigurationWithParameters: parameters];
    GADRequest *request = [self createAdRequestForBiddingAd: isBiddingAd
                                                   adFormat: MAAdFormat.interstitial
                                             withParameters: parameters];
    
    [GADInterstitialAd loadWithAdUnitID: placementIdentifier
                                request: request
                      completionHandler:^(GADInterstitialAd *_Nullable interstitialAd, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleMediationAdapter toMaxError: error];
            [self log: @"Interstitial ad (%@) failed to load with error: %@", placementIdentifier, adapterError];
            [delegate didFailToLoadInterstitialAdWithError: adapterError];
            
            return;
        }
        
        if ( !interstitialAd )
        {
            [self log: @"Interstitial ad (%@) failed to load: ad is nil", placementIdentifier];
            [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        [self log: @"Interstitial ad loaded: %@", placementIdentifier];
        
        self.interstitialAd = interstitialAd;
        self.interstitialDelegate = [[ALGoogleInterstitialDelegate alloc] initWithParentAdapter: self
                                                                            placementIdentifier: placementIdentifier
                                                                                      andNotify: delegate];
        self.interstitialAd.fullScreenContentDelegate = self.interstitialDelegate;
        
        NSString *responseId = self.interstitialAd.responseInfo.responseIdentifier;
        if ( ALSdk.versionCode >= 6150000 && [responseId al_isValidString] )
        {
            [delegate performSelector: @selector(didLoadInterstitialAdWithExtraInfo:)
                           withObject: @{@"creative_id" : responseId}];
        }
        else
        {
            [delegate didLoadInterstitialAd];
        }
    }];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad: %@...", placementIdentifier];
    
    if ( self.interstitialAd )
    {
        UIViewController *presentingViewController = [self presentingViewControllerForParameters: parameters];
        [self.interstitialAd presentFromRootViewController: presentingViewController];
    }
    else
    {
        [self log: @"Interstitial ad failed to show: %@", placementIdentifier];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205
                                                                             errorString: @"Ad Display Failed"
                                                                  thirdPartySdkErrorCode: 0
                                                               thirdPartySdkErrorMessage: @"Interstitial ad not ready"]];
#pragma clang diagnostic pop
    }
}

#pragma mark - MAAppOpenAdapter Methods

- (void)loadAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegateTemp>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    BOOL isInterstitial = [parameters.serverParameters al_boolForKey: @"is_inter_placement"];
    
    [self log: @"Loading %@app open %@ad: %@...", ( isBiddingAd ? @"bidding " : @"" ), ( isInterstitial ? @"interstitial " : @"" ), placementIdentifier];
    
    [self updateMuteStateFromResponseParameters: parameters];
    [self setRequestConfigurationWithParameters: parameters];
    
    if ( isInterstitial )
    {
        GADRequest *request = [self createAdRequestForBiddingAd: isBiddingAd
                                                       adFormat: MAAdFormat.interstitial
                                                 withParameters: parameters];
        
        [GADInterstitialAd loadWithAdUnitID: placementIdentifier
                                    request: request
                          completionHandler:^(GADInterstitialAd *_Nullable interstitialAd, NSError *_Nullable error) {
            
            if ( error )
            {
                MAAdapterError *adapterError = [ALGoogleMediationAdapter toMaxError: error];
                [self log: @"App open interstitial ad (%@) failed to load with error: %@", placementIdentifier, adapterError];
                [delegate didFailToLoadAppOpenAdWithError: adapterError];
                
                return;
            }
            
            if ( !interstitialAd )
            {
                [self log: @"App open interstitial ad (%@) failed to load: ad is nil", placementIdentifier];
                [delegate didFailToLoadAppOpenAdWithError: MAAdapterError.adNotReady];
                
                return;
            }
            
            [self log: @"App open interstitial ad loaded: %@", placementIdentifier];
            
            self.appOpenInterstitialAd = interstitialAd;
            self.appOpenInterstitialAdDelegate = [[ALGoogleAppOpenDelegate alloc] initWithParentAdapter: self
                                                                                    placementIdentifier: placementIdentifier
                                                                                              andNotify: delegate];
            self.appOpenInterstitialAd.fullScreenContentDelegate = self.appOpenInterstitialAdDelegate;
            
            NSString *responseId = self.appOpenInterstitialAd.responseInfo.responseIdentifier;
            if ( [responseId al_isValidString] )
            {
                [delegate didLoadAppOpenAdWithExtraInfo: @{@"creative_id" : responseId}];
            }
            else
            {
                [delegate didLoadAppOpenAd];
            }
        }];
    }
    else
    {
        GADRequest *request = [self createAdRequestForBiddingAd: isBiddingAd
                                                       adFormat: MAAdFormat.appOpen
                                                 withParameters: parameters];
        
        [GADAppOpenAd loadWithAdUnitID: placementIdentifier
                               request: request
                     completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
            
            if ( error )
            {
                MAAdapterError *adapterError = [ALGoogleMediationAdapter toMaxError: error];
                [self log: @"App open ad (%@) failed to load with error: %@", placementIdentifier, adapterError];
                [delegate didFailToLoadAppOpenAdWithError: adapterError];
                
                return;
            }
            
            if ( !appOpenAd )
            {
                [self log: @"App open ad (%@) failed to load: ad is nil", placementIdentifier];
                [delegate didFailToLoadAppOpenAdWithError: MAAdapterError.adNotReady];
                
                return;
            }
            
            [self log: @"App open ad loaded: %@", placementIdentifier];
            
            self.appOpenAd = appOpenAd;
            self.appOpenDelegate = [[ALGoogleAppOpenDelegate alloc] initWithParentAdapter: self
                                                                      placementIdentifier: placementIdentifier
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
        }];
    }
}

- (void)showAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegateTemp>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isInterstitial = [parameters.serverParameters al_boolForKey: @"is_inter_placement"];
    [self log: @"Showing app open %@ad: %@...", ( isInterstitial ? @"interstitial " : @"" ), placementIdentifier];
    
    if ( self.appOpenInterstitialAd )
    {
        UIViewController *presentingViewController = [self presentingViewControllerForParameters: parameters];
        [self.appOpenInterstitialAd presentFromRootViewController: presentingViewController];
    }
    else if ( self.appOpenAd )
    {
        UIViewController *presentingViewController = [self presentingViewControllerForParameters: parameters];
        [self.appOpenAd presentFromRootViewController: presentingViewController];
    }
    else
    {
        [self log: @"App open ad failed to show: %@", placementIdentifier];
        [delegate didFailToDisplayAppOpenAdWithError: [MAAdapterError errorWithCode: -4205
                                                                        errorString: @"Ad Display Failed"
                                                           mediatedNetworkErrorCode: 0
                                                        mediatedNetworkErrorMessage: @"App open ad not ready"]];
    }
}

#pragma mark - MARewardedInterstitialAdapter Methods

- (void)loadRewardedInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    [self log: @"Loading %@rewarded interstitial ad: %@...", ( isBiddingAd ? @"bidding " : @"" ), placementIdentifier];
    
    [self updateMuteStateFromResponseParameters: parameters];
    [self setRequestConfigurationWithParameters: parameters];
    GADRequest *request = [self createAdRequestForBiddingAd: isBiddingAd
                                                   adFormat: MAAdFormat.rewardedInterstitial
                                             withParameters: parameters];
    
    [GADRewardedInterstitialAd loadWithAdUnitID: placementIdentifier
                                        request: request
                              completionHandler:^(GADRewardedInterstitialAd * _Nullable rewardedInterstitialAd, NSError * _Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleMediationAdapter toMaxError: error];
            [self log: @"Rewarded interstitial ad (%@) failed to load with error: %@", placementIdentifier, adapterError];
            [delegate didFailToLoadRewardedInterstitialAdWithError: adapterError];
            
            return;
        }
        
        if ( !rewardedInterstitialAd )
        {
            [self log: @"Rewarded interstitial ad (%@) failed to load: ad is nil", placementIdentifier];
            [delegate didFailToLoadRewardedInterstitialAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        [self log: @"Rewarded interstitial ad loaded: %@", placementIdentifier];
        
        self.rewardedInterstitialAd = rewardedInterstitialAd;
        self.rewardedInterstitialDelegate = [[ALGoogleRewardedInterstitialDelegate alloc] initWithParentAdapter: self
                                                                                            placementIdentifier: placementIdentifier
                                                                                                      andNotify: delegate];
        self.rewardedInterstitialAd.fullScreenContentDelegate = self.rewardedInterstitialDelegate;
        
        NSString *responseId = self.rewardedInterstitialAd.responseInfo.responseIdentifier;
        if ( ALSdk.versionCode >= 6150000 && [responseId al_isValidString] )
        {
            [delegate performSelector: @selector(didLoadRewardedInterstitialAdWithExtraInfo:)
                           withObject: @{@"creative_id" : responseId}];
        }
        else
        {
            [delegate didLoadRewardedInterstitialAd];
        }
    }];
}

- (void)showRewardedInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded interstitial ad: %@...", placementIdentifier];
    
    if ( self.rewardedInterstitialAd )
    {
        [self configureRewardForParameters: parameters];
        
        UIViewController *presentingViewController = [self presentingViewControllerForParameters: parameters];
        [self.rewardedInterstitialAd presentFromRootViewController: presentingViewController userDidEarnRewardHandler:^{
            [self log: @"Rewarded interstitial ad user earned reward: %@", placementIdentifier];
            self.rewardedInterstitialDelegate.grantedReward = YES;
        }];
    }
    else
    {
        [self log: @"Rewarded interstitial ad failed to show: %@", placementIdentifier];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayRewardedInterstitialAdWithError: [MAAdapterError errorWithCode: -4205
                                                                                     errorString: @"Ad Display Failed"
                                                                          thirdPartySdkErrorCode: 0
                                                                       thirdPartySdkErrorMessage: @"Rewarded Interstitial ad not ready"]];
#pragma clang diagnostic pop
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    [self log: @"Loading %@rewarded ad: %@...", ( isBiddingAd ? @"bidding " : @"" ), placementIdentifier];
    
    [self updateMuteStateFromResponseParameters: parameters];
    [self setRequestConfigurationWithParameters: parameters];
    GADRequest *request = [self createAdRequestForBiddingAd: isBiddingAd
                                                   adFormat: MAAdFormat.rewarded
                                             withParameters: parameters];
    
    [GADRewardedAd loadWithAdUnitID: placementIdentifier
                            request: request
                  completionHandler:^(GADRewardedAd *_Nullable rewardedAd, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleMediationAdapter toMaxError: error];
            [self log: @"Rewarded ad (%@) failed to load with error: %@", placementIdentifier, adapterError];
            [delegate didFailToLoadRewardedAdWithError: adapterError];
            
            return;
        }
        
        if ( !rewardedAd )
        {
            [self log: @"Rewarded ad (%@) failed to load: ad is nil", placementIdentifier];
            [delegate didFailToLoadRewardedAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        [self log: @"Rewarded ad loaded: %@", placementIdentifier];
        
        self.rewardedAd = rewardedAd;
        self.rewardedDelegate = [[ALGoogleRewardedDelegate alloc] initWithParentAdapter: self
                                                                    placementIdentifier: placementIdentifier
                                                                              andNotify: delegate];
        self.rewardedAd.fullScreenContentDelegate = self.rewardedDelegate;
        
        NSString *responseId = self.rewardedAd.responseInfo.responseIdentifier;
        if ( ALSdk.versionCode >= 6150000 && [responseId al_isValidString] )
        {
            [delegate performSelector: @selector(didLoadRewardedAdWithExtraInfo:)
                           withObject: @{@"creative_id" : responseId}];
        }
        else
        {
            [delegate didLoadRewardedAd];
        }
    }];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad: %@...", placementIdentifier];
    
    if ( self.rewardedAd )
    {
        [self configureRewardForParameters: parameters];
        
        UIViewController *presentingViewController = [self presentingViewControllerForParameters: parameters];
        [self.rewardedAd presentFromRootViewController: presentingViewController userDidEarnRewardHandler:^{
            [self log: @"Rewarded ad user earned reward: %@", placementIdentifier];
            self.rewardedDelegate.grantedReward = YES;
        }];
    }
    else
    {
        [self log: @"Rewarded ad failed to show: %@", placementIdentifier];
        
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
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    [self log: @"Loading %@%@%@ ad: %@...", ( isBiddingAd ? @"bidding " : @""), ( isNative ? @"native " : @"" ), adFormat.label, placementIdentifier];
    
    [self setRequestConfigurationWithParameters: parameters];
    GADRequest *request = [self createAdRequestForBiddingAd: isBiddingAd
                                                   adFormat: adFormat
                                             withParameters: parameters];
    
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
            self.nativeAdLoader = [[GADAdLoader alloc] initWithAdUnitID: placementIdentifier
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
        BOOL isAdaptiveBanner = [parameters.serverParameters al_boolForKey: @"adaptive_banner" defaultValue: NO];
        
        GADAdSize adSize = [self adSizeFromAdFormat: adFormat
                                   isAdaptiveBanner: isAdaptiveBanner
                                         parameters: parameters];
        self.adView = [[GADBannerView alloc] initWithAdSize: adSize];
        self.adView.frame = (CGRect) {.size = adSize.size};
        self.adView.adUnitID = placementIdentifier;
        self.adView.rootViewController = [ALUtils topViewControllerFromKeyWindow];
        self.adViewDelegate = [[ALGoogleAdViewDelegate alloc] initWithParentAdapter: self
                                                                           adFormat: adFormat
                                                                          andNotify: delegate];
        self.adView.delegate = self.adViewDelegate;
        
        [self.adView loadRequest: request];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    [self log: @"Loading %@native ad: %@...", ( isBiddingAd ? @"bidding " : @""), placementIdentifier];
    
    [self setRequestConfigurationWithParameters: parameters];
    GADRequest *request = [self createAdRequestForBiddingAd: isBiddingAd
                                                   adFormat: MAAdFormat.native
                                             withParameters: parameters];
    
    GADNativeAdViewAdOptions *nativeAdViewOptions = [[GADNativeAdViewAdOptions alloc] init];
    nativeAdViewOptions.preferredAdChoicesPosition = [self adChoicesPlacementFromParameters: parameters];
    
    GADNativeAdImageAdLoaderOptions *nativeAdImageAdLoaderOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
    
    // Medium templates can handle multiple images via AdMob's media view
    NSString *templateName = [parameters.serverParameters al_stringForKey: @"template" defaultValue: @""];
    nativeAdImageAdLoaderOptions.shouldRequestMultipleImages = [templateName containsString: @"medium"];
    
    self.nativeAdDelegate = [[ALGoogleNativeAdDelegate alloc] initWithParentAdapter: self
                                                                         parameters: parameters
                                                                          andNotify: delegate];
    
    // Fetching the top view controller needs to be on the main queue
    dispatchOnMainQueue(^{
        self.nativeAdLoader = [[GADAdLoader alloc] initWithAdUnitID: placementIdentifier
                                                 rootViewController: [ALUtils topViewControllerFromKeyWindow]
                                                            adTypes: @[GADAdLoaderAdTypeNative]
                                                            options: @[nativeAdViewOptions, nativeAdImageAdLoaderOptions]];
        self.nativeAdLoader.delegate = self.nativeAdDelegate;
        
        [self.nativeAdLoader loadRequest: request];
    });
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
        case GADErrorMediationNoFill:
            adapterError = MAAdapterError.noFill;
            break;
        case GADErrorNetworkError:
            adapterError = MAAdapterError.noConnection;
            break;
        case GADErrorServerError:
        case GADErrorMediationDataError:
        case GADErrorReceivedInvalidResponse:
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
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: googleAdsErrorCode
               thirdPartySdkErrorMessage: googleAdsError.localizedDescription];
#pragma clang diagnostic pop
}

- (GADAdSize)adSizeFromAdFormat:(MAAdFormat *)adFormat
               isAdaptiveBanner:(BOOL)isAdaptiveBanner
                     parameters:(id<MAAdapterParameters>)parameters
{
    if ( adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader )
    {
        if ( isAdaptiveBanner )
        {
            __block GADAdSize adSize;
            
            dispatchSyncOnMainQueue(^{
                adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth([self adaptiveBannerWidthFromParameters: parameters]);
            });
            
            return adSize;
        }
        else
        {
            return adFormat == MAAdFormat.banner ? GADAdSizeBanner : GADAdSizeLeaderboard;
        }
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

- (CGFloat)adaptiveBannerWidthFromParameters:(id<MAAdapterParameters>)parameters
{
    if ( ALSdk.versionCode >= 11000000 )
    {
        NSNumber *customWidth = [parameters.localExtraParameters al_numberForKey: @"adaptive_banner_width"];
        if ( customWidth != nil )
        {
            return customWidth.floatValue;
        }
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
    else if ( adFormat == MAAdFormat.rewardedInterstitial )
    {
        return GADAdFormatRewardedInterstitial;
    }
    // NOTE: App open ads were added in AppLovin v11.5.0 and must be checked after all the other ad formats to avoid throwing an exception
    else if ( adFormat == MAAdFormat.appOpen )
    {
        return GADAdFormatAppOpen;
    }
    
    [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
    
    return -1;
}

- (void)setRequestConfigurationWithParameters:(id<MAAdapterParameters>)parameters
{
    [GADMobileAds sharedInstance].requestConfiguration.tagForChildDirectedTreatment = [parameters isAgeRestrictedUser];
}

- (GADRequest *)createAdRequestForBiddingAd:(BOOL)isBiddingAd
                                   adFormat:(MAAdFormat *)adFormat
                             withParameters:(id<MAAdapterParameters>)parameters
{
    GADRequest *request = [GADRequest request];
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    NSMutableDictionary<NSString *, id> *extraParameters = [NSMutableDictionary dictionaryWithCapacity: 5];
    BOOL isDv360Bidding = NO;
    
    if ( isBiddingAd )
    {
        NSString *bidderType = [serverParameters al_stringForKey: @"bidder" defaultValue: @""];
        if ( [@"dv360" al_isEqualToStringIgnoringCase: bidderType] )
        {
            isDv360Bidding = YES;
        }
        
        // Requested by Google for signal collection
        extraParameters[@"query_info_type"] = isDv360Bidding ? @"requester_type_3" : @"requester_type_2";
        
        if ( ALSdk.versionCode >= 11000000 && [adFormat isAdViewAd] )
        {
            BOOL isAdaptiveBanner = [parameters.localExtraParameters al_boolForKey: @"adaptive_banner"];
            if ( isAdaptiveBanner )
            {
                GADAdSize adaptiveAdSize = [self adSizeFromAdFormat: adFormat
                                                   isAdaptiveBanner: isAdaptiveBanner
                                                         parameters: parameters];
                extraParameters[@"adaptive_banner_w"] = @(adaptiveAdSize.size.width);
                extraParameters[@"adaptive_banner_h"] = @(adaptiveAdSize.size.height);
            }
        }
        
        if ( [parameters respondsToSelector: @selector(bidResponse)] )
        {
            NSString *bidResponse = ((id<MAAdapterResponseParameters>) parameters).bidResponse;
            if ( [bidResponse al_isValidString] )
            {
                request.adString = bidResponse;
            }
        }
    }
    
    if ( [serverParameters al_numberForKey: @"set_mediation_identifier" defaultValue: @(YES)].boolValue )
    {
        // Use "applovin" instead of mediationTag for Google's specs
        // "applovin_dv360" is for DV360_BIDDING, which is a separate bidder from regular ADMOB_BIDDING
        [request setRequestAgent: isDv360Bidding ? @"applovin_dv360" : @"applovin"];
    }
    
    // Use event id as AdMob's placement request id - https://app.asana.com/0/1126394401843426/1200682332716267
    NSString *eventIdentifier = [serverParameters al_stringForKey: @"event_id"];
    if ( [eventIdentifier al_isValidString] )
    {
        extraParameters[@"placement_req_id"] = eventIdentifier;
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
    
    if ( ALSdk.versionCode >= 11000000 )
    {
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
    }
    
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = extraParameters;
    [request registerAdNetworkExtras: extras];
    
    return request;
}

/**
 * Update the global mute state for AdMob - must be done _before_ ad load to restrict inventory which requires playing with volume.
 */
- (void)updateMuteStateFromResponseParameters:(id<MAAdapterResponseParameters>)responseParameters
{
    NSDictionary *serverParameters = responseParameters.serverParameters;
    // Overwritten by `mute_state` setting, unless `mute_state` is disabled
    if ( [serverParameters al_containsValueForKey: @"is_muted"] ) // Introduced in 6.10.0
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
    // Note: This feature requires AppLovin v11.0.0+
    if ( ALSdk.versionCode >= 11000000 )
    {
        NSDictionary<NSString *, id> *localExtraParams = parameters.localExtraParameters;
        id adChoicesPlacementObj = localExtraParams ? localExtraParams[@"admob_ad_choices_placement"] : nil;
        
        return [self isValidAdChoicesPlacement: adChoicesPlacementObj] ? ((NSNumber *) adChoicesPlacementObj).integerValue : GADAdChoicesPositionTopRightCorner;
    }
    
    return GADAdChoicesPositionTopRightCorner;
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
    if ( ALSdk.versionCode >= 11020199 )
    {
        return parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    }
    else
    {
        return [ALUtils topViewControllerFromKeyWindow];
    }
}

@end
