//
//  ALGoogleAdManagerMediationAdapter.m
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 12/3/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALGoogleAdManagerMediationAdapter.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define ADAPTER_VERSION @"12.9.0.0"

#define TITLE_LABEL_TAG          1
#define MEDIA_VIEW_CONTAINER_TAG 2
#define ICON_VIEW_TAG            3
#define BODY_VIEW_TAG            4
#define CALL_TO_ACTION_VIEW_TAG  5
#define ADVERTISER_VIEW_TAG      8

// TODO: Remove when SDK with App Open APIs is released
@protocol MAAppOpenAdapterDelegateTemp <MAAdapterDelegate>
- (void)didLoadAppOpenAd;
- (void)didLoadAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;
- (void)didFailToLoadAppOpenAdWithError:(MAAdapterError *)adapterError;
- (void)didDisplayAppOpenAd;
- (void)didDisplayAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;
- (void)didClickAppOpenAd;
- (void)didClickAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;
- (void)didHideAppOpenAd;
- (void)didHideAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;
- (void)didFailToDisplayAppOpenAdWithError:(MAAdapterError *)adapterError;
@end

@interface ALGoogleAdManagerInterstitialDelegate : NSObject <GADFullScreenContentDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALGoogleAdManagerAppOpenDelegate : NSObject <GADFullScreenContentDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) id<MAAppOpenAdapterDelegateTemp> delegate;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAAppOpenAdapterDelegateTemp>)delegate;
@end

@interface ALGoogleAdManagerRewardedDelegate : NSObject <GADFullScreenContentDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALGoogleAdManagerAdViewDelegate : NSObject <GADBannerViewDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALGoogleAdManagerNativeAdViewAdDelegate : NSObject <GADNativeAdLoaderDelegate, GADAdLoaderDelegate, GADNativeAdDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALGoogleAdManagerNativeAdDelegate : NSObject <GADNativeAdLoaderDelegate, GADAdLoaderDelegate, GADNativeAdDelegate>
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, assign) NSInteger gadNativeAdViewTag;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAGoogleAdManagerNativeAd : MANativeAd
@property (nonatomic,   weak) ALGoogleAdManagerMediationAdapter *parentAdapter;
@property (nonatomic, assign) NSInteger gadNativeAdViewTag;
- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                   gadNativeAdViewTag:(NSInteger)gadNativeAdViewTag
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALGoogleAdManagerMediationAdapter ()

@property (nonatomic, strong) GAMInterstitialAd *interstitialAd;
@property (nonatomic, strong) GADAppOpenAd *appOpenAd;
@property (nonatomic, strong) GADRewardedAd *rewardedAd;
@property (nonatomic, strong) GAMBannerView *adView;
@property (nonatomic, strong) GADNativeAdView *nativeAdView;
@property (nonatomic, strong) GADAdLoader *nativeAdLoader;
@property (nonatomic, strong) GADNativeAd *nativeAd;

@property (nonatomic, strong) ALGoogleAdManagerInterstitialDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALGoogleAdManagerAppOpenDelegate *appOpenAdapterDelegate;
@property (nonatomic, strong) ALGoogleAdManagerRewardedDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) ALGoogleAdManagerAdViewDelegate *adViewAdapterDelegate;
@property (nonatomic, strong) ALGoogleAdManagerNativeAdViewAdDelegate *nativeAdViewAdapterDelegate;
@property (nonatomic, strong) ALGoogleAdManagerNativeAdDelegate *nativeAdAdapterDelegate;

@end

