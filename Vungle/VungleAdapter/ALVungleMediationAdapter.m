//
//  ALVungleMediationAdapter.m
//  Adapters
//
//  Created by Christopher Cong on 10/19/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

#import "ALVungleMediationAdapter.h"
#import <VungleAdsSDK/VungleAdsSDK.h>

#define ADAPTER_VERSION @"7.4.0.0"

@interface ALVungleMediationAdapterInterstitialAdDelegate : NSObject <VungleInterstitialDelegate>
@property (nonatomic,   weak) ALVungleMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALVungleMediationAdapterAppOpenAdDelegate : NSObject <VungleInterstitialDelegate>
@property (nonatomic,   weak) ALVungleMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAppOpenAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter andNotify:(id<MAAppOpenAdapterDelegate>)delegate;
@end

@interface ALVungleMediationAdapterRewardedAdDelegate : NSObject <VungleRewardedDelegate>
@property (nonatomic,   weak) ALVungleMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALVungleMediationAdapterAdViewDelegate : NSObject <VungleBannerDelegate>
@property (nonatomic,   weak) ALVungleMediationAdapter *parentAdapter;
@property (nonatomic, strong) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MAAdapterResponseParameters> parameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)adFormat
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALVungleMediationAdapterNativeAdViewDelegate : NSObject <VungleNativeDelegate>
@property (nonatomic,   weak) ALVungleMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) MAAdFormat *adFormat;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)adFormat
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALVungleMediationAdapterNativeAdDelegate : NSObject <VungleNativeDelegate>
@property (nonatomic,   weak) ALVungleMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAVungleNativeAd : MANativeAd
@property (nonatomic, weak) ALVungleMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALVungleMediationAdapter ()

// Interstitial
@property (nonatomic, strong) VungleInterstitial *interstitialAd;
@property (nonatomic, strong) ALVungleMediationAdapterInterstitialAdDelegate *interstitialAdDelegate;

//App Open Ads
@property (nonatomic, strong) VungleInterstitial *appOpenAd;
@property (nonatomic, strong) ALVungleMediationAdapterAppOpenAdDelegate *appOpenAdDelegate;

// Rewarded
@property (nonatomic, strong) VungleRewarded *rewardedAd;
@property (nonatomic, strong) ALVungleMediationAdapterRewardedAdDelegate *rewardedAdDelegate;

// AdView
@property (nonatomic, strong) VungleBanner *adView;
@property (nonatomic, strong) UIView *adViewContainer;
@property (nonatomic, strong) ALVungleMediationAdapterAdViewDelegate *adViewDelegate;

// Native Ad
@property (nonatomic, strong) VungleNative *nativeAd;
@property (nonatomic, strong) ALVungleMediationAdapterNativeAdDelegate *nativeAdDelegate;
@property (nonatomic, strong) ALVungleMediationAdapterNativeAdViewDelegate *nativeAdViewDelegate;

@end

@implementation ALVungleMediationAdapter

