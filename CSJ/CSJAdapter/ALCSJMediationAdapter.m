//
//  ALCSJMediationAdapter.m
//  Adapters
//
//  Created by Vedant Mehta on 09/30/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALCSJMediationAdapter.h"
#import <BUAdSDK/BUAdSDK.h>

#define ADAPTER_VERSION @"6.1.3.4.0"

@interface ALCSJInterstitialAdDelegate : NSObject <BUNativeExpressFullscreenVideoAdDelegate>
@property (nonatomic,   weak) ALCSJMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter slotId:(NSString *)slotId andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALCSJAppOpenSplashAdDelegate : NSObject <BUSplashAdDelegate>
@property (nonatomic,   weak) ALCSJMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) id<MAAppOpenAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter slotId:(NSString *)slotId andNotify:(id<MAAppOpenAdapterDelegate>)delegate;
@end

@interface ALCSJRewardedVideoAdDelegate : NSObject <BUNativeExpressRewardedVideoAdDelegate>
@property (nonatomic,   weak) ALCSJMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter slotId:(NSString *)slotId andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALCSJAdViewAdDelegate : NSObject <BUNativeExpressBannerViewDelegate>
@property (nonatomic,   weak) ALCSJMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter slotId:(NSString *)slotId andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALCSJNativeAdViewAdDelegate : NSObject <BUNativeAdsManagerDelegate, BUNativeAdDelegate>
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic,   weak) ALCSJMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters format:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALCSJNativeAdDelegate : NSObject <BUNativeAdsManagerDelegate, BUNativeAdDelegate>
@property (nonatomic,   weak) ALCSJMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MACSJNativeAd : MANativeAd
@property (nonatomic, weak) ALCSJMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALCSJMediationAdapter ()

@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *interstitialAd;
@property (nonatomic, strong) ALCSJInterstitialAdDelegate *interstitialAdDelegate;

@property (nonatomic, strong) BUSplashAd *appOpenAd;
@property (nonatomic, strong) ALCSJAppOpenSplashAdDelegate *appOpenAdDelegate;

@property (nonatomic, strong) BUNativeExpressRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) ALCSJRewardedVideoAdDelegate *rewardedVideoAdDelegate;

@property (nonatomic, strong) BUNativeExpressBannerView *adViewAd;
@property (nonatomic, strong) ALCSJAdViewAdDelegate *adViewAdDelegate;
@property (nonatomic, strong) BUNativeAdsManager *nativeAdViewAdManager;
@property (nonatomic, strong) ALCSJNativeAdViewAdDelegate *nativeAdViewAdDelegate;

@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) BUNativeAdsManager *nativeAdManager;
@property (nonatomic, strong) ALCSJNativeAdDelegate *nativeAdDelegate;

// Whether or not we want to call back ad load success on video loaded or cached
@property (nonatomic, assign, getter=isStreaming) BOOL streaming;

@end

@implementation ALCSJMediationAdapter
static NSTimeInterval const kDefaultImageTaskTimeoutSeconds = 10.0;
static ALAtomicBoolean              *ALCSJInitialized;
static MAAdapterInitializationStatus ALCSJInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALCSJInitialized = [[ALAtomicBoolean alloc] init];
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALCSJInitialized compareAndSet: NO update: YES] )
    {
        ALCSJInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        BUAdSDKConfiguration *configuration = [BUAdSDKConfiguration configuration];
        
        NSString *appID = [parameters.serverParameters al_stringForKey: @"app_id"];
        [self log: @"Initializing CSJ SDK with app id: %@...", appID];
        configuration.appID = appID;
        
        configuration.appLogoImage = [self appIconImage];
        
        [BUAdSDKManager setUserExtData: [self createUserExtData: parameters]];
        
        [BUAdSDKManager startWithAsyncCompletionHandler:^(BOOL success, NSError *error) {
            if ( !success || error )
            {
                [self log: @"CSJ SDK failed to initialize with error: %@", error];
                
                ALCSJInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALCSJInitializationStatus, error.localizedDescription);
                
                return;
            }
            
            [self log: @"CSJ SDK initialized"];
            
            ALCSJInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            completionHandler(ALCSJInitializationStatus, nil);
        }];
    }
    else
    {
        [self log: @"CSJ SDK already initialized"];
        completionHandler(ALCSJInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [BUAdSDKManager SDKVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroying..."];
    
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdDelegate.delegate = nil;
    self.interstitialAdDelegate = nil;
    
    self.appOpenAd.delegate = nil;
    self.appOpenAd = nil;
    self.appOpenAdDelegate.delegate = nil;
    self.appOpenAdDelegate = nil;
    
    self.rewardedVideoAd.delegate = nil;
    self.rewardedVideoAd = nil;
    self.rewardedVideoAdDelegate.delegate = nil;
    self.rewardedVideoAdDelegate = nil;
    
    self.adViewAd.delegate = nil;
    self.adViewAd = nil;
    self.adViewAdDelegate.delegate = nil;
    self.adViewAdDelegate = nil;
    
    self.nativeAdViewAdManager.delegate = nil;
    self.nativeAdViewAdManager = nil;
    self.nativeAdViewAdDelegate.delegate = nil;
    self.nativeAdViewAdDelegate = nil;
    
    [self.nativeAd unregisterView];
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdManager.delegate = nil;
    self.nativeAdManager = nil;
    self.nativeAdDelegate.delegate = nil;
    self.nativeAdDelegate = nil;
}

#pragma mark - Interstitial Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@interstitial ad for slot id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", slotId];
    
    // Determine whether we allow streaming or not - allow by default
    self.streaming = [parameters.serverParameters al_numberForKey: @"streaming" defaultValue: @(YES)].boolValue;
    
    self.interstitialAd = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID: slotId];
    self.interstitialAdDelegate = [[ALCSJInterstitialAdDelegate alloc] initWithParentAdapter: self slotId: slotId andNotify: delegate];
    self.interstitialAd.delegate = self.interstitialAdDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        // setAdMarkup will trigger an ad load
        [self.interstitialAd setAdMarkup: bidResponse];
    }
    else
    {
        [self.interstitialAd loadAdData];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial..."];
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self.interstitialAd showAdFromRootViewController: presentingViewController];
}

