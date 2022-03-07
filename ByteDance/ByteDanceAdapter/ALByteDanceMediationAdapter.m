//
//  ALByteDanceMediationAdapter.m
//  Adapters
//
//  Created by Thomas So on 12/25/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

#import "ALByteDanceMediationAdapter.h"
#import <BUAdSDK/BUAdSDK.h>

#define ADAPTER_VERSION @"4.3.0.2.2"

@interface ALByteDanceInterstitialAdDelegate : NSObject<BUFullscreenVideoAdDelegate>
@property (nonatomic,   weak) ALByteDanceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALByteDanceRewardedVideoAdDelegate : NSObject<BURewardedVideoAdDelegate>
@property (nonatomic,   weak) ALByteDanceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALByteDanceAdViewAdDelegate : NSObject<BUNativeExpressBannerViewDelegate>
@property (nonatomic,   weak) ALByteDanceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALByteDanceNativeAdViewAdDelegate : NSObject<BUNativeAdsManagerDelegate, BUNativeAdDelegate>
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic,   weak) ALByteDanceMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters format:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALByteDanceNativeAdDelegate : NSObject<BUNativeAdsManagerDelegate, BUNativeAdDelegate>
@property (nonatomic,   weak) ALByteDanceMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAByteDanceNativeAd : MANativeAd
@property (nonatomic, weak) ALByteDanceMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALByteDanceMediationAdapter()

@property (nonatomic, strong) BUFullscreenVideoAd *interstitialAd;
@property (nonatomic, strong) ALByteDanceInterstitialAdDelegate *interstitialAdDelegate;

@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) ALByteDanceRewardedVideoAdDelegate *rewardedVideoAdDelegate;

@property (nonatomic, strong) BUNativeExpressBannerView *adViewAd;
@property (nonatomic, strong) ALByteDanceAdViewAdDelegate *adViewAdDelegate;
@property (nonatomic, strong) BUNativeAdsManager *nativeAdViewAdManager;
@property (nonatomic, strong) ALByteDanceNativeAdViewAdDelegate *nativeAdViewAdDelegate;

@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) BUNativeAdsManager *nativeAdManager;
@property (nonatomic, strong) ALByteDanceNativeAdDelegate *nativeAdDelegate;

// Whether or not we want to call back ad load success on video loaded or cached
@property (nonatomic, assign, getter=isStreaming) BOOL streaming;

@end

@implementation ALByteDanceMediationAdapter
static NSTimeInterval const kDefaultImageTaskTimeoutSeconds = 10.0;
static ALAtomicBoolean              *ALByteDanceInitialized;
static MAAdapterInitializationStatus ALByteDanceInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALByteDanceInitialized = [[ALAtomicBoolean alloc] init];
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [ALByteDanceInitialized compareAndSet: NO update: YES] )
    {
        ALByteDanceInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        BUAdSDKConfiguration *configuration = [BUAdSDKConfiguration configuration];
        
        // Setting of territory should be done _prior_ to init
        BUAdSDKTerritory territory = [parameters.serverParameters al_boolForKey: @"is_cn"] ? BUAdSDKTerritory_CN : BUAdSDKTerritory_NO_CN;
        configuration.territory = territory;
        
        NSString *appID = [parameters.serverParameters al_stringForKey: @"app_id"];
        [self log: @"Initializing ByteDance SDK with app id: %@...", appID];
        configuration.appID = appID;
        
        if ( [parameters isTesting] )
        {
            configuration.logLevel = BUAdSDKLogLevelDebug;
        }
        
        [BUAdSDKManager setUserExtData: [self createUserExtData: parameters isInitializing: YES]];
        [self updateConsentWithParameters: parameters];
        
        [BUAdSDKManager startWithAsyncCompletionHandler:^(BOOL success, NSError *error) {
            if ( success )
            {
                [self log: @"ByteDance SDK initialized"];
                
                ALByteDanceInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
                completionHandler(ALByteDanceInitializationStatus, nil);
            }
            else
            {
                [self log: @"ByteDance SDK failed to initialize with error: %@", error];
                
                ALByteDanceInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALByteDanceInitializationStatus, error.localizedDescription);
            }
        }];
    }
    else
    {
        [self log: @"ByteDance SDK already initialized"];
        completionHandler(ALByteDanceInitializationStatus, nil);
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
    
    self.interstitialAd = nil;
    self.interstitialAdDelegate = nil;
    
    self.rewardedVideoAd = nil;
    self.rewardedVideoAdDelegate = nil;
    
    self.adViewAd = nil;
    self.adViewAdDelegate = nil;
    self.nativeAdViewAdManager = nil;
    self.nativeAdViewAdDelegate = nil;
    
    [self.nativeAd unregisterView];
    self.nativeAd = nil;
    self.nativeAdManager = nil;
    self.nativeAdDelegate = nil;
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *signal = [BUAdSDKManager mopubBiddingToken];
    [delegate didCollectSignal: signal];
}

