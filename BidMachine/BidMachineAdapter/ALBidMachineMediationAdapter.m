//
//  ALBidMachineMediationAdapter.m
//  Adapters
//
//  Created by Josh on 4/5/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALBidMachineMediationAdapter.h"
#import <BidMachine/BidMachine-Swift.h>

#define ADAPTER_VERSION @"4.0.0.0.0"

#define TITLE_LABEL_TAG          1
#define MEDIA_VIEW_CONTAINER_TAG 2
#define ICON_VIEW_TAG            3
#define BODY_VIEW_TAG            4
#define CALL_TO_ACTION_VIEW_TAG  5
#define ADVERTISER_VIEW_TAG      8

@interface ALBidMachineInterstitialDelegate : NSObject <BidMachineInterstitialDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALBidMachineRewardedDelegate : NSObject <BidMachineRewardedDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALBidMachineAdViewDelegate : NSObject <BidMachineBannerDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALBidMachineNativeDelegate : NSObject <BidMachineNativeDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MABidMachineNativeAd : MANativeAd
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
@end

@interface ALBidMachineConsentProvider : NSObject <BidMachineConsentProvider>
@property (nonatomic, strong, nullable) NSNumber *coppa;
@property (nonatomic, strong, nullable) NSNumber *gdprApplies;
@property (nonatomic, strong, nullable) NSNumber *gdprConsent;
@property (nonatomic, strong, nullable) NSNumber *nonPersonalized;
@property (nonatomic,   copy, nullable) NSString *gppString;
@property (nonatomic,   copy, nullable) NSArray<NSNumber *> *gppSids;
@end

@interface ALBidMachineMediationAdapter ()
@property (nonatomic, strong) BidMachineInterstitial *interstitialAd;
@property (nonatomic, strong) BidMachineRewarded *rewardedAd;
@property (nonatomic, strong) BidMachineBanner *adView;
@property (nonatomic, strong) BidMachineNative *nativeAd;

@property (nonatomic, strong) ALBidMachineInterstitialDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALBidMachineRewardedDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) ALBidMachineAdViewDelegate *adViewAdapterDelegate;
@property (nonatomic, strong) ALBidMachineNativeDelegate *nativeAdAdapterDelegate;
@end

@implementation ALBidMachineMediationAdapter
static ALAtomicBoolean *ALBidMachineSDKInitialized;
static MAAdapterInitializationStatus ALBidMachineSDKInitializationStatus = NSIntegerMin;
static BidMachineInstance *ALBidMachineSDKInstance;