static ALAtomicBoolean              *ALVungleInitialized;
static MAAdapterInitializationStatus ALVungleIntializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALVungleInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [self updateUserPrivacySettingsForParameters: parameters];
    
    if ( [ALVungleInitialized compareAndSet: NO update: YES] )
    {
        ALVungleIntializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *appID = [parameters.serverParameters al_stringForKey: @"app_id"];
        [self log: @"Initializing Vungle SDK with app id: %@...", appID];
        
        [VungleAds setIntegrationName: @"max" version: ADAPTER_VERSION];
        [VungleAds initWithAppId: appID completion:^(NSError * _Nullable error) {
            if ( error )
            {
                [ALVungleInitialized set: NO];
                
                [self log: @"Vungle SDK failed to initialize with error: %@", error];
                
                ALVungleIntializationStatus = MAAdapterInitializationStatusInitializedFailure;
                NSString *errorString = [NSString stringWithFormat: @"%ld:%@", (long) error.code, error.localizedDescription];
                
                completionHandler(ALVungleIntializationStatus, errorString);
                
                return;
            }
            
            [self log: @"Vungle SDK initialized"];
            
            ALVungleIntializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            completionHandler(ALVungleIntializationStatus, nil);
        }];
    }
    else
    {
        completionHandler(ALVungleIntializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [VungleAds sdkVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdDelegate = nil;
    
    self.appOpenAd.delegate = nil;
    self.appOpenAd = nil;
    self.appOpenAdDelegate = nil;
    
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewDelegate = nil;
    self.adViewContainer = nil;
    
    [self.nativeAd unregisterView];
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdDelegate.delegate = nil;
    self.nativeAdViewDelegate.delegate = nil;
    self.nativeAdDelegate = nil;
    self.nativeAdViewDelegate = nil;
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updateUserPrivacySettingsForParameters: parameters];
    
    NSString *signal = [VungleAds getBiddingToken];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@interstitial ad for placement: %@...", ( isBiddingAd ? @"bidding " : @"" ), placementIdentifier];
    
    if ( [self shouldFailAdLoadWhenSDKNotInitialized: parameters] && ![VungleAds isInitialized] )
    {
        [self log: @"Vungle SDK not successfully initialized: failing interstitial ad load..."];
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateUserPrivacySettingsForParameters: parameters];
    
    self.interstitialAd = [[VungleInterstitial alloc] initWithPlacementId: placementIdentifier];
    self.interstitialAdDelegate = [[ALVungleMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd.delegate = self.interstitialAdDelegate;
    
    [self.interstitialAd load: bidResponse];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    if ( [self.interstitialAd canPlayAd] )
    {
        [self log: @"Showing interstitial ad for placement: %@...", parameters.thirdPartyAdPlacementIdentifier];
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [self.interstitialAd presentWith: presentingViewController];
    }
    else
    {
        [self log: @"Failed to show interstitial ad: ad not ready"];
        
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

- (void)loadAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@app open ad for placement: %@...", ( isBiddingAd ? @"bidding " : @"" ), placementIdentifier];
    
    if ( [self shouldFailAdLoadWhenSDKNotInitialized: parameters] && ![VungleAds isInitialized] )
    {
        [self log: @"Vungle SDK not successfully initialized: failing app open ad load..."];
        [delegate didFailToLoadAppOpenAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateUserPrivacySettingsForParameters: parameters];
    
    self.appOpenAdDelegate = [[ALVungleMediationAdapterAppOpenAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.appOpenAd = [[VungleInterstitial alloc] initWithPlacementId: placementIdentifier];
    self.appOpenAd.delegate = self.appOpenAdDelegate;
    
    [self.appOpenAd load: bidResponse];
}

- (void)showAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegate>)delegate
{
    if ( [self.appOpenAd canPlayAd] )
    {
        [self log: @"Showing app open ad for placement: %@...", parameters.thirdPartyAdPlacementIdentifier];
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [self.appOpenAd presentWith: presentingViewController];
    }
    else
    {
        [self log: @"Failed to show app open ad: ad not ready"];
        [delegate didFailToDisplayAppOpenAdWithError: [MAAdapterError errorWithCode: -4205
                                                                        errorString: @"Ad Display Failed"
                                                           mediatedNetworkErrorCode: 0
                                                        mediatedNetworkErrorMessage: @"App open ad not ready"]];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@rewarded ad for placement: %@...", ( isBiddingAd ? @"bidding " : @"" ), placementIdentifier];
    
    if ( [self shouldFailAdLoadWhenSDKNotInitialized: parameters] && ![VungleAds isInitialized] )
    {
        [self log: @"Vungle SDK not successfully initialized: failing rewarded ad load..."];
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateUserPrivacySettingsForParameters: parameters];
    
    self.rewardedAd = [[VungleRewarded alloc] initWithPlacementId: placementIdentifier];
    self.rewardedAdDelegate = [[ALVungleMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd.delegate = self.rewardedAdDelegate;
    
    [self.rewardedAd load: bidResponse];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    if ( [self.rewardedAd canPlayAd] )
    {
        [self log: @"Showing rewarded ad for placement: %@...", parameters.thirdPartyAdPlacementIdentifier];
        
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
        
        [self.rewardedAd presentWith: presentingViewController];
    }
    else
    {
        [self log: @"Failed to show rewarded ad: ad not ready"];
        
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

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    NSString *adFormatLabel = adFormat.label;
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    
    BOOL isBiddingAd = [bidResponse al_isValidString];
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    
    [self log: @"Loading %@%@%@ ad for placement: %@...", ( isBiddingAd ? @"bidding " : @"" ), ( isNative ? @"native " : @"" ), adFormatLabel, placementIdentifier];
    
    if ( [self shouldFailAdLoadWhenSDKNotInitialized: parameters] && ![VungleAds isInitialized] )
    {
        [self log: @"Vungle SDK not successfully initialized: failing %@ ad load...", adFormatLabel];
        [delegate didFailToLoadAdViewAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateUserPrivacySettingsForParameters: parameters];
    
    if ( isNative )
    {
        self.nativeAdViewDelegate = [[ALVungleMediationAdapterNativeAdViewDelegate alloc] initWithParentAdapter: self
                                                                                                         format: adFormat
                                                                                                     parameters: parameters
                                                                                                      andNotify: delegate];
        [self loadVungleNativeAdForParameters: parameters andNotify: self.nativeAdViewDelegate];
    }
    else
    {
        BannerSize adSize = [self adSizeFromAdFormat: adFormat];
        
        self.adView = [[VungleBanner alloc] initWithPlacementId: placementIdentifier size: adSize];
        self.adViewDelegate = [[ALVungleMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self
                                                                                             format: adFormat
                                                                                         parameters: parameters
                                                                                          andNotify: delegate];
        self.adView.delegate = self.adViewDelegate;
        
        self.adViewContainer = [[UIView alloc] initWithFrame: (CGRect) { CGPointZero, adFormat.size }];
        
        [self.adView load: bidResponse];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    
    [self log: @"Loading %@native ad for placement: %@...", ( isBiddingAd ? @"bidding " : @"" ), placementIdentifier];
    
    if ( [self shouldFailAdLoadWhenSDKNotInitialized: parameters] && ![VungleAds isInitialized] )
    {
        [self log: @"Vungle SDK not successfully initialized: failing native ad load..."];
        [delegate didFailToLoadNativeAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateUserPrivacySettingsForParameters: parameters];
    
    self.nativeAdDelegate = [[ALVungleMediationAdapterNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                         parameters: parameters
                                                                                          andNotify: delegate];
    [self loadVungleNativeAdForParameters: parameters andNotify: self.nativeAdDelegate];
}

#pragma mark - Shared Methods

- (BOOL)shouldFailAdLoadWhenSDKNotInitialized:(id<MAAdapterResponseParameters>)parameters
{
    return [parameters.serverParameters al_boolForKey: @"fail_ad_load_when_sdk_not_initialized" defaultValue: YES];
}

- (void)updateUserPrivacySettingsForParameters:(id<MAAdapterParameters>)parameters
{
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent != nil )
    {
        [VunglePrivacySettings setGDPRStatus: hasUserConsent.boolValue];
        [VunglePrivacySettings setGDPRMessageVersion: @""];
    }
    
    NSNumber *isAgeRestrictedUser = [parameters isAgeRestrictedUser];
    if ( isAgeRestrictedUser != nil )
    {
        [VunglePrivacySettings setCOPPAStatus: isAgeRestrictedUser.boolValue];
    }
    
    NSNumber *isDoNotSell = [parameters isDoNotSell];
    if ( isDoNotSell != nil )
    {
        [VunglePrivacySettings setCCPAStatus: !isDoNotSell.boolValue];
    }
}

- (void)loadVungleNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<VungleNativeDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    
    self.nativeAd = [[VungleNative alloc] initWithPlacementId: placementIdentifier];
    self.nativeAd.delegate = delegate;
    self.nativeAd.adOptionsPosition = NativeAdOptionsPositionTopRight;
    [self.nativeAd load: bidResponse];
}

- (NSArray<UIView *> *)clickableViewsForNativeAdView:(MANativeAdView *)maxNativeAdView
{
    NSMutableArray *clickableViews = [NSMutableArray array];
    if ( maxNativeAdView.titleLabel )
    {
        [clickableViews addObject: maxNativeAdView.titleLabel];
    }
    if ( maxNativeAdView.bodyLabel )
    {
        [clickableViews addObject: maxNativeAdView.bodyLabel];
    }
    if ( maxNativeAdView.callToActionButton )
    {
        [clickableViews addObject: maxNativeAdView.callToActionButton];
    }
    if ( maxNativeAdView.iconImageView )
    {
        [clickableViews addObject: maxNativeAdView.iconImageView];
    }
    if ( maxNativeAdView.mediaContentView )
    {
        [clickableViews addObject: maxNativeAdView.mediaContentView];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // Introduced in 10.4.0
    if ( [maxNativeAdView respondsToSelector: @selector(advertiserLabel)] )
    {
        id advertiserLabel = [maxNativeAdView performSelector: @selector(advertiserLabel)];
        if ( advertiserLabel )
        {
            [clickableViews addObject: advertiserLabel];
        }
    }
#pragma clang diagnostic pop
    
    return clickableViews;
}

- (BannerSize)adSizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return BannerSizeRegular;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return BannerSizeLeaderboard;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return BannerSizeMrec;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return BannerSizeRegular;
    }
}

+ (MAAdapterError *)toMaxError:(nullable NSError *)vungleError isAdPresentError:(BOOL)adPresentError
{
    if ( !vungleError ) return MAAdapterError.unspecified;
    
    int vungleErrorCode = (int) vungleError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
    switch ( vungleErrorCode )
    {
        case VungleErrorSdkNotInitialized:
            adapterError = MAAdapterError.notInitialized;
            break;
        case VungleErrorInvalidAppID:
        case VungleErrorInvalidPlacementID:
        case VungleErrorPlacementAdTypeMismatch:
        case VungleErrorInvalidWaterfallPlacementID:
        case VungleErrorBannerViewInvalidSize:
        case VungleErrorAdPublisherMismatch:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case VungleErrorJsonEncodeError:
        case VungleErrorAdInternalIntegrationError:
            adapterError = MAAdapterError.internalError;
            break;
        case VungleErrorAdConsumed:
        case VungleErrorAdIsLoading:
        case VungleErrorAdAlreadyLoaded:
        case VungleErrorAdIsPlaying:
        case VungleErrorAdAlreadyFailed:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case VungleErrorAdNotLoaded:
            adapterError = adPresentError ? MAAdapterError.adNotReady : MAAdapterError.invalidLoadState;
            break;
        case VungleErrorInvalidIndexURL:
        case VungleErrorInvalidIfaStatus:
        case VungleErrorMraidBridgeError:
        case VungleErrorConcurrentPlaybackUnsupported:
            adapterError = MAAdapterError.adDisplayFailedError;
            break;
        case VungleErrorPlacementSleep:
        case VungleErrorAdNoFill:
        case VungleErrorAdLoadTooFrequently:
            adapterError = MAAdapterError.noFill;
            break;
        case VungleErrorAdResponseTimedOut:
            adapterError = MAAdapterError.timeout;
            break;
        case VungleErrorAdResponseRetryAfter:
        case VungleErrorAdLoadFailRetryAfter:
        case VungleErrorAdServerError:
            adapterError = MAAdapterError.serverError;
            break;
        case VungleErrorAdExpired:
        case VungleErrorAdExpiredOnPlay:
            adapterError = MAAdapterError.adExpiredError;
            break;
        case VungleErrorNativeAssetError:
            adapterError = MAAdapterError.missingRequiredNativeAdAssets;
            break;
        case VungleErrorWebViewWebContentProcessDidTerminate:
        case VungleErrorWebViewFailedNavigation:
            adapterError = MAAdapterError.webViewError;
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

@end

@implementation ALVungleMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialAdDidLoad:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad loaded: %@", interstitial.placementId];
    
    NSString *creativeIdentifier = interstitial.creativeId;
    if ( [creativeIdentifier al_isValidString] )
    {
        [self.delegate didLoadInterstitialAdWithExtraInfo: @{@"creative_id" : creativeIdentifier}];
    }
    else
    {
        [self.delegate didLoadInterstitialAd];
    }
}

- (void)interstitialAdDidFailToLoad:(VungleInterstitial *)interstitial withError:(NSError *)error
{
    MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error isAdPresentError: NO];
    [self.parentAdapter log: @"Interstitial ad (%@) failed to load with error: %@", interstitial.placementId, adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialAdWillPresent:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad will present: %@", interstitial.placementId];
}

- (void)interstitialAdDidPresent:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad shown: %@", interstitial.placementId];
}

- (void)interstitialAdDidTrackImpression:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad impression tracked: %@", interstitial.placementId];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialAdDidFailToPresent:(VungleInterstitial *)interstitial withError:(NSError *)error
{
    MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error isAdPresentError: YES];
    [self.parentAdapter log: @"Interstitial ad (%@) failed to show with error: %@", interstitial.placementId, adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)interstitialAdDidClick:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad clicked: %@", interstitial.placementId];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialAdWillLeaveApplication:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad will leave application: %@", interstitial.placementId];
}

- (void)interstitialAdWillClose:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad will close: %@", interstitial.placementId];
}

- (void)interstitialAdDidClose:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad hidden: %@", interstitial.placementId];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALVungleMediationAdapterAppOpenAdDelegate

- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter andNotify:(id<MAAppOpenAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialAdDidLoad:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"App Open ad loaded: %@", interstitial.placementId];
    
    NSString *creativeIdentifier = interstitial.creativeId;
    if ( [creativeIdentifier al_isValidString] )
    {
        [self.delegate didLoadAppOpenAdWithExtraInfo: @{@"creative_id" : creativeIdentifier}];
    }
    else
    {
        [self.delegate didLoadAppOpenAd];
    }
}

- (void)interstitialAdDidFailToLoad:(VungleInterstitial *)interstitial withError:(NSError *)error
{
    MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error isAdPresentError: NO];
    [self.parentAdapter log: @"App Open ad (%@) failed to load with error: %@", interstitial.placementId, adapterError];
    [self.delegate didFailToLoadAppOpenAdWithError: adapterError];
}

- (void)interstitialAdWillPresent:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"App Open will present: %@", interstitial.placementId];
}

- (void)interstitialAdDidPresent:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"App Open ad shown: %@", interstitial.placementId];
}

- (void)interstitialAdDidTrackImpression:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"App Open ad impression tracked: %@", interstitial.placementId];
    [self.delegate didDisplayAppOpenAd];
}

- (void)interstitialAdDidFailToPresent:(VungleInterstitial *)interstitial withError:(NSError *)error
{
    MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error isAdPresentError: YES];
    [self.parentAdapter log: @"App Open ad (%@) failed to show with error: %@", interstitial.placementId, adapterError];
    [self.delegate didFailToLoadAppOpenAdWithError: adapterError];
}

