//
//  ALMobileFuseMediationAdapter.m
//  Adapters
//
//  Created by Wootae on 9/30/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALMobileFuseMediationAdapter.h"
#import <MobileFuseSDK/MobileFuse.h>
#import <MobileFuseSDK/MobileFuseSettings.h>
#import <MobileFuseSDK/IMFAdCallbackReceiver.h>
#import <MobileFuseSDK/MFBiddingTokenProvider.h>
#import <MobileFuseSDK/MFInterstitialAd.h>
#import <MobileFuseSDK/MFBannerAd.h>
#import <MobileFuseSDK/MFRewardedAd.h>
#import <MobileFuseSDK/MFNativeAd.h>

#define ADAPTER_VERSION @"1.4.0.1"

/**
 * Enum representing the list of MobileFuse SDK error codes in https://docs.mobilefuse.com/docs/error-codes.
 */
typedef NS_ENUM(NSInteger, MFAdErrorCode)
{
    /**
     * Cannot load this ad - it is already loaded.
     */
    MFAdErrorCodeAdAlreadyLoaded = 1,
    
    /**
     * There was an error while attempting to display the ad such as a bad campaign or invalid ad markup.
     */
    MFAdErrorCodeAdRuntimeError = 3,
    
    /**
     * Cannot show this ad - it has already been displayed (call LoadAd again).
     */
    MFAdErrorCodeAdAlreadyRendered = 4,
    
    /**
     * The ad failed to load.
     */
    MFAdErrorCodeAdLoadError = 5
};

@interface ALMobileFuseInterstitialDelegate : NSObject <IMFAdCallbackReceiver>
@property (nonatomic,   weak) ALMobileFuseMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALMobileFuseRewardedDelegate : NSObject <IMFAdCallbackReceiver>
@property (nonatomic,   weak) ALMobileFuseMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALMobileFuseAdViewDelegate : NSObject <IMFAdCallbackReceiver>
@property (nonatomic,   weak) ALMobileFuseMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALMobileFuseNativeAdViewDelegate : NSObject <IMFAdCallbackReceiver>
@property (nonatomic,   weak) ALMobileFuseMediationAdapter *parentAdapter;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)adFormat
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALMobileFuseNativeAdDelegate : NSObject <IMFAdCallbackReceiver>
@property (nonatomic,   weak) ALMobileFuseMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAMobileFuseNativeAd : MANativeAd
@property (nonatomic, weak) ALMobileFuseMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter format:(MAAdFormat *)adFormat builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALMobileFuseMediationAdapter ()

@property (nonatomic, strong) MFInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALMobileFuseInterstitialDelegate *interstitialAdapterDelegate;

@property (nonatomic, strong) MFRewardedAd *rewardedAd;
@property (nonatomic, strong) ALMobileFuseRewardedDelegate *rewardedAdapterDelegate;

@property (nonatomic, strong) MFBannerAd *adView;
@property (nonatomic, strong) ALMobileFuseAdViewDelegate *adViewAdapterDelegate;
@property (nonatomic, strong) ALMobileFuseNativeAdViewDelegate *nativeAdViewAdapterDelegate;

@property (nonatomic, strong) MFNativeAd *nativeAd;
@property (nonatomic, strong) ALMobileFuseNativeAdDelegate *nativeAdAdapterDelegate;

@end

@implementation ALMobileFuseMediationAdapter

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [MobileFuseSettings setTestMode: [parameters isTesting]];
    completionHandler(MAAdapterInitializationStatusInitializedUnknown, nil);
}