+ (void)initialize
{
    [super initialize];
    
    ALBidMachineSDKInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALBidMachineSDKInitialized compareAndSet: NO update: YES] )
    {
        ALBidMachineSDKInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *sourceId = [parameters.serverParameters al_stringForKey: @"source_id"];
        if ( ![sourceId al_isValidString] )
        {
            [self log: @"BidMachine SDK failed to initialize: source id is missing"];
            
            ALBidMachineSDKInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
            [ALBidMachineSDKInitialized set: NO];
            
            completionHandler(ALBidMachineSDKInitializationStatus, @"source_id is missing");
            return;
        }
        
        [self log: @"Initializing BidMachine SDK with source id: %@", sourceId];
        
        if ( [parameters isTesting] )
        {
            BidMachineSdk.testMode = YES;
            BidMachineSdk.isLoggingEnabled = YES;
        }
        
        [self updateSettings: parameters];
        
        ALBidMachineSDKInstance = [BidMachineSdk initializeWithSourceId: sourceId
                                                          configuration: [self mediationSettings]];
    }
    
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (NSString *)SDKVersion
{
    return BidMachineSdk.sdkVersion;
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (nullable NSNumber *)shouldShowAdsOnMainThreadForAdFormat:(MAAdFormat *)adFormat
{
    return @(YES);
}

- (void)destroy
{
    [self log: @"Destroy called for adapter %@", self];
    
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdapterDelegate.delegate = nil;
    self.interstitialAdapterDelegate = nil;
    
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
    
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdAdapterDelegate.delegate = nil;
    self.nativeAdAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal for %@ ad...", parameters.adFormat.label];
    
    [self updateSettings: parameters];
    
    if ( !ALBidMachineSDKInstance )
    {
        [self log: @"Signal collection failed: BidMachine SDK is not initialized"];
        [delegate didFailToCollectSignalWithErrorMessage: @"BidMachine SDK is not initialized"];
        
        return;
    }
    
    BidMachinePlacement *placement = [self placementFromParameters: parameters];
    NSArray<BidMachinePlacement *> *placements = placement ? @[placement] : @[];
    
    __weak typeof(self) weakSelf = self;
    [ALBidMachineSDKInstance collectTokenWithPlacements: placements completion:^(NSString *_Nullable signal, BidMachineError *_Nullable error) {
        if ( error )
        {
            [weakSelf log: @"Signal collection failed with error: %@", error];
            [delegate didFailToCollectSignalWithErrorMessage: error.description];
            
            return;
        }
        
        [weakSelf log: @"Signal collection successful with%@ valid signal", [signal al_isValidString] ? @"" : @"out"];
        [delegate didCollectSignal: signal];
    }];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading interstitial ad..."];
    
    [self updateSettings: parameters];
    
    if ( !ALBidMachineSDKInstance )
    {
        [self log: @"Interstitial ad failed to load: BidMachine SDK is not initialized"];
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    void (^completion)(BidMachineInterstitial *, BidMachineError *) = ^(BidMachineInterstitial *interstitialAd, BidMachineError *error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"Interstitial ad failed to load with error: %@", adapterError];
            [delegate didFailToLoadInterstitialAdWithError: adapterError];
            
            return;
        }
        
        if ( !interstitialAd )
        {
            [weakSelf log: @"Interstitial ad not ready"];
            [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        [weakSelf log: @"Interstitial ad loaded"];
        
        weakSelf.interstitialAd = interstitialAd;
        weakSelf.interstitialAdapterDelegate = [[ALBidMachineInterstitialDelegate alloc] initWithParentAdapter: weakSelf andNotify: delegate];
        weakSelf.interstitialAd.delegate = weakSelf.interstitialAdapterDelegate;
        
        NSString *creativeId = interstitialAd.auctionInfo.creativeId;
        NSDictionary *extraInfo;
        
        if ( [creativeId al_isValidString] )
        {
            extraInfo = @{@"creative_id" : creativeId};
        }
        
        [delegate didLoadInterstitialAdWithExtraInfo: extraInfo];
    };
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        [ALBidMachineSDKInstance loadInterstitialWithPayload: bidResponse completion: completion];
    }
    else
    {
        [ALBidMachineSDKInstance loadInterstitialWithPlacement: [self placementFromParameters: parameters] completion: completion];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( ![self.interstitialAd canShow] )
    {
        [self log: @"Unable to show interstitial - ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                        mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                     mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
        
        return;
    }
    
    UIViewController *presentingViewController = [self presentingViewControllerFromParameters: parameters];
    if ( !presentingViewController )
    {
        [self log: @"Unable to show interstitial - missing view controller"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                        mediatedNetworkErrorCode: MAAdapterError.missingViewController.code
                                                                     mediatedNetworkErrorMessage: MAAdapterError.missingViewController.message]];
        
        return;
    }
    
    [self.interstitialAd showFrom: presentingViewController];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Loading rewarded ad..."];
    
    [self updateSettings: parameters];
    
    if ( !ALBidMachineSDKInstance )
    {
        [self log: @"Rewarded ad failed to load: BidMachine SDK is not initialized"];
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    void (^completion)(BidMachineRewarded *, BidMachineError *) = ^(BidMachineRewarded *rewardedAd, BidMachineError *error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"Rewarded ad failed to load with error: %@", adapterError];
            [delegate didFailToLoadRewardedAdWithError: adapterError];
            
            return;
        }
        
        if ( !rewardedAd )
        {
            [weakSelf log: @"Rewarded ad failed to load: ad is nil"];
            [delegate didFailToLoadRewardedAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        [weakSelf log: @"Rewarded ad loaded"];
        
        weakSelf.rewardedAd = rewardedAd;
        weakSelf.rewardedAdapterDelegate = [[ALBidMachineRewardedDelegate alloc] initWithParentAdapter: weakSelf andNotify: delegate];
        weakSelf.rewardedAd.delegate = weakSelf.rewardedAdapterDelegate;
        
        NSString *creativeId = rewardedAd.auctionInfo.creativeId;
        NSDictionary *extraInfo;
        
        if ( [creativeId al_isValidString] )
        {
            extraInfo = @{@"creative_id" : creativeId};
        }
        
        [delegate didLoadRewardedAdWithExtraInfo: extraInfo];
    };
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        [ALBidMachineSDKInstance loadRewardedWithPayload: bidResponse completion: completion];
    }
    else
    {
        [ALBidMachineSDKInstance loadRewardedWithPlacement: [self placementFromParameters: parameters] completion: completion];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( ![self.rewardedAd canShow] )
    {
        [self log: @"Unable to show rewarded ad - ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                    mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                 mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
        
        return;
    }
    
    [self configureRewardForParameters: parameters];
    
    UIViewController *presentingViewController = [self presentingViewControllerFromParameters: parameters];
    if ( !presentingViewController )
    {
        [self log: @"Unable to show rewarded ad - missing view controller"];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                    mediatedNetworkErrorCode: MAAdapterError.missingViewController.code
                                                                 mediatedNetworkErrorMessage: MAAdapterError.missingViewController.message]];
        
        return;
    }
    
    [self.rewardedAd showFrom: presentingViewController];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self log: @"Loading %@ ad...", adFormat.label];
    
    [self updateSettings: parameters];
    
    if ( !ALBidMachineSDKInstance )
    {
        [self log: @"AdView ad failed to load: BidMachine SDK is not initialized"];
        [delegate didFailToLoadAdViewAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    BOOL isAdaptiveAdViewEnabled = [parameters.serverParameters al_boolForKey: @"adaptive_banner"];
    BidMachineBannerSize *size = [self bannerSizeFromAdFormat: adFormat
                                      isAdaptiveAdViewEnabled: isAdaptiveAdViewEnabled
                                                   parameters: parameters];
    if ( !size )
    {
        [self log: @"AdView ad failed to load: unsupported ad format: %@", adFormat.label];
        [delegate didFailToLoadAdViewAdWithError: MAAdapterError.invalidConfiguration];
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    void (^completion)(BidMachineBanner *, BidMachineError *) = ^(BidMachineBanner *bannerAd, BidMachineError *error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"AdView failed to load with error: %@", adapterError];
            [delegate didFailToLoadAdViewAdWithError: adapterError];
            
            return;
        }
        
        if ( !bannerAd )
        {
            [weakSelf log: @"AdView ad failed to load: ad is nil"];
            [delegate didFailToLoadAdViewAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        [weakSelf log: @"AdView loaded"];
        
        weakSelf.adView = bannerAd;
        weakSelf.adViewAdapterDelegate = [[ALBidMachineAdViewDelegate alloc] initWithParentAdapter: weakSelf andNotify: delegate];
        weakSelf.adView.delegate = weakSelf.adViewAdapterDelegate;
        weakSelf.adView.rootViewController = [ALUtils topViewControllerFromKeyWindow];
        
        NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithCapacity: 3];
        
        NSString *creativeId = bannerAd.auctionInfo.creativeId;
        if ( [creativeId al_isValidString] )
        {
            extraInfo[@"creative_id"] = creativeId;
        }
        
        CGSize adSize = bannerAd.adSize.cgSize;
        if ( !CGSizeEqualToSize(CGSizeZero, adSize) )
        {
            extraInfo[@"ad_width"] = @(adSize.width);
            extraInfo[@"ad_height"] = @(adSize.height);
        }
        
        [delegate didLoadAdForAdView: bannerAd withExtraInfo: extraInfo];
    };
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        [ALBidMachineSDKInstance loadBannerWithPayload: bidResponse size: size completion: completion];
    }
    else
    {
        [ALBidMachineSDKInstance loadBannerWithPlacement: [self placementFromParameters: parameters] size: size completion: completion];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    [self log: @"Loading native ad..."];
    
    [self updateSettings: parameters];
    
    if ( !ALBidMachineSDKInstance )
    {
        [self log: @"Native ad failed to load: BidMachine SDK is not initialized"];
        [delegate didFailToLoadNativeAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    void (^completion)(BidMachineNative *, BidMachineError *) = ^(BidMachineNative *nativeAd, BidMachineError *error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"Native ad failed to load with error: %@", adapterError];
            [delegate didFailToLoadNativeAdWithError: adapterError];
            
            return;
        }
        
        if ( !nativeAd )
        {
            [weakSelf log: @"Native ad failed to load: ad is nil"];
            [delegate didFailToLoadNativeAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        if ( ![nativeAd canShow] )
        {
            [weakSelf log: @"Native ad not ready to show"];
            [delegate didFailToLoadNativeAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        NSString *templateName = [parameters.serverParameters al_stringForKey: @"template" defaultValue: @""];
        BOOL isTemplateAd = [templateName al_isValidString];
        if ( isTemplateAd && ![nativeAd.title al_isValidString] )
        {
            [weakSelf log: @"Native ad (%@) does not have required assets.", nativeAd];
            [delegate didFailToLoadNativeAdWithError: MAAdapterError.missingRequiredNativeAdAssets];
            
            return;
        }
        
        [weakSelf log: @"Native ad loaded"];
        
        weakSelf.nativeAd = nativeAd;
        weakSelf.nativeAdAdapterDelegate = [[ALBidMachineNativeDelegate alloc] initWithParentAdapter: weakSelf andNotify: delegate];
        weakSelf.nativeAd.delegate = weakSelf.nativeAdAdapterDelegate;
        weakSelf.nativeAd.rootViewController = [ALUtils topViewControllerFromKeyWindow];
        
        MANativeAd *maxNativeAd = [[MABidMachineNativeAd alloc] initWithParentAdapter: weakSelf builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = nativeAd.title;
            builder.advertiser = nativeAd.advertiser;
            builder.body = nativeAd.body;
            builder.callToAction = nativeAd.callToAction;
            builder.icon = [weakSelf nativeAdImageFromImage: nativeAd.icon];
            builder.mainImage = [weakSelf nativeAdImageFromImage: nativeAd.mainImage];
            builder.optionsView = nativeAd.adChoice;
            builder.mediaView = nativeAd.mediaView;
            builder.starRating = nativeAd.starRating;
        }];
        
        NSString *creativeId = nativeAd.auctionInfo.creativeId;
        NSDictionary *extraInfo;
        
        if ( [creativeId al_isValidString] )
        {
            extraInfo = @{@"creative_id" : creativeId};
        }
        
        [delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: extraInfo];
    };
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        [ALBidMachineSDKInstance loadNativeWithPayload: bidResponse completion: completion];
    }
    else
    {
        [ALBidMachineSDKInstance loadNativeWithPlacement: [self placementFromParameters: parameters] completion: completion];
    }
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(NSError *)bidmachineError
{
    NSInteger bidmachineErrorCode = bidmachineError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
    switch ( bidmachineErrorCode )
    {
        case BidMachineErrorCodeNoConnection:
            adapterError = MAAdapterError.noConnection;
            break;
        case BidMachineErrorCodeTimeout:
            adapterError = MAAdapterError.timeout;
            break;
        case BidMachineErrorCodeNoContent:
            adapterError = MAAdapterError.noFill;
            break;
        case BidMachineErrorCodeWasUsedAlready:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case BidMachineErrorCodeWasExpired:
            adapterError = MAAdapterError.adExpiredError;
            break;
        case BidMachineErrorCodeNotInitialized:
            adapterError = MAAdapterError.notInitialized;
            break;
        case BidMachineErrorCodeBadContent:
        case BidMachineErrorCodeWasDestroyed:
        case BidMachineErrorCodeInternalError:
        case BidMachineErrorCodeEncryption:
            adapterError = MAAdapterError.internalError;
            break;
        case BidMachineErrorCodeHttpServerError:
            adapterError = MAAdapterError.serverError;
            break;
        case BidMachineErrorCodeHttpBadRequest:
            adapterError = MAAdapterError.badRequest;
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: bidmachineErrorCode
                     mediatedNetworkErrorMessage: bidmachineError.localizedDescription];
}

- (BidMachineBannerSize *)bannerSizeFromAdFormat:(MAAdFormat *)adFormat
                         isAdaptiveAdViewEnabled:(BOOL)isAdaptiveAdViewEnabled
                                      parameters:(id<MAAdapterParameters>)parameters
{
    if ( isAdaptiveAdViewEnabled && ALSdk.versionCode < 13020099 )
    {
        [self userError: @"Please update AppLovin MAX SDK to version 13.2.0 or higher in order to use BidMachine adaptive ads"];
        isAdaptiveAdViewEnabled = NO;
    }
    
    if ( isAdaptiveAdViewEnabled && [self isAdaptiveAdViewFormat: adFormat forParameters: parameters] )
    {
        return [self adaptiveBannerSizeFromParameters: parameters];
    }
    
    return [self bannerSizeFromAdFormat: adFormat];
}

- (BidMachineBannerSize *)adaptiveBannerSizeFromParameters:(id<MAAdapterParameters>)parameters
{
    CGFloat adaptiveAdWidth = [self adaptiveAdViewWidthFromParameters: parameters];
    
    if ( [self isInlineAdaptiveAdViewForParameters: parameters] )
    {
        CGFloat inlineMaximumHeight = [self inlineAdaptiveAdViewMaximumHeightFromParameters: parameters];
        return [BidMachineBannerSize adaptiveWithWidth: (uint32_t) adaptiveAdWidth maxHeight: (uint32_t) MAX(inlineMaximumHeight, 0)];
    }
    
    CGFloat anchoredHeight = [MAAdFormat.banner adaptiveSizeForWidth: adaptiveAdWidth].height;
    return [BidMachineBannerSize adaptiveWithWidth: (uint32_t) adaptiveAdWidth maxHeight: (uint32_t) anchoredHeight];
}

- (BidMachineBannerSize *)bannerSizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return BidMachineBannerSize.banner;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return BidMachineBannerSize.leaderboard;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return BidMachineBannerSize.mrec;
    }
    else
    {
        return nil;
    }
}

- (BidMachineConfiguration *)mediationSettings
{
    BidMachineConfiguration *configuration = [[BidMachineConfiguration alloc] init];
    configuration.mediationInfo = [[BidMachineMediationInfo alloc] initWithName: @"applovin_max"
                                                                        version: ALSdk.version
                                                                 adapterVersion: ADAPTER_VERSION];
    return configuration;
}

- (BidMachinePlacement *)placementFromParameters:(id<MAAdapterParameters>)parameters
{
    NSString *placementId = [parameters.serverParameters al_stringForKey: @"placement_id"];
    if ( ![placementId al_isValidString] )
    {
        NSDictionary *placementIds = [parameters.serverParameters al_dictionaryForKey: @"placement_ids"];
        placementId = [placementIds al_stringForKey: parameters.adUnitIdentifier];
    }
    
    if ( ![placementId al_isValidString] )
    {
        [self log: @"No valid placement ID found"];
        return nil;
    }
    
    return [[BidMachinePlacement alloc] initWithId: placementId extras: @{}];
}

- (void)updateSettings:(id<MAAdapterParameters>)parameters
{
    @synchronized ( [ALBidMachineMediationAdapter class] )
    {
        ALBidMachineConsentProvider *consentProvider = [[ALBidMachineConsentProvider alloc] init];
        consentProvider.gdprConsent = [parameters hasUserConsent];
        BidMachineSdk.consentProvider = consentProvider;
    }
}

- (MANativeAdImage *)nativeAdImageFromImage:(BidMachineNativeImage *)nativeImage
{
    if ( nativeImage.image )
    {
        return [[MANativeAdImage alloc] initWithImage: nativeImage.image];
    }
    else if ( nativeImage.url )
    {
        return [[MANativeAdImage alloc] initWithURL: nativeImage.url];
    }
    
    return nil;
}

- (UIViewController *)presentingViewControllerFromParameters:(id<MAAdapterResponseParameters>)parameters
{
    return parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
}

@end

@implementation ALBidMachineConsentProvider

@end

@implementation ALBidMachineInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialDidPresent:(BidMachineInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad shown"];
}

- (void)interstitialDidTrackImpression:(BidMachineInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad impression tracked"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialDidDismiss:(BidMachineInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)interstitialDidFailPresent:(BidMachineInterstitial *)ad error:(BidMachineError *)error
{
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.localizedDescription];
    [self.parentAdapter log: @"Interstitial failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)interstitialDidClick:(BidMachineInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialWillPresentScreen:(BidMachineInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad screen will present"];
}

- (void)interstitialDidDismissScreen:(BidMachineInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad screen dismissed"];
}

- (void)interstitialDidExpire:(BidMachineInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad expired"];
}

@end

@implementation ALBidMachineRewardedDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedDidPresent:(BidMachineRewarded *)ad
{
    [self.parentAdapter log: @"Rewarded ad shown"];
}

- (void)rewardedDidTrackImpression:(BidMachineRewarded *)ad
{
    [self.parentAdapter log: @"Rewarded ad impression tracked"];
    [self.delegate didDisplayRewardedAd];
}

- (void)rewardedDidDismiss:(BidMachineRewarded *)ad
{
    [self.parentAdapter log: @"Rewarded ad hidden"];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.delegate didHideRewardedAd];
}

- (void)rewardedDidClick:(BidMachineRewarded *)ad
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)rewardedDidReceiveReward:(BidMachineRewarded *)ad
{
    [self.parentAdapter log: @"Rewarded ad should grant reward"];
    self.grantedReward = YES;
}

- (void)rewardedDidFailPresent:(BidMachineRewarded *)ad error:(BidMachineError *)error
{
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.localizedDescription];
    [self.parentAdapter log: @"Rewarded failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)rewardedWillPresentScreen:(BidMachineRewarded *)ad
{
    [self.parentAdapter log: @"Rewarded ad screen will present"];
}

- (void)rewardedDidDismissScreen:(BidMachineRewarded *)ad
{
    [self.parentAdapter log: @"Rewarded ad screen dismissed"];
}

- (void)rewardedDidExpire:(BidMachineRewarded *)ad
{
    [self.parentAdapter log: @"Rewarded ad expired"];
}

@end

@implementation ALBidMachineAdViewDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)bannerDidTrackImpression:(BidMachineBanner *)ad
{
    [self.parentAdapter log: @"AdView shown"];
    [self.delegate didDisplayAdViewAd];
}

- (void)bannerDidPresent:(BidMachineBanner *)ad
{
    [self.parentAdapter log: @"AdView ad presented"];
}

- (void)bannerDidClick:(BidMachineBanner *)ad
{
    [self.parentAdapter log: @"AdView clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)bannerWillPresentScreen:(BidMachineBanner *)ad
{
    [self.parentAdapter log: @"AdView screen will present"];
    [self.delegate didExpandAdViewAd];
}

- (void)bannerDidDismissScreen:(BidMachineBanner *)ad
{
    [self.parentAdapter log: @"AdView dismissed screen"];
    [self.delegate didCollapseAdViewAd];
}

- (void)bannerDidFailPresent:(BidMachineBanner *)ad error:(BidMachineError *)error
{
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.localizedDescription];
    [self.parentAdapter log: @"AdView failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
}

- (void)bannerDidExpire:(BidMachineBanner *)ad
{
    [self.parentAdapter log: @"AdView expired"];
}

@end

@implementation ALBidMachineNativeDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeDidTrackImpression:(BidMachineNative *)ad
{
    [self.parentAdapter log: @"Native ad shown"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeDidPresent:(BidMachineNative *)ad
{
    [self.parentAdapter log: @"Native ad presented"];
}

- (void)nativeDidClick:(BidMachineNative *)ad
{
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)nativeWillPresentScreen:(BidMachineNative *)ad
{
    [self.parentAdapter log: @"Native ad screen will present"];
}

- (void)nativeDidDismissScreen:(BidMachineNative *)ad
{
    [self.parentAdapter log: @"Native ad screen dismissed"];
}

- (void)nativeDidFailPresent:(BidMachineNative *)ad error:(BidMachineError *)error
{
    [self.parentAdapter log: @"Native ad failed to present with error: %@", error];
}

- (void)nativeDidExpire:(BidMachineNative *)ad
{
    [self.parentAdapter log: @"Native ad expired"];
}

@end

@implementation MABidMachineNativeAd

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(MANativeAdView *)container
{
    BidMachineNative *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    [self.parentAdapter d: @"Preparing views for interaction: %@ with container: %@", clickableViews, container];
    
    NSMutableArray<BidMachineNativeAdEntry *> *clickables = [NSMutableArray arrayWithCapacity: clickableViews.count];
    for ( UIView *view in clickableViews )
    {
        BidMachineNativeAsset asset = [self assetForClickableView: view inContainer: container];
        [clickables addObject: [[BidMachineNativeAdEntry alloc] initWithView: view asset: asset]];
    }
    
    nativeAd.rootViewController = [ALUtils topViewControllerFromKeyWindow];
    
    if ( ![nativeAd bind: container clickables: clickables] )
    {
        [self.parentAdapter e: @"Native ad failed to present"];
        return NO;
    }
    
    return YES;
}

- (BidMachineNativeAsset)assetForClickableView:(UIView *)view inContainer:(UIView *)container
{
    if ( [container isKindOfClass: [MANativeAdView class]] )
    {
        MANativeAdView *nativeAdView = (MANativeAdView *) container;
        
        if ( view == nativeAdView.titleLabel )
        {
            return BidMachineNativeAssetTitle;
        }
        else if ( view == nativeAdView.advertiserLabel )
        {
            return BidMachineNativeAssetAdvertiser;
        }
        else if ( view == nativeAdView.bodyLabel )
        {
            return BidMachineNativeAssetBody;
        }
        else if ( view == nativeAdView.callToActionButton )
        {
            return BidMachineNativeAssetCallToAction;
        }
        else if ( view == nativeAdView.iconImageView )
        {
            return BidMachineNativeAssetIcon;
        }
        else if ( view == nativeAdView.mediaContentView )
        {
            return BidMachineNativeAssetMainImage;
        }
        else if ( view == nativeAdView.starRatingContentView )
        {
            return BidMachineNativeAssetStarRating;
        }
    }
    else
    {
        if ( view.tag == TITLE_LABEL_TAG )
        {
            return BidMachineNativeAssetTitle;
        }
        else if ( view.tag == MEDIA_VIEW_CONTAINER_TAG )
        {
            return BidMachineNativeAssetMainImage;
        }
        else if ( view.tag == ICON_VIEW_TAG )
        {
            return BidMachineNativeAssetIcon;
        }
        else if ( view.tag == BODY_VIEW_TAG )
        {
            return BidMachineNativeAssetBody;
        }
        else if ( view.tag == CALL_TO_ACTION_VIEW_TAG )
        {
            return BidMachineNativeAssetCallToAction;
        }
        else if ( view.tag == ADVERTISER_VIEW_TAG )
        {
            return BidMachineNativeAssetAdvertiser;
        }
    }
    
    return BidMachineNativeAssetUnknown;
}

@end