@implementation ALGoogleAdManagerMediationAdapter
static NSString *const kAdaptiveBannerTypeInline = @"inline";

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [self log: @"Initializing Google Ad Manager SDK..."];
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
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
    self.interstitialAdapterDelegate.delegate = nil;
    self.interstitialAdapterDelegate = nil;
    
    self.appOpenAd.fullScreenContentDelegate = nil;
    self.appOpenAd = nil;
    self.appOpenAdapterDelegate.delegate = nil;
    self.appOpenAdapterDelegate = nil;
    
    self.rewardedAd.fullScreenContentDelegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
    
    self.nativeAdLoader.delegate = nil;
    self.nativeAdLoader = nil;
    
    [self.nativeAd unregisterAdView];
    self.nativeAd = nil;
    
    // Remove the view from MANativeAdView in case the publisher decides to re-use the native ad view.
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nil;
    
    self.nativeAdViewAdapterDelegate.delegate = nil;
    self.nativeAdAdapterDelegate.delegate = nil;
    self.nativeAdViewAdapterDelegate = nil;
    self.nativeAdAdapterDelegate = nil;
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad: %@...", placementId];
    
    [self updateMuteStateFromServerParameters: parameters.serverParameters];
    GAMRequest *request = [self createAdRequestWithParameters: parameters];
    
    [GAMInterstitialAd loadWithAdManagerAdUnitID: placementId
                                         request: request
                               completionHandler:^(GAMInterstitialAd *_Nullable interstitialAd, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
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
        self.interstitialAdapterDelegate = [[ALGoogleAdManagerInterstitialDelegate alloc] initWithParentAdapter: self
                                                                                            placementIdentifier: placementId
                                                                                                      andNotify: delegate];
        self.interstitialAd.fullScreenContentDelegate = self.interstitialAdapterDelegate;
        
        NSString *responseId = self.interstitialAd.responseInfo.responseIdentifier;
        if ( [responseId al_isValidString] )
        {
            [delegate didLoadInterstitialAdWithExtraInfo: @{@"creative_id" : responseId}];
        }
        else
        {
            [delegate didLoadInterstitialAd];
        }
    }];
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
                                             mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                          mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message];
        [delegate didFailToDisplayInterstitialAdWithError: error];
    }
}

#pragma mark - MAAppOpenAdapter Methods