#pragma mark - App Open Methods

- (void)loadAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@app open ad for slot id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", slotId];
    
    self.appOpenAd = [[BUSplashAd alloc] initWithSlotID: slotId adSize: [UIScreen mainScreen].bounds.size];
    self.appOpenAdDelegate = [[ALCSJAppOpenSplashAdDelegate alloc] initWithParentAdapter: self slotId: slotId andNotify: delegate];
    self.appOpenAd.delegate = self.appOpenAdDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        // setAdMarkup will trigger an ad load
        [self.appOpenAd setAdMarkup: bidResponse];
    }
    else
    {
        [self.appOpenAd loadAdData];
    }
}

- (void)showAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegate>)delegate
{
    [self log: @"Showing app open..."];
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self.appOpenAd showSplashViewInRootViewController: presentingViewController];
}

#pragma mark - Rewarded Ad Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@rewarded ad for slot id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", slotId];
    
    // Determine whether we allow streaming or not - allow by default
    self.streaming = [parameters.serverParameters al_numberForKey: @"streaming" defaultValue: @(YES)].boolValue;
    
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    
    self.rewardedVideoAd = [[BUNativeExpressRewardedVideoAd alloc] initWithSlotID: slotId rewardedVideoModel: model];
    self.rewardedVideoAdDelegate = [[ALCSJRewardedVideoAdDelegate alloc] initWithParentAdapter: self slotId: slotId andNotify: delegate];
    self.rewardedVideoAd.delegate = self.rewardedVideoAdDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        // setAdMarkup will trigger an ad load
        [self.rewardedVideoAd setAdMarkup: bidResponse];
    }
    else
    {
        [self.rewardedVideoAd loadAdData];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    // Configure reward from server.
    [self configureRewardForParameters: parameters];
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self.rewardedVideoAd showAdFromRootViewController: presentingViewController];
}

#pragma mark - AdView Ad Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@%@%@ ad for slot id \"%@\"...", isNative ? @"native " : @"", [bidResponse al_isValidString] ? @"bidding " : @"", adFormat.label, slotId];
    
    dispatchOnMainQueue(^{
        
        if ( isNative )
        {
            BUAdSlot *slot = [[BUAdSlot alloc] init];
            slot.ID = slotId;
            slot.AdType = BUAdSlotAdTypeFeed;
            slot.position = BUAdSlotPositionTop;
            slot.imgSize = [BUSize sizeBy: BUProposalSize_Banner600_400];
            
            self.nativeAdViewAdManager = [[BUNativeAdsManager alloc] initWithSlot: slot];
            self.nativeAdViewAdDelegate = [[ALCSJNativeAdViewAdDelegate alloc] initWithParentAdapter: self
                                                                                          parameters: parameters
                                                                                              format: adFormat
                                                                                           andNotify: delegate];
            self.nativeAdViewAdManager.delegate = self.nativeAdViewAdDelegate;
            
            if ( [bidResponse al_isValidString] )
            {
                // setAdMarkup will trigger an ad load
                [self.nativeAdViewAdManager setAdMarkup: bidResponse];
            }
            else
            {
                [self.nativeAdViewAdManager loadAdDataWithCount: 1];
            }
        }
        else
        {
            self.adViewAd = [[BUNativeExpressBannerView alloc] initWithSlotID: slotId
                                                           rootViewController: [ALUtils topViewControllerFromKeyWindow]
                                                                       adSize: adFormat.size];
            self.adViewAdDelegate = [[ALCSJAdViewAdDelegate alloc] initWithParentAdapter: self slotId: slotId andNotify: delegate];
            self.adViewAd.delegate = self.adViewAdDelegate;
            
            if ( [bidResponse al_isValidString] )
            {
                // setAdMarkup will trigger an ad load
                [self.adViewAd setAdMarkup: bidResponse];
            }
            else
            {
                [self.adViewAd loadAdData];
            }
        }
    });
}

