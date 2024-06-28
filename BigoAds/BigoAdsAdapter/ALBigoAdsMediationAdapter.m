//
//  BigoAdsMediationAdapter.m
//  BigoAds
//
//  Created by Avi Leung on 2/13/24.
//

#import "ALBigoAdsMediationAdapter.h"
#import <BigoADS/BigoAdSdk.h>
#import <BigoADS/BigoInterstitialAdLoader.h>
#import <BigoADS/BigoSplashAdLoader.h>
#import <BigoADS/BigoRewardVideoAdLoader.h>
#import <BigoADS/BigoBannerAdLoader.h>
#import <BigoADS/BigoNativeAdLoader.h>
#import <BigoADS/BigoAdInteractionDelegate.h>

#define ADAPTER_VERSION @"4.2.3.1"

@interface ALBigoAdsMediationAdapterInterstitialAdDelegate : NSObject <BigoInterstitialAdLoaderDelegate, BigoAdInteractionDelegate>
@property (nonatomic,   weak) ALBigoAdsMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALBigoAdsMediationAdapterAppOpenAdDelegate : NSObject <BigoSplashAdLoaderDelegate, BigoSplashAdInteractionDelegate>
@property (nonatomic,   weak) ALBigoAdsMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) id<MAAppOpenAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                            andNotify:(id<MAAppOpenAdapterDelegate>)delegate;
@end

@interface ALBigoAdsMediationAdapterRewardedAdDelegate : NSObject <BigoRewardVideoAdLoaderDelegate, BigoRewardVideoAdInteractionDelegate>
@property (nonatomic,   weak) ALBigoAdsMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                            andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALBigoAdsMediationAdapterAdViewDelegate : NSObject <BigoBannerAdLoaderDelegate, BigoAdInteractionDelegate>
@property (nonatomic,   weak) ALBigoAdsMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALBigoAdsMediationAdapterNativeAdViewDelegate : NSObject <BigoNativeAdLoaderDelegate, BigoAdInteractionDelegate>
@property (nonatomic,   weak) ALBigoAdsMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                             adFormat:(MAAdFormat *)adFormat
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALBigoAdsMediationAdapterNativeAdDelegate : NSObject <BigoNativeAdLoaderDelegate, BigoAdInteractionDelegate>
@property (nonatomic,   weak) ALBigoAdsMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MABigoAdsNativeAd : MANativeAd
@property (nonatomic, weak) ALBigoAdsMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
@end

// NOTE: We need another class name to access `ALBigoAdsMediationAdapter` from the Mediation Debugger because there is currently a naming conflict.
@interface MDBigoAdsMediationAdapter : ALBigoAdsMediationAdapter

@end

@interface ALBigoAdsMediationAdapter ()

@property (nonatomic, strong) BigoInterstitialAd *interstitialAd;
@property (nonatomic, strong) BigoSplashAd *appOpenAd;
@property (nonatomic, strong) BigoRewardVideoAd *rewardedAd;
@property (nonatomic, strong) BigoBannerAd *adViewAd;
@property (nonatomic, strong) BigoNativeAd *nativeAd;
@property (nonatomic, strong) BigoAdLoader *adLoader;

@property (nonatomic, strong) ALBigoAdsMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALBigoAdsMediationAdapterAppOpenAdDelegate *appOpenAdapterDelegate;
@property (nonatomic, strong) ALBigoAdsMediationAdapterRewardedAdDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) ALBigoAdsMediationAdapterAdViewDelegate *adViewAdapterDelegate;
@property (nonatomic, strong) ALBigoAdsMediationAdapterNativeAdViewDelegate *nativeAdViewAdapterDelegate;
@property (nonatomic, strong) ALBigoAdsMediationAdapterNativeAdDelegate *nativeAdAdapterDelegate;

@end

@implementation ALBigoAdsMediationAdapter

static NSString                      *ALMediationInfo;

static ALAtomicBoolean               *ALBigoAdsInitialized;
static MAAdapterInitializationStatus ALBigoAdsInitializationStatus = NSIntegerMin;

#pragma mark - Class Initialization