- (void)interstitialAdDidClick:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"App Open ad clicked: %@", interstitial.placementId];
    [self.delegate didClickAppOpenAd];
}

- (void)interstitialAdWillLeaveApplication:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"App Open ad will leave application: %@", interstitial.placementId];
}

- (void)interstitialAdWillClose:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"App Open ad will close: %@", interstitial.placementId];
}

- (void)interstitialAdDidClose:(VungleInterstitial *)interstitial
{
    [self.parentAdapter log: @"App Open ad hidden: %@", interstitial.placementId];
    [self.delegate didHideAppOpenAd];
}

@end

@implementation ALVungleMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedAdDidLoad:(VungleRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad loaded: %@", rewarded.placementId];
    
    NSString *creativeIdentifier = rewarded.creativeId;
    if ( [creativeIdentifier al_isValidString] )
    {
        [self.delegate didLoadRewardedAdWithExtraInfo: @{@"creative_id" : creativeIdentifier}];
    }
    else
    {
        [self.delegate didLoadRewardedAd];
    }
}

- (void)rewardedAdDidFailToLoad:(VungleRewarded *)rewarded withError:(NSError *)error
{
    MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error isAdPresentError: NO];
    [self.parentAdapter log: @"Rewarded ad (%@) failed to load with error: %@", rewarded.placementId, adapterError];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedAdWillPresent:(VungleRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad will present: %@", rewarded.placementId];
}

