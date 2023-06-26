//
//  ALMyTargetMediationAdapter.m
//  AppLovinSDK
//
//  Created by Lorenzo Gentile on 7/16/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMyTargetMediationAdapter.h"
#import <myTargetSDK/MyTargetSDK.h>

#define ADAPTER_VERSION @"5.18.0.0"

@interface ALMyTargetMediationAdapterInterstitialAdDelegate : NSObject <MTRGInterstitialAdDelegate>
@property (nonatomic,   weak) ALMyTargetMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMyTargetMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALMyTargetMediationAdapterRewardedAdDelegate : NSObject <MTRGRewardedAdDelegate>
@property (nonatomic,   weak) ALMyTargetMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALMyTargetMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALMyTargetMediationAdapterAdViewDelegate : NSObject <MTRGAdViewDelegate>
@property (nonatomic,   weak) ALMyTargetMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMyTargetMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALMyTargetMediationAdapterNativeDelegate : NSObject <MTRGNativeAdDelegate, MTRGNativeAdMediaDelegate>
@property (nonatomic,   weak) ALMyTargetMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMyTargetMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAMyTargetNativeAd : MANativeAd
@property (nonatomic, weak) ALMyTargetMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALMyTargetMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALMyTargetMediationAdapter ()

@property (nonatomic, strong) MTRGInterstitialAd *interstitialAd;
@property (nonatomic, strong) MTRGRewardedAd *rewardedAd;
@property (nonatomic, strong) MTRGAdView *adView;
@property (nonatomic, strong) MTRGNativeAd *nativeAd;

@property (nonatomic, strong) ALMyTargetMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALMyTargetMediationAdapterRewardedAdDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) ALMyTargetMediationAdapterAdViewDelegate *adViewAdapterDelegate;
@property (nonatomic, strong) ALMyTargetMediationAdapterNativeDelegate *nativeAdapterDelegate;

@end

@implementation ALMyTargetMediationAdapter

#pragma mark - MAAdapter Methods

- (NSString *)SDKVersion
{
    return [MTRGVersion currentVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void(^)(MAAdapterInitializationStatus initializationStatus, NSString *_Nullable errorMessage))completionHandler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( [parameters isTesting] )
        {
            [MTRGManager setDebugMode: YES];
        }
        
        [self log: @"Initializing myTarget SDK..."];
        [MTRGManager initSdk];
    });
    
    completionHandler( MAAdapterInitializationStatusDoesNotApply, nil );
}