- (NSString *)SDKVersion
{
    return MobileFuse.version;
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self.interstitialAd destroy];
    self.interstitialAd = nil;
    self.interstitialAdapterDelegate = nil;
    
    [self.rewardedAd destroy];
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate = nil;
    
    [self.adView destroy];
    self.adView = nil;
    self.adViewAdapterDelegate = nil;
    
    [self.nativeAd unregisterViews];
    [self.nativeAd destroy];
    self.nativeAd = nil;
    self.nativeAdViewAdapterDelegate = nil;
    self.nativeAdAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updatePrivacyPreferences: parameters];
    
    MFBiddingTokenRequest *request = [[MFBiddingTokenRequest alloc] init];
    request.isTestMode = [parameters isTesting];
    
    NSString *token = [MFBiddingTokenProvider getTokenWithRequest: request];
    [delegate didCollectSignal: token];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    
    [self log: @"Loading interstitial ad: %@...", placementId];
    
    [self updatePrivacyPreferences: parameters];
    
    self.interstitialAd = [[MFInterstitialAd alloc] initWithPlacementId: placementId];
    self.interstitialAdapterDelegate = [[ALMobileFuseInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    [self.interstitialAd registerAdCallbackReceiver: self.interstitialAdapterDelegate];
    [self.interstitialAd loadAdWithBiddingResponseToken: parameters.bidResponse];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad: %@...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( [self.interstitialAd isExpired] )
    {
        [self log: @"Unable to show interstitial - ad expired"];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adExpiredError];
        
        return;
    }
    else if ( ![self.interstitialAd isAdReady] )
    {
        [self log: @"Unable to show interstitial - ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205
                                                                             errorString: @"Ad Display Failed"
                                                                mediatedNetworkErrorCode: 0
                                                             mediatedNetworkErrorMessage: @"Interstitial ad not ready"]];
        
        return;
    }
    
    UIViewController *presentingViewController = [self presentingViewControllerFromParameters: parameters];
    [presentingViewController.view addSubview: self.interstitialAd];
    [self.interstitialAd showAd];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    
    [self log: @"Loading rewarded ad: %@...", placementId];
    
    [self updatePrivacyPreferences: parameters];
    
    self.rewardedAd = [[MFRewardedAd alloc] initWithPlacementId: placementId];
    self.rewardedAdapterDelegate = [[ALMobileFuseRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    [self.rewardedAd registerAdCallbackReceiver: self.rewardedAdapterDelegate];
    [self.rewardedAd loadAdWithBiddingResponseToken: parameters.bidResponse];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad: %@...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( [self.rewardedAd isExpired] )
    {
        [self log: @"Unable to show rewarded ad - ad expired"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adExpiredError];
        
        return;
    }
    else if ( ![self.rewardedAd isAdReady] )
    {
        [self log: @"Unable to show rewarded ad - ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithCode: -4205
                                                                         errorString: @"Ad Display Failed"
                                                            mediatedNetworkErrorCode: 0
                                                         mediatedNetworkErrorMessage: @"Rewarded ad not ready"]];
        
        return;
    }
    
    [self configureRewardForParameters: parameters];
    
    UIViewController *presentingViewController = [self presentingViewControllerFromParameters: parameters];
    [presentingViewController.view addSubview: self.rewardedAd];
    [self.rewardedAd showAd];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    
    [self log: @"Loading %@%@ ad: %@...", ( isNative ? @"native " : @"" ), adFormat.label, placementId];
    
    [self updatePrivacyPreferences: parameters];
    
    if ( isNative )
    {
        self.nativeAd = [[MFNativeAd alloc] initWithPlacementId: placementId];
        self.nativeAdViewAdapterDelegate = [[ALMobileFuseNativeAdViewDelegate alloc] initWithParentAdapter: self
                                                                                                    format: adFormat
                                                                                                parameters: parameters
                                                                                                 andNotify: delegate];
        [self.nativeAd registerAdCallbackReceiver: self.nativeAdViewAdapterDelegate];
        [self.nativeAd loadAdWithBiddingResponseToken: parameters.bidResponse];
    }
    else
    {
        self.adView = [[MFBannerAd alloc] initWithPlacementId: placementId withSize: [self sizeFromAdFormat: adFormat]];
        self.adViewAdapterDelegate = [[ALMobileFuseAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        [self.adView registerAdCallbackReceiver: self.adViewAdapterDelegate];
        [self.adView setAutorefreshEnabled: NO];
        [self.adView setMuted: YES];
        [self.adView loadAdWithBiddingResponseToken: parameters.bidResponse];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    
    [self log: @"Loading native ad: %@", placementId];
    
    [self updatePrivacyPreferences: parameters];
    
    self.nativeAd = [[MFNativeAd alloc] initWithPlacementId: placementId];
    self.nativeAdAdapterDelegate = [[ALMobileFuseNativeAdDelegate alloc] initWithParentAdapter: self parameters: parameters andNotify: delegate];
    [self.nativeAd registerAdCallbackReceiver: self.nativeAdAdapterDelegate];
    [self.nativeAd loadAdWithBiddingResponseToken: parameters.bidResponse];
}

#pragma mark - Helper Methods

+ (MAAdapterError *)toMaxError:(MFAdError *)mobileFuseError
{
    MFAdErrorCode mobileFuseErrorCode = mobileFuseError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
    switch ( mobileFuseErrorCode )
    {
        case MFAdErrorCodeAdAlreadyLoaded:
        case MFAdErrorCodeAdLoadError:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case MFAdErrorCodeAdRuntimeError:
        case MFAdErrorCodeAdAlreadyRendered:
            adapterError = MAAdapterError.adDisplayFailedError;
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: mobileFuseErrorCode
                     mediatedNetworkErrorMessage: mobileFuseError.localizedDescription];
}

- (void)updatePrivacyPreferences:(id<MAAdapterParameters>)parameters
{
    MobileFusePrivacyPreferences *privacyPreferences = [[MobileFusePrivacyPreferences alloc] init];
    
    if ( [parameters isDoNotSell] )
    {
        [privacyPreferences setUsPrivacyConsentString: [parameters isDoNotSell].boolValue ? @"1YY-" : @"1YN-"];
    }
    else
    {
        [privacyPreferences setUsPrivacyConsentString: @"1---"];
    }
    
    if ( [parameters isAgeRestrictedUser] )
    {
        [privacyPreferences setSubjectToCoppa: [parameters isAgeRestrictedUser].boolValue];
    }
    
    if ( parameters.consentString )
    {
        [privacyPreferences setIabConsentString: parameters.consentString];
    }
    
    [MobileFuse setPrivacyPreferences: privacyPreferences];
}

- (MFBannerAdSize)sizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return MOBILEFUSE_BANNER_SIZE_320x50;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return MOBILEFUSE_BANNER_SIZE_728x90;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return MOBILEFUSE_BANNER_SIZE_300x250;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format: %@", adFormat];
        return MOBILEFUSE_BANNER_SIZE_320x50;
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
    if ( maxNativeAdView.iconImageView )
    {
        [clickableViews addObject: maxNativeAdView.iconImageView];
    }
    if ( maxNativeAdView.mediaContentView )
    {
        [clickableViews addObject: maxNativeAdView.mediaContentView];
    }
    
    return clickableViews;
}

- (UIViewController *)presentingViewControllerFromParameters:(id<MAAdapterResponseParameters>)parameters
{
    return parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
}

@end

#pragma mark - ALMobileFuseInterstitialDelegate

@implementation ALMobileFuseInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)onAdLoaded:(MFAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad loaded: %@", ad.placementId];
    [self.delegate didLoadInterstitialAd];
}

- (void)onAdNotFilled:(MFAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad failed to load - no fill: %@", ad.placementId];
    [self.delegate didFailToLoadInterstitialAdWithError: MAAdapterError.noFill];
}

- (void)onAdExpired:(MFAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad expired: %@", ad.placementId];
}

- (void)onAdRendered:(MFAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad displayed: %@", ad.placementId];
    [self.delegate didDisplayInterstitialAd];
}

- (void)onAdClicked:(MFAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad clicked: %@", ad.placementId];
    [self.delegate didClickInterstitialAd];
}

- (void)onAdClosed:(MFAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad hidden: %@", ad.placementId];
    [self.delegate didHideInterstitialAd];
}

- (void)onAdError:(MFAd *)ad withError:(MFAdError *)error;
{
    MAAdapterError *adapterError = [ALMobileFuseMediationAdapter toMaxError: error];
    
    if ( error.code == MFAdErrorCodeAdAlreadyLoaded || error.code == MFAdErrorCodeAdLoadError )
    {
        [self.parentAdapter log: @"Interstitial ad failed to load with error: %@", adapterError];
        [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"Interstitial ad failed to display with error: %@", adapterError];
        [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
    }
}

@end

#pragma mark - ALMobileFuseRewardedAdDelegate

@implementation ALMobileFuseRewardedDelegate

- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)onAdLoaded:(MFAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad loaded: %@", ad.placementId];
    [self.delegate didLoadRewardedAd];
}

- (void)onAdNotFilled:(MFAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad failed to load - no fill: %@", ad.placementId];
    [self.delegate didFailToLoadRewardedAdWithError: MAAdapterError.noFill];
}

- (void)onAdExpired:(MFAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad expired: %@", ad.placementId];
}

- (void)onAdRendered:(MFAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad displayed: %@", ad.placementId];
    [self.delegate didDisplayRewardedAd];
}

- (void)onAdClicked:(MFAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad clicked: %@", ad.placementId];
    [self.delegate didClickRewardedAd];
}

- (void)onUserEarnedReward:(MFAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad should grant reward: %@", ad.placementId];
    self.grantedReward = YES;
}

- (void)onAdClosed:(MFAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad hidden: %@", ad.placementId];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.delegate didHideRewardedAd];
}

- (void)onAdError:(MFAd *)ad withError:(MFAdError *)error;
{
    MAAdapterError *adapterError = [ALMobileFuseMediationAdapter toMaxError: error];
    
    if ( error.code == MFAdErrorCodeAdAlreadyLoaded || error.code == MFAdErrorCodeAdLoadError )
    {
        [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", adapterError];
        [self.delegate didFailToLoadRewardedAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"Rewarded ad failed to display with error: %@", adapterError];
        [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
    }
}

@end

#pragma mark - ALMobileFuseAdViewDelegate

@implementation ALMobileFuseAdViewDelegate

- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)onAdLoaded:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad loaded: %@", ad.placementId];
    [self.delegate didLoadAdForAdView: ad];
    
    [(MFBannerAd *) ad showAdWithViewController: [ALUtils topViewControllerFromKeyWindow]];
}

- (void)onAdNotFilled:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad failed to load - no fill: %@", ad.placementId];
    [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
}

- (void)onAdExpired:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad expired: %@", ad.placementId];
}