+ (void)initialize
{
    [super initialize];
    
    ALBigoAdsInitialized = [[ALAtomicBoolean alloc] init];
    
    NSDictionary *mediationInfoDict = @{@"mediationName" : @"Max",
                                        @"mediationVersion" : ALSdk.version,
                                        @"adapterVersion" : ADAPTER_VERSION};
    
    NSError *error = nil;
    NSData *mediationInfoJSONData = [NSJSONSerialization dataWithJSONObject: mediationInfoDict options: 0 error: &error];
    
    if ( !error )
    {
        ALMediationInfo = [[NSString alloc] initWithData: mediationInfoJSONData encoding: NSUTF8StringEncoding];
    }
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALBigoAdsInitialized compareAndSet: NO update: YES] )
    {
        ALBigoAdsInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *appId = [parameters.serverParameters al_stringForKey: @"app_id"];
        [self log: @"Initializing Bigo Ads SDK with app id: %@", appId];
        
        BigoAdConfig *adConfig = [[BigoAdConfig alloc] initWithAppId: appId];
        
        if ( [parameters isTesting] )
        {
            adConfig.testMode = YES;
        }
        
        [[BigoAdSdk sharedInstance] initializeSdkWithAdConfig: adConfig completion:^{
            
            if ( [BigoAdSdk.sharedInstance isInitialized] )
            {
                [self log: @"Bigo Ads SDK initialized"];
                ALBigoAdsInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            }
            else
            {
                [self log: @"Bigo Ads SDK failed to initialize"];
                ALBigoAdsInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
            }
            
            completionHandler( ALBigoAdsInitializationStatus, nil );
        }];
    }
    else
    {
        [self log: @"Bigo Ads attempted initialization already"];
        completionHandler( ALBigoAdsInitializationStatus, nil );
    }
}

- (NSString *)SDKVersion
{
    return [BigoAdSdk.sharedInstance getSDKVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for adapter %@", self];
    
    [self.interstitialAd destroy];
    self.interstitialAd = nil;
    self.interstitialAdapterDelegate.delegate = nil;
    self.interstitialAdapterDelegate = nil;
    
    [self.appOpenAd destroy];
    self.appOpenAd = nil;
    self.appOpenAdapterDelegate.delegate = nil;
    self.appOpenAdapterDelegate = nil;
    
    [self.rewardedAd destroy];
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;
    
    [self.adViewAd destroy];
    self.adViewAd = nil;
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
    
    self.nativeAdViewAdapterDelegate.delegate = nil;
    self.nativeAdViewAdapterDelegate = nil;
    
    [self.nativeAd destroy];
    self.nativeAd = nil;
    self.nativeAdAdapterDelegate.delegate = nil;
    self.nativeAdAdapterDelegate = nil;
    
    self.adLoader = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updateUserConsentForParameters: parameters];
    
    NSString *signal = [BigoAdSdk.sharedInstance getBidderToken];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad for slot id: %@...", slotId];
    
    if ( ![BigoAdSdk.sharedInstance isInitialized] )
    {
        [self log: @"Bigo Ads SDK not successfully initialized: failing interstitial ad load for slot id: %@", slotId];
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateUserConsentForParameters: parameters];
    
    self.interstitialAdapterDelegate = [[ALBigoAdsMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self
                                                                                                               slotId: slotId
                                                                                                            andNotify: delegate];
    
    self.adLoader = [[BigoInterstitialAdLoader alloc] initWithInterstitialAdLoaderDelegate: self.interstitialAdapterDelegate];
    self.adLoader.ext = ALMediationInfo;
    
    BigoInterstitialAdRequest *request = [[BigoInterstitialAdRequest alloc] initWithSlotId: slotId];
    [request setServerBidPayload: parameters.bidResponse];
    [self.adLoader loadAd: request];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad for slot id: %@...", slotId];
    
    if ( [self.interstitialAd isExpired] )
    {
        [self log: @"Unable to show interstitial ad for slot id: %@ - ad expired", slotId];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adExpiredError];
    }
    else
    {
        [self.interstitialAd setAdInteractionDelegate: self.interstitialAdapterDelegate];
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.interstitialAd show: presentingViewController];
    }
}

#pragma mark - MAAppOpenAdapter Methods