- (void)destroy
{
    [self log: @"Destroy called for adapter: %@", self];
    
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdapterDelegate.delegate = nil;
    self.interstitialAdapterDelegate = nil;
    
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView.viewController = nil;
    self.adView = nil;
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
    
    [self.nativeAd unregisterView];
    self.nativeAd.delegate = nil;
    self.nativeAd.mediaDelegate = nil;
    self.nativeAd = nil;
    self.nativeAdapterDelegate.delegate = nil;
    self.nativeAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updatePrivacyStates: parameters];
    
    NSString *signal = [MTRGManager getBidderToken];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSUInteger slotId = @(parameters.thirdPartyAdPlacementIdentifier.longLongValue).unsignedIntegerValue;
    [self log: @"Loading %@interstitial ad: %tu...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @"" ), slotId];
    
    self.interstitialAdapterDelegate = [[ALMyTargetMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId: slotId];
    self.interstitialAd.delegate = self.interstitialAdapterDelegate;
    [self.interstitialAd.customParams setCustomParam: @"7" forKey: @"mediation"]; // MAX specific
    [self updatePrivacyStates: parameters];
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        [self.interstitialAd loadFromBid: bidResponse];
    }
    else
    {
        [self.interstitialAd load];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    UIViewController *presentingViewController;
    if ( ALSdk.versionCode >= 11020199 )
    {
        presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    }
    else
    {
        presentingViewController = [ALUtils topViewControllerFromKeyWindow];
    }
    
    [self.interstitialAd showWithController: presentingViewController];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSUInteger slotId = @(parameters.thirdPartyAdPlacementIdentifier.longLongValue).unsignedIntegerValue;
    [self log: @"Loading %@rewarded ad: %tu...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @"" ), slotId];
    
    self.rewardedAdapterDelegate = [[ALMyTargetMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd = [[MTRGRewardedAd alloc] initWithSlotId: slotId];
    self.rewardedAd.delegate = self.rewardedAdapterDelegate;
    [self.rewardedAd.customParams setCustomParam: @"7" forKey: @"mediation"]; // myTarget requested that we add this
    [self updatePrivacyStates: parameters];
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        [self.rewardedAd loadFromBid: bidResponse];
    }
    else
    {
        [self.rewardedAd load];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
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
    
    [self.rewardedAd showWithController: presentingViewController];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSUInteger slotId = @(parameters.thirdPartyAdPlacementIdentifier.longLongValue).unsignedIntegerValue;
    [self log: @"Loading %@%@ ad: %tu...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @""), adFormat.label, slotId];
    
    self.adViewAdapterDelegate = [[ALMyTargetMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.adView = [MTRGAdView adViewWithSlotId: slotId shouldRefreshAd: NO];
    self.adView.adSize = [ALMyTargetMediationAdapter adViewSizeForAdFormat: adFormat];
    self.adView.delegate = self.adViewAdapterDelegate;
    self.adView.viewController = [ALUtils topViewControllerFromKeyWindow];
    [self.adView.customParams setCustomParam: @"7" forKey: @"mediation"]; // MAX specific
    [self updatePrivacyStates: parameters];
    
    NSString *bidResponse = parameters.bidResponse;
    
    if ( [bidResponse al_isValidString] )
    {
        [self.adView loadFromBid: bidResponse];
    }
    else
    {
        [self.adView load];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSUInteger slotId = @(parameters.thirdPartyAdPlacementIdentifier.longLongValue).unsignedIntegerValue;
    [self log: @"Loading %@ad: %tu...", ( [parameters.bidResponse al_isValidString] ? @"bidding " : @""), slotId];
    
    self.nativeAdapterDelegate = [[ALMyTargetMediationAdapterNativeDelegate alloc] initWithParentAdapter: self parameters: parameters andNotify: delegate];
    self.nativeAd = [MTRGNativeAd nativeAdWithSlotId: slotId];
    self.nativeAd.delegate = self.nativeAdapterDelegate;
    self.nativeAd.mediaDelegate = self.nativeAdapterDelegate;
    [self.nativeAd.customParams setCustomParam: @"7" forKey: @"mediation"]; // MAX specific
    self.nativeAd.adChoicesPlacement = [parameters.serverParameters al_numberForKey: @"ad_choices_placement" defaultValue: @(MTRGAdChoicesPlacementTopRight)].unsignedIntegerValue;
    self.nativeAd.cachePolicy = [parameters.serverParameters al_numberForKey: @"cache_policy" defaultValue: @(MTRGCachePolicyAll)].intValue;
    
    [self updatePrivacyStates: parameters];
    
    // Note: only bidding is officially supported by MAX, but placements support is needed for test mode
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        [self.nativeAd loadFromBid: bidResponse];
    }
    else
    {
        [self.nativeAd load];
    }
}

#pragma mark - Helper Methods

- (void)updatePrivacyStates:(id<MAAdapterParameters>)parameters
{
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent )
    {
        [MTRGPrivacy setUserConsent: hasUserConsent.boolValue];
    }
    
    NSNumber *isAgeRestrictedUser = [parameters isAgeRestrictedUser];
    if ( isAgeRestrictedUser )
    {
        [MTRGPrivacy setUserAgeRestricted: isAgeRestrictedUser.boolValue];
    }
    
    NSNumber *isDoNotSell = [parameters isDoNotSell];
    if ( isDoNotSell )
    {
        [MTRGPrivacy setCcpaUserConsent: isDoNotSell.boolValue];
    }
}

+ (MTRGAdSize *)adViewSizeForAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return [MTRGAdSize adSize320x50];
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return [MTRGAdSize adSize300x250];
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return [MTRGAdSize adSize728x90];
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return [MTRGAdSize adSize320x50];
    }
}

+ (MAAdapterError *)toMaxError:(NSString *)reason
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: MAAdapterError.noFill.errorCode
                             errorString: MAAdapterError.noFill.errorMessage
                  thirdPartySdkErrorCode: 0
               thirdPartySdkErrorMessage: reason];
#pragma clang diagnostic pop
}

@end

#pragma mark - ALMyTargetMediationAdapterInterstitialAdDelegate

@implementation ALMyTargetMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALMyTargetMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad failed to load with reason: %@", reason];
    [self.delegate didFailToLoadInterstitialAdWithError: [ALMyTargetMediationAdapter toMaxError: reason]];
}

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad displayed"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad video completed"];
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)onLeaveApplicationWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad user left application"];
}