- (void)onAdRendered:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad displayed: %@", ad.placementId];
    [self.delegate didDisplayAdViewAd];
}

- (void)onAdClicked:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad clicked: %@", ad.placementId];
    [self.delegate didClickAdViewAd];
}

- (void)onAdExpanded:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad expanded: %@", ad.placementId];
    [self.delegate didExpandAdViewAd];
}

- (void)onAdCollapsed:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad collapsed: %@", ad.placementId];
    [self.delegate didCollapseAdViewAd];
}

- (void)onAdClosed:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad hidden: %@", ad.placementId];
}

- (void)onAdError:(MFAd *)ad withError:(MFAdError *)error;
{
    MAAdapterError *adapterError = [ALMobileFuseMediationAdapter toMaxError: error];
    
    if ( error.code == MFAdErrorCodeAdAlreadyLoaded || error.code == MFAdErrorCodeAdLoadError )
    {
        [self.parentAdapter log: @"AdView ad failed to load with error: %@", adapterError];
        [self.delegate didFailToLoadAdViewAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"AdView ad failed to display with error: %@", adapterError];
        [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
    }
}

@end

#pragma mark - ALMobileFuseNativeAdViewDelegate

@implementation ALMobileFuseNativeAdViewDelegate

- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)adFormat
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.adFormat = adFormat;
        self.serverParameters = parameters.serverParameters;
        self.delegate = delegate;
    }
    return self;
}