- (void)loadAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading app open ad for slot id: %@...", slotId];
    
    if ( ![BigoAdSdk.sharedInstance isInitialized] )
    {
        [self log: @"Bigo Ads SDK not successfully initialized: failing app open ad load for slot id: %@", slotId];
        [delegate didFailToLoadAppOpenAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateUserConsentForParameters: parameters];
    
    self.appOpenAdapterDelegate = [[ALBigoAdsMediationAdapterAppOpenAdDelegate alloc] initWithParentAdapter: self
                                                                                                     slotId: slotId
                                                                                                  andNotify: delegate];
    
    self.adLoader = [[BigoSplashAdLoader alloc] initWithSplashAdLoaderDelegate: self.appOpenAdapterDelegate];
    self.adLoader.ext = ALMediationInfo;
    
    BigoSplashAdRequest *request = [[BigoSplashAdRequest alloc] initWithSlotId: slotId];
    [request setServerBidPayload: parameters.bidResponse];
    [self.adLoader loadAd: request];
}

- (void)showAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing app open ad for slot id: %@...", slotId];
    
    if ( [self.appOpenAd isExpired] )
    {
        [self log: @"Unable to show app open ad for slot id: %@ - ad expired", slotId];
        [delegate didFailToDisplayAppOpenAdWithError: MAAdapterError.adExpiredError];
    }
    else
    {
        [self.appOpenAd setSplashAdInteractionDelegate: self.appOpenAdapterDelegate];
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.appOpenAd show: presentingViewController];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad for slot id: %@...", slotId];
    
    if ( ![BigoAdSdk.sharedInstance isInitialized] )
    {
        [self log: @"Bigo Ads SDK not successfully initialized: failing rewarded ad load for slot id: %@", slotId];
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateUserConsentForParameters: parameters];
    
    self.rewardedAdapterDelegate = [[ALBigoAdsMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self
                                                                                                       slotId: slotId
                                                                                                    andNotify: delegate];
    
    self.adLoader = [[BigoRewardVideoAdLoader alloc] initWithRewardVideoAdLoaderDelegate: self.rewardedAdapterDelegate];
    self.adLoader.ext = ALMediationInfo;
    
    BigoRewardVideoAdRequest *request = [[BigoRewardVideoAdRequest alloc] initWithSlotId: slotId];
    [request setServerBidPayload: parameters.bidResponse];
    [self.adLoader loadAd: request];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad for slot id: %@...", slotId];
    
    if ( [self.rewardedAd isExpired] )
    {
        [self log: @"Unable to show rewarded ad for slot id: %@ - ad expired", slotId];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adExpiredError];
    }
    else
    {
        [self configureRewardForParameters: parameters];
        [self.rewardedAd setRewardVideoAdInteractionDelegate: self.rewardedAdapterDelegate];
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.rewardedAd show: presentingViewController];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    [self log: @"Loading%@%@ ad for slot id: %@...", isNative ? @" native " : @" ", adFormat.label, slotId];
    
    if ( ![BigoAdSdk.sharedInstance isInitialized] )
    {
        [self log: @"Bigo Ads SDK not successfully initialized: failing %@ ad load for slot id: %@", adFormat.label, slotId];
        [delegate didFailToLoadAdViewAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateUserConsentForParameters: parameters];
    
    if ( isNative )
    {
        self.nativeAdViewAdapterDelegate = [[ALBigoAdsMediationAdapterNativeAdViewDelegate alloc] initWithParentAdapter: self
                                                                                                                 slotId: slotId
                                                                                                               adFormat: adFormat
                                                                                                       serverParameters: parameters.serverParameters
                                                                                                              andNotify: delegate];
        
        self.adLoader = [[BigoNativeAdLoader alloc] initWithNativeAdLoaderDelegate: self.nativeAdViewAdapterDelegate];
        self.adLoader.ext = ALMediationInfo;
        
        BigoNativeAdRequest *request = [[BigoNativeAdRequest alloc] initWithSlotId: slotId];
        [request setServerBidPayload: parameters.bidResponse];
        [self.adLoader loadAd: request];
    }
    else
    {
        self.adViewAdapterDelegate = [[ALBigoAdsMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self
                                                                                                     slotId: slotId
                                                                                                   adFormat: adFormat
                                                                                                  andNotify: delegate];
        
        self.adLoader = [[BigoBannerAdLoader alloc] initWithBannerAdLoaderDelegate: self.adViewAdapterDelegate];
        self.adLoader.ext = ALMediationInfo;
        
        BigoAdSize *adSize = [self adSizeFromAdFormat: adFormat];
        BigoBannerAdRequest *request = [[BigoBannerAdRequest alloc] initWithSlotId: slotId adSizes: @[adSize]];
        [request setServerBidPayload: parameters.bidResponse];
        [self.adLoader loadAd: request];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading native ad for slot id: %@...", slotId];
    
    if ( ![BigoAdSdk.sharedInstance isInitialized] )
    {
        [self log: @"Bigo Ads SDK not successfully initialized: failing native ad load for slot id: %@", slotId];
        [delegate didFailToLoadNativeAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateUserConsentForParameters: parameters];
    
    self.nativeAdAdapterDelegate = [[ALBigoAdsMediationAdapterNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                                     slotId: slotId
                                                                                           serverParameters: parameters.serverParameters
                                                                                                  andNotify: delegate];
    
    self.adLoader = [[BigoNativeAdLoader alloc] initWithNativeAdLoaderDelegate: self.nativeAdAdapterDelegate];
    self.adLoader.ext = ALMediationInfo;
    
    BigoNativeAdRequest *request = [[BigoNativeAdRequest alloc] initWithSlotId: slotId];
    [request setServerBidPayload: parameters.bidResponse];
    [self.adLoader loadAd: request];
}

#pragma mark - Shared Methods

- (BigoAdSize *)adSizeFromAdFormat:(MAAdFormat *)adFormat
{
    // TODO: Bigo does not currently have a leader of size 728x90 but they will be adding it in a later SDK release.
    
    if ( adFormat == MAAdFormat.banner)
    {
        return BigoAdSize.BANNER;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return BigoAdSize.MEDIUM_RECTANGLE;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        
        return BigoAdSize.BANNER;
    }
}

- (NSArray<UIView *> *)clickableViewsForNativeAdView:(MANativeAdView *)maxNativeAdView
{
    NSMutableArray *clickableViews = [NSMutableArray array];
    if ( maxNativeAdView.titleLabel )
    {
        [clickableViews addObject: maxNativeAdView.titleLabel];
    }
    if ( maxNativeAdView.advertiserLabel )
    {
        [clickableViews addObject: maxNativeAdView.advertiserLabel];
    }
    if ( maxNativeAdView.bodyLabel )
    {
        [clickableViews addObject: maxNativeAdView.bodyLabel];
    }
    if ( maxNativeAdView.callToActionButton )
    {
        [clickableViews addObject: maxNativeAdView.callToActionButton];
    }
    
    return clickableViews;
}

- (MAAdapterError *)toMaxError:(BigoAdError *)error
{
    NSInteger bigoErrorCode = error.errorCode;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
    switch ( bigoErrorCode )
    {
        case BIGO_AD_ERROR_CODE_UNINITIALIZED:
            adapterError = MAAdapterError.notInitialized;
            break;
        case BIGO_AD_ERROR_CODE_INVALID_REQUEST:
            adapterError = MAAdapterError.badRequest;
            break;
        case BIGO_AD_ERROR_CODE_NETWORK_ERROR:
            adapterError = MAAdapterError.noConnection;
            break;
        case BIGO_AD_ERROR_CODE_NO_FILL:
            adapterError = MAAdapterError.noFill;
            break;
        case BIGO_AD_ERROR_CODE_INTERNAL_ERROR:
            adapterError = MAAdapterError.internalError;
            break;
        case BIGO_AD_ERROR_CODE_APP_ID_UNMATCHED:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case BIGO_AD_ERROR_CODE_AD_EXPIRED:
            adapterError = MAAdapterError.adExpiredError;
            break;
        case BIGO_AD_ERROR_CODE_NATIVE_VIEW_MISSING:
            adapterError = MAAdapterError.missingRequiredNativeAdAssets;
            break;
        case BIGO_AD_ERROR_CODE_ASSETS_ERROR:
        case BIGO_AD_ERROR_CODE_VIDEO_ERROR:
        case BIGO_AD_ERROR_CODE_FULLSCREEN_AD_FAILED_TO_SHOW:
            adapterError = MAAdapterError.adDisplayFailedError;
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: bigoErrorCode
                     mediatedNetworkErrorMessage: error.errorMsg];
}

- (void)updateUserConsentForParameters:(id<MAAdapterParameters>)parameters
{
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent != nil )
    {
        [BigoAdSdk setUserConsentWithOption: BigoConsentOptionsGDPR consent: hasUserConsent.boolValue];
    }
    
    NSNumber *isDoNotSell = [parameters isDoNotSell];
    if ( isDoNotSell != nil )
    {
        [BigoAdSdk setUserConsentWithOption: BigoConsentOptionsCCPA consent: !isDoNotSell.boolValue];
    }
}

@end

@implementation ALBigoAdsMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.slotId = slotId;
        self.delegate = delegate;
    }
    return self;
}

- (void)onInterstitialAdLoaded:(BigoInterstitialAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad loaded for slot id: %@", self.slotId];
    self.parentAdapter.interstitialAd = ad;
    [self.delegate didLoadInterstitialAd];
}

- (void)onInterstitialAdLoadError:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial ad (%@) failed to load with error: %@", self.slotId, adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)onAdOpened:(BigoAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad opened for slot id: %@", self.slotId];
}