@end

#pragma mark - ALMyTargetMediationAdapterRewardedAdDelegate

@implementation ALMyTargetMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALMyTargetMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)onLoadWithRewardedAd:(MTRGRewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)onNoAdWithReason:(NSString *)reason rewardedAd:(MTRGRewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad failed to load with reason: %@", reason];
    [self.delegate didFailToLoadRewardedAdWithError: [ALMyTargetMediationAdapter toMaxError: reason]];
}

- (void)onDisplayWithRewardedAd:(MTRGRewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad displayed"];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)onClickWithRewardedAd:(MTRGRewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)onReward:(MTRGReward *)reward rewardedAd:(MTRGRewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad reward granted"];
    self.grantedReward = YES;
}

- (void)onCloseWithRewardedAd:(MTRGRewardedAd *)rewardedAd
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden"];
    [self.delegate didHideRewardedAd];
}

- (void)onLeaveApplicationWithRewardedAd:(MTRGRewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad user left application"];
}

@end

#pragma mark - ALMyTargetMediationAdapterAdViewDelegate

@implementation ALMyTargetMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALMyTargetMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)onLoadWithAdView:(MTRGAdView *)adView
{
    [self.parentAdapter log: @"Ad view loaded"];
    [self.delegate didLoadAdForAdView: adView];
}

- (void)onNoAdWithReason:(NSString *)reason adView:(MTRGAdView *)adView
{
    [self.parentAdapter log: @"Ad view failed to load with reason: %@", reason];
    [self.delegate didFailToLoadAdViewAdWithError: [ALMyTargetMediationAdapter toMaxError: reason]];
}

- (void)onAdShowWithAdView:(MTRGAdView *)adView
{
    [self.parentAdapter log: @"Ad view shown"];
    [self.delegate didDisplayAdViewAd];
}

- (void)onAdClickWithAdView:(MTRGAdView *)adView
{
    [self.parentAdapter log: @"Ad view clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)onShowModalWithAdView:(MTRGAdView *)adView
{
    [self.parentAdapter log: @"Ad view modal shown"];
    // Don't forward expand/collapse callbacks because they don't always fire dismiss callback for banners displaying StoreKit.
    // [self.delegate didExpandAdViewAd];
}

- (void)onDismissModalWithAdView:(MTRGAdView *)adView
{
    [self.parentAdapter log: @"Ad view modal dismissed"];
    // Don't forward expand/collapse callbacks because they don't always fire dismiss callback for banners displaying StoreKit.
    // [self.delegate didCollapseAdViewAd];
}

- (void)onLeaveApplicationWithAdView:(MTRGAdView *)adView
{
    [self.parentAdapter log: @"Ad view user left application"];
}

@end

#pragma mark - ALMyTargetMediationAdapterNativeDelegate

@implementation ALMyTargetMediationAdapterNativeDelegate

- (instancetype)initWithParentAdapter:(ALMyTargetMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.slotId = parameters.thirdPartyAdPlacementIdentifier;
        self.serverParameters = parameters.serverParameters;
        self.delegate = delegate;
    }
    return self;
}

- (void)onLoadWithNativePromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad loaded: %@", self.slotId];
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    MTRGNativePromoBanner *banner = nativeAd.banner;
    if ( isTemplateAd && ![banner.title al_isValidString] )
    {
        [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    MANativeAd *maxNativeAd = [[MAMyTargetNativeAd alloc] initWithParentAdapter: self.parentAdapter builderBlock:^(MANativeAdBuilder *builder) {
        
        builder.title = promoBanner.title;
        builder.body = promoBanner.descriptionText;
        builder.callToAction = promoBanner.ctaText;
        
        if ( promoBanner.icon.image ) // Cached
        {
            builder.icon = [[MANativeAdImage alloc] initWithImage: promoBanner.icon.image];
        }
        else // URL may require fetching
        {
            builder.icon = [[MANativeAdImage alloc] initWithURL: [NSURL URLWithString: promoBanner.icon.url]];
        }
        
        MANativeAdImage *mainImage = nil;
        if ( promoBanner.image.image )
        {
            mainImage = [[MANativeAdImage alloc] initWithImage: promoBanner.image.image];
        }
        else
        {
            mainImage = [[MANativeAdImage alloc] initWithURL: [NSURL URLWithString: promoBanner.image.url]];
        }
        
        if ( ALSdk.versionCode >= 11040299 )
        {
            [builder performSelector: @selector(setMainImage:) withObject: mainImage];
        }
        
        MTRGMediaAdView *mediaView = [MTRGNativeViewsFactory createMediaAdView];
        builder.mediaView = mediaView;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        // Introduced in 10.4.0
        if ( [builder respondsToSelector: @selector(setAdvertiser:)] )
        {
            [builder performSelector: @selector(setAdvertiser:) withObject: promoBanner.advertisingLabel];
        }

        // Introduced in 11.4.0
        if ( [builder respondsToSelector: @selector(setMediaContentAspectRatio:)] )
        {
            [builder performSelector: @selector(setMediaContentAspectRatio:) withObject: @(mediaView.aspectRatio)];
        }
#pragma clang diagnostic pop
    }];
    
    // Only available in 11.0.0+
    [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
}

- (void)onNoAdWithReason:(NSString *)reason nativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad (%@) failed to load with reason: %@", self.slotId, reason];
    [self.delegate didFailToLoadNativeAdWithError: [ALMyTargetMediationAdapter toMaxError: reason]];
}

- (void)onAdShowWithNativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad shown: %@", self.slotId];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)onAdClickWithNativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad clicked: %@", self.slotId];
    [self.delegate didClickNativeAd];
}

