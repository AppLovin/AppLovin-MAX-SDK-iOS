//
//  ALBidscubeMediationAdapter.m
//  AppLovin MAX Bidscube Adapter
//
//  Created by AppLovin Corporation on 1/27/25.
//  Copyright © 2025 AppLovin Corporation. All rights reserved.
//

#import "ALBidscubeMediationAdapter.h"
#import <bidscubeSdk/bidscubeSdk.h>

#define ADAPTER_VERSION @"0.1.0.0"

@interface ALBidscubeMediationAdapterInterstitialDelegate : NSObject <AdCallback>
@property (nonatomic, weak) ALBidscubeMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
@property (nonatomic, strong) NSString *placementId;
- (instancetype)initWithParentAdapter:(ALBidscubeMediationAdapter *)parentAdapter
                       placementId:(NSString *)placementId
                         andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALBidscubeMediationAdapterRewardedDelegate : NSObject <AdCallback>
@property (nonatomic, weak) ALBidscubeMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, strong) NSString *placementId;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALBidscubeMediationAdapter *)parentAdapter
                       placementId:(NSString *)placementId
                         andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALBidscubeMediationAdapterAdViewDelegate : NSObject <AdCallback>
@property (nonatomic, weak) ALBidscubeMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@property (nonatomic, strong) NSString *placementId;
@property (nonatomic, strong) MAAdFormat *adFormat;
- (instancetype)initWithParentAdapter:(ALBidscubeMediationAdapter *)parentAdapter
                       placementId:(NSString *)placementId
                            format:(MAAdFormat *)format
                         andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALBidscubeMediationAdapterNativeDelegate : NSObject <AdCallback>
@property (nonatomic, weak) ALBidscubeMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) NSString *placementId;
- (instancetype)initWithParentAdapter:(ALBidscubeMediationAdapter *)parentAdapter
                       placementId:(NSString *)placementId
                         andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface ALBidscubeMediationAdapter ()

@property (nonatomic, strong) UIView *interstitialAdView;
@property (nonatomic, strong) UIView *rewardedAdView;
@property (nonatomic, strong) UIView *adView;
@property (nonatomic, strong) UIView *nativeAdView;

@property (nonatomic, strong) ALBidscubeMediationAdapterInterstitialDelegate *interstitialDelegate;
@property (nonatomic, strong) ALBidscubeMediationAdapterRewardedDelegate *rewardedDelegate;
@property (nonatomic, strong) ALBidscubeMediationAdapterAdViewDelegate *adViewDelegate;
@property (nonatomic, strong) ALBidscubeMediationAdapterNativeDelegate *nativeDelegate;

@end

@implementation ALBidscubeMediationAdapter

