//
//  ALPubMaticMediationAdapter.h
//  AppLovinSDK
//
//  Created by Paul Hounshell on 6/26/24.
//  Copyright © 2024 AppLovin. All rights reserved.
//

#import "ALPubMaticMediationAdapter.h"
#import <OpenWrapSDK/OpenWrapSDK.h>

#define ADAPTER_VERSION @"4.8.0.0"

@interface ALPubMaticMediationAdapterInterstitialDelegate : NSObject <POBInterstitialDelegate>
@property (nonatomic,   weak) ALPubMaticMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALPubMaticMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALPubMaticMediationAdapterRewardedDelegate : NSObject <POBRewardedAdDelegate>
@property (nonatomic,   weak) ALPubMaticMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALPubMaticMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALPubMaticMediationAdapterAdViewDelegate : NSObject <POBBannerViewDelegate>
@property (nonatomic,   weak) MAAdFormat *format;
@property (nonatomic,   weak) ALPubMaticMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALPubMaticMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALPubMaticMediationAdapterNativeDelegate : NSObject <POBNativeAdLoaderDelegate, POBNativeAdDelegate>
@property (nonatomic,   weak) ALPubMaticMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALPubMaticMediationAdapter *)parentAdapter andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAPubMaticNativeAd : MANativeAd
@property (nonatomic, weak) ALPubMaticMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALPubMaticMediationAdapter *)parentAdapter
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
@end

@interface ALPubMaticMediationAdapter ()

@property (nonatomic, strong) POBInterstitial *interstitialAd;
@property (nonatomic, strong) POBRewardedAd *rewardedAd;
@property (nonatomic, strong) POBBannerView *adView;
@property (nonatomic, strong) POBNativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) id<POBNativeAd> nativeAd;

@property (nonatomic, strong) ALPubMaticMediationAdapterInterstitialDelegate *interstitialAdDelegate;
@property (nonatomic, strong) ALPubMaticMediationAdapterRewardedDelegate *rewardedAdDelegate;
@property (nonatomic, strong) ALPubMaticMediationAdapterAdViewDelegate *adViewDelegate;
@property (nonatomic, strong) ALPubMaticMediationAdapterNativeDelegate *nativeAdDelegate;

@end

@implementation ALPubMaticMediationAdapter
static ALAtomicBoolean              *ALPubMaticInitialized;
static MAAdapterInitializationStatus ALPubMaticInitializationStatus = NSIntegerMin;

#pragma mark - Class Initialization