- (void)onAdImpression:(BigoAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad impression recorded for slot id: %@", self.slotId];
    [self.delegate didDisplayInterstitialAd];
}

- (void)onAd:(BigoAd *)ad error:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial ad (%@) failed to show with error: %@", self.slotId, adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)onAdClicked:(BigoAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad click recorded for slot id: %@", self.slotId];
    [self.delegate didClickInterstitialAd];
}

- (void)onAdClosed:(BigoAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad hidden for slot id: %@", self.slotId];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALBigoAdsMediationAdapterAppOpenAdDelegate

- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                            andNotify:(id<MAAppOpenAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.slotId = slotId;
        self.delegate = delegate;
    }
    return self;
}

- (void)onSplashAdLoaded:(BigoSplashAd *)ad
{
    [self.parentAdapter log: @"App open ad loaded for slot id: %@", self.slotId];
    self.parentAdapter.appOpenAd = ad;
    [self.delegate didLoadAppOpenAd];
}

- (void)onSplashAdLoadError:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"App open ad (%@) failed to load with error: %@", self.slotId, adapterError];
    [self.delegate didFailToLoadAppOpenAdWithError: adapterError];
}

- (void)onAdImpression:(BigoAd *)ad
{
    [self.parentAdapter log: @"App open ad impression recorded for slot id: %@", self.slotId];
    [self.delegate didDisplayAppOpenAd];
}