static ALAtomicBoolean *ALBidscubeInitialized;
static MAAdapterInitializationStatus ALBidscubeInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALBidscubeInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [self log: @"Initializing Bidscube SDK..."];
    
    if ( [ALBidscubeInitialized compareAndSet: NO update: YES] )
    {
        ALBidscubeInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        // Configure the SDK
        SDKConfig *config = [[SDKConfig alloc] init];
        config.enableLogging = YES;
        config.enableDebugMode = [parameters isTesting];
        config.defaultAdTimeout = 30000; // 30 seconds
        
        // Initialize the SDK
        [BidscubeSDK initializeWithConfig: config];
        
        [self log: @"Bidscube SDK initialized successfully"];
        ALBidscubeInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
        completionHandler(ALBidscubeInitializationStatus, nil);
    }
    else
    {
        completionHandler(ALBidscubeInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return @"0.1.0";
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for adapter %@", self];
    
    self.interstitialAdView = nil;
    self.interstitialDelegate = nil;
    
    self.rewardedAdView = nil;
    self.rewardedDelegate = nil;
    
    self.adView = nil;
    self.adViewDelegate = nil;
    
    self.nativeAdView = nil;
    self.nativeDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    // Bidscube SDK doesn't provide signal collection in the current version
    // Return empty signal for now
    [delegate didCollectSignal: @""];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad: %@...", placementId];
    
    self.interstitialDelegate = [[ALBidscubeMediationAdapterInterstitialDelegate alloc] initWithParentAdapter: self
                                                                                                placementId: placementId
                                                                                                  andNotify: delegate];
    
    // Get video ad view for interstitial (full screen video)
    self.interstitialAdView = [BidscubeSDK getVideoAdView: placementId
                                               adDelegate: self.interstitialDelegate];
    
    if ( self.interstitialAdView )
    {
        [self log: @"Interstitial ad loaded: %@", placementId];
        [delegate didLoadInterstitialAd];
    }
    else
    {
        [self log: @"Interstitial ad failed to load: %@", placementId];
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.noFill];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad: %@...", placementId];
    
    if ( self.interstitialAdView )
    {
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [presentingViewController.view addSubview: self.interstitialAdView];
        
        // Set constraints to make it full screen
        self.interstitialAdView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints: @[
            [self.interstitialAdView.topAnchor constraintEqualToAnchor: presentingViewController.view.topAnchor],
            [self.interstitialAdView.leadingAnchor constraintEqualToAnchor: presentingViewController.view.leadingAnchor],
            [self.interstitialAdView.trailingAnchor constraintEqualToAnchor: presentingViewController.view.trailingAnchor],
            [self.interstitialAdView.bottomAnchor constraintEqualToAnchor: presentingViewController.view.bottomAnchor]
        ]];
    }
    else
    {
        [self log: @"Interstitial ad failed to show: %@", placementId];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad: %@...", placementId];
    
    self.rewardedDelegate = [[ALBidscubeMediationAdapterRewardedDelegate alloc] initWithParentAdapter: self
                                                                                          placementId: placementId
                                                                                            andNotify: delegate];
    
    // Get video ad view for rewarded (full screen video)
    self.rewardedAdView = [BidscubeSDK getVideoAdView: placementId
                                           adDelegate: self.rewardedDelegate];
    
    if ( self.rewardedAdView )
    {
        [self log: @"Rewarded ad loaded: %@", placementId];
        [delegate didLoadRewardedAd];
    }
    else
    {
        [self log: @"Rewarded ad failed to load: %@", placementId];
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.noFill];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad: %@...", placementId];
    
    if ( self.rewardedAdView )
    {
        [self configureRewardForParameters: parameters];
        
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [presentingViewController.view addSubview: self.rewardedAdView];
        
        // Set constraints to make it full screen
        self.rewardedAdView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints: @[
            [self.rewardedAdView.topAnchor constraintEqualToAnchor: presentingViewController.view.topAnchor],
            [self.rewardedAdView.leadingAnchor constraintEqualToAnchor: presentingViewController.view.leadingAnchor],
            [self.rewardedAdView.trailingAnchor constraintEqualToAnchor: presentingViewController.view.trailingAnchor],
            [self.rewardedAdView.bottomAnchor constraintEqualToAnchor: presentingViewController.view.bottomAnchor]
        ]];
    }
    else
    {
        [self log: @"Rewarded ad failed to show: %@", placementId];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    [self log: @"Loading%@%@ ad: %@...", isNative ? @" native " : @" ", adFormat.label, placementId];
    
    self.adViewDelegate = [[ALBidscubeMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self
                                                                                      placementId: placementId
                                                                                           format: adFormat
                                                                                        andNotify: delegate];
    
    if ( isNative )
    {
        // Get native ad view
        self.adView = [BidscubeSDK getNativeAdView: placementId
                                        adDelegate: self.adViewDelegate];
    }
    else
    {
        // Get image ad view for banner
        self.adView = [BidscubeSDK getImageAdView: placementId
                                       adDelegate: self.adViewDelegate];
    }
    
    if ( self.adView )
    {
        [self log: @"%@ ad loaded: %@", adFormat.label, placementId];
        [delegate didLoadAdForAdView: self.adView];
    }
    else
    {
        [self log: @"%@ ad failed to load: %@", adFormat.label, placementId];
        [delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading native ad: %@...", placementId];
    
    self.nativeDelegate = [[ALBidscubeMediationAdapterNativeDelegate alloc] initWithParentAdapter: self
                                                                                      placementId: placementId
                                                                                        andNotify: delegate];
    
    // Get native ad view
    self.nativeAdView = [BidscubeSDK getNativeAdView: placementId
                                           adDelegate: self.nativeDelegate];
    
    if ( self.nativeAdView )
    {
        [self log: @"Native ad loaded: %@", placementId];
        
        // Create a MANativeAd from the Bidscube native ad view
        MANativeAd *maxNativeAd = [[MANativeAd alloc] initWithFormat: MAAdFormat.native builderBlock:^(MANativeAdBuilder *builder) {
            // Set basic properties - these would need to be extracted from the Bidscube native ad
            builder.title = @"Bidscube Native Ad";
            builder.body = @"This is a native ad from Bidscube";
            builder.callToAction = @"Learn More";
        }];
        
        [delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
    }
    else
    {
        [self log: @"Native ad failed to load: %@", placementId];
        [delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
    }
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(NSError *)bidscubeError
{
    // Map Bidscube errors to MAX errors
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
    // Add specific error mapping based on Bidscube SDK error codes
    // For now, return unspecified error
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: bidscubeError.code
                     mediatedNetworkErrorMessage: bidscubeError.localizedDescription];
}

@end

#pragma mark - Interstitial Delegate

@implementation ALBidscubeMediationAdapterInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALBidscubeMediationAdapter *)parentAdapter
                          placementId:(NSString *)placementId
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}

- (void)onAdLoading:(NSString *)placementId
{
    [self.parentAdapter log: @"Interstitial ad loading: %@", placementId];
}

- (void)onAdLoaded:(NSString *)placementId
{
    [self.parentAdapter log: @"Interstitial ad loaded: %@", placementId];
}

- (void)onAdDisplayed:(NSString *)placementId
{
    [self.parentAdapter log: @"Interstitial ad displayed: %@", placementId];
    [self.delegate didDisplayInterstitialAd];
}

- (void)onAdFailed:(NSString *)placementId errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage
{
    [self.parentAdapter log: @"Interstitial ad failed: %@ - %@", placementId, errorMessage];
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.noFill
                                             mediatedNetworkErrorCode: errorCode
                                          mediatedNetworkErrorMessage: errorMessage];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)onAdClicked:(NSString *)placementId
{
    [self.parentAdapter log: @"Interstitial ad clicked: %@", placementId];
    [self.delegate didClickInterstitialAd];
}

- (void)onAdClosed:(NSString *)placementId
{
    [self.parentAdapter log: @"Interstitial ad closed: %@", placementId];
    [self.delegate didHideInterstitialAd];
}

- (void)onVideoAdStarted:(NSString *)placementId
{
    [self.parentAdapter log: @"Interstitial video ad started: %@", placementId];
}

- (void)onVideoAdCompleted:(NSString *)placementId
{
    [self.parentAdapter log: @"Interstitial video ad completed: %@", placementId];
}

- (void)onVideoAdSkipped:(NSString *)placementId
{
    [self.parentAdapter log: @"Interstitial video ad skipped: %@", placementId];
}

@end

#pragma mark - Rewarded Delegate

@implementation ALBidscubeMediationAdapterRewardedDelegate

- (instancetype)initWithParentAdapter:(ALBidscubeMediationAdapter *)parentAdapter
                          placementId:(NSString *)placementId
                            andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}

- (void)onAdLoading:(NSString *)placementId
{
    [self.parentAdapter log: @"Rewarded ad loading: %@", placementId];
}

- (void)onAdLoaded:(NSString *)placementId
{
    [self.parentAdapter log: @"Rewarded ad loaded: %@", placementId];
}

- (void)onAdDisplayed:(NSString *)placementId
{
    [self.parentAdapter log: @"Rewarded ad displayed: %@", placementId];
    [self.delegate didDisplayRewardedAd];
}

- (void)onAdFailed:(NSString *)placementId errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage
{
    [self.parentAdapter log: @"Rewarded ad failed: %@ - %@", placementId, errorMessage];
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.noFill
                                             mediatedNetworkErrorCode: errorCode
                                          mediatedNetworkErrorMessage: errorMessage];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)onAdClicked:(NSString *)placementId
{
    [self.parentAdapter log: @"Rewarded ad clicked: %@", placementId];
    [self.delegate didClickRewardedAd];
}

- (void)onAdClosed:(NSString *)placementId
{
    [self.parentAdapter log: @"Rewarded ad closed: %@", placementId];
    [self.delegate didHideRewardedAd];
}

- (void)onVideoAdStarted:(NSString *)placementId
{
    [self.parentAdapter log: @"Rewarded video ad started: %@", placementId];
}

- (void)onVideoAdCompleted:(NSString *)placementId
{
    [self.parentAdapter log: @"Rewarded video ad completed: %@", placementId];
    self.grantedReward = YES;
    
    // Grant reward when video is completed
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
}

- (void)onVideoAdSkipped:(NSString *)placementId
{
    [self.parentAdapter log: @"Rewarded video ad skipped: %@", placementId];
}

@end

#pragma mark - AdView Delegate

@implementation ALBidscubeMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALBidscubeMediationAdapter *)parentAdapter
                          placementId:(NSString *)placementId
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.adFormat = format;
        self.delegate = delegate;
    }
    return self;
}