- (void)onAdLoaded:(MFAd *)ad
{
    MFNativeAd *nativeAd = (MFNativeAd *) ad;
    
    [self.parentAdapter log: @"Native %@ ad loaded: %@", self.adFormat.label, nativeAd.placementId];
    
    if ( ![nativeAd hasTitle] )
    {
        [self.parentAdapter e: @"Native %@ ad does not have required assets: %@", self.adFormat.label, nativeAd];
        [self.delegate didFailToLoadAdViewAdWithError: [MAAdapterError missingRequiredNativeAdAssets]];
        
        return;
    }
    
    self.parentAdapter.nativeAd = nativeAd;
    
    MANativeAd *maxMobileFuseNativeAd = [[MAMobileFuseNativeAd alloc] initWithParentAdapter: self.parentAdapter
                                                                                     format: self.adFormat
                                                                               builderBlock:^(MANativeAdBuilder *builder) {
        builder.title = [nativeAd getTitle];
        builder.body = [nativeAd getDescriptionText];
        builder.advertiser = [nativeAd getSponsoredText];
        builder.callToAction = [nativeAd getCtaButtonText];
        builder.icon = [[MANativeAdImage alloc] initWithImage: [nativeAd getIconImage]];
        builder.mediaView = [nativeAd getMainContentView];
    }];
    
    MANativeAdView *maxNativeAdView;
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    if ( [templateName isEqualToString: @"vertical"] )
    {
        NSString *verticalTemplateName = ( self.adFormat == MAAdFormat.leader ) ? @"vertical_leader_template" : @"vertical_media_banner_template";
        maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxMobileFuseNativeAd withTemplate: verticalTemplateName];
    }
    else
    {
        maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxMobileFuseNativeAd withTemplate: [templateName al_isValidString] ? templateName : @"media_banner_template"];
    }
    
    [maxMobileFuseNativeAd prepareForInteractionClickableViews: [self.parentAdapter clickableViewsForNativeAdView: maxNativeAdView] withContainer: maxNativeAdView];
    [self.delegate didLoadAdForAdView: maxNativeAdView];
}