+ (void)initialize
{
    [super initialize];
    
    ALPubMaticInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALPubMaticInitialized compareAndSet: NO update: YES] )
    {
        ALPubMaticInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *publisherId = [parameters.serverParameters al_stringForKey: @"publisher_id"];
        NSNumber *profileId = [parameters.serverParameters al_numberForKey: @"profile_id"];
        
        OpenWrapSDKConfig *config = [[OpenWrapSDKConfig alloc] initWithPublisherId: publisherId andProfileIds: @[profileId]];
        
        [OpenWrapSDK initializeWithConfig: config andCompletionHandler:^(BOOL success, NSError *error) {
            
            if ( success )
            {
                [self log: @"PubMatic SDK initialized"];
                ALPubMaticInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
                completionHandler(ALPubMaticInitializationStatus, nil);
            }
            else
            {
                [self log: @"PubMatic SDK failed to initialize with error: %@", error];
                ALPubMaticInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALPubMaticInitializationStatus, error.localizedDescription);
            }
        }];
    }
    else
    {
        completionHandler(ALPubMaticInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [OpenWrapSDK version];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for adapter %@", self];
    
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdDelegate.delegate = nil;
    self.interstitialAdDelegate = nil;
    
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdDelegate.delegate = nil;
    self.rewardedAdDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewDelegate.delegate = nil;
    self.adViewDelegate = nil;
    
    self.nativeAdLoader.delegate = nil;
    self.nativeAdLoader = nil;
    self.nativeAd = nil;
    self.nativeAdDelegate.delegate = nil;
    self.nativeAdDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    POBAdFormat adFormat = [self POBAdFormatFromAdFormat: parameters.adFormat];
    if ( adFormat == -1 )
    {
        [self log: @"Signal collection failed with error: Unsupported ad format: %@", parameters.adFormat];
        [delegate didFailToCollectSignalWithErrorMessage: [NSString stringWithFormat: @"Unsupported ad format: %@", parameters.adFormat]];
        
        return;
    }
    
    POBSignalConfig *signalConfig = [[POBSignalConfig alloc] initWithAdFormat: adFormat];
    signalConfig.gpid = parameters.adUnitIdentifier;
    
    NSString *bidToken = [POBSignalGenerator generateSignalForBiddingHost: POBSDKBiddingHostALMAX
                                                                andConfig: signalConfig];
    
    [delegate didCollectSignal: bidToken];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading interstitial ad"];
    
    self.interstitialAdDelegate = [[ALPubMaticMediationAdapterInterstitialDelegate alloc] initWithParentAdapter: self
                                                                                                      andNotify: delegate];
    self.interstitialAd = [[POBInterstitial alloc] init];
    self.interstitialAd.delegate = self.interstitialAdDelegate;
    
    [self.interstitialAd loadAdWithResponse: parameters.bidResponse forBiddingHost: POBSDKBiddingHostALMAX];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad"];
    
    if ( ![self.interstitialAd isReady] )
    {
        [self log: @"Interstitial ad failed to show - ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                        mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                     mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
        return;
    }
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self.interstitialAd showFromViewController: presentingViewController];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Loading rewarded ad"];
    
    self.rewardedAdDelegate = [[ALPubMaticMediationAdapterRewardedDelegate alloc] initWithParentAdapter: self
                                                                                              andNotify: delegate];
    self.rewardedAd = [[POBRewardedAd alloc] init];
    self.rewardedAd.delegate = self.rewardedAdDelegate;
    
    [self.rewardedAd loadAdWithResponse: parameters.bidResponse forBiddingHost: POBSDKBiddingHostALMAX];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad"];
    
    if ( ![self.rewardedAd isReady] )
    {
        [self log: @"Rewarded ad failed to show - ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                    mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                 mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
        return;
    }
    
    [self configureRewardForParameters: parameters];
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self.rewardedAd showFromViewController: presentingViewController];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self log: @"Loading %@ ad", adFormat.label];
    
    self.adViewDelegate = [[ALPubMaticMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self
                                                                                           format: adFormat
                                                                                        andNotify: delegate];
    self.adView = [[POBBannerView alloc] init];
    self.adView.delegate = self.adViewDelegate;
    
    [self.adView loadAdWithResponse: parameters.bidResponse forBiddingHost: POBSDKBiddingHostALMAX];
    [self.adView pauseAutoRefresh];
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    [self log: @"Loading native ad"];
    
    self.nativeAdDelegate = [[ALPubMaticMediationAdapterNativeDelegate alloc] initWithParentAdapter: self
                                                                                           andNotify: delegate];
    self.nativeAdLoader = [[POBNativeAdLoader alloc] init];
    self.nativeAdLoader.delegate = self.nativeAdDelegate;
    
    [self.nativeAdLoader loadAdWithResponse: parameters.bidResponse forBiddingHost: POBSDKBiddingHostALMAX];
}

#pragma mark - Shared Methods

- (POBAdFormat)POBAdFormatFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return POBAdFormatBanner;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return POBAdFormatBanner;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return POBAdFormatMREC;
    }
    else if ( adFormat == MAAdFormat.interstitial )
    {
        return POBAdFormatInterstitial;
    }
    else if ( adFormat == MAAdFormat.rewarded )
    {
        return POBAdFormatRewarded;
    }
    else if ( adFormat == MAAdFormat.native )
    {
        return POBAdFormatNative;
    }
    else
    {
        return -1;
    }
}

+ (MAAdapterError *)toMaxError:(NSError *)error
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( error.code )
    {
        case POBErrorAdRequestNotAllowed:
        case POBErrorInvalidRequest:
            adapterError = MAAdapterError.badRequest;
            break;
        case POBErrorNoAds:
            adapterError = MAAdapterError.noFill;
            break;
        case POBErrorNetworkError:
        case POBErrorServerError:
            adapterError = MAAdapterError.noConnection;
            break;
        case POBErrorTimeout:
            adapterError = MAAdapterError.timeout;
            break;
        case POBErrorInitFailed:
            adapterError = MAAdapterError.notInitialized;
            break;
        case POBErrorInternalError:
        case POBErrorInvalidResponse:
        case POBErrorRequestCancelled:
        case POBErrorClientSideAuctionLost:
        case POBErrorAdServerAuctionLost:
        case POBErrorAdNotUsed:
        case POBSignalingError:
        case POBErrorAdAlreadyShown:
            adapterError = MAAdapterError.internalError;
            break;
        case POBErrorRenderError:
            adapterError = MAAdapterError.webViewError;
            break;
        case POBErrorAdExpired:
            adapterError = MAAdapterError.adExpiredError;
            break;
        case POBErrorAdNotReady:
            adapterError = MAAdapterError.adNotReady;
            break;
        case POBErrorNoPartnerDetails:
        case POBErrorInvalidRewardSelected:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: error.code
                     mediatedNetworkErrorMessage: error.localizedDescription];
}

@end

#pragma mark - Delegates

@implementation ALPubMaticMediationAdapterInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALPubMaticMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialDidReceiveAd:(POBInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial received"];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitial:(POBInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALPubMaticMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialDidRecordImpression:(POBInterstitial *)interstitial
{
    // NOTE: This may fire on load, depending on the demand source
    [self.parentAdapter log: @"Interstitial impression"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitial:(POBInterstitial *)interstitial didFailToShowAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.localizedDescription];
    [self.parentAdapter log: @"Interstitial failed to show with error: %@", adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)interstitialDidClickAd:(POBInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialDidDismissAd:(POBInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial closed"];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALPubMaticMediationAdapterRewardedDelegate

- (instancetype)initWithParentAdapter:(ALPubMaticMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedAdDidReceiveAd:(POBRewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)rewardedAd:(POBRewardedAd *)rewardedAd didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALPubMaticMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedAdDidRecordImpression:(POBRewardedAd *)rewardedAd
{
    // NOTE: This may fire on load, depending on the demand source
    [self.parentAdapter log: @"Rewarded ad impression"];
    [self.delegate didDisplayRewardedAd];
}

- (void)rewardedAd:(POBRewardedAd *)rewardedAd didFailToShowAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.localizedDescription];
    [self.parentAdapter log: @"Rewarded ad failed to show with error: %@", adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)rewardedAdDidClickAd:(POBRewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)rewardedAd:(POBRewardedAd *)rewardedAd shouldReward:(POBReward *)reward
{
    [self.parentAdapter log: @"Rewarded ad reward granted"];
    self.grantedReward = YES;
}

- (void)rewardedAdDidDismissAd:(POBRewardedAd *)rewardedAd
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad closed"];
    [self.delegate didHideRewardedAd];
}

@end

@implementation ALPubMaticMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALPubMaticMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.format = format;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)bannerViewDidReceiveAd:(POBBannerView *)bannerView
{
    [self.parentAdapter log: @"Ad view received"];
    [self.delegate didLoadAdForAdView: bannerView];
}

- (void)bannerView:(POBBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALPubMaticMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Ad view failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)bannerViewDidRecordImpression:(POBBannerView *)bannerView
{
    // NOTE: This may fire on load, depending on the demand source
    [self.parentAdapter log: @"Ad view impression"];
    [self.delegate didDisplayAdViewAd];
}

- (void)bannerViewDidClickAd:(POBBannerView *)bannerView
{
    [self.parentAdapter log: @"Ad view clicked"];
    [self.delegate didClickAdViewAd];
}

- (UIViewController *)bannerViewPresentationController
{
    return [ALUtils topViewControllerFromKeyWindow];
}

@end

@implementation ALPubMaticMediationAdapterNativeDelegate

- (instancetype)initWithParentAdapter:(ALPubMaticMediationAdapter *)parentAdapter andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

#pragma POBNativeAdLoaderDelegate Methods

- (void)nativeAdLoader:(POBNativeAdLoader *)adLoader didReceiveAd:(id<POBNativeAd>)nativeAd
{
    [self.parentAdapter log: @"Native ad loaded"];
    
    self.parentAdapter.nativeAd = nativeAd;
    [self.parentAdapter.nativeAd setAdDelegate: self];
    
    MANativeAd *maxNativeAd = [[MAPubMaticNativeAd alloc] initWithParentAdapter:self.parentAdapter builderBlock:^(MANativeAdBuilder *builder) {
        
        builder.title = nativeAd.titleAsset.text;
        builder.body = nativeAd.descriptionAsset.value;
        builder.callToAction = nativeAd.callToActionAsset.value;
        
        if (nativeAd.iconAsset.imageURL)
        {
            builder.icon = [[MANativeAdImage alloc] initWithURL:[NSURL URLWithString:nativeAd.iconAsset.imageURL]];
        }
        
        if (nativeAd.mainImageAsset.imageURL)
        {
            builder.mainImage = [[MANativeAdImage alloc] initWithURL:[NSURL URLWithString:nativeAd.mainImageAsset.imageURL]];
        }
        
        builder.advertiser = nativeAd.advertiserAsset.value;
        
        if (nativeAd.ratingAsset)
        {
            builder.starRating = [NSNumber numberWithDouble:nativeAd.ratingAsset.value.doubleValue];
        }
        
        builder.optionsView = nativeAd.adInfoIconView;
    }];
    
    [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
}

- (void)nativeAdLoader:(POBNativeAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALPubMaticMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

#pragma POBNativeAdDelegate Methods

- (void)nativeAdDidRecordImpression:(id<POBNativeAd>)nativeAd
{
    [self.parentAdapter log: @"Native ad impression"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeAdDidRecordClick:(id<POBNativeAd>)nativeAd
{
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)nativeAd:(id<POBNativeAd>)nativeAd didRecordClickForAsset:(NSInteger)assetId {
    [self.parentAdapter log: @"Native ad asset clicked"];
    [self.delegate didClickNativeAd];
}

- (nonnull UIViewController *)viewControllerForPresentingModal { 
    return [ALUtils topViewControllerFromKeyWindow];
}

@end

@implementation MAPubMaticNativeAd

- (instancetype)initWithParentAdapter:(ALPubMaticMediationAdapter *)parentAdapter
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container
{
    id<POBNativeAd> nativeAd = self.parentAdapter.nativeAd;
    
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    [self.parentAdapter d: @"Preparing views for interaction: %@ with container: %@", clickableViews, container];
    
    // Register native ad's container & clickable views for tracking imp/clicks
    [nativeAd registerViewForInteractions:container clickableViews:clickableViews];
    
    return YES;
}

@end