- (void)rewardedAdDidPresent:(VungleRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad shown: %@", rewarded.placementId];
}

- (void)rewardedAdDidTrackImpression:(VungleRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad impression tracked: %@", rewarded.placementId];
    [self.delegate didDisplayRewardedAd];
}

- (void)rewardedAdDidFailToPresent:(VungleRewarded *)rewarded withError:(NSError *)error
{
    MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error isAdPresentError: YES];
    [self.parentAdapter log: @"Rewarded ad (%@) failed to show with error: %@", rewarded.placementId, adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)rewardedAdDidClick:(VungleRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad clicked: %@", rewarded.placementId];
    [self.delegate didClickRewardedAd];
}

- (void)rewardedAdWillLeaveApplication:(VungleRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad will leave application: %@", rewarded.placementId];
}

- (void)rewardedAdDidRewardUser:(VungleRewarded *)rewarded
{
    [self.parentAdapter log: @"User earned reward: %@", rewarded.placementId];
    self.grantedReward = YES;
}

- (void)rewardedAdWillClose:(VungleRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad will close: %@", rewarded.placementId];
}

- (void)rewardedAdDidClose:(VungleRewarded *)rewarded
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden: %@", rewarded.placementId];
    [self.delegate didHideRewardedAd];
}