#pragma mark - Interstitial Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@interstitial ad for slot id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", slotId];
    
    [BUAdSDKManager setUserExtData: [self createUserExtData: parameters isInitializing: NO]];
    [self updateConsentWithParameters: parameters];
    
    // Determine whether we allow streaming or not - allow by default
    self.streaming = [parameters.serverParameters al_numberForKey: @"streaming" defaultValue: @(YES)].boolValue;
    
    self.interstitialAd = [[BUFullscreenVideoAd alloc] initWithSlotID: slotId];
    self.interstitialAdDelegate = [[ALByteDanceInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd.delegate = self.interstitialAdDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        [self.interstitialAd setMopubAdMarkUp: bidResponse];
    }
    else
    {
        [self.interstitialAd loadAdData];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial..."];
    
    UIViewController *presentingViewController;
    if ( ALSdk.versionCode >= 11020199 )
    {
        presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    }
    else
    {
        presentingViewController = [ALUtils topViewControllerFromKeyWindow];
    }
    
    [self.interstitialAd showAdFromRootViewController: presentingViewController];
}

#pragma mark - Rewarded Ad Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@rewarded ad for slot id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", slotId];
    
    [BUAdSDKManager setUserExtData: [self createUserExtData: parameters isInitializing: NO]];
    [self updateConsentWithParameters: parameters];
    
    // Determine whether we allow streaming or not - allow by default
    self.streaming = [parameters.serverParameters al_numberForKey: @"streaming" defaultValue: @(YES)].boolValue;
    
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    
    if ( [parameters.serverParameters al_containsValueForKey: @"reward_user_id"] ) // For S2S
    {
        model.userId = [parameters.serverParameters al_stringForKey: @"reward_user_id"];
    }
    
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID: slotId rewardedVideoModel: model];
    self.rewardedVideoAdDelegate = [[ALByteDanceRewardedVideoAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedVideoAd.delegate = self.rewardedVideoAdDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        [self.rewardedVideoAd setMopubAdMarkUp: bidResponse];
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
    
    UIViewController *presentingViewController;
    if ( ALSdk.versionCode >= 11020199 )
    {
        presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    }
    else
    {
        presentingViewController = [ALUtils topViewControllerFromKeyWindow];
    }
    
    [self.rewardedVideoAd showAdFromRootViewController: presentingViewController];
}

#pragma mark - AdView Ad Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@%@%@ ad for slot id \"%@\"...", isNative ? @"native " : @"", [bidResponse al_isValidString] ? @"bidding " : @"", adFormat.label, slotId];
    
    [BUAdSDKManager setUserExtData: [self createUserExtData: parameters isInitializing: NO]];
    [self updateConsentWithParameters: parameters];
    
    if ( isNative )
    {
        BUAdSlot *slot = [[BUAdSlot alloc] init];
        slot.ID = slotId;
        slot.AdType = BUAdSlotAdTypeFeed;
        slot.position = BUAdSlotPositionTop;
        slot.imgSize = [BUSize sizeBy: BUProposalSize_Banner600_400];
        
        self.nativeAdViewAdManager = [[BUNativeAdsManager alloc] initWithSlot: slot];
        
        self.nativeAdViewAdDelegate = [[ALByteDanceNativeAdViewAdDelegate alloc] initWithParentAdapter: self
                                                                                            parameters: parameters
                                                                                                format: adFormat
                                                                                             andNotify: delegate];
        self.nativeAdViewAdManager.delegate = self.nativeAdViewAdDelegate;
        
        if ( [bidResponse al_isValidString] )
        {
            [self.nativeAdViewAdManager setMopubAdMarkUp: bidResponse];
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
                                                                   adSize: [self sizeFromAdFormat: adFormat]];
        
        self.adViewAdDelegate = [[ALByteDanceAdViewAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        self.adViewAd.delegate = self.adViewAdDelegate;
        
        if ( [bidResponse al_isValidString] )
        {
            [self.adViewAd setMopubAdMarkUp: bidResponse];
        }
        else
        {
            [self.adViewAd loadAdData];
        }
    }
}

#pragma mark - Native Ad Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@native ad for slot id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", slotId];
    
    [BUAdSDKManager setUserExtData: [self createUserExtData: parameters isInitializing: NO]];
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = slotId;
    slot.AdType = BUAdSlotAdTypeFeed;
    slot.position = BUAdSlotPositionTop;
    slot.imgSize = [BUSize sizeBy: BUProposalSize_Banner600_400];
    
    self.nativeAdManager = [[BUNativeAdsManager alloc] initWithSlot: slot];
    
    self.nativeAdDelegate = [[ALByteDanceNativeAdDelegate alloc] initWithParentAdapter: self
                                                                            parameters: parameters
                                                                             andNotify: delegate];
    self.nativeAdManager.delegate = self.nativeAdDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        [self.nativeAdManager setMopubAdMarkUp: bidResponse];
    }
    else
    {
        [self.nativeAdManager loadAdDataWithCount: 1];
    }
}