- (void)onAd:(BigoAd *)ad error:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"App open ad (%@) failed to show with error: %@", self.slotId, adapterError];
    [self.delegate didFailToDisplayAppOpenAdWithError: adapterError];
}

- (void)onAdClicked:(BigoAd *)ad
{
    [self.parentAdapter log: @"App open ad click recorded for slot id: %@", self.slotId];
    [self.delegate didClickAppOpenAd];
}

- (void)onAdFinished:(BigoAd *)ad
{
    // NOTE: This callback indicates the display countdown has ended.
    [self.parentAdapter log: @"App open ad finished for slot id: %@", self.slotId];
}

- (void)onAdSkipped:(BigoAd *)ad
{
    [self.parentAdapter log: @"App open ad skipped for slot id: %@", self.slotId];
    
    // NOTE: According to Bigo, the only way to hide their app open ads is by clicking the skip button.
    [self.delegate didHideAppOpenAd];
}

@end

@implementation ALBigoAdsMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                            andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.slotId = slotId;
        self.delegate = delegate;
    }
    return self;
}

- (void)onRewardVideoAdLoaded:(BigoRewardVideoAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad loaded for slot id: %@", self.slotId];
    self.parentAdapter.rewardedAd = ad;
    [self.delegate didLoadRewardedAd];
}

- (void)onRewardVideoAdLoadError:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded ad (%@) failed to load with error: %@", self.slotId, adapterError];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)onAdOpened:(BigoAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad opened for slot id: %@", self.slotId];
}

- (void)onAdImpression:(BigoAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad impression recorded for slot id: %@", self.slotId];
    [self.delegate didDisplayRewardedAd];
}

- (void)onAd:(BigoAd *)ad error:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded ad (%@) failed to show with error: %@", self.slotId, adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)onAdClicked:(BigoAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad click recorded for slot id: %@", self.slotId];
    [self.delegate didClickRewardedAd];
}