- (void)onShowModalWithNativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad modal shown: %@", self.slotId];
}

- (void)onDismissModalWithNativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad modal dismissed: %@", self.slotId];
}

- (void)onLeaveApplicationWithNativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad user left application: %@", self.slotId];
}

- (void)onVideoPlayWithNativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad video started: %@", self.slotId];
}

- (void)onVideoPauseWithNativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad video paused: %@", self.slotId];
}

- (void)onVideoCompleteWithNativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad video completed: %@", self.slotId];
}

#pragma mark MTRGNativeAdMediaDelegate

- (void)onIconLoadWithNativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad icon loaded: %@", self.slotId];
}

- (void)onImageLoadWithNativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad image loaded: %@", self.slotId];
}

- (void)onAdChoicesIconLoadWithNativeAd:(MTRGNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad choices icon loaded: %@", self.slotId];
}

@end

@implementation MAMyTargetNativeAd

- (instancetype)initWithParentAdapter:(ALMyTargetMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
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
    NSMutableArray *clickableViews = [NSMutableArray array];
    if ( [self.title al_isValidString] && maxNativeAdView.titleLabel )
    {
        [clickableViews addObject: maxNativeAdView.titleLabel];
    }
    if ( [self.body al_isValidString] && maxNativeAdView.bodyLabel )
    {
        [clickableViews addObject: maxNativeAdView.bodyLabel];
    }
    if ( [self.callToAction al_isValidString] && maxNativeAdView.callToActionButton )
    {
        [clickableViews addObject: maxNativeAdView.callToActionButton];
    }
    if ( self.icon && maxNativeAdView.iconImageView )
    {
        [clickableViews addObject: maxNativeAdView.iconImageView];
    }
    if ( self.mediaView && maxNativeAdView.mediaContentView )
    {
        [clickableViews addObject: maxNativeAdView.mediaContentView];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // Introduced in 10.4.0
    if ( [maxNativeAdView respondsToSelector: @selector(advertiserLabel)] && [self respondsToSelector: @selector(advertiser)] )
    {
        id advertiserLabel = [maxNativeAdView performSelector: @selector(advertiserLabel)];
        id advertiser = [self performSelector: @selector(advertiser)];
        if ( [advertiser al_isValidString] && advertiserLabel )
        {
            [clickableViews addObject: advertiserLabel];
        }
    }
#pragma clang diagnostic pop
    
    [self prepareForInteractionClickableViews: clickableViews withContainer: maxNativeAdView];
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container
{
    MTRGNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    [self.parentAdapter d: @"Preparing views for interaction: %@ with container: %@", clickableViews, container];
    
    [nativeAd registerView: container
            withController: [ALUtils topViewControllerFromKeyWindow]
        withClickableViews: clickableViews];
    
    return YES;
}

@end