#pragma mark - Helper Methods

- (CGSize)sizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader )
    {
        return CGSizeMake(320, 50);
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return CGSizeMake(300, 250);
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return CGSizeZero;
    }
}

- (NSString *)createUserExtData:(id<MAAdapterParameters>)parameters isInitializing:(BOOL)isInitializing
{
    if ( isInitializing )
    {
        return [NSString stringWithFormat: @"[{\"name\":\"mediation\",\"value\":\"MAX\"},{\"name\":\"adapter_version\",\"value\":\"%@\"}]", self.adapterVersion];
    }
    else
    {
        return [NSString stringWithFormat: @"[{\"name\":\"mediation\",\"value\":\"MAX\"},{\"name\":\"adapter_version\",\"value\":\"%@\"},{\"name\":\"hybrid_id\",\"value\":\"%@\"}]", self.adapterVersion, [parameters.serverParameters al_stringForKey: @"event_id"]];
    }
}

- (void)updateConsentWithParameters:(id<MAAdapterParameters>)parameters
{
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
        if ( hasUserConsent )
        {
            [BUAdSDKManager setGDPR: hasUserConsent.boolValue ? 1 : 0];
        }
    }
    
    NSNumber *isAgeRestrictedUser = [self privacySettingForSelector: @selector(isAgeRestrictedUser) fromParameters: parameters];
    if ( isAgeRestrictedUser )
    {
        [BUAdSDKManager setCoppa: isAgeRestrictedUser.boolValue ? 1 : 0];
    }
    
    if ( ALSdk.versionCode >= 611000 )
    {
        NSNumber *isDoNotSell = [self privacySettingForSelector: @selector(isDoNotSell) fromParameters: parameters];
        if ( isDoNotSell )
        {
            [BUAdSDKManager setCCPA: isDoNotSell.boolValue ? 1 : 0];
        }
    }
}

