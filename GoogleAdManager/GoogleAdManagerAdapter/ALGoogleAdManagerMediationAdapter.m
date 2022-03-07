//
//  ALGoogleAdManagerMediationAdapter.m
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 12/3/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALGoogleAdManagerMediationAdapter.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define ADAPTER_VERSION @"8.13.0.8"

@interface ALGoogleAdManagerInterstitialDelegate : NSObject<GADFullScreenContentDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALGoogleAdManagerRewardedInterstitialDelegate : NSObject<GADFullScreenContentDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) id<MARewardedInterstitialAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MARewardedInterstitialAdapterDelegate>)delegate;
@end

@interface ALGoogleAdManagerRewardedDelegate : NSObject<GADFullScreenContentDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALGoogleAdManagerAdViewDelegate : NSObject<GADBannerViewDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALGoogleAdManagerNativeAdViewAdDelegate : NSObject<GADNativeAdLoaderDelegate, GADAdLoaderDelegate, GADNativeAdDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALGoogleAdManagerNativeAdDelegate : NSObject<GADNativeAdLoaderDelegate, GADAdLoaderDelegate, GADNativeAdDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAGoogleAdManagerNativeAd : MANativeAd
@property (nonatomic, weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALGoogleAdManagerMediationAdapter()

@property (nonatomic, strong) GAMInterstitialAd *interstitialAd;
@property (nonatomic, strong) GADRewardedInterstitialAd *rewardedInterstitialAd;
@property (nonatomic, strong) GADRewardedAd *rewardedAd;
@property (nonatomic, strong) GAMBannerView *adView;
@property (nonatomic, strong) GADNativeAdView *nativeAdView;
@property (nonatomic, strong) GADAdLoader *nativeAdLoader;
@property (nonatomic, strong) GADNativeAd *nativeAd;

@property (nonatomic, strong) ALGoogleAdManagerInterstitialDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALGoogleAdManagerRewardedInterstitialDelegate *rewardedInterstitialAdapterDelegate;
@property (nonatomic, strong) ALGoogleAdManagerRewardedDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) ALGoogleAdManagerAdViewDelegate *adViewAdapterDelegate;
@property (nonatomic, strong) ALGoogleAdManagerNativeAdViewAdDelegate *nativeAdViewAdapterDelegate;
@property (nonatomic, strong) ALGoogleAdManagerNativeAdDelegate *nativeAdAdapterDelegate;

@end