- (void)onAdLoading:(NSString *)placementId
{
    [self.parentAdapter log: @"%@ ad loading: %@", self.adFormat.label, placementId];
}

- (void)onAdLoaded:(NSString *)placementId
{
    [self.parentAdapter log: @"%@ ad loaded: %@", self.adFormat.label, placementId];
}

- (void)onAdDisplayed:(NSString *)placementId
{
    [self.parentAdapter log: @"%@ ad displayed: %@", self.adFormat.label, placementId];
    [self.delegate didDisplayAdViewAd];
}

- (void)onAdFailed:(NSString *)placementId errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage
{
    [self.parentAdapter log: @"%@ ad failed: %@ - %@", self.adFormat.label, placementId, errorMessage];
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.noFill
                                             mediatedNetworkErrorCode: errorCode
                                          mediatedNetworkErrorMessage: errorMessage];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)onAdClicked:(NSString *)placementId
{
    [self.parentAdapter log: @"%@ ad clicked: %@", self.adFormat.label, placementId];
    [self.delegate didClickAdViewAd];
}

- (void)onAdClosed:(NSString *)placementId
{
    [self.parentAdapter log: @"%@ ad closed: %@", self.adFormat.label, placementId];
}

- (void)onVideoAdStarted:(NSString *)placementId
{
    [self.parentAdapter log: @"%@ video ad started: %@", self.adFormat.label, placementId];
}

