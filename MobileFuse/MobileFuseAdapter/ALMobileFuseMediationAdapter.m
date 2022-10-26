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

#define ADAPTER_VERSION @"1.3.1.0"

@interface ALMobileFuseInterstitialDelegate : NSObject<IMFAdCallbackReceiver>
@property (nonatomic,   weak) ALMobileFuseMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALMobileFuseRewardedAdDelegate : NSObject<IMFAdCallbackReceiver>
@property (nonatomic,   weak) ALMobileFuseMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALMobileFuseAdViewDelegate : NSObject<IMFAdCallbackReceiver>
@property (nonatomic,   weak) MAAdFormat *format;
@property (nonatomic,   weak) ALMobileFuseMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALMobileFuseMediationAdapter()

@property (nonatomic, strong) MFInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALMobileFuseInterstitialDelegate *interstitialAdapterDelegate;

@property (nonatomic, strong) MFRewardedAd *rewardedAd;
@property (nonatomic, strong) ALMobileFuseRewardedAdDelegate *rewardedAdapterDelegate;

@property (nonatomic, strong) MFBannerAd *adView;
@property (nonatomic, strong) ALMobileFuseAdViewDelegate *adViewAdapterDelegate;

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
    
    [self.adView destroy];
    self.adView = nil;
    self.adViewAdapterDelegate = nil;
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
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
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
    self.rewardedAdapterDelegate = [[ALMobileFuseRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
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
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
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
    [self log: @"Loading %@ ad: %@", adFormat.label, placementId];
    
    [self updatePrivacyPreferences: parameters];
    
    self.adView = [[MFBannerAd alloc] initWithPlacementId: placementId withSize: [self sizeFromAdFormat: adFormat]];
    self.adViewAdapterDelegate = [[ALMobileFuseAdViewDelegate alloc] initWithParentAdapter: self
                                                                                    format: adFormat
                                                                                 andNotify: delegate];
    [self.adView registerAdCallbackReceiver: self.adViewAdapterDelegate];
    [self.adView setAutorefreshEnabled: NO];
    [self.adView setMuted: YES];
    
    [self.adView loadAdWithBiddingResponseToken: parameters.bidResponse];
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(NSString *)mobileFuseErrorMessage
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
    if ( [mobileFuseErrorMessage isEqualToString: @"VAST Player failed to initialize"] )
    {
        adapterError = MAAdapterError.invalidLoadState;
    }
    else if ( [mobileFuseErrorMessage hasPrefix: @"VAST Player failed with error code"] || [mobileFuseErrorMessage isEqualToString: @"MRAID Renderer failed to initialize and display a companion ad"] )
    {
        adapterError = MAAdapterError.adDisplayFailedError;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: MAErrorCodeUnspecified
                     mediatedNetworkErrorMessage: mobileFuseErrorMessage];
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
    [self.parentAdapter log: @"Interstitial ad failed to load: %@", ad.placementId];
    [self.delegate didFailToLoadInterstitialAdWithError: MAAdapterError.noFill];
}

- (void)onAdExpired:(MFAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad expired: %@", ad.placementId];
}

- (void)onAdRendered:(MFAd *)ad
{
    [self.parentAdapter log: @"Interstitial ad shown: %@", ad.placementId];
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

- (void)onAdError:(MFAd *)ad withMessage:(NSString *)message
{
    [self.parentAdapter log: @"Interstitial ad failed to load: %@, with message: %@", ad.placementId, message];
    
    MAAdapterError *adapterError = [ALMobileFuseMediationAdapter toMaxError: message];
    if ( adapterError == MAAdapterError.invalidLoadState )
    {
        [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
    }
    else
    {
        [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
    }
}

@end

#pragma mark - ALMobileFuseRewardedAdDelegate

@implementation ALMobileFuseRewardedAdDelegate

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
    [self.parentAdapter log: @"Rewarded ad failed to load: %@", ad.placementId];
    [self.delegate didFailToLoadRewardedAdWithError: MAAdapterError.noFill];
}

- (void)onAdExpired:(MFAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad expired: %@", ad.placementId];
}

- (void)onAdRendered:(MFAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad shown: %@", ad.placementId];
    [self.delegate didDisplayRewardedAd];
}

- (void)onAdClicked:(MFAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad clicked: %@", ad.placementId];
    [self.delegate didClickRewardedAd];
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

- (void)onAdError:(MFAd *)ad withMessage:(NSString *)message
{
    [self.parentAdapter log: @"Rewarded ad failed to load: %@, with message: %@", ad.placementId, message];
    
    MAAdapterError *adapterError = [ALMobileFuseMediationAdapter toMaxError: message];
    if ( adapterError == MAAdapterError.invalidLoadState )
    {
        [self.delegate didFailToLoadRewardedAdWithError: adapterError];
    }
    else
    {
        [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
    }
}

@end

#pragma mark - ALMobileFuseAdViewDelegate

@implementation ALMobileFuseAdViewDelegate

- (instancetype)initWithParentAdapter:(ALMobileFuseMediationAdapter *)parentAdapter format:(MAAdFormat *)format andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.format = format;
    }
    return self;
}

- (void)onAdLoaded:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad loaded: %@", ad.placementId];
    [self.delegate didLoadAdForAdView: ad];
    
    [(MFBannerAd *)ad showAdWithViewController: [ALUtils topViewControllerFromKeyWindow]];
}

- (void)onAdNotFilled:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad not filled: %@", ad.placementId];
    [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
}

- (void)onAdExpired:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad expired: %@", ad.placementId];
}

- (void)onAdRendered:(MFAd *)ad
{
    [self.parentAdapter log: @"AdView ad rendered: %@", ad.placementId];
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

- (void)onAdError:(MFAd *)ad withMessage:(NSString *)message
{
    [self.parentAdapter log: @"AdView ad failed to load: %@, with message: %@", ad.placementId, message];
    
    MAAdapterError *adapterError = [ALMobileFuseMediationAdapter toMaxError: message];
    if ( adapterError == MAAdapterError.invalidLoadState )
    {
        [self.delegate didFailToLoadAdViewAdWithError: adapterError];
    }
    else
    {
        [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
    }
}

@end