#pragma mark - Native Ad Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@native ad for slot id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", slotId];
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = slotId;
    slot.AdType = BUAdSlotAdTypeFeed;
    slot.position = BUAdSlotPositionTop;
    slot.imgSize = [BUSize sizeBy: BUProposalSize_Banner600_400];
    
    self.nativeAdManager = [[BUNativeAdsManager alloc] initWithSlot: slot];
    self.nativeAdDelegate = [[ALCSJNativeAdDelegate alloc] initWithParentAdapter: self
                                                                      parameters: parameters
                                                                       andNotify: delegate];
    self.nativeAdManager.delegate = self.nativeAdDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        // setAdMarkup will trigger an ad load
        [self.nativeAdManager setAdMarkup: bidResponse];
    }
    else
    {
        [self.nativeAdManager loadAdDataWithCount: 1];
    }
}

#pragma mark - Helper Methods

- (NSString *)createUserExtData:(id<MAAdapterParameters>)parameters
{
    return [NSString stringWithFormat: @"[{\"name\":\"mediation\",\"value\":\"MAX\"},{\"name\":\"adapter_version\",\"value\":\"%@\"}]", self.adapterVersion];
}

- (void)loadImageForURLString:(NSString *)urlString group:(dispatch_group_t)group successHandler:(void (^)(UIImage *image))successHandler;
{
    // Pangle's image resource comes in the form of a URL which needs to be fetched in a non-blocking manner
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        dispatch_group_enter(group);
        
        [[[NSURLSession sharedSession] dataTaskWithURL: [NSURL URLWithString: urlString]
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if ( error )
            {
                [self log: @"Failed to fetch native ad image with error: %@", error];
            }
            else if ( data )
            {
                [self log: @"Native ad image data retrieved"];
                
                UIImage *image = [UIImage imageWithData: data];
                if ( image )
                {
                    // Run on main queue for convenient image view updates
                    dispatchOnMainQueue(^{
                        successHandler(image);
                    });
                }
            }
            
            // Don't consider the block done until this task is complete
            dispatch_group_leave(group);
        }] resume];
    });
}

- (BOOL)isVideoMediaView:(BUFeedADMode)imageMode
{
    return ( imageMode == BUFeedVideoAdModeImage
            || imageMode == BUFeedVideoAdModePortrait
            || imageMode == BUFeedADModeSquareVideo );
}

- (nullable UIImage *)appIconImage
{
    NSDictionary *icons = [[NSBundle mainBundle] infoDictionary][@"CFBundleIcons"];
    NSDictionary *primary = icons[@"CFBundlePrimaryIcon"];
    NSArray *files = primary[@"CFBundleIconFiles"];
    return [UIImage imageNamed: files.lastObject];
}