- (void)loadAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegateTemp>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading app open ad: %@...", placementId];
    
    [self updateMuteStateFromServerParameters: parameters.serverParameters];
    GADRequest *request = [self createAdRequestWithParameters: parameters];
    
    [GADAppOpenAd loadWithAdUnitID: placementId
                           request: request
                 completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
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
        self.appOpenAdapterDelegate = [[ALGoogleAdManagerAppOpenDelegate alloc] initWithParentAdapter: self
                                                                                  placementIdentifier: placementId
                                                                                            andNotify: delegate];
        self.appOpenAd.fullScreenContentDelegate = self.appOpenAdapterDelegate;
        
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
                                             mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                          mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message];
        [delegate didFailToDisplayAppOpenAdWithError: error];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad: %@...", placementId];
    
    [self updateMuteStateFromServerParameters: parameters.serverParameters];
    GAMRequest *request = [self createAdRequestWithParameters: parameters];
    
    [GADRewardedAd loadWithAdUnitID: placementId
                            request: request
                  completionHandler:^(GADRewardedAd *_Nullable rewardedAd, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALGoogleAdManagerMediationAdapter toMaxError: error];
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
        self.rewardedAdapterDelegate = [[ALGoogleAdManagerRewardedDelegate alloc] initWithParentAdapter: self
                                                                                    placementIdentifier: placementId
                                                                                              andNotify: delegate];
        self.rewardedAd.fullScreenContentDelegate = self.rewardedAdapterDelegate;
        
        NSString *responseId = self.rewardedAd.responseInfo.responseIdentifier;
        if ( [responseId al_isValidString] )
        {
            [delegate didLoadRewardedAdWithExtraInfo: @{@"creative_id" : responseId}];
        }
        else
        {
            [delegate didLoadRewardedAd];
        }
    }];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad: %@...", placementId];
    
    if ( self.rewardedAd )
    {
        [self configureRewardForParameters: parameters];
        [self.rewardedAd presentFromRootViewController: [self presentingViewControllerForParameters: parameters] userDidEarnRewardHandler:^{
            
            [self log: @"Rewarded ad user earned reward: %@", placementId];
            self.rewardedAdapterDelegate.grantedReward = YES;
        }];
    }
    else
    {
        [self log: @"Rewarded ad failed to show: %@", placementId];
        
        MAAdapterError *error = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                             mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                          mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message];
        [delegate didFailToDisplayRewardedAdWithError: error];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    [self log: @"Loading %@%@ ad: %@...", ( isNative ? @"native " : @"" ), adFormat.label, placementId];
    
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
            self.nativeAdLoader = [[GADAdLoader alloc] initWithAdUnitID: placementId
                                                     rootViewController: [ALUtils topViewControllerFromKeyWindow]
                                                                adTypes: @[GADAdLoaderAdTypeNative]
                                                                options: @[adViewAdOptions, nativeAdImageAdLoaderOptions]];
            self.nativeAdLoader.delegate = self.nativeAdViewAdapterDelegate;
            
            [self.nativeAdLoader loadRequest: request];
        });
    }
    else
    {
        BOOL isAdaptiveBanner = [parameters.serverParameters al_boolForKey: @"adaptive_banner" defaultValue: NO];
        GADAdSize adSize = [self adSizeFromAdFormat: adFormat
                                   isAdaptiveBanner: isAdaptiveBanner
                                         parameters: parameters];
        self.adView = [[GAMBannerView alloc] initWithAdSize: adSize];
        self.adView.frame = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
        self.adView.adUnitID = placementId;
        self.adView.rootViewController = [ALUtils topViewControllerFromKeyWindow];
        self.adViewAdapterDelegate = [[ALGoogleAdManagerAdViewDelegate alloc] initWithParentAdapter: self
                                                                                           adFormat: adFormat
                                                                                          andNotify: delegate];
        self.adView.delegate = self.adViewAdapterDelegate;
        
        [self.adView loadRequest: request];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading native ad: %@...", placementId];
    
    GADRequest *request = [self createAdRequestWithParameters: parameters];
    
    GADNativeAdViewAdOptions *nativeAdViewOptions = [[GADNativeAdViewAdOptions alloc] init];
    nativeAdViewOptions.preferredAdChoicesPosition = [self adChoicesPlacementFromParameters: parameters];
    
    GADNativeAdImageAdLoaderOptions *nativeAdImageAdLoaderOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
    
    // Medium templates can handle multiple images via AdMob's media view
    NSString *templateName = [parameters.serverParameters al_stringForKey: @"template" defaultValue: @""];
    nativeAdImageAdLoaderOptions.shouldRequestMultipleImages = [templateName containsString: @"medium"];
    
    self.nativeAdAdapterDelegate = [[ALGoogleAdManagerNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                         parameters: parameters
                                                                                          andNotify: delegate];
    
    // Fetching the top view controller needs to be on the main queue
    dispatchOnMainQueue(^{
        self.nativeAdLoader = [[GADAdLoader alloc] initWithAdUnitID: placementId
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
                        mediatedNetworkErrorCode: googleAdManagerErrorCode
                     mediatedNetworkErrorMessage: googleAdManagerError.localizedDescription];
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

- (GAMRequest *)createAdRequestWithParameters:(id<MAAdapterParameters>)parameters
{
    GAMRequest *request = [GAMRequest request];
    [request setRequestAgent: self.mediationTag];
    
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
    
    NSString *publisherProvidedId = [localExtraParameters al_stringForKey: @"ppid"];
    if ( [publisherProvidedId al_isValidString] )
    {
        request.publisherProvidedID = publisherProvidedId;
    }
    
    NSDictionary<NSString *, NSString *> *customTargetingData = [localExtraParameters al_dictionaryForKey: @"custom_targeting"];
    if ( customTargetingData )
    {
        request.customTargeting = customTargetingData;
    }
    
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = extraParameters;
    [request registerAdNetworkExtras: extras];
    
    return request;
}

/**
 * Update the global mute state for Ad Manager - must be done _before_ ad load to restrict inventory which requires playing with volume.
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
    // Publishers can set via nativeAdLoader.setLocalExtraParameterForKey("gam_ad_choices_placement", value: Int)
    NSDictionary<NSString *, id> *localExtraParams = parameters.localExtraParameters;
    id adChoicesPlacementObj = localExtraParams ? localExtraParams[@"gam_ad_choices_placement"] : nil;
    
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

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Interstitial ad shown: %@", self.placementIdentifier];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.localizedDescription];
    [self.parentAdapter log: @"Interstitial ad (%@) failed to show with error: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Interstitial ad impression recorded: %@", self.placementIdentifier];
    [self.delegate didDisplayInterstitialAd];
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

@implementation ALGoogleAdManagerAppOpenDelegate

- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAAppOpenAdapterDelegateTemp>)delegate
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

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"App open ad shown: %@", self.placementIdentifier];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.localizedDescription];
    [self.parentAdapter log: @"App open ad (%@) failed to show with error: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToDisplayAppOpenAdWithError: adapterError];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"App open ad impression recorded: %@", self.placementIdentifier];
    [self.delegate didDisplayAppOpenAd];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"App open ad click recorded: %@", self.placementIdentifier];
    [self.delegate didClickAppOpenAd];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"App open ad hidden: %@", self.placementIdentifier];
    [self.delegate didHideAppOpenAd];
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

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded ad shown: %@", self.placementIdentifier];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.localizedDescription];
    [self.parentAdapter log: @"Rewarded ad (%@) failed to show: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded ad impression recorded: %@", self.placementIdentifier];
    [self.delegate didDisplayRewardedAd];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded ad click recorded: %@", self.placementIdentifier];
    [self.delegate didClickRewardedAd];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
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
    
    [self.delegate didLoadAdForAdView: bannerView withExtraInfo: extraInfo];
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

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad clicked: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didClickAdViewAd];
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad will present: %@", self.adFormat.label, bannerView.adUnitID];
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
    
    GADMediaView *gadMediaView = [[GADMediaView alloc] init];
    MANativeAd *maxNativeAd = [[MANativeAd alloc] initWithFormat: self.adFormat builderBlock:^(MANativeAdBuilder *builder) {
        
        builder.title = nativeAd.headline;
        builder.body = nativeAd.body;
        builder.callToAction = nativeAd.callToAction;
        
        if ( nativeAd.icon.image ) // Cached
        {
            builder.icon = [[MANativeAdImage alloc] initWithImage: nativeAd.icon.image];
        }
        else // URL may require fetching
        {
            builder.icon = [[MANativeAdImage alloc] initWithURL: nativeAd.icon.imageURL];
        }
        
        if ( nativeAd.mediaContent )
        {
            [gadMediaView setMediaContent: nativeAd.mediaContent];
            builder.mediaView = gadMediaView;
        }
    }];
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    
    nativeAd.delegate = self;
    
    dispatchOnMainQueue(^{
        
        nativeAd.rootViewController = [ALUtils topViewControllerFromKeyWindow];
        
        MANativeAdView *maxNativeAdView;
        maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: templateName];
        
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
        if ( [responseId al_isValidString] )
        {
            [self.delegate didLoadAdForAdView: maxNativeAdView withExtraInfo: @{@"creative_id" : responseId}];
        }
        else
        {
            [self.delegate didLoadAdForAdView: maxNativeAdView];
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
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.serverParameters = parameters.serverParameters;
        self.delegate = delegate;
        
        id gadNativeAdViewTagObj = parameters.localExtraParameters[@"google_native_ad_view_tag"];
        if ( [gadNativeAdViewTagObj isKindOfClass: [NSNumber class]] )
        {
            self.gadNativeAdViewTag = ((NSNumber *) gadNativeAdViewTagObj).integerValue;
        }
        else
        {
            self.gadNativeAdViewTag = -1;
        }
    }
    return self;
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad loaded: %@", adLoader.adUnitID];
    
    self.parentAdapter.nativeAd = nativeAd;
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    if ( isTemplateAd && ![nativeAd.headline al_isValidString] )
    {
        [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.missingRequiredNativeAdAssets];
        
        return;
    }
    
    UIView *mediaView;
    GADMediaContent *mediaContent = nativeAd.mediaContent;
    MANativeAdImage *mainImage = nil;
    CGFloat mediaContentAspectRatio = 0.0f;
    
    if ( mediaContent )
    {
        GADMediaView *gadMediaView = [[GADMediaView alloc] init];
        [gadMediaView setMediaContent: mediaContent];
        mediaView = gadMediaView;
        mainImage = [[MANativeAdImage alloc] initWithImage: mediaContent.mainImage];
        
        mediaContentAspectRatio = mediaContent.aspectRatio;
    }
    else if ( nativeAd.images.count > 0 )
    {
        GADNativeAdImage *mediaImage = nativeAd.images[0];
        UIImageView *mediaImageView = [[UIImageView alloc] initWithImage: mediaImage.image];
        mediaView = mediaImageView;
        mainImage = [[MANativeAdImage alloc] initWithImage: mediaImage.image];
        
        mediaContentAspectRatio = mediaImage.image.size.width / mediaImage.image.size.height;
    }
    
    nativeAd.delegate = self;
    
    // Fetching the top view controller needs to be on the main queue
    dispatchOnMainQueue(^{
        nativeAd.rootViewController = [ALUtils topViewControllerFromKeyWindow];
    });
    
    MANativeAd *maxNativeAd = [[MAGoogleAdManagerNativeAd alloc] initWithParentAdapter: self.parentAdapter
                                                                    gadNativeAdViewTag: self.gadNativeAdViewTag
                                                                          builderBlock:^(MANativeAdBuilder *builder) {
        
        builder.title = nativeAd.headline;
        builder.advertiser = nativeAd.advertiser;
        builder.body = nativeAd.body;
        builder.callToAction = nativeAd.callToAction;
        
        if ( nativeAd.icon.image ) // Cached
        {
            builder.icon = [[MANativeAdImage alloc] initWithImage: nativeAd.icon.image];
        }
        else // URL may require fetching
        {
            builder.icon = [[MANativeAdImage alloc] initWithURL: nativeAd.icon.imageURL];
        }
        
        builder.mainImage = mainImage;
        builder.mediaView = mediaView;
        builder.mediaContentAspectRatio = mediaContentAspectRatio;
        builder.starRating = nativeAd.starRating;
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

@end

@implementation MAGoogleAdManagerNativeAd

- (instancetype)initWithParentAdapter:(ALGoogleAdManagerMediationAdapter *)parentAdapter
                   gadNativeAdViewTag:(NSInteger)gadNativeAdViewTag
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.gadNativeAdViewTag = gadNativeAdViewTag;
    }
    return self;
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container
{
    GADNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    // Check if the publisher included Google's `GADNativeAdView`. If we can use an integrated view, Google
    // won't need to overlay the view on top of the pub view, causing unrelated buttons to be unclickable
    GADNativeAdView *gadNativeAdView = [container viewWithTag: self.gadNativeAdViewTag];
    if ( ![gadNativeAdView isKindOfClass: [GADNativeAdView class]] )
    {
        gadNativeAdView = [[GADNativeAdView alloc] init];
        
        // Save the manually created view to be removed later
        self.parentAdapter.nativeAdView = gadNativeAdView;
        
        // NOTE: iOS needs order to be maxNativeAdView -> gadNativeAdView in order for assets to be sized correctly
        [container addSubview: gadNativeAdView];
        
        // Pin view in order to make it clickable - this makes views not registered with the native ad view unclickable
        [gadNativeAdView al_pinToSuperview];
    }
    
    // Native integrations
    if ( [container isKindOfClass: [MANativeAdView class]] )
    {
        MANativeAdView *maxNativeAdView = (MANativeAdView *) container;
        gadNativeAdView.headlineView = maxNativeAdView.titleLabel;
        gadNativeAdView.advertiserView = maxNativeAdView.advertiserLabel;
        gadNativeAdView.bodyView = maxNativeAdView.bodyLabel;
        gadNativeAdView.iconView = maxNativeAdView.iconImageView;
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
    }
    // Plugins
    else
    {
        for ( UIView *clickableView in clickableViews )
        {
            if ( clickableView.tag == TITLE_LABEL_TAG )
            {
                gadNativeAdView.headlineView = clickableView;
            }
            else if ( clickableView.tag == ICON_VIEW_TAG )
            {
                gadNativeAdView.iconView = clickableView;
            }
            else if ( clickableView.tag == MEDIA_VIEW_CONTAINER_TAG )
            {
                // `self.mediaView` is created when ad is loaded
                if ( [self.mediaView isKindOfClass: [GADMediaView class]] )
                {
                    gadNativeAdView.mediaView = (GADMediaView *) self.mediaView;
                }
                else if ( [self.mediaView isKindOfClass: [UIImageView class]] )
                {
                    gadNativeAdView.imageView = self.mediaView;
                }
            }
            else if ( clickableView.tag == BODY_VIEW_TAG )
            {
                gadNativeAdView.bodyView = clickableView;
            }
            else if ( clickableView.tag == CALL_TO_ACTION_VIEW_TAG )
            {
                gadNativeAdView.callToActionView = clickableView;
            }
            else if ( clickableView.tag == ADVERTISER_VIEW_TAG )
            {
                gadNativeAdView.advertiserView = clickableView;
            }
        }
    }
    
    gadNativeAdView.nativeAd = self.parentAdapter.nativeAd;
    
    return YES;
}

@end