- (nullable NSNumber *)privacySettingForSelector:(SEL)selector fromParameters:(id<MAAdapterParameters>)parameters
{
    // Use reflection because compiled adapters have trouble fetching `BOOL` from old SDKs and `NSNumber` from new SDKs (above 6.14.0)
    NSMethodSignature *signature = [[parameters class] instanceMethodSignatureForSelector: selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: signature];
    [invocation setSelector: selector];
    [invocation setTarget: parameters];
    [invocation invoke];
    
    // Privacy parameters return nullable `NSNumber` on newer SDKs
    if ( ALSdk.versionCode >= 6140000 )
    {
        NSNumber *__unsafe_unretained value;
        [invocation getReturnValue: &value];
        
        return value;
    }
    // Privacy parameters return BOOL on older SDKs
    else
    {
        BOOL rawValue;
        [invocation getReturnValue: &rawValue];
        
        return @(rawValue);
    }
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
    return ( imageMode == BUFeedVideoAdModeImage ||
            imageMode == BUFeedVideoAdModePortrait ||
            imageMode == BUFeedADModeSquareVideo );
}

+ (MAAdapterError *)toMaxError:(NSError *)byteDanceError
{
    BUErrorCode byteDanceErrorCode = byteDanceError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( byteDanceErrorCode )
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
        case BUErrorCodeDynamic_1_JSContextEmpty:
        case BUErrorCodeDynamic_1_ParseError:
        case BUErrorCodeDynamic_1_Timeout:
        case BUErrorCodeDynamic_1_SubComponentNotExist:
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
            adapterError = MAAdapterError.internalError;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: byteDanceErrorCode
               thirdPartySdkErrorMessage: byteDanceError.localizedDescription];
#pragma clang diagnostic pop
}

@end

@implementation ALByteDanceInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial loaded"];
    
    if ( [self.parentAdapter isStreaming] )
    {
        [self.parentAdapter log: @"Calling back ad load success"];
        [self.delegate didLoadInterstitialAd];
    }
}

- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial cached"];
    
    if ( ![self.parentAdapter isStreaming] )
    {
        [self.parentAdapter log: @"Calling back ad load success"];
        [self.delegate didLoadInterstitialAd];
    }
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Interstitial failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALByteDanceMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)fullscreenVideoAdDidVisible:(BUFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial shown"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)fullscreenVideoAdDidClick:(BUFullscreenVideoAd *)fullscreenVideoAd
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)fullscreenVideoAdDidPlayFinish:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error
{
    if ( error )
    {
        [self.parentAdapter log: @"Interstitial finished with error: %@", error];
        [self.delegate didFailToDisplayInterstitialAdWithError: [ALByteDanceMediationAdapter toMaxError: error]];
        
        return;
    }
    
    [self.parentAdapter log: @"Interstitial finished without error"];
}

@end

@implementation ALByteDanceRewardedVideoAdDelegate

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    
    if ( [self.parentAdapter isStreaming] )
    {
        [self.parentAdapter log: @"Calling back ad load success"];
        [self.delegate didLoadRewardedAd];
    }
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad cached"];
    
    if ( ![self.parentAdapter isStreaming] )
    {
        [self.parentAdapter log: @"Calling back ad load success"];
        [self.delegate didLoadRewardedAd];
    }
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALByteDanceMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad shown"];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd
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

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    if ( error )
    {
        [self.parentAdapter log: @"Rewarded ad finished with error: %@", error];
        [self.delegate didFailToDisplayRewardedAdWithError: [ALByteDanceMediationAdapter toMaxError: error]];
        
        return;
    }
    
    [self.parentAdapter log: @"Rewarded ad finished without error"];
    [self.delegate didCompleteRewardedAdVideo];
}

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify
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

- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd error:(NSError *)error;
{
    [self.parentAdapter log: @"Reward failed with error: %@", error];
}

@end