@end

@implementation ALVungleMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)adFormat
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.adFormat = adFormat;
        self.parameters = parameters;
        self.delegate = delegate;
    }
    return self;
}

- (void)bannerAdDidLoad:(VungleBanner *)banner
{
    [self.parentAdapter log: @"AdView loaded: %@", banner.placementId];
    
    NSString *creativeIdentifier = banner.creativeId;
    if ( [creativeIdentifier al_isValidString] )
    {
        [self.delegate didLoadAdForAdView: self.parentAdapter.adViewContainer withExtraInfo: @{@"creative_id" : creativeIdentifier}];
    }
    else
    {
        [self.delegate didLoadAdForAdView: self.parentAdapter.adViewContainer];
    }
    
    if ( [banner canPlayAd] )
    {
        [banner presentOn: self.parentAdapter.adViewContainer];
    }
    else
    {
        [self.parentAdapter log: @"Failed to load ad view ad: ad not ready"];
        [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.adNotReady];
    }
}

- (void)bannerAdDidFailToLoad:(VungleBanner *)banner withError:(NSError *)error
{
    MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error isAdPresentError: NO];
    [self.parentAdapter log: @"AdView failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)bannerAdWillPresent:(VungleBanner *)banner
{
    [self.parentAdapter log: @"AdView ad will present %@", banner.placementId];
}

- (void)bannerAdDidPresent:(VungleBanner *)banner
{
    [self.parentAdapter log: @"AdView ad shown %@", banner.placementId];
}

- (void)bannerAdDidTrackImpression:(VungleBanner *)banner
{
    [self.parentAdapter log: @"AdView ad impression tracked %@", banner.placementId];
    [self.delegate didDisplayAdViewAd];
}

- (void)bannerAdDidClick:(VungleBanner *)banner
{
    [self.parentAdapter log: @"AdView ad clicked %@", banner.placementId];
    [self.delegate didClickAdViewAd];
}

- (void)bannerAdWillLeaveApplication:(VungleBanner *)banner
{
    [self.parentAdapter log: @"AdView ad will leave application %@", banner.placementId];
}

- (void)bannerAdDidFailToPresent:(VungleBanner *)banner withError:(NSError *)error
{
    MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error isAdPresentError: YES];
    [self.parentAdapter log: @"AdView ad failed to present with error: %@", adapterError];
    [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
}

- (void)bannerAdWillClose:(VungleBanner *)banner
{
    [self.parentAdapter log: @"AdView ad will close %@", banner.placementId];
}

- (void)bannerAdDidClose:(VungleBanner *)banner
{
    [self.parentAdapter log: @"AdView ad hidden %@", banner.placementId];
    [self.delegate didHideAdViewAd];
}

@end

@implementation ALVungleMediationAdapterNativeAdViewDelegate

- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)adFormat
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
        self.adFormat = adFormat;
        self.serverParameters = parameters.serverParameters;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeAdDidLoad:(VungleNative *)nativeAd
{
    if ( !nativeAd || self.parentAdapter.nativeAd != nativeAd )
    {
        [self.parentAdapter log: @"Native %@ ad failed to load: no fill", self.adFormat];
        [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
        
        return;
    }
    
    if ( ![nativeAd.title al_isValidString] )
    {
        [self.parentAdapter e: @"Native %@ ad (%@) does not have required assets.", self.adFormat, nativeAd];
        [self.delegate didFailToLoadAdViewAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    [self.parentAdapter log: @"Native %@ ad loaded: %@", self.adFormat, self.placementIdentifier];
    
    dispatchOnMainQueue(^{
        MediaView *mediaView = [[MediaView alloc] init];
        
        MAVungleNativeAd *maxVungleNativeAd = [[MAVungleNativeAd alloc] initWithParentAdapter: self.parentAdapter adFormat: self.adFormat builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = nativeAd.title;
            builder.body = nativeAd.bodyText;
            builder.callToAction = nativeAd.callToAction;
            builder.icon = [[MANativeAdImage alloc] initWithImage: nativeAd.iconImage];
            builder.mediaView = mediaView;
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            // Introduced in 10.4.0
            if ( [builder respondsToSelector: @selector(setAdvertiser:)] )
            {
                [builder performSelector: @selector(setAdvertiser:) withObject: nativeAd.sponsoredText];
            }
#pragma clang diagnostic pop
        }];
        
        // Backend will pass down `vertical` as the template to indicate using a vertical native template
        MANativeAdView *maxNativeAdView;
        NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
        if ( [templateName containsString: @"vertical"] )
        {
            if ( [templateName isEqualToString: @"vertical"] )
            {
                NSString *verticalTemplateName = ( self.adFormat == MAAdFormat.leader ) ? @"vertical_leader_template" : @"vertical_media_banner_template";
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxVungleNativeAd withTemplate: verticalTemplateName];
            }
            else
            {
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxVungleNativeAd withTemplate: templateName];
            }
        }
        else
        {
            maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxVungleNativeAd withTemplate: [templateName al_isValidString] ? templateName : @"media_banner_template"];
        }
        
        [maxVungleNativeAd prepareForInteractionClickableViews: [self.parentAdapter clickableViewsForNativeAdView: maxNativeAdView] withContainer: maxNativeAdView];
        
        NSString *creativeIdentifier = nativeAd.creativeId;
        if ( [creativeIdentifier al_isValidString] )
        {
            [self.delegate didLoadAdForAdView: maxNativeAdView withExtraInfo: @{@"creative_id" : creativeIdentifier}];
        }
        else
        {
            [self.delegate didLoadAdForAdView: maxNativeAdView];
        }
    });
}