- (void)onAdRewarded:(BigoRewardVideoAd *)ad
{
    [self.parentAdapter log: @"User earned reward for slot id: %@", self.slotId];
    self.grantedReward = YES;
}

- (void)onAdClosed:(BigoAd *)ad
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden for slot id: %@", self.slotId];
    [self.delegate didHideRewardedAd];
}

@end

@implementation ALBigoAdsMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.slotId = slotId;
        self.adFormat = adFormat;
        self.delegate = delegate;
    }
    return self;
}

- (void)onBannerAdLoaded:(BigoBannerAd *)ad
{
    [self.parentAdapter log: @"%@ ad loaded for slot id: %@", self.adFormat.label, self.slotId];
    
    self.parentAdapter.adViewAd = ad;
    [self.delegate didLoadAdForAdView: ad.adView];
    [ad setAdInteractionDelegate: self.parentAdapter.adViewAdapterDelegate];
}

- (void)onBannerAdLoadError:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"%@ ad (%@) failed to load with error: %@", self.adFormat.label, self.slotId, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)onAdImpression:(BigoAd *)ad
{
    [self.parentAdapter log: @"%@ ad impression recorded for slot id: %@", self.adFormat.label, self.slotId];
    [self.delegate didDisplayAdViewAd];
}

- (void)onAd:(BigoAd *)ad error:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"%@ ad (%@) failed to show with error: %@", self.adFormat.label, self.slotId, adapterError];
    [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
}

- (void)onAdClicked:(BigoAd *)ad
{
    [self.parentAdapter log: @"%@ ad click recorded for slot id: %@", self.adFormat.label, self.slotId];
    [self.delegate didClickAdViewAd];
}

@end

@implementation ALBigoAdsMediationAdapterNativeAdViewDelegate

- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                             adFormat:(MAAdFormat *)adFormat
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.slotId = slotId;
        self.adFormat = adFormat;
        self.serverParameters = serverParameters;
        self.delegate = delegate;
    }
    return self;
}

- (void)onNativeAdLoaded:(BigoNativeAd *)ad
{
    [self.parentAdapter log: @"Native %@ ad loaded for slot id: %@", self.adFormat.label, self.slotId];
    
    if ( !ad )
    {
        [self.parentAdapter log: @"Native %@ ad (%@) can't be nil.", self.adFormat.label, ad];
        [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
        
        return;
    }
    
    if ( ![ad.title al_isValidString] )
    {
        [self.parentAdapter log: @"Native %@ ad (%@) does not have required assets.", self.adFormat, ad];
        [self.delegate didFailToLoadAdViewAdWithError: [MAAdapterError missingRequiredNativeAdAssets]];
        
        return;
    }
    
    [ad setAdInteractionDelegate: self.parentAdapter.nativeAdViewAdapterDelegate];
    self.parentAdapter.nativeAd = ad;
    
    UIImageView *iconView = [[UIImageView alloc] init];
    BigoAdOptionsView *optionsView = [[BigoAdOptionsView alloc] init];
    BigoAdMediaView *mediaView = [[BigoAdMediaView alloc] init];
    
    MANativeAd *maxNativeAd = [[MABigoAdsNativeAd alloc] initWithParentAdapter: self.parentAdapter adFormat: self.adFormat builderBlock:^(MANativeAdBuilder *builder) {
        builder.title = ad.title;
        builder.advertiser = ad.advertiser;
        builder.body = ad.adDescription;
        builder.callToAction = ad.callToAction;
        builder.iconView = iconView;
        builder.optionsView = optionsView;
        builder.mediaView = mediaView;
    }];
    
    MANativeAdView *maxNativeAdView;
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    if ( [templateName isEqualToString: @"vertical"] )
    {
        NSString *verticalTemplateName = ( self.adFormat == MAAdFormat.leader ) ? @"vertical_leader_template" : @"vertical_media_banner_template";
        maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: verticalTemplateName];
    }
    else
    {
        maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: templateName];
    }
    
    [maxNativeAd prepareForInteractionClickableViews: [self.parentAdapter clickableViewsForNativeAdView: maxNativeAdView] withContainer: maxNativeAdView];
    [self.delegate didLoadAdForAdView: maxNativeAdView];
}