@implementation ALGoogleAdManagerMediationAdapter
static NSString *ALGoogleSDKVersion;

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [self log: @"Initializing Google Ad Manager SDK..."];
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (NSString *)SDKVersion
{
    if ( ALGoogleSDKVersion ) return ALGoogleSDKVersion;
    
    dispatchSyncOnMainQueue(^{
        ALGoogleSDKVersion = [GADMobileAds sharedInstance].sdkVersion;
    });
    
    return ALGoogleSDKVersion;
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for adapter %@", self ];
    
    self.interstitialAd.fullScreenContentDelegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdapterDelegate = nil;
    
    self.rewardedInterstitialAd.fullScreenContentDelegate = nil;
    self.rewardedInterstitialAd = nil;
    self.rewardedInterstitialAdapterDelegate = nil;
    
    self.rewardedAd.fullScreenContentDelegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewAdapterDelegate = nil;
    
    self.nativeAdLoader = nil;
    
    [self.nativeAd unregisterAdView];
    self.nativeAd = nil;
    
    // Remove the view from MANativeAdView in case the publisher decies to re-use the native ad view.
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nil;
    self.nativeAdViewAdapterDelegate = nil;
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad: %@...", placementIdentifier];
    
    [self updateMuteStateFromResponseParameters: parameters];
    [self setRequestConfigurationWithParameters: parameters];
    GAMRequest *request = [self createAdRequestWithParameters: parameters];
    
    [GAMInterstitialAd loadWithAdManagerAdUnitID: placementIdentifier
                                         request: request
                               completionHandler:^(GAMInterstitialAd *_Nullable interstitialAd, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
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
        self.interstitialAdapterDelegate = [[ALGoogleAdManagerInterstitialDelegate alloc] initWithParentAdapter: self
                                                                                            placementIdentifier: placementIdentifier
                                                                                                      andNotify: delegate];
        self.interstitialAd.fullScreenContentDelegate = self.interstitialAdapterDelegate;
        
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
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [self.interstitialAd presentFromRootViewController: presentingViewController];
    }
    else
    {
        [self log: @"Interstitial ad failed to show: %@", placementIdentifier];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardedInterstitialAdapter Methods

- (void)loadRewardedInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded interstitial ad: %@...", placementIdentifier];
    
    [self updateMuteStateFromResponseParameters: parameters];
    [self setRequestConfigurationWithParameters: parameters];
    GADRequest *request = [self createAdRequestWithParameters: parameters];
    
    [GADRewardedInterstitialAd loadWithAdUnitID: placementIdentifier
                                        request: request
                              completionHandler:^(GADRewardedInterstitialAd * _Nullable rewardedInterstitialAd, NSError * _Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
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
        self.rewardedInterstitialAdapterDelegate = [[ALGoogleAdManagerRewardedInterstitialDelegate alloc] initWithParentAdapter: self
                                                                                                            placementIdentifier: placementIdentifier
                                                                                                                      andNotify: delegate];
        self.rewardedInterstitialAd.fullScreenContentDelegate = self.rewardedInterstitialAdapterDelegate;
        
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
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [self.rewardedInterstitialAd presentFromRootViewController: presentingViewController userDidEarnRewardHandler:^{
            
            [self log: @"Rewarded interstitial ad user earned reward: %@", placementIdentifier];
            self.rewardedInterstitialAdapterDelegate.grantedReward = YES;
        }];
    }
    else
    {
        [self log: @"Rewarded interstitial ad failed to show: %@", placementIdentifier];
        [delegate didFailToDisplayRewardedInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad: %@...", placementIdentifier];
    
    [self updateMuteStateFromResponseParameters: parameters];
    [self setRequestConfigurationWithParameters: parameters];
    GAMRequest *request = [self createAdRequestWithParameters: parameters];
    
    [GADRewardedAd loadWithAdUnitID: placementIdentifier
                            request: request
                  completionHandler:^(GADRewardedAd *_Nullable rewardedAd, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
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
        self.rewardedAdapterDelegate = [[ALGoogleAdManagerRewardedDelegate alloc] initWithParentAdapter: self
                                                                                    placementIdentifier: placementIdentifier
                                                                                              andNotify: delegate];
        self.rewardedAd.fullScreenContentDelegate = self.rewardedAdapterDelegate;
        
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
        [self.rewardedAd presentFromRootViewController: [ALUtils topViewControllerFromKeyWindow] userDidEarnRewardHandler:^{
            
            [self log: @"Rewarded ad user earned reward: %@", placementIdentifier];
            self.rewardedAdapterDelegate.grantedReward = YES;
        }];
    }
    else
    {
        [self log: @"Rewarded ad failed to show: %@", placementIdentifier];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    [self log: @"Loading %@%@ ad: %@...", ( isNative ? @"native " : @"" ), adFormat.label, placementIdentifier];
    
    [self setRequestConfigurationWithParameters: parameters];
    GAMRequest *request = [self createAdRequestWithParameters: parameters];
    
    if ( isNative )
    {
        GADNativeAdViewAdOptions *adViewAdOptions = [[GADNativeAdViewAdOptions alloc] init];
        adViewAdOptions.preferredAdChoicesPosition = [self adChoicesPlacementFromParameters: parameters];
        
        GADNativeAdImageAdLoaderOptions *nativeAdImageAdLoaderOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
        nativeAdImageAdLoaderOptions.shouldRequestMultipleImages = (adFormat == MAAdFormat.mrec); // MRECs can handle multiple images via AdMob's media view
        
        self.nativeAdViewAdapterDelegate = [[ALGoogleAdManagerNativeAdViewAdDelegate alloc] initWithParentAdapter: self
                                                                                                         adFormat: adFormat
                                                                                                 serverParameters: parameters.serverParameters
                                                                                                        andNotify: delegate];
        
        // Fetching the top view controller needs to be on the main queue
        dispatchOnMainQueue(^{
            self.nativeAdLoader = [[GADAdLoader alloc] initWithAdUnitID: placementIdentifier
                                                     rootViewController: [ALUtils topViewControllerFromKeyWindow]
                                                                adTypes: @[GADAdLoaderAdTypeNative]
                                                                options: @[adViewAdOptions, nativeAdImageAdLoaderOptions]];
            self.nativeAdLoader.delegate = self.nativeAdViewAdapterDelegate;
            
            [self.nativeAdLoader loadRequest: request];
        });
    }
    else
    {
        GADAdSize adSize = [self adSizeFromAdFormat: adFormat withServerParameters: parameters.serverParameters];
        self.adView = [[GAMBannerView alloc] initWithAdSize: adSize];
        self.adView.frame = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
        self.adView.adUnitID = placementIdentifier;
        self.adView.rootViewController = [ALUtils topViewControllerFromKeyWindow];
        self.adViewAdapterDelegate = [[ALGoogleAdManagerAdViewDelegate alloc] initWithParentAdapter: self
                                                                                           adFormat: adFormat
                                                                                          andNotify: delegate];
        self.adView.delegate = self.adViewAdapterDelegate;
        
        [self.adView loadRequest: request];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MANativeAdAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading native ad: %@...", placementIdentifier];
    
    [self setRequestConfigurationWithParameters: parameters];
    GADRequest *request = [self createAdRequestWithParameters: parameters];
    
    GADNativeAdViewAdOptions *nativeAdViewOptions = [[GADNativeAdViewAdOptions alloc] init];
    nativeAdViewOptions.preferredAdChoicesPosition = [self adChoicesPlacementFromParameters: parameters];
    
    GADNativeAdImageAdLoaderOptions *nativeAdImageAdLoaderOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
    
    // Medium templates can handle multiple images via AdMob's media view
    NSString *templateName = [parameters.serverParameters al_stringForKey: @"template" defaultValue: @""];
    nativeAdImageAdLoaderOptions.shouldRequestMultipleImages = [templateName containsString: @"medium"];
    
    self.nativeAdAdapterDelegate = [[ALGoogleAdManagerNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                   serverParameters: parameters.serverParameters
                                                                                          andNotify: delegate];
    
    // Fetching the top view controller needs to be on the main queue
    dispatchOnMainQueue(^{
        self.nativeAdLoader = [[GADAdLoader alloc] initWithAdUnitID: placementIdentifier
                                                 rootViewController: [ALUtils topViewControllerFromKeyWindow]
                                                            adTypes: @[GADAdLoaderAdTypeNative]
                                                            options: @[nativeAdViewOptions, nativeAdImageAdLoaderOptions]];
        self.nativeAdLoader.delegate = self.nativeAdAdapterDelegate;
        
        [self.nativeAdLoader loadRequest: request];
    });
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(NSError *)googleAdManagerError
{
    GADErrorCode googleAdManagerErrorCode = googleAdManagerError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( googleAdManagerErrorCode )
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
                  thirdPartySdkErrorCode: googleAdManagerErrorCode
               thirdPartySdkErrorMessage: googleAdManagerError.localizedDescription];
#pragma clang diagnostic pop
}

- (GADAdSize)adSizeFromAdFormat:(MAAdFormat *)adFormat withServerParameters:(NSDictionary<NSString *, id> *)serverParameters
{
    if ( adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader )
    {
        // Check if adaptive banner sizes should be used
        if ( [serverParameters al_boolForKey: @"adaptive_banner" defaultValue: NO] )
        {
            UIViewController *viewController = [ALUtils topViewControllerFromKeyWindow];
            UIWindow *window = viewController.view.window;
            CGRect frame = window.frame;
            
            // Use safe area insents when available.
            if ( @available(iOS 11.0, *) )
            {
                frame = UIEdgeInsetsInsetRect(window.frame, window.safeAreaInsets);
            }
            
            CGFloat viewWidth = CGRectGetWidth(frame);
            return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);
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
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        
        return GADAdFormatBanner;
    }
}

- (void)setRequestConfigurationWithParameters:(id<MAAdapterParameters>)parameters
{
    NSNumber *isAgeRestrictedUser = [self privacySettingForSelector: @selector(isAgeRestrictedUser) fromParameters: parameters];
    if ( isAgeRestrictedUser )
    {
        [[GADMobileAds sharedInstance].requestConfiguration tagForChildDirectedTreatment: isAgeRestrictedUser.boolValue];
    }
    
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    NSString *testDevicesString = [serverParameters al_stringForKey: @"test_device_ids"];
    if ( [testDevicesString al_isValidString] )
    {
        NSArray<NSString *> *testDevices = [testDevicesString componentsSeparatedByString: @","];
        [[GADMobileAds sharedInstance].requestConfiguration setTestDeviceIdentifiers: testDevices];
    }
}

- (GAMRequest *)createAdRequestWithParameters:(id<MAAdapterParameters>)parameters
{
    GAMRequest *request = [GAMRequest request];
    
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    if ( [serverParameters al_numberForKey: @"set_mediation_identifier" defaultValue: @(YES)].boolValue )
    {
        [request setRequestAgent: self.mediationTag];
    }
    
    GADExtras *extras = [[GADExtras alloc] init];
    NSMutableDictionary<NSString *, NSString *> *extraParameters = [NSMutableDictionary dictionaryWithCapacity: 2];
    
    // Use event id as AdMob's placement request id
    NSString *eventIdentifier = [serverParameters al_stringForKey: @"event_id"];
    if ( [eventIdentifier al_isValidString] )
    {
        extraParameters[@"placement_req_id"] = eventIdentifier;
    }
    
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
        if ( hasUserConsent && !hasUserConsent.boolValue )
        {
            extraParameters[@"npa"] = @"1"; // Non-personalized ads
        }
    }
    
    if ( ALSdk.versionCode >= 61100 ) // Pre-beta versioning (6.14.0)
    {
        NSNumber *isDoNotSell = [self privacySettingForSelector: @selector(isDoNotSell) fromParameters: parameters];
        if ( isDoNotSell && isDoNotSell.boolValue )
        {
            // Restrict data processing - https://developers.google.com/admob/ios/ccpa
            [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"gad_rdp"];
        }
    }
    
    extras.additionalParameters = extraParameters;
    [request registerAdNetworkExtras: extras];
    
    return request;
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

/**
 * Update the global mute state for Ad Manager - must be done _before_ ad load to restrict inventory which requires playing with volume.
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

- (BOOL)isValidNativeAd:(GADNativeAd *)nativeAd
{
    return nativeAd.headline != nil;
}

- (NSInteger)adChoicesPlacementFromParameters:(id<MAAdapterParameters>)parameters
{
    // Publishers can set via nativeAdLoader.setLocalExtraParameterForKey("gam_ad_choices_placement", value: Int)
    // Note: This feature requires AppLovin v11.0.0+
    if ( ALSdk.versionCode >= 11000000 )
    {
        NSDictionary<NSString *, id> *localExtraParams = parameters.localExtraParameters;
        id adChoicesPlacementObj = localExtraParams ? localExtraParams[@"gam_ad_choices_placement"] : nil;
        
        return [self isValidAdChoicesPlacement: adChoicesPlacementObj] ? ((NSNumber *) adChoicesPlacementObj).integerValue : GADAdChoicesPositionTopRightCorner;
    }
    
    return GADAdChoicesPositionTopRightCorner;
}

- (BOOL)isValidAdChoicesPlacement:(id)placementObj
{
    if ( [placementObj isKindOfClass: [NSNumber class]] )
    {
        GADAdChoicesPosition rawValue = ((NSNumber *) placementObj).integerValue;
        
        return rawValue == GADAdChoicesPositionTopRightCorner ||
        rawValue == GADAdChoicesPositionTopLeftCorner ||
        rawValue == GADAdChoicesPositionBottomRightCorner ||
        rawValue == GADAdChoicesPositionBottomLeftCorner;
    }
    
    return NO;
}

@end

@implementation ALGoogleAdManagerInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementIdentifier = placementIdentifier;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Interstitial ad shown: %@", self.placementIdentifier];
    [self.delegate didDisplayInterstitialAd];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial ad (%@) failed to show with error: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Interstitial ad impression recorded: %@", self.placementIdentifier];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Interstitial ad click recorded: %@", self.placementIdentifier];
    [self.delegate didClickInterstitialAd];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Interstitial ad hidden: %@", self.placementIdentifier];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALGoogleAdManagerRewardedInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MARewardedInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementIdentifier = placementIdentifier;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded interstitial ad shown: %@", self.placementIdentifier];
    
    [self.delegate didDisplayRewardedInterstitialAd];
    [self.delegate didStartRewardedInterstitialAdVideo];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded interstitial ad (%@) failed to show: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToDisplayRewardedInterstitialAdWithError: adapterError];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded interstitial ad impression recorded: %@", self.placementIdentifier];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded interstitial ad click recorded: %@", self.placementIdentifier];
    [self.delegate didClickRewardedInterstitialAd];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.delegate didCompleteRewardedInterstitialAdVideo];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded interstitial ad rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded interstitial ad hidden: %@", self.placementIdentifier];
    [self.delegate didHideRewardedInterstitialAd];
}

@end

@implementation ALGoogleAdManagerRewardedDelegate

- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementIdentifier = placementIdentifier;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded ad shown: %@", self.placementIdentifier];
    
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded ad (%@) failed to show: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded ad impression recorded: %@", self.placementIdentifier];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded ad click recorded: %@", self.placementIdentifier];
    [self.delegate didClickRewardedAd];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.delegate didCompleteRewardedAdVideo];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden: %@", self.placementIdentifier];
    [self.delegate didHideRewardedAd];
}

@end

@implementation ALGoogleAdManagerAdViewDelegate

- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.adFormat = adFormat;
        self.delegate = delegate;
    }
    return self;
}

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad loaded: %@", self.adFormat.label, bannerView.adUnitID];
    
    if ( ALSdk.versionCode >= 6150000 )
    {
        NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithCapacity: 3];
        
        NSString *responseId = bannerView.responseInfo.responseIdentifier;
        if ( [responseId al_isValidString] )
        {
            extraInfo[@"creative_id"] = responseId;
        }
        
        CGSize adSize = bannerView.adSize.size;
        if ( !CGSizeEqualToSize(CGSizeZero, adSize) )
        {
            extraInfo[@"ad_width"] = @(adSize.width);
            extraInfo[@"ad_height"] = @(adSize.height);
        }
        
        [self.delegate performSelector: @selector(didLoadAdForAdView:withExtraInfo:)
                            withObject: bannerView
                            withObject: extraInfo];
    }
    else
    {
        [self.delegate didLoadAdForAdView: bannerView];
    }
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"%@ ad (%@) failed to load with error: %@", self.adFormat.label, bannerView.adUnitID, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad shown: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didDisplayAdViewAd];
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad clicked: %@", self.adFormat.label, bannerView.adUnitID];
    
    [self.delegate didClickAdViewAd];
    [self.delegate didExpandAdViewAd];
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad collapsed: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didCollapseAdViewAd];
}

@end

@implementation ALGoogleAdManagerNativeAdViewAdDelegate

- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.serverParameters = serverParameters;
        self.adFormat = adFormat;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad loaded: %@", self.adFormat.label, adLoader.adUnitID];
    
    if ( ![self.parentAdapter isValidNativeAd: nativeAd] )
    {
        [self.parentAdapter log: @"Native %@ ad failed to load: Google native ad is missing one or more required assets", self.adFormat.label];
        [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.invalidConfiguration];
        
        return;
    }
    
    GADMediaView *gadMediaView = [[GADMediaView alloc] init];
    MANativeAd *maxNativeAd = [[MANativeAd alloc] initWithFormat: self.adFormat builderBlock:^(MANativeAdBuilder *builder) {
        
        builder.title = nativeAd.headline;
        builder.body = nativeAd.body;
        builder.callToAction = nativeAd.callToAction;
        
        if ( nativeAd.mediaContent )
        {
            [gadMediaView setMediaContent: nativeAd.mediaContent];
            builder.mediaView = gadMediaView;
        }
        
        if ( nativeAd.icon.image ) // Cached
        {
            builder.icon = [[MANativeAdImage alloc] initWithImage: nativeAd.icon.image];
        }
        else // URL may require fetching
        {
            builder.icon = [[MANativeAdImage alloc] initWithURL: nativeAd.icon.imageURL];
        }
    }];
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    if ( [templateName containsString: @"vertical"] && ALSdk.versionCode < 6140500 )
    {
        [self.parentAdapter log: @"Vertical native banners are only supported on MAX SDK 6.14.5 and above. Default native template will be used."];
    }
    
    nativeAd.delegate = self;
    
    dispatchOnMainQueue(^{
        
        nativeAd.rootViewController = [ALUtils topViewControllerFromKeyWindow];
        
        MANativeAdView *maxNativeAdView;
        if ( ALSdk.versionCode < 6140000 )
        {
            [self.parentAdapter log: @"Native ads with media views are only supported on MAX SDK version 6.14.0 and above. Default native template will be used."];
            maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd];
        }
        else
        {
            maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: templateName];
        }
        
        GADNativeAdView *gadNativeAdView = [[GADNativeAdView alloc] init];
        gadNativeAdView.iconView = maxNativeAdView.iconImageView;
        gadNativeAdView.headlineView = maxNativeAdView.titleLabel;
        gadNativeAdView.bodyView = maxNativeAdView.bodyLabel;
        gadNativeAdView.mediaView = gadMediaView;
        gadNativeAdView.callToActionView = maxNativeAdView.callToActionButton;
        gadNativeAdView.callToActionView.userInteractionEnabled = NO;
        gadNativeAdView.nativeAd = nativeAd;
        
        self.parentAdapter.nativeAdView = gadNativeAdView;
        
        // NOTE: iOS needs order to be maxNativeAdView -> gadNativeAdView in order for assets to be sized correctly
        [maxNativeAdView addSubview: self.parentAdapter.nativeAdView];
        
        // Pin view in order to make it clickable
        [self.parentAdapter.nativeAdView al_pinToSuperview];
        
        NSString *responseId = nativeAd.responseInfo.responseIdentifier;
        if ( ALSdk.versionCode >= 6150000 && [responseId al_isValidString] )
        {
            [self.delegate performSelector: @selector(didLoadAdForAdView:withExtraInfo:)
                                withObject: self.parentAdapter.nativeAdView
                                withObject: @{@"creative_id" : responseId}];
        }
        else
        {
            [self.delegate didLoadAdForAdView: self.parentAdapter.nativeAdView];
        }
    });
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error;
{
    MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native %@ ad (%@) failed to load with error: %@", self.adFormat.label, adLoader.adUnitID, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad shown", self.adFormat.label];
    [self.delegate didDisplayAdViewAd];
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad clicked", self.adFormat.label];
    [self.delegate didClickAdViewAd];
}

- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad will present", self.adFormat.label];
    [self.delegate didExpandAdViewAd];
}

- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad did dismiss", self.adFormat.label];
    [self.delegate didCollapseAdViewAd];
}

@end

@implementation ALGoogleAdManagerNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *,id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.serverParameters = serverParameters;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad loaded: %@", adLoader.adUnitID];
    
    if ( ![self.parentAdapter isValidNativeAd: nativeAd] )
    {
        [self.parentAdapter log: @"Native ad failed to load: Google native ad is missing one or more required assets"];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.invalidConfiguration];
        
        return;
    }
    
    self.parentAdapter.nativeAd = nativeAd;
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    if ( ![self hasRequiredAssetsInAd: nativeAd isTemplateAd: isTemplateAd] )
    {
        [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    UIView *mediaView;
    if ( nativeAd.mediaContent )
    {
        GADMediaView *gadMediaView = [[GADMediaView alloc] init];
        [gadMediaView setMediaContent: nativeAd.mediaContent];
        mediaView = gadMediaView;
    }
    else if ( nativeAd.images.count > 0 )
    {
        GADNativeAdImage *mainImage = nativeAd.images[0];
        UIImageView *mediaImageView = [[UIImageView alloc] initWithImage: mainImage.image];
        mediaView = mediaImageView;
    }
    
    // Media view is required for non-template native ads.
    if ( !isTemplateAd && !mediaView )
    {
        [self.parentAdapter e: @"Media view asset is null for native custom ad view. Failing ad request."];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    nativeAd.delegate = self;
    
    // Fetching the top view controller needs to be on the main queue
    dispatchOnMainQueue(^{
        nativeAd.rootViewController = [ALUtils topViewControllerFromKeyWindow];
    });
    
    MANativeAd *maxNativeAd = [[MAGoogleAdManagerNativeAd alloc] initWithParentAdapter: self.parentAdapter builderBlock:^(MANativeAdBuilder *builder) {
        
        builder.title = nativeAd.headline;
        builder.body = nativeAd.body;
        builder.callToAction = nativeAd.callToAction;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        // Introduced in 10.4.0
        if ( [builder respondsToSelector: @selector(setAdvertiser:)] )
        {
            [builder performSelector: @selector(setAdvertiser:) withObject: nativeAd.advertiser];
        }
#pragma clang diagnostic pop
        
        builder.mediaView = mediaView;
        
        if ( nativeAd.icon.image ) // Cached
        {
            builder.icon = [[MANativeAdImage alloc] initWithImage: nativeAd.icon.image];
        }
        else // URL may require fetching
        {
            builder.icon = [[MANativeAdImage alloc] initWithURL: nativeAd.icon.imageURL];
        }
    }];
    
    NSString *responseId = nativeAd.responseInfo.responseIdentifier;
    NSDictionary *extraInfo = [responseId al_isValidString] ? @{@"creative_id" : responseId} : nil;
    
    [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: extraInfo];
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad (%@) failed to load with error: %@", adLoader.adUnitID, adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad shown"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad will present"];
}

- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad did dismiss"];
}

- (BOOL)hasRequiredAssetsInAd:(GADNativeAd *)nativeAd isTemplateAd:(BOOL)isTemplateAd
{
    if ( isTemplateAd )
    {
        return [nativeAd.headline al_isValidString];
    }
    else
    {
        // NOTE: Media view is required and is checked separately.
        return [nativeAd.headline al_isValidString]
        && [nativeAd.callToAction al_isValidString];
    }
}

@end

@implementation MAGoogleAdManagerNativeAd

- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (void)prepareViewForInteraction:(MANativeAdView *)maxNativeAdView
{
    if ( !self.parentAdapter.nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return;
    }
    
    GADNativeAdView *gadNativeAdView = [[GADNativeAdView alloc] init];
    gadNativeAdView.iconView = maxNativeAdView.iconImageView;
    gadNativeAdView.headlineView = maxNativeAdView.titleLabel;
    gadNativeAdView.bodyView = maxNativeAdView.bodyLabel;
    gadNativeAdView.callToActionView = maxNativeAdView.callToActionButton;
    gadNativeAdView.callToActionView.userInteractionEnabled = NO;
    
    if ( [self.mediaView isKindOfClass: [GADMediaView class]] )
    {
        gadNativeAdView.mediaView = (GADMediaView *) self.mediaView;
    }
    else if ( [self.mediaView isKindOfClass: [UIImageView class]] )
    {
        gadNativeAdView.imageView = self.mediaView;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // Introduced in 10.4.0
    if ( [maxNativeAdView respondsToSelector: @selector(advertiserLabel)] )
    {
        id advertiserLabel = [maxNativeAdView performSelector: @selector(advertiserLabel)];
        gadNativeAdView.advertiserView = advertiserLabel;
    }
#pragma clang diagnostic pop
    
    gadNativeAdView.nativeAd = self.parentAdapter.nativeAd;
    
    // NOTE: iOS needs order to be maxNativeAdView -> gadNativeAdView in order for assets to be sized correctly
    [maxNativeAdView addSubview: gadNativeAdView];
    
    // Pin view in order to make it clickable
    [gadNativeAdView al_pinToSuperview];
    
    self.parentAdapter.nativeAdView = gadNativeAdView;
}

@end