@implementation ALByteDanceAdViewAdDelegate

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView
{
    [self.parentAdapter log: @"AdView loaded"];
    [self.delegate didLoadAdForAdView: bannerAdView];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(nullable NSError *)error
{
    [self.parentAdapter log: @"AdView failed to load with error: %@", error];
    [self.delegate didFailToLoadAdViewAdWithError: [ALByteDanceMediationAdapter toMaxError: error]];
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
    [self.parentAdapter log: @"AdView failed to show with error: %@", error];
    [self.delegate didFailToDisplayAdViewAdWithError: [ALByteDanceMediationAdapter toMaxError: error]];
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

@implementation ALByteDanceNativeAdViewAdDelegate

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters format:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
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
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(imageTaskTimeoutSeconds * NSEC_PER_SEC)));
        
        // Create MANativeAd after images are loaded from remote URLs
        dispatchOnMainQueue(^{
            [self.parentAdapter log: @"Creating native ad with assets"];
            
            MANativeAd *maxNativeAd = [[MANativeAd alloc] initWithFormat: self.adFormat builderBlock:^(MANativeAdBuilder *builder) {
                builder.title = data.AdTitle;
                builder.body = data.AdDescription;
                builder.callToAction = data.buttonText;
                builder.icon = iconImage;
                builder.mediaView = [self.parentAdapter isVideoMediaView: data.imageMode] ? relatedView.videoAdView : mediaImageView;
                builder.optionsView = relatedView.logoADImageView;
            }];
            
            NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
            if ( [templateName containsString: @"vertical"] && ALSdk.versionCode < 6140500 )
            {
                [self.parentAdapter log: @"Vertical native banners are only supported on MAX SDK 6.14.5 and above. Default native template will be used."];
            }
            
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
    [self.parentAdapter log: @"Native %@ (%@) failed to load with error: %@", self.adFormat.label, self.slotId, error];
    
    MAAdapterError *adapterError = [ALByteDanceMediationAdapter toMaxError: error];
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

@implementation ALByteDanceNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
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
    if ( ![self hasRequiredAssetsInAd: nativeAd isTemplateAd: isTemplateAd] )
    {
        [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
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
                    
                    mediaView = mediaImageView;
                }];
            }
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Timeout tasks if incomplete within the given time
        NSTimeInterval imageTaskTimeoutSeconds = [[self.serverParameters al_numberForKey: @"image_task_timeout_seconds" defaultValue: @(kDefaultImageTaskTimeoutSeconds)] doubleValue];
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(imageTaskTimeoutSeconds * NSEC_PER_SEC)));
        
        // Media view is required for non-template native ads.
        if ( !isTemplateAd && !mediaView )
        {
            [self.parentAdapter e: @"Media view asset is nil for native custom ad view. Failing ad request."];
            [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
            
            return;
        }
        
        // Create MANativeAd after images are loaded from remote URLs
        [self.parentAdapter log: @"Creating native ad with assets"];
        
        MANativeAd *maxNativeAd = [[MAByteDanceNativeAd alloc] initWithParentAdapter: self.parentAdapter builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = data.AdTitle;
            builder.body = data.AdDescription;
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            // Introduced in 10.4.0
            if ( [builder respondsToSelector: @selector(setAdvertiser:)] )
            {
                // NOTE: Might be same as `AdTitle` - ignore if that's the case
                if ( ![data.AdTitle isEqualToString: data.source] )
                {
                    [builder performSelector: @selector(setAdvertiser:) withObject: data.source];
                }
            }
#pragma clang diagnostic pop
            
            builder.callToAction = data.buttonText;
            builder.icon = iconImage;
            builder.mediaView = mediaView;
            builder.optionsView = optionsView;
        }];
        
        [self.parentAdapter log: @"Native ad fully loaded: %@", self.slotId];
        [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
    });
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(nullable NSError *)error
{
    [self.parentAdapter log: @"Native ad (%@) failed to load with error: %@", self.slotId, error];
    
    MAAdapterError *adapterError = [ALByteDanceMediationAdapter toMaxError: error];
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

- (BOOL)hasRequiredAssetsInAd:(BUNativeAd *)nativeAd isTemplateAd:(BOOL)isTemplateAd
{
    if ( isTemplateAd )
    {
        return [nativeAd.data.AdTitle al_isValidString];
    }
    else
    {
        // NOTE: Media view is required and is checked separately.
        return [nativeAd.data.AdTitle al_isValidString]
        && [nativeAd.data.buttonText al_isValidString];
    }
}

@end

@implementation MAByteDanceNativeAd

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
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
    if ( !self.parentAdapter.nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views for interaction: native ad is nil."];
        return;
    }
    
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
    
    [self.parentAdapter.nativeAd registerContainer: maxNativeAdView withClickableViews: clickableViews];
}

@end