- (void)onVideoAdCompleted:(NSString *)placementId
{
    [self.parentAdapter log: @"%@ video ad completed: %@", self.adFormat.label, placementId];
}

- (void)onVideoAdSkipped:(NSString *)placementId
{
    [self.parentAdapter log: @"%@ video ad skipped: %@", self.adFormat.label, placementId];
}

@end

#pragma mark - Native Delegate

@implementation ALBidscubeMediationAdapterNativeDelegate

- (instancetype)initWithParentAdapter:(ALBidscubeMediationAdapter *)parentAdapter
                          placementId:(NSString *)placementId
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}

- (void)onAdLoading:(NSString *)placementId
{
    [self.parentAdapter log: @"Native ad loading: %@", placementId];
}

- (void)onAdLoaded:(NSString *)placementId
{
    [self.parentAdapter log: @"Native ad loaded: %@", placementId];
}

- (void)onAdDisplayed:(NSString *)placementId
{
    [self.parentAdapter log: @"Native ad displayed: %@", placementId];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)onAdFailed:(NSString *)placementId errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage
{
    [self.parentAdapter log: @"Native ad failed: %@ - %@", placementId, errorMessage];
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.noFill
                                             mediatedNetworkErrorCode: errorCode
                                          mediatedNetworkErrorMessage: errorMessage];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)onAdClicked:(NSString *)placementId
{
    [self.parentAdapter log: @"Native ad clicked: %@", placementId];
    [self.delegate didClickNativeAd];
}

- (void)onAdClosed:(NSString *)placementId
{
    [self.parentAdapter log: @"Native ad closed: %@", placementId];
}

- (void)onVideoAdStarted:(NSString *)placementId
{
    [self.parentAdapter log: @"Native video ad started: %@", placementId];
}

- (void)onVideoAdCompleted:(NSString *)placementId
{
    [self.parentAdapter log: @"Native video ad completed: %@", placementId];
}

- (void)onVideoAdSkipped:(NSString *)placementId
{
    [self.parentAdapter log: @"Native video ad skipped: %@", placementId];
}

@end