- (void)nativeAd:(VungleNative *)nativeAd didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error isAdPresentError: NO];
    [self.parentAdapter log: @"Native %@ ad failed to load with error: %@", self.adFormat, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)nativeAdDidTrackImpression:(VungleNative *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad shown: %@", self.adFormat, self.placementIdentifier];
    [self.delegate didDisplayAdViewAd];
}

- (void)nativeAdDidClick:(VungleNative *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad clicked: %@", self.adFormat, self.placementIdentifier];
    [self.delegate didClickAdViewAd];
}

@end

@implementation ALVungleMediationAdapterNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
        self.serverParameters = parameters.serverParameters;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeAdDidLoad:(VungleNative *)nativeAd
{
    if ( !nativeAd || self.parentAdapter.nativeAd != nativeAd )
    {
        [self.parentAdapter log: @"Native ad failed to load: no fill"];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
        
        return;
    }
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    if ( isTemplateAd && ![nativeAd.title al_isValidString] )
    {
        [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    [self.parentAdapter log: @"Native ad loaded: %@", self.placementIdentifier];
    
    dispatchOnMainQueue(^{
        MediaView *mediaView = [[MediaView alloc] init];
        
        MANativeAd *maxNativeAd = [[MAVungleNativeAd alloc] initWithParentAdapter: self.parentAdapter adFormat: MAAdFormat.native builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = nativeAd.title;
            builder.body = nativeAd.bodyText;
            builder.callToAction = nativeAd.callToAction;
            builder.icon = [[MANativeAdImage alloc] initWithImage: nativeAd.iconImage];
            builder.mediaView = mediaView;
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            // Introduced in 10.4.0
            if ( [builder respondsToSelector: @selector(setAdvertiser:)] )
            {
                [builder performSelector: @selector(setAdvertiser:) withObject: nativeAd.sponsoredText];
            }
#pragma clang diagnostic pop
        }];
        
        NSString *creativeIdentifier = nativeAd.creativeId;
        if ( [creativeIdentifier al_isValidString] )
        {
            [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: @{@"creative_id" : creativeIdentifier}];
        }
        else
        {
            [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
        }
    });
}

- (void)nativeAd:(VungleNative *)nativeAd didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALVungleMediationAdapter toMaxError: error isAdPresentError: NO];
    [self.parentAdapter log: @"Native ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeAdDidTrackImpression:(VungleNative *)nativeAd
{
    [self.parentAdapter log: @"Native ad shown: %@", self.placementIdentifier];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeAdDidClick:(VungleNative *)nativeAd
{
    [self.parentAdapter log: @"Native ad clicked: %@", self.placementIdentifier];
    [self.delegate didClickNativeAd];
}

@end

@implementation MAVungleNativeAd

- (instancetype)initWithParentAdapter:(ALVungleMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: format builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (void)prepareViewForInteraction:(MANativeAdView *)maxNativeAdView
{
    [self prepareForInteractionClickableViews: [self.parentAdapter clickableViewsForNativeAdView: maxNativeAdView] withContainer: maxNativeAdView];
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container
{
    VungleNative *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    NSMutableArray *vungleClickableViews = [clickableViews mutableCopy];
    if ( self.mediaView )
    {
        [vungleClickableViews addObject: self.mediaView]; // mediaView needs to be in the clickableViews for the mediaView to be clickable even though it is only a container of the network's media view
    }
    
    UIImageView *iconImageView = nil;
    for ( UIView *clickableView in clickableViews )
    {
        if( [clickableView isKindOfClass: [UIImageView class]] )
        {
            iconImageView = (UIImageView *)clickableView;
            break;
        }
    }
    
    [self.parentAdapter d: @"Preparing views for interaction: %@ with container: %@", vungleClickableViews, container];
    
    [nativeAd registerViewForInteractionWithView: container
                                       mediaView: (MediaView *) self.mediaView
                                   iconImageView: iconImageView
                                  viewController: [ALUtils topViewControllerFromKeyWindow]
                                  clickableViews: vungleClickableViews];
    
    return YES;
}

@end