- (void)onNativeAdLoadError:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"Native %@ ad (%@) failed to load with error: %@", self.adFormat.label, self.slotId, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)onAdImpression:(BigoAd *)ad
{
    [self.parentAdapter log: @"Native %@ ad impression recorded for slot id: %@", self.adFormat.label, self.slotId];
    [self.delegate didDisplayAdViewAd];
}

- (void)onAd:(BigoAd *)ad error:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"Native %@ ad (%@) failed to show with error: %@", self.adFormat.label, self.slotId, adapterError];
    [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
}

- (void)onAdClicked:(BigoAd *)ad
{
    [self.parentAdapter log: @"Native %@ ad click recorded for slot id: %@", self.adFormat.label, self.slotId];
    [self.delegate didClickAdViewAd];
}

@end

@implementation ALBigoAdsMediationAdapterNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.slotId = slotId;
        self.serverParameters = serverParameters;
        self.delegate = delegate;
    }
    return self;
}

- (void)onNativeAdLoaded:(BigoNativeAd *)ad
{
    [self.parentAdapter log: @"Native ad loaded for slot id: %@", self.slotId];
    
    if ( !ad )
    {
        [self.parentAdapter log: @"Native ad (%@) can't be nil.", ad];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
        
        return;
    }
    
    [ad setAdInteractionDelegate: self.parentAdapter.nativeAdAdapterDelegate];
    self.parentAdapter.nativeAd = ad;
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    
    if ( isTemplateAd && ![ad.title al_isValidString] )
    {
        [self.parentAdapter log: @"Native ad (%@) does not have required assets.", ad];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.missingRequiredNativeAdAssets];
        
        return;
    }
    
    UIImageView *iconView = [[UIImageView alloc] init];
    BigoAdOptionsView *optionsView = [[BigoAdOptionsView alloc] init];
    BigoAdMediaView *mediaView = [[BigoAdMediaView alloc] init];
    
    MANativeAd *maxNativeAd = [[MABigoAdsNativeAd alloc] initWithParentAdapter: self.parentAdapter adFormat: MAAdFormat.native builderBlock:^(MANativeAdBuilder *builder) {
        builder.title = ad.title;
        builder.advertiser = ad.advertiser;
        builder.body = ad.adDescription;
        builder.callToAction = ad.callToAction;
        builder.iconView = iconView;
        builder.optionsView = optionsView;
        builder.mediaView = mediaView;
    }];
    
    [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
}

- (void)onNativeAdLoadError:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad (%@) failed to load with error: %@", self.slotId, adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)onAdImpression:(BigoAd *)ad
{
    [self.parentAdapter log: @"Native ad impression recorded for slot id: %@", self.slotId];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)onAd:(BigoAd *)ad error:(BigoAdError *)error
{
    MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad (%@) failed to show with error: %@", self.slotId, adapterError];
}

- (void)onAdClicked:(BigoAd *)ad
{
    [self.parentAdapter log: @"Native ad click recorded for slot id: %@", self.slotId];
    [self.delegate didClickNativeAd];
}

@end

@implementation MABigoAdsNativeAd

- (instancetype)initWithParentAdapter:(ALBigoAdsMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: adFormat builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container
{
    BigoNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    MANativeAdView *maxNativeAdView = (MANativeAdView *) container;
    
    BigoAdMediaView *mediaView;
    if ( maxNativeAdView.mediaContentView )
    {
        mediaView = (BigoAdMediaView *) self.mediaView;
    }
    
    UIImageView *iconView;
    if ( maxNativeAdView.iconContentView )
    {
        iconView = (UIImageView *) self.iconView;
    }
    else if ( maxNativeAdView.iconImageView )
    {
        iconView = maxNativeAdView.iconImageView;
    }
    
    BigoAdOptionsView *optionsView;
    if ( maxNativeAdView.optionsContentView )
    {
        optionsView = (BigoAdOptionsView *) self.optionsView;
    }
    
    [nativeAd registerViewForInteraction: container
                               mediaView: mediaView
                              adIconView: iconView
                           adOptionsView: optionsView
                          clickableViews: clickableViews];
    
    return YES;
}

@end

@implementation MDBigoAdsMediationAdapter

@end