- (void)onAdNotFilled:(MFAd *)ad
{
    [self.parentAdapter log: @"Native %@ ad failed to load - no fill: %@", self.adFormat.label, ad.placementId];
    [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
}

- (void)onAdExpired:(MFAd *)ad
{
    [self.parentAdapter log: @"Native %@ ad expired: %@", self.adFormat.label, ad.placementId];
}

- (void)onAdRendered:(MFAd *)ad
{
    [self.parentAdapter log: @"Native %@ ad displayed: %@", self.adFormat.label, ad.placementId];
    [self.delegate didDisplayAdViewAd];
}

- (void)onAdClicked:(MFAd *)ad
{
    [self.parentAdapter log: @"Native %@ ad clicked: %@", self.adFormat.label, ad.placementId];
    [self.delegate didClickAdViewAd];
}

- (void)onAdError:(MFAd *)ad withError:(MFAdError *)error;
{
    MAAdapterError *adapterError = [ALMobileFuseMediationAdapter toMaxError: error];
    
    if ( error.code == MFAdErrorCodeAdAlreadyLoaded || error.code == MFAdErrorCodeAdLoadError )
    {
        [self.parentAdapter log: @"Native %@ ad failed to load with error: %@", self.adFormat.label, adapterError];
        [self.delegate didFailToLoadAdViewAdWithError: adapterError];
    }
    else
    {
        [self.parentAdapter log: @"Native %@ ad failed to display with error: %@", self.adFormat.label, adapterError];
        [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
    }
}

@end

#pragma mark - ALMobileFuseNativeAdDelegate

@implementation ALMobileFuseNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.serverParameters = parameters.serverParameters;
        self.delegate = delegate;
    }
    return self;
}

- (void)onAdLoaded:(MFAd *)ad
{
    MFNativeAd *nativeAd = (MFNativeAd *) ad;
    
    [self.parentAdapter log: @"Native ad loaded: %@", nativeAd.placementId];
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    
    if ( isTemplateAd && ![nativeAd hasTitle] )
    {
        [self.parentAdapter e: @"Native ad does not have required assets: %@", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError missingRequiredNativeAdAssets]];
        
        return;
    }
    
    self.parentAdapter.nativeAd = nativeAd;
    
    MANativeAd *maxNativeAd = [[MAMobileFuseNativeAd alloc] initWithParentAdapter: self.parentAdapter
                                                                           format: MAAdFormat.native
                                                                     builderBlock:^(MANativeAdBuilder *builder) {
        builder.title = [nativeAd getTitle];
        builder.advertiser = [nativeAd getSponsoredText];
        builder.body = [nativeAd getDescriptionText];
        builder.callToAction = [nativeAd getCtaButtonText];
        builder.icon = [[MANativeAdImage alloc] initWithImage: [nativeAd getIconImage]];
        builder.mediaView = [nativeAd getMainContentView];
    }];
    
    [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
}

- (void)onAdNotFilled:(MFAd *)ad
{
    [self.parentAdapter log: @"Native ad failed to load - no fill: %@", ad.placementId];
    [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
}

- (void)onAdExpired:(MFAd *)ad
{
    [self.parentAdapter log: @"Native ad expired: %@", ad.placementId];
}

- (void)onAdRendered:(MFAd *)ad
{
    [self.parentAdapter log: @"Native ad displayed: %@", ad.placementId];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)onAdClicked:(MFAd *)ad
{
    [self.parentAdapter log: @"Native ad clicked: %@", ad.placementId];
    [self.delegate didClickNativeAd];
}

- (void)onAdError:(MFAd *)ad withError:(MFAdError *)error;
{
    MAAdapterError *adapterError = [ALMobileFuseMediationAdapter toMaxError: error];
    
    if ( error.code == MFAdErrorCodeAdAlreadyLoaded || error.code == MFAdErrorCodeAdLoadError )
    {
        [self.parentAdapter log: @"Native ad failed to load with error: %@", adapterError];
    }
    else
    {
        [self.parentAdapter log: @"Native ad failed to display with error: %@", adapterError];
    }
    
    // possible display error for native ads also handled by load error callback
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

@end

@implementation MAMobileFuseNativeAd

- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)adFormat
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: adFormat builderBlock: builderBlock];
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
    MFNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    [self.parentAdapter d: @"Preparing views for interaction: %@ with container: %@", clickableViews, container];
    
    [nativeAd registerViewForInteraction: container withClickableViews: clickableViews];
    return YES;
}

@end