+ (MAAdapterError *)toMaxError:(NSError *)csjError
{
    BUErrorCode csjErrorCode = csjError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( csjErrorCode )
    {
        case BUErrorCodeSDKInitConfigUnfinished:
            adapterError = MAAdapterError.notInitialized;
            break;
        case BUErrorCodeNOAdError:
        case BUErrorCodeNOAD:
            adapterError = MAAdapterError.noFill;
            break;
        case BUErrorCodeNetError:
        case BUErrorCodeNetworkError:
            adapterError = MAAdapterError.noConnection;
            break;
        case BUErrorCodeParamError:
        case BUUnionAppSiteRelError:
        case BUUnionPackageNameError:
        case BUUnionConfigurationError:
        case BUErrorCodeAdSlotIDError:
        case BUUnionSDKVersionTooLow:
        case BUUnionNewInterstitialStyleVersionError:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case BUErrorCodeTimeout:
            adapterError = MAAdapterError.timeout;
            break;
        case BUErrorCodeTempError:
        case BUErrorCodeTempAddationError:
        case BUErrorCodeOpenAPPStoreFail:
        case BUErrorCodeParseError:
        case BUErrorCodePlayableError_ERR_HAS_CACHE:
        case BUErrorCodePlayableError_ERR_UNZIP:
        case BUErrorCodeNERenderResultError:
        case BUErrorCodeNETempError:
        case BUErrorCodeNETempPluginError:
        case BUErrorCodeNEDataError:
        case BUErrorCodeNEParseError:
        case BUErrorCodeNERenderError:
        case BUErrorCodeNERenderTimoutError:
        case BUErrorCodeTempLoadError:
        case BUErrorCodeSDKStop:
        case BUErrorCodeSuccess:
        case BUErrorCodeContentType:
        case BUErrorCodeRequestPBError:
        case BUErrorCodeAppEmpty:
        case BUErrorCodeWapEMpty:
        case BUErrorCodeAdSlotEmpty:
        case BUErrorCodeAdSlotSizeEmpty:
        case BUErrorCodeAdCountError:
        case BUUnionAdImageSizeError:
        case BUUnionAdSiteIdError:
        case BUUnionAdSiteMeiaTypeError:
        case BUUnionAdSiteAdTypeError:
        case BUUnionAdSiteAccessMethodError:
        case BUUnionSplashAdTypeError:
        case BUUnionRedirectError:
        case BUUnionRequestInvalidError:
        case BUUnionAccessMethodError:
        case BUUnionRequestLimitError:
        case BUUnionSignatureError:
        case BUUnionIncompleteError:
        case BUUnionOSError:
        case BUUnionLowVersion:
        case BUErrorCodeAdPackageIncomplete:
        case BUUnionMedialCheckError:
        case BUUnionSlotIDRenderMthodNoMatch:
        case BUErrorCodeSysError:
        case BUErrorCodeDRRenderEngineError:
        case BUErrorCodeDRRenderContextError:
        case BUErrorCodeDRRenderItemNotExist:
        case BUErrorCodeDynamic_2_ParseError:
        case BUErrorCodeDynamic_2_Timeout:
        case BUErrorCodeDynamic_2_SubComponentNotExist:
        case BUUnionCpidChannelCodeError:
        case BUUnionInternationalRequestCurrencyTypeError:
        case BUUnionOpenRTBRequestTokenError:
        case BUUnionHardCodeError:
        case BUUnionPreviewFlowInvalid:
        case BUErrorCodeUndefined:
        case BUErrorSlotAB_Disable:
        case BUErrorSlotAB_EmptyResult:
        case BUErrorCodeResource:
            adapterError = MAAdapterError.internalError;
            break;
        case BUErrorCodeBiddingAdmExpired:
            adapterError = MAAdapterError.adExpiredError;
            break;
    }
    
    return [MAAdapterError errorWithCode: adapterError.code
                             errorString: adapterError.message
                mediatedNetworkErrorCode: csjErrorCode
             mediatedNetworkErrorMessage: csjError.localizedDescription];
}

@end

@implementation ALCSJInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter slotId:(NSString *)slotId andNotify:(id<MAInterstitialAdapterDelegate>)delegate
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

- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial loaded: %@", self.slotId];
    
    if ( [self.parentAdapter isStreaming] )
    {
        [self.parentAdapter log: @"Calling back ad load success"];
        
        NSString *creativeId = [fullscreenVideoAd getAdCreativeToken];
        NSDictionary *extraInfo = nil;
        
        if ( [creativeId al_isValidString] )
        {
            extraInfo = @{@"creative_id" : creativeId};
        }
        
        [self.delegate didLoadInterstitialAdWithExtraInfo: extraInfo];
    }
}

- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial cached: %@", self.slotId];
    
    if ( ![self.parentAdapter isStreaming] )
    {
        [self.parentAdapter log: @"Calling back ad load success"];
        
        NSString *creativeId = [fullscreenVideoAd getAdCreativeToken];
        NSDictionary *extraInfo = nil;
        
        if ( [creativeId al_isValidString] )
        {
            extraInfo = @{@"creative_id" : creativeId};
        }
        
        [self.delegate didLoadInterstitialAdWithExtraInfo: extraInfo];
    }
}

- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALCSJMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)nativeExpressFullscreenVideoAdWillVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial will be shown"];
}

- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial shown"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)nativeExpressFullscreenVideoAdDidClickSkip:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial skip button has been clicked"];
}

- (void)nativeExpressFullscreenVideoAdDidCloseOtherController:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd interactionType:(BUInteractionType)interactionType
{
    [self.parentAdapter log: @"Interstitial closed other controller"];
}

- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error
{
    if ( error )
    {
        [self.parentAdapter log: @"Interstitial finished with error: %@", error];
        [self.delegate didFailToDisplayInterstitialAdWithError: [ALCSJMediationAdapter toMaxError: error]];
        
        return;
    }
    
    [self.parentAdapter log: @"Interstitial finished without error"];
}

- (void)nativeExpressFullscreenVideoAdWillClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial will be closed"];
}

- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)nativeExpressFullscreenVideoAdCallback:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd withType:(BUNativeExpressFullScreenAdType)nativeExpressVideoAdType
{
    NSString *adType;
    switch ( nativeExpressVideoAdType )
    {
        case BUNativeExpressFullScreenAdTypeEndcard:
            adType = @"Video + Endcard";
            break;
        case BUNativeExpressFullScreenAdTypeVideoPlayable:
            adType = @"Video + Playable";
            break;
        case BUNativeExpressFullScreenAdTypePurePlayable:
            adType = @"Pure Playable";
            break;
        default:
            adType = @"";
    }
    [self.parentAdapter log: @"Interstitial ad is of type: %@", adType];
}

@end

@implementation ALCSJAppOpenSplashAdDelegate

- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter slotId:(NSString *)slotId andNotify:(id<MAAppOpenAdapterDelegate>)delegate
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

- (void)splashAdLoadSuccess:(BUSplashAd *)splashAd
{
    [self.parentAdapter log: @"App open ad loaded: %@", self.slotId];
    [self.delegate didLoadAppOpenAd];
}

- (void)splashAdLoadFail:(BUSplashAd *)splashAd error:(nullable BUAdError *)error
{
    MAAdapterError *adapterError = [ALCSJMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"App open ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadAppOpenAdWithError: adapterError];
}

- (void)splashAdRenderSuccess:(BUSplashAd *)splashAd
{
    [self.parentAdapter log: @"App open ad rendered succesfully"];
}

- (void)splashAdRenderFail:(BUSplashAd *)splashAd error:(nullable BUAdError *)error
{
    MAAdapterError *adapterError = [ALCSJMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"App open ad render failed with error: %@", adapterError];
    [self.delegate didFailToDisplayAppOpenAdWithError: adapterError];
}

- (void)splashAdWillShow:(BUSplashAd *)splashAd
{
    [self.parentAdapter log: @"App open ad will show"];
}

- (void)splashAdDidShow:(BUSplashAd *)splashAd
{
    [self.parentAdapter log: @"App open shown"];
    [self.delegate didDisplayAppOpenAd];
}

- (void)splashAdDidClick:(BUSplashAd *)splashAd
{
    [self.parentAdapter log: @"App open clicked"];
    [self.delegate didClickAppOpenAd];
}

- (void)splashDidCloseOtherController:(BUSplashAd *)splashAd interactionType:(BUInteractionType)interactionType
{
    [self.parentAdapter log: @"App open closed other controller"];
}

- (void)splashVideoAdDidPlayFinish:(BUSplashAd *)splashAd didFailWithError:(NSError *)error
{
    if ( error )
    {
        MAAdapterError *adapterError = [ALCSJMediationAdapter toMaxError: error];
        [self.parentAdapter log: @"Video ad failed to play with an error: %@", adapterError];
        [self.delegate didFailToDisplayAppOpenAdWithError: adapterError];
        
        return;
    }
    
    [self.parentAdapter log: @"Video ad finished playing"];
}

- (void)splashAdDidClose:(BUSplashAd *)splashAd closeType:(BUSplashAdCloseType)closeType
{
    if ( closeType == BUSplashAdCloseType_ClickAd )
    {
        [self.parentAdapter log: @"App open clicked"];
        [self.delegate didClickAppOpenAd];
    }
    
    [self.parentAdapter log: @"App open ad hidden"];
    [self.delegate didHideAppOpenAd];
}

- (void)splashAdViewControllerDidClose:(BUSplashAd *)splashAd
{
    [self.parentAdapter log: @"App open ad controller closed"];
}

@end

@implementation ALCSJRewardedVideoAdDelegate

- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter slotId:(NSString *)slotId andNotify:(id<MARewardedAdapterDelegate>)delegate
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

- (void)nativeExpressRewardedVideoAdDidLoad:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad loaded: %@", self.slotId];
    
    if ( [self.parentAdapter isStreaming] )
    {
        [self.parentAdapter log: @"Calling back ad load success"];
        
        NSString *creativeId = [rewardedVideoAd getAdCreativeToken];
        NSDictionary *extraInfo = nil;
        
        if ( [creativeId al_isValidString] )
        {
            extraInfo = @{@"creative_id" : creativeId};
        }
        
        [self.delegate didLoadRewardedAdWithExtraInfo: extraInfo];
    }
}

- (void)nativeExpressRewardedVideoAdDidDownLoadVideo:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad cached: %@", self.slotId];
    
    if ( ![self.parentAdapter isStreaming] )
    {
        [self.parentAdapter log: @"Calling back ad load success"];
        
        NSString *creativeId = [rewardedVideoAd getAdCreativeToken];
        NSDictionary *extraInfo = nil;
        
        if ( [creativeId al_isValidString] )
        {
            extraInfo = @{@"creative_id" : creativeId};
        }
        
        [self.delegate didLoadRewardedAdWithExtraInfo: extraInfo];
    }
}

- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALCSJMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)nativeExpressRewardedVideoAdWillVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad will be shown"];
}

- (void)nativeExpressRewardedVideoAdDidVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad shown"];
    [self.delegate didDisplayRewardedAd];
}

- (void)nativeExpressRewardedVideoAdDidClick:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)nativeExpressRewardedVideoAdDidClickSkip:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad skip button has been clicked"];
}

- (void)nativeExpressRewardedVideoAdDidCloseOtherController:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd interactionType:(BUInteractionType)interactionType
{
    [self.parentAdapter log: @"Rewarded ad: Another controller closed"];
}

- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    if ( error )
    {
        [self.parentAdapter log: @"Rewarded ad finished with error: %@", error];
        [self.delegate didFailToDisplayRewardedAdWithError: [ALCSJMediationAdapter toMaxError: error]];
        
        return;
    }
    
    [self.parentAdapter log: @"Rewarded ad finished"];
}

- (void)nativeExpressRewardedVideoAdWillClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad will close"];
}

- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd
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

- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify
{
    [self.parentAdapter log: @"Reward verified: %d", verify];
    
    if ( verify )
    {
        self.grantedReward = YES;
    }
    else
    {
        [self.parentAdapter log: @"Reward verification failed"];
    }
}

- (void)nativeExpressRewardedVideoAdServerRewardDidFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *)error;
{
    [self.parentAdapter log: @"Reward failed with error: %@", error];
}

- (void)nativeExpressRewardedVideoAdCallback:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd withType:(BUNativeExpressRewardedVideoAdType)nativeExpressVideoType
{
    NSString *adType;
    switch ( nativeExpressVideoType )
    {
        case BUNativeExpressRewardedVideoAdTypeEndcard:
            adType = @"Video + Endcard";
            break;
        case BUNativeExpressRewardedVideoAdTypeVideoPlayable:
            adType = @"Video + Playable";
            break;
        case BUNativeExpressRewardedVideoAdTypePurePlayable:
            adType = @"Pure Playable";
            break;
        default:
            adType = @"";
    }
    [self.parentAdapter log: @"Rewarded ad is of type: %@", adType];
}

@end

@implementation ALCSJAdViewAdDelegate

- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter slotId:(NSString *)slotId andNotify:(id<MAAdViewAdapterDelegate>)delegate
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

- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView
{
    [self.parentAdapter log: @"AdView loaded: %@", self.slotId];
    [self.delegate didLoadAdForAdView: bannerAdView];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(nullable NSError *)error
{
    MAAdapterError *adapterError = [ALCSJMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"AdView failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView
{
    [self.parentAdapter log: @"AdView will show"];
    [self.delegate didDisplayAdViewAd];
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView
{
    [self.parentAdapter log: @"AdView shown successfully"];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(nullable NSError *)error
{
    MAAdapterError *adapterError = [ALCSJMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"AdView failed to show with error: %@", adapterError];
    [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView
{
    [self.parentAdapter log: @"AdView ad clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)nativeExpressBannerAdViewDidCloseOtherController:(BUNativeExpressBannerView *)bannerAdView interactionType:(BUInteractionType)interactionType
{
    [self.parentAdapter log: @"AdView ad has left the application"];
}

@end

@implementation ALCSJNativeAdViewAdDelegate

- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters format:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.slotId = parameters.thirdPartyAdPlacementIdentifier;
        self.serverParameters = parameters.serverParameters;
        self.adFormat = adFormat;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(nullable NSArray<BUNativeAd *> *)nativeAdDataArray
{
    if ( nativeAdDataArray.count == 0 )
    {
        [self.parentAdapter log: @"Native %@ ad (%@) failed to load: no fill", self.adFormat.label, self.slotId];
        [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
        
        return;
    }
    
    [self.parentAdapter log: @"Native %@ ad loaded: %@. Preparing assets...", self.adFormat.label, self.slotId];
    
    BUNativeAd *nativeAd = nativeAdDataArray.firstObject;
    self.parentAdapter.nativeAd = nativeAd;
    
    // Pangle iOS doesn't link the passed in delegate so we do it here
    nativeAd.delegate = self;
    
    // Run image fetching tasks asynchronously in the background
    dispatch_group_t group = dispatch_group_create();
    
    __block MANativeAdImage *iconImage = nil;
    BUMaterialMeta *data = nativeAd.data;
    if ( data.icon && [data.icon.imageURL al_isValidURL] )
    {
        [self.parentAdapter log: @"Fetching native ad icon: %@", data.icon.imageURL];
        [self.parentAdapter loadImageForURLString: data.icon.imageURL group: group successHandler:^(UIImage *image) {
            iconImage = [[MANativeAdImage alloc] initWithImage: image];
        }];
    }
    
    // Pangle's media view can be either a video or image (which they don't provide a view for)
    __block BUNativeAdRelatedView *relatedView;
    __block UIImageView *mediaImageView = nil;
    if ( [self.parentAdapter isVideoMediaView: data.imageMode] )
    {
        dispatchOnMainQueue(^{
            relatedView = [[BUNativeAdRelatedView alloc] init];
            relatedView.videoAdView.hidden = NO;
            [relatedView refreshData: nativeAd];
        });
    }
    else if ( data.imageAry && data.imageAry.count > 0 )
    {
        BUImage *mediaImage = data.imageAry.firstObject;
        if ( [mediaImage.imageURL al_isValidURL] )
        {
            [self.parentAdapter log: @"Fetching native ad media: %@", mediaImage.imageURL];
            [self.parentAdapter loadImageForURLString: mediaImage.imageURL group: group successHandler:^(UIImage *image) {
                mediaImageView = [[UIImageView alloc] initWithImage: image];
                mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
            }];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Timeout tasks if incomplete within the given time
        NSTimeInterval imageTaskTimeoutSeconds = [[self.serverParameters al_numberForKey: @"image_task_timeout_seconds" defaultValue: @(kDefaultImageTaskTimeoutSeconds)] doubleValue];
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t) (imageTaskTimeoutSeconds * NSEC_PER_SEC)));
        
        // Create MANativeAd after images are loaded from remote URLs
        dispatchOnMainQueue(^{
            [self.parentAdapter log: @"Creating native ad with assets"];
            
            MANativeAd *maxNativeAd = [[MANativeAd alloc] initWithFormat: self.adFormat builderBlock:^(MANativeAdBuilder *builder) {
                builder.title = data.AdTitle;
                builder.body = data.AdDescription;
                builder.callToAction = data.buttonText;
                builder.icon = iconImage;
                builder.optionsView = relatedView.logoADImageView;
                builder.mediaView = [self.parentAdapter isVideoMediaView: data.imageMode] ? relatedView.videoAdView : mediaImageView;
            }];
            
            NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
            MANativeAdView *maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: templateName];
            
            NSMutableArray *clickableViews = [NSMutableArray array];
            if ( [maxNativeAd.title al_isValidString] && maxNativeAdView.titleLabel )
            {
                [clickableViews addObject: maxNativeAdView.titleLabel];
            }
            if ( [maxNativeAd.body al_isValidString] && maxNativeAdView.bodyLabel )
            {
                [clickableViews addObject: maxNativeAdView.bodyLabel];
            }
            if ( [maxNativeAd.callToAction al_isValidString] && maxNativeAdView.callToActionButton )
            {
                [clickableViews addObject: maxNativeAdView.callToActionButton];
            }
            if ( maxNativeAd.icon && maxNativeAdView.iconImageView )
            {
                [clickableViews addObject: maxNativeAdView.iconImageView];
            }
            if ( maxNativeAd.mediaView && maxNativeAdView.mediaContentView )
            {
                [clickableViews addObject: maxNativeAdView.mediaContentView];
            }
            
            [nativeAd registerContainer: maxNativeAdView withClickableViews: clickableViews];
            
            [self.parentAdapter log: @"Native %@ ad fully loaded: %@", self.adFormat.label, self.slotId];
            [self.delegate didLoadAdForAdView: maxNativeAdView];
        });
    });
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(nullable NSError *)error
{
    MAAdapterError *adapterError = [ALCSJMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native %@ (%@) failed to load with error: %@", self.adFormat.label, self.slotId, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad displayed: %@", self.adFormat.label, self.slotId];
    [self.delegate didDisplayAdViewAd];
}

- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(nullable UIView *)view
{
    [self.parentAdapter log: @"Native %@ ad clicked: %@", self.adFormat.label, self.slotId];
    [self.delegate didClickAdViewAd];
}

- (void)nativeAdDidCloseOtherController:(BUNativeAd *)nativeAd interactionType:(BUInteractionType)interactionType
{
    [self.parentAdapter log: @"Native %@ ad closed other controller: %@", self.adFormat.label, self.slotId];
}

@end

@implementation ALCSJNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.slotId = parameters.thirdPartyAdPlacementIdentifier;
        self.serverParameters = parameters.serverParameters;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(nullable NSArray<BUNativeAd *> *)nativeAdDataArray
{
    if ( nativeAdDataArray.count == 0 )
    {
        [self.parentAdapter log: @"Native ad (%@) failed to load: no fill", self.slotId];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
        
        return;
    }
    
    [self.parentAdapter log: @"Native ad loaded: %@. Preparing assets...", self.slotId];
    
    BUNativeAd *nativeAd = nativeAdDataArray.firstObject;
    self.parentAdapter.nativeAd = nativeAd;
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    if ( isTemplateAd && ![nativeAd.data.AdTitle al_isValidString] )
    {
        [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.missingRequiredNativeAdAssets];
        
        return;
    }
    
    // Pangle iOS doesn't link the passed in delegate so we do it here
    nativeAd.delegate = self;
    
    // Run image fetching tasks asynchronously in the background
    dispatch_group_t group = dispatch_group_create();
    
    __block MANativeAdImage *iconImage = nil;
    BUMaterialMeta *data = nativeAd.data;
    if ( data.icon && [data.icon.imageURL al_isValidURL] )
    {
        [self.parentAdapter log: @"Fetching native ad icon: %@", data.icon.imageURL];
        [self.parentAdapter loadImageForURLString: data.icon.imageURL group: group successHandler:^(UIImage *image) {
            iconImage = [[MANativeAdImage alloc] initWithImage: image];
        }];
    }
    
    // Pangle's media view can be either a video or image (which they don't provide a view for)
    __block UIView *mediaView;
    __block MANativeAdImage *mainImage = nil;
    
    // Pangle's native ad logo view
    __block UIView *optionsView;
    
    dispatchOnMainQueue(^{
        // to show privacy icon (ad logo view) for image native ads we need to initialize related view outside the if
        BUNativeAdRelatedView *relatedView = [[BUNativeAdRelatedView alloc] init];
        [relatedView refreshData: nativeAd];
        
        optionsView = relatedView.logoADImageView;
        
        if ( [self.parentAdapter isVideoMediaView: data.imageMode] )
        {
            relatedView.videoAdView.hidden = NO;
            
            mediaView = relatedView.videoAdView;
        }
        else if ( data.imageAry && data.imageAry.count > 0 )
        {
            BUImage *mediaImage = data.imageAry.firstObject;
            __block UIImageView *mediaImageView = nil;
            
            if ( [mediaImage.imageURL al_isValidURL] )
            {
                [self.parentAdapter log: @"Fetching native ad media: %@", mediaImage.imageURL];
                [self.parentAdapter loadImageForURLString: mediaImage.imageURL group: group successHandler:^(UIImage *image) {
                    mediaImageView = [[UIImageView alloc] initWithImage: image];
                    mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
                    mainImage = [[MANativeAdImage alloc] initWithImage: image];
                    
                    mediaView = mediaImageView;
                }];
            }
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Timeout tasks if incomplete within the given time
        NSTimeInterval imageTaskTimeoutSeconds = [[self.serverParameters al_numberForKey: @"image_task_timeout_seconds" defaultValue: @(kDefaultImageTaskTimeoutSeconds)] doubleValue];
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t) (imageTaskTimeoutSeconds * NSEC_PER_SEC)));
        
        // Create MANativeAd after images are loaded from remote URLs
        [self.parentAdapter log: @"Creating native ad with assets"];
        
        MANativeAd *maxNativeAd = [[MACSJNativeAd alloc] initWithParentAdapter: self.parentAdapter builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = data.AdTitle;
            builder.body = data.AdDescription;
            // NOTE: Might be same as `AdTitle` - ignore if that's the case
            if ( ![data.AdTitle isEqualToString: data.source] )
            {
                builder.advertiser = data.source;
            }
            builder.callToAction = data.buttonText;
            builder.icon = iconImage;
            builder.optionsView = optionsView;
            builder.mediaView = mediaView;
            builder.mainImage = mainImage;
            builder.mediaContentAspectRatio = data.videoResolutionWidth / data.videoResolutionHeight;
        }];
        
        [self.parentAdapter log: @"Native ad fully loaded: %@", self.slotId];
        [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
    });
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(nullable NSError *)error
{
    MAAdapterError *adapterError = [ALCSJMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad (%@) failed to load with error: %@", self.slotId, adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad displayed: %@", self.slotId];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(nullable UIView *)view
{
    [self.parentAdapter log: @"Native ad clicked: %@", self.slotId];
    [self.delegate didClickNativeAd];
}

- (void)nativeAdDidCloseOtherController:(BUNativeAd *)nativeAd interactionType:(BUInteractionType)interactionType
{
    [self.parentAdapter log: @"Native ad closed other controller: %@", self.slotId];
}

@end

@implementation MACSJNativeAd

- (instancetype)initWithParentAdapter:(ALCSJMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
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
    if ( [self.advertiser al_isValidString] && maxNativeAdView.advertiserLabel )
    {
        [clickableViews addObject: maxNativeAdView.advertiserLabel];
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
    
    [self prepareForInteractionClickableViews: clickableViews withContainer: maxNativeAdView];
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container
{
    BUNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views for interaction: native ad is nil."];
        return false;
    }
    
    [self.parentAdapter d: @"Preparing views for interaction: %@ with container: %@", clickableViews, container];
    
    [nativeAd registerContainer: container withClickableViews: clickableViews];
    
    return true;
}

@end
