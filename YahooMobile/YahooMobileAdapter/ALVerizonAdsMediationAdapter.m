//
//  ALVerizonAdsMediationAdapter.m
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 4/7/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALVerizonAdsMediationAdapter.h"
#import <YahooAds/YahooAds.h>

// Major version number is '2' since certifying against the rebranded Yahoo SDK
#define ADAPTER_VERSION @"2.2.0.3"

/**
 * Dedicated delegate object for Yahoo Mobile interstitial ads.
 */
@interface ALVerizonAdsMediationAdapterInterstitialDelegate : NSObject<YASInterstitialAdDelegate>
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * Dedicated delegate object for Yahoo Mobile rewarded ads.
 */
@interface ALVerizonAdsMediationAdapterRewardedDelegate : NSObject<YASInterstitialAdDelegate>
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * Dedicated delegate object for Yahoo Mobile AdView ads.
 */
@interface ALVerizonAdsMediationAdapterInlineAdViewDelegate : NSObject<YASInlineAdViewDelegate>
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * Dedicated delegate object for Yahoo Mobile native ad view ads.
 */
@interface ALVerizonAdsMediationAdapterNativeAdViewAdDelegate : NSObject<YASNativeAdDelegate>
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * Dedicated delegate object for Yahoo Mobile native ads.
 */
@interface ALVerizonAdsMediationAdapterNativeAdDelegate : NSObject<YASNativeAdDelegate>
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

@interface MAVerizonNativeAd : MANativeAd
@property (nonatomic, weak) ALVerizonAdsMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)adFormat builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALVerizonAdsMediationAdapter()

// Interstitial
@property (nonatomic, strong) YASInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALVerizonAdsMediationAdapterInterstitialDelegate *interstitialDelegate;

// Rewarded
@property (nonatomic, strong) YASInterstitialAd *rewardedAd;
@property (nonatomic, strong) ALVerizonAdsMediationAdapterRewardedDelegate *rewardedDelegate;

// AdView
@property (nonatomic, strong) YASInlineAdView *inlineAdView;
@property (nonatomic, strong) ALVerizonAdsMediationAdapterInlineAdViewDelegate *inlineAdViewDelegate;
@property (nonatomic, strong) YASNativeAd *nativeAdViewAd;
@property (nonatomic, strong) ALVerizonAdsMediationAdapterNativeAdViewAdDelegate *nativeAdViewAdDelegate;

// Native
@property (nonatomic, strong) YASNativeAd *nativeAd;
@property (nonatomic, strong) ALVerizonAdsMediationAdapterNativeAdDelegate *nativeAdDelegate;

@end

@implementation ALVerizonAdsMediationAdapter

static NSArray *kNativeAdAdTypes;

// Event IDs
static NSString *const kMAVideoCompleteEventId = @"onVideoComplete";
static NSString *const kMAAdImpressionEventId = @"adImpression";

+ (void)initialize
{
    [super initialize];
    
    kNativeAdAdTypes = @[@"simpleImage", @"simpleVideo"];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    MAAdapterInitializationStatus status;
    
    if ( ![[YASAds sharedInstance] isInitialized] )
    {
        [self log: @"Initializing SDK..."];
        
        YASLogLevel logLevel = [parameters isTesting] ? YASLogLevelVerbose : YASLogLevelError;
        [YASAds setLogLevel: logLevel];
        
        NSString *siteID = [parameters.serverParameters al_stringForKey: @"site_id"];
        BOOL initialized = [YASAds initializeWithSiteId: siteID];
        status = initialized ? MAAdapterInitializationStatusInitializedSuccess : MAAdapterInitializationStatusInitializedFailure;
        
        // ...GDPR settings, which is part of Yahoo Mobile SDK data, should be established after initialization and prior to making any ad requests... (https://sdk.yahooinc.com/yahoo-ads/publisher-privacy.html#general-data-protection-regulation-gdpr)
        [self updatePrivacyStatesForParameters: parameters];
        [self updateLocationCollectionEnabled: parameters];
    }
    else
    {
        status = MAAdapterInitializationStatusInitializedSuccess;
    }
    
    completionHandler(status, nil);
}

- (NSString *)SDKVersion
{
    return [YASAds sdkInfo].editionId;
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self.interstitialAd destroy];
    self.interstitialAd = nil;
    self.interstitialDelegate = nil;
    
    [self.rewardedAd destroy];
    self.rewardedAd = nil;
    self.rewardedDelegate = nil;
    
    [self.inlineAdView destroy];
    self.inlineAdView = nil;
    self.inlineAdViewDelegate = nil;
    
    [self.nativeAd clear];
    [self.nativeAd destroy];
    self.nativeAd = nil;
    self.nativeAdDelegate = nil;
    
    [self.nativeAdViewAd clear];
    [self.nativeAdViewAd destroy];
    self.nativeAdViewAd = nil;
    self.nativeAdViewAdDelegate = nil;
}

#pragma mark - MASignalProvider

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updatePrivacyStatesForParameters: parameters];
    [self updateLocationCollectionEnabled: parameters];
    
    NSString *token = [[YASAds sharedInstance] biddingTokenTrimmedToSize: 4000];
    if ( !token )
    {
        NSString *errorMessage = @"Yahoo SDK not initialized; failed to return a bid.";
        [delegate didFailToCollectSignalWithErrorMessage: errorMessage];
        
        return;
    }
    
    [delegate didCollectSignal: token];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@ interstitial ad for placement: %@...", ([bidResponse al_isValidString] ? @"bidding" : @""), placementId];
    
    [self updatePrivacyStatesForParameters: parameters];
    [self updateLocationCollectionEnabled: parameters];
    
    self.interstitialDelegate = [[ALVerizonAdsMediationAdapterInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [[YASInterstitialAd alloc] initWithPlacementId: placementId];
    self.interstitialAd.delegate = self.interstitialDelegate;
    
    YASRequestMetadata *requestMetadata = [self createRequestMetadataForBidResponse: bidResponse];
    YASInterstitialPlacementConfig *placementConfig = [[YASInterstitialPlacementConfig alloc] initWithPlacementId: placementId
                                                                                                  requestMetadata: requestMetadata];
    [self.interstitialAd loadWithPlacementConfig: placementConfig];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad: '%@'...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( !self.interstitialAd )
    {
        [self log: @"Unable to show interstitial - no ad loaded"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205
                                                                             errorString: @"Ad Display Failed"
                                                                mediatedNetworkErrorCode: 0
                                                             mediatedNetworkErrorMessage: @"Interstitial ad not ready"]];
        
        return;
    }
    
    UIViewController *presentingViewController;
    if ( ALSdk.versionCode >= 11020199 )
    {
        presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    }
    else
    {
        presentingViewController = [ALUtils topViewControllerFromKeyWindow];
    }
    
    [self.interstitialAd setImmersiveEnabled: YES];
    [self.interstitialAd showFromViewController: presentingViewController];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@ interstitial ad for placement: %@...", ([bidResponse al_isValidString] ? @"bidding" : @""), placementId];
    
    [self updatePrivacyStatesForParameters: parameters];
    [self updateLocationCollectionEnabled: parameters];
    
    self.rewardedDelegate = [[ALVerizonAdsMediationAdapterRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd = [[YASInterstitialAd alloc] initWithPlacementId: placementId];
    self.rewardedAd.delegate = self.rewardedDelegate;
    
    YASRequestMetadata *requestMetadata = [self createRequestMetadataForBidResponse: bidResponse];
    YASInterstitialPlacementConfig *placementConfig = [[YASInterstitialPlacementConfig alloc] initWithPlacementId: placementId
                                                                                                  requestMetadata: requestMetadata];
    [self.rewardedAd loadWithPlacementConfig: placementConfig];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad: '%@'...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( !self.rewardedAd )
    {
        [self log: @"Unable to show rewarded ad - no ad loaded"];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithCode: -4205
                                                                         errorString: @"Ad Display Failed"
                                                            mediatedNetworkErrorCode: 0
                                                         mediatedNetworkErrorMessage: @"Rewarded ad not ready"]];
        
        return;
    }
    
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
    
    [self.rewardedAd setImmersiveEnabled: YES];
    [self.rewardedAd showFromViewController: presentingViewController];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    
    [self log: @"Loading %@%@%@ for placement: %@...", isNative ? @"native " : @"", ([bidResponse al_isValidString] ? @"bidding " : @""), adFormat.label, placementId];
    
    [self updatePrivacyStatesForParameters: parameters];
    [self updateLocationCollectionEnabled: parameters];
    
    YASRequestMetadata *requestMetadata = [self createRequestMetadataForBidResponse: bidResponse];
    
    if ( isNative )
    {
        if ( ALSdk.versionCode < 11050500 )
        {
            [self log: @"Failing ad load for AppLovin SDK < 11.5.5 since native ad view ad templates don't have some assets required by Yahoo SDK on older AppLovin SDKs."];
            [delegate didFailToLoadAdViewAdWithError: MAAdapterError.unspecified];
            
            return;
        }
        
        self.nativeAdViewAdDelegate = [[ALVerizonAdsMediationAdapterNativeAdViewAdDelegate alloc] initWithParentAdapter: self
                                                                                                               adFormat: adFormat
                                                                                                       serverParameters: parameters.serverParameters
                                                                                                              andNotify: delegate];
        
        self.nativeAdViewAd = [[YASNativeAd alloc] initWithPlacementId: placementId];
        self.nativeAdViewAd.delegate = self.nativeAdViewAdDelegate;
        
        YASNativePlacementConfig *placementConfig = [[YASNativePlacementConfig alloc] initWithPlacementId: placementId
                                                                                          requestMetadata: requestMetadata
                                                                                            nativeAdTypes: kNativeAdAdTypes];
        [self.nativeAdViewAd loadWithPlacementConfig: placementConfig];
    }
    else
    {
        self.inlineAdViewDelegate = [[ALVerizonAdsMediationAdapterInlineAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        self.inlineAdView = [[YASInlineAdView alloc] initWithPlacementId: placementId];
        self.inlineAdView.delegate = self.inlineAdViewDelegate;
        
        YASInlineAdSize *adSize = [self adSizeFromAdFormat: adFormat];
        YASInlinePlacementConfig *placementConfig = [[YASInlinePlacementConfig alloc] initWithPlacementId: placementId
                                                                                          requestMetadata: requestMetadata
                                                                                                  adSizes: @[adSize]];
        [self.inlineAdView loadWithPlacementConfig: placementConfig];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@ native for placement: %@...", ([bidResponse al_isValidString] ? @"bidding " : @""), placementId];
    
    self.nativeAdDelegate = [[ALVerizonAdsMediationAdapterNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                       serverParameters: parameters.serverParameters
                                                                                              andNotify: delegate];
    
    self.nativeAd = [[YASNativeAd alloc] initWithPlacementId: placementId];
    self.nativeAd.delegate = self.nativeAdDelegate;
    
    [self updatePrivacyStatesForParameters: parameters];
    [self updateLocationCollectionEnabled: parameters];
    
    YASRequestMetadata *requestMetadata = [self createRequestMetadataForBidResponse: bidResponse];
    YASNativePlacementConfig *placementConfig = [[YASNativePlacementConfig alloc] initWithPlacementId: placementId
                                                                                      requestMetadata: requestMetadata
                                                                                        nativeAdTypes: kNativeAdAdTypes];
    [self.nativeAd loadWithPlacementConfig: placementConfig];
}

#pragma mark - Shared Methods

- (void)updateLocationCollectionEnabled:(id<MAAdapterParameters>)parameters
{
    if ( ALSdk.versionCode >= 11000000 )
    {
        NSDictionary<NSString *, id> *localExtraParamters = parameters.localExtraParameters;
        NSNumber *isLocationCollectionEnabled = [localExtraParamters al_numberForKey: @"is_location_collection_enabled"];
        if ( isLocationCollectionEnabled )
        {
            [self log: @"Setting location collection: %@", isLocationCollectionEnabled];
            [[YASAds sharedInstance] setLocationAccessMode: isLocationCollectionEnabled.boolValue ? YASLocationAccessModePrecise : YASLocationAccessModeDenied];
        }
    }
}
- (void)updatePrivacyStatesForParameters:(id<MAAdapterParameters>)parameters
{
    if ( ALSdk.versionCode >= 11040299 )
    {
        if ( parameters.consentString )
        {
            [[YASAds sharedInstance] addConsent: [[YASGdprConsent alloc] initWithConsentString: parameters.consentString]];
        }
    }
    
    NSNumber *isAgeRestrictedUser = [self privacySettingForSelector: @selector(isAgeRestrictedUser) fromParameters: parameters];
    if ( isAgeRestrictedUser.boolValue )
    {
        [[YASAds sharedInstance] applyCoppa];
    }
    
    if ( ALSdk.versionCode >= 61100 )
    {
        NSNumber *isDoNotSell = [self privacySettingForSelector: @selector(isDoNotSell) fromParameters: parameters];
        if ( isDoNotSell )
        {
            [[YASAds sharedInstance] addConsent: [[YASCcpaConsent alloc] initWithConsentString: isDoNotSell ? @"1YY-" : @"1YN-"]];
        }
        else
        {
            [[YASAds sharedInstance] addConsent: [[YASCcpaConsent alloc] initWithConsentString: @"1---"]];
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

- (YASRequestMetadata *)createRequestMetadataForBidResponse:(NSString *)bidResponse
{
    YASRequestMetadataBuilder *builder = [[YASRequestMetadataBuilder alloc] init];
    builder.mediator = self.mediationTag;
    
    if ( [bidResponse al_isValidString] )
    {
        builder.placementData = @{@"adContent" : bidResponse,
                                  @"overrideWaterfallProvider" : @"waterfallprovider/sideloading"};
    }
    
    return [builder build];
}

+ (MAAdapterError *)toMaxError:(YASErrorInfo *)yahooAdsError
{
    YASCoreError yahooErrorCode = yahooAdsError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( yahooErrorCode )
    {
        case YASCoreErrorAdNotAvailable:
            adapterError = MAAdapterError.noFill;
            break;
        case YASCoreErrorAdFetchFailure:
        case YASCoreErrorUnexpectedServerError:
        case YASCoreErrorBadServerResponseCode:
            adapterError = MAAdapterError.serverError;
            break;
        case YASCoreErrorTimeout:
            adapterError = MAAdapterError.timeout;
            break;
        case YASCoreErrorEmptyExchangeServerResponse:
            adapterError = MAAdapterError.serverError;
            break;
        case YASCoreErrorPlacementConfigNotAvailable:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case YASCoreErrorSDKNotInitialized:
            adapterError = MAAdapterError.notInitialized;
            break;
        case YASCoreErrorNotImplemented:
        case YASCoreErrorAdAdapterNotFound:
        case YASCoreErrorAdPrepareFailure:
        case YASCoreErrorWaterfallFailure:
        case YASCoreErrorPluginNotEnabled:
        case YASCoreErrorAdFetchFailureApplicationInBackground:
            adapterError = MAAdapterError.unspecified;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: yahooAdsError.code
               thirdPartySdkErrorMessage: yahooAdsError.localizedDescription];
#pragma clang diagnostic pop
}

- (YASInlineAdSize *)adSizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return [[YASInlineAdSize alloc] initWithWidth: 320 height: 50];
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return [[YASInlineAdSize alloc] initWithWidth: 300 height: 250];
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return [[YASInlineAdSize alloc] initWithWidth: 728 height: 90];
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        
        return [[YASInlineAdSize alloc] initWithWidth: 320 height: 50];
    }
}

- (NSString *)validTemplateUsingTemplateName:(NSString *)templateName
{
    if ( [templateName al_isValidString] )
    {
        // Since all of the leader templates and the templates containing "media", have the
        // requisite assets, we can just use the same templateName.
        if ( [templateName containsString: @"media"] || [templateName containsString: @"leader"] ) return templateName;
        
        return [templateName containsString: @"vertical"] ? @"vertical_media_banner_template" : @"media_banner_template";
    }
    
    // We can just return the banner template, because for an mrec
    // it would by default use the mrec template which is compatible
    return @"media_banner_template";
}

@end

@implementation ALVerizonAdsMediationAdapterInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialAdDidLoad:(YASInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    
    self.parentAdapter.interstitialAd = interstitialAd;
    
    NSString *creativeId = interstitialAd.creativeInfo.creativeId;
    if ( ALSdk.versionCode >= 6150000 && [creativeId al_isValidString] )
    {
        [self.delegate performSelector: @selector(didLoadInterstitialAdWithExtraInfo:)
                            withObject: @{@"creative_id" : creativeId}];
    }
    else
    {
        [self.delegate didLoadInterstitialAd];
    }
}

- (void)interstitialAdLoadDidFail:(YASInterstitialAd *)interstitialAd withError:(YASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"Interstitial ad load failed with error: %@", errorInfo.description];
    [self.delegate didFailToLoadInterstitialAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)interstitialAdDidFail:(YASInterstitialAd *)interstitialAd withError:(YASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"Interstitial ad failed with error: %@", errorInfo.description];
    [self.delegate didFailToLoadInterstitialAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)interstitialAdDidShow:(YASInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad shown"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialAdClicked:(YASInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialAdDidLeaveApplication:(YASInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad left application"];
}

- (void)interstitialAdDidClose:(YASInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad closed"];
    [self.delegate didHideInterstitialAd];
}

- (void)interstitialAdEvent:(YASInterstitialAd *)interstitialAd source:(NSString *)source eventId:(NSString *)eventId arguments:(NSDictionary<NSString *, id> *)arguments
{
    [self.parentAdapter log: @"Interstitial ad event from source: %@ with event ID: %@ and arguments: %@", source, eventId, arguments];
    
    if ( [kMAAdImpressionEventId isEqualToString: eventId] )
    {
        [self.delegate didDisplayInterstitialAd];
    }
}

@end

@implementation ALVerizonAdsMediationAdapterRewardedDelegate

- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialAdDidLoad:(YASInterstitialAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    
    self.parentAdapter.rewardedAd = rewardedAd;
    
    NSString *creativeId = rewardedAd.creativeInfo.creativeId;
    if ( ALSdk.versionCode >= 6150000 && [creativeId al_isValidString] )
    {
        [self.delegate performSelector: @selector(didLoadRewardedAdWithExtraInfo:)
                            withObject: @{@"creative_id" : creativeId}];
    }
    else
    {
        [self.delegate didLoadRewardedAd];
    }
}

- (void)interstitialAdLoadDidFail:(YASInterstitialAd *)rewardedAd withError:(YASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"Rewarded ad load failed with error: %@", errorInfo.description];
    [self.delegate didFailToLoadRewardedAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)interstitialAdDidFail:(YASInterstitialAd *)rewardedAd withError:(YASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"Rewarded ad failed with error: %@", errorInfo.description];
    [self.delegate didFailToLoadRewardedAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)interstitialAdDidShow:(YASInterstitialAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad shown"];
    
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)interstitialAdClicked:(YASInterstitialAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)interstitialAdDidLeaveApplication:(YASInterstitialAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad left application"];
}

- (void)interstitialAdDidClose:(YASInterstitialAd *)rewardedAd
{
    [self.delegate didCompleteRewardedAdVideo];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad closed"];
    [self.delegate didHideRewardedAd];
}

- (void)interstitialAdEvent:(YASInterstitialAd *)rewardedAd source:(NSString *)source eventId:(NSString *)eventId arguments:(NSDictionary<NSString *, id> *)arguments
{
    [self.parentAdapter log: @"Rewarded ad event from source: %@ with event ID: %@ and arguments: %@", source, eventId, arguments];
    
    if ( [kMAAdImpressionEventId isEqualToString: eventId] )
    {
        [self.delegate didDisplayRewardedAd];
    }
    else if ( [kMAVideoCompleteEventId isEqualToString: eventId] )
    {
        self.grantedReward = YES;
    }
}

@end

@implementation ALVerizonAdsMediationAdapterInlineAdViewDelegate

- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (UIViewController *)inlineAdPresentingViewController
{
    return [ALUtils topViewControllerFromKeyWindow];
}

- (void)inlineAdDidLoad:(YASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView loaded"];
    
    self.parentAdapter.inlineAdView = inlineAd;
    
    NSString *creativeId = inlineAd.creativeInfo.creativeId;
    if ( ALSdk.versionCode >= 6150000 && [creativeId al_isValidString] )
    {
        [self.delegate performSelector: @selector(didLoadAdForAdView:withExtraInfo:)
                            withObject: inlineAd
                            withObject: @{@"creative_id" : creativeId}];
    }
    else
    {
        [self.delegate didLoadAdForAdView: inlineAd];
    }
}

- (void)inlineAdLoadDidFail:(YASInlineAdView *)inlineAd withError:(YASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"AdView failed to load with error: %@", errorInfo];
    [self.delegate didFailToLoadAdViewAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)inlineAdDidFail:(YASInlineAdView *)inlineAd withError:(YASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"AdView failed to load with error: %@", errorInfo];
    [self.delegate didFailToLoadAdViewAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)inlineAdClicked:(YASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)inlineAdDidLeaveApplication:(YASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView left application"];
}

- (void)inlineAdDidExpand:(YASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView expanded"];
    [self.delegate didExpandAdViewAd];
}

- (void)inlineAdDidCollapse:(YASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView collapsed"];
    [self.delegate didCollapseAdViewAd];
}

- (void)inlineAdDidRefresh:(YASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView refreshed"];
}

- (void)inlineAdDidResize:(YASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView resized"];
}

- (void)inlineAd:(YASInlineAdView *)inlineAd event:(NSString *)eventId source:(NSString *)source arguments:(NSDictionary<NSString *, id> *)arguments
{
    [self.parentAdapter log: @"AdView event from source: %@ with event ID: %@ and arguments: %@", source, eventId, arguments];
    
    if ( [kMAAdImpressionEventId isEqualToString: eventId] )
    {
        [self.delegate didDisplayAdViewAd];
    }
}

@end

@implementation ALVerizonAdsMediationAdapterNativeAdViewAdDelegate

- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.adFormat = adFormat;
        self.serverParameters = serverParameters;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeAdDidLoad:(YASNativeAd *)nativeAdViewAd
{
    dispatchOnMainQueue(^{
        [self.parentAdapter log: @"Native %@ ad loaded: %@", self.adFormat.label, nativeAdViewAd.placementId];
        
        NSString *title = ((id<YASNativeTextComponent>)[nativeAdViewAd component: @"title"]).text;
        if ( ![title al_isValidString] )
        {
            [self.parentAdapter e: @"Native %@ ad (%@) does not have required assets.", self.adFormat.label, nativeAdViewAd];
            [self.delegate didFailToLoadAdViewAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
            
            return;
        }
        
        NSString *body = ((id<YASNativeTextComponent>)[nativeAdViewAd component: @"body"]).text;
        NSString *advertiser = ((id<YASNativeTextComponent>)[nativeAdViewAd component: @"disclaimer"]).text;
        NSString *callToAction = ((id<YASNativeTextComponent>)[nativeAdViewAd component: @"callToAction"]).text;
        
        MANativeAdImage *iconImage;
        id<YASNativeImageComponent> iconImageComponent = (id<YASNativeImageComponent>)[nativeAdViewAd component: @"iconImage"];
        if ( iconImageComponent )
        {
            UIImageView *iconImageView = [[UIImageView alloc] init];
            iconImageView.contentMode = UIViewContentModeScaleAspectFit;
            [iconImageComponent prepareView: iconImageView];
            
            // NOTE: Yahoo's SDK only returns UIImageView with the image pre-cached, we cannot use the 'URL' property
            // since it is un-cached and our SDK will attempt to re-cache it, and we do not support passing UIImageView for custom native
            iconImage = [[MANativeAdImage alloc] initWithImage: iconImageView.image];
        }
        
        UIView *mediaView;
        id<YASNativeVideoComponent> videoComponent = (id<YASNativeVideoComponent>)[nativeAdViewAd component: @"video"];
        id<YASNativeImageComponent> mainImageComponent = (id<YASNativeImageComponent>)[nativeAdViewAd component: @"mainImage"];
        
        // If video is available, use that
        if ( videoComponent )
        {
            mediaView = [[YASYahooVideoPlayerView alloc] init];
            [videoComponent prepareView: (YASVideoPlayerView *) mediaView];
        }
        else if ( mainImageComponent )
        {
            mediaView = [[UIImageView alloc] init];
            mediaView.contentMode = UIViewContentModeScaleAspectFit;
            [mainImageComponent prepareView: (UIImageView *) mediaView];
        }
        
        self.parentAdapter.nativeAdViewAd = nativeAdViewAd;
        
        MANativeAd *maxNativeAd = [[MAVerizonNativeAd alloc] initWithParentAdapter: self.parentAdapter
                                                                          adFormat: self.adFormat
                                                                      builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = title;
            builder.body = body;
            builder.advertiser = advertiser;
            builder.callToAction = callToAction;
            builder.icon = iconImage;
            builder.mediaView = mediaView;
        }];
        
        NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
        NSString *validTemplateName = [self.parentAdapter validTemplateUsingTemplateName: templateName];
        MANativeAdView *maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: validTemplateName];
        
        [maxNativeAd prepareViewForInteraction: maxNativeAdView];
        
        NSString *creativeId = nativeAdViewAd.creativeInfo.creativeId;
        if ( ALSdk.versionCode >= 6150000 && [creativeId al_isValidString] )
        {
            [self.delegate performSelector: @selector(didLoadAdForAdView:withExtraInfo:)
                                withObject: maxNativeAdView
                                withObject: @{@"creative_id" : creativeId}];
        }
        else
        {
            [self.delegate didLoadAdForAdView: maxNativeAdView];
        }
    });
}

- (void)nativeAdLoadDidFail:(YASNativeAd *)nativeAd withError:(YASErrorInfo *)errorInfo
{
    MAAdapterError *adapterError = [ALVerizonAdsMediationAdapter toMaxError: errorInfo];
    [self.parentAdapter log: @"Native %@ ad (%@) failed to load with error: %@", self.adFormat.label, nativeAd.placementId, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)nativeAdDidFail:(YASNativeAd *)nativeAd withError:(YASErrorInfo *)errorInfo
{
    MAAdapterError *adapterError = [ALVerizonAdsMediationAdapter toMaxError: errorInfo];
    [self.parentAdapter log: @"Native %@ ad (%@) failed to load with error: %@", self.adFormat.label, nativeAd.placementId, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)nativeAdClicked:(YASNativeAd *)nativeAd withComponent:(id<YASNativeComponent>)component
{
    [self.parentAdapter log: @"Native %@ ad clicked", self.adFormat.label];
    [self.delegate didClickAdViewAd];
}

- (void)nativeAdDidLeaveApplication:(YASNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad left application", self.adFormat.label];
}

- (void)nativeAdDidClose:(YASNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad closed", self.adFormat.label];
}

- (void)nativeAd:(YASNativeAd *)nativeAd event:(NSString *)eventId source:(NSString *)source arguments:(NSDictionary<NSString *, id> *)arguments
{
    [self.parentAdapter log: @"Native event from source: %@ with event ID: %@ and arguments: %@", source, eventId, arguments];
    
    if ( [kMAAdImpressionEventId isEqualToString: eventId] )
    {
        [self.delegate didDisplayAdViewAdWithExtraInfo: nil];
    }
}

- (UIViewController *)nativeAdPresentingViewController
{
    return [ALUtils topViewControllerFromKeyWindow];
}

@end

@implementation ALVerizonAdsMediationAdapterNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.serverParameters = serverParameters;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeAdDidLoad:(YASNativeAd *)nativeAd
{
    dispatchOnMainQueue(^{
        [self.parentAdapter log: @"Native ad loaded: %@", nativeAd.placementId];
        
        NSString *title = ((id<YASNativeTextComponent>)[nativeAd component: @"title"]).text;
        NSString *body = ((id<YASNativeTextComponent>)[nativeAd component: @"body"]).text;
        NSString *advertiser = ((id<YASNativeTextComponent>)[nativeAd component: @"disclaimer"]).text;
        NSString *callToAction = ((id<YASNativeTextComponent>)[nativeAd component: @"callToAction"]).text;
        
        MANativeAdImage *iconImage;
        id<YASNativeImageComponent> iconImageComponent = (id<YASNativeImageComponent>)[self.parentAdapter.nativeAd component: @"iconImage"];
        if ( iconImageComponent )
        {
            UIImageView *iconImageView = [[UIImageView alloc] init];
            iconImageView.contentMode = UIViewContentModeScaleAspectFit;
            [iconImageComponent prepareView: iconImageView];
            
            // NOTE: Yahoo's SDK only returns UIImageView with the image pre-cached, we cannot use the 'URL' property
            // since it is un-cached and our SDK will attempt to re-cache it, and we do not support passing UIImageView for custom native
            iconImage = [[MANativeAdImage alloc] initWithImage: iconImageView.image];
        }
        
        UIView *mediaView;
        CGFloat mediaContentAspectRatio = 0.0f;
        MANativeAdImage *mainImage = nil;
        id<YASNativeVideoComponent> videoComponent = (id<YASNativeVideoComponent>)[nativeAd component: @"video"];
        id<YASNativeImageComponent> mainImageComponent = (id<YASNativeImageComponent>)[nativeAd component: @"mainImage"];
        
        // If video is available, use that
        if ( videoComponent )
        {
            mediaContentAspectRatio = videoComponent.width / videoComponent.height;
            
            mediaView = [[YASYahooVideoPlayerView alloc] init];
            [videoComponent prepareView: (YASVideoPlayerView *) mediaView];
        }
        else if ( mainImageComponent )
        {
            mediaContentAspectRatio = mainImageComponent.width / mainImageComponent.height;
            
            mediaView = [[UIImageView alloc] init];
            mediaView.contentMode = UIViewContentModeScaleAspectFit;
            [mainImageComponent prepareView: (UIImageView *) mediaView];
            
            UIImage *image = ((UIImageView *) mediaView).image;
            mainImage = [[MANativeAdImage alloc] initWithImage: image];
        }
        
        NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
        BOOL isTemplateAd = [templateName al_isValidString];
        if ( isTemplateAd && ![title al_isValidString] )
        {
            [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
            [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
            
            return;
        }
        
        self.parentAdapter.nativeAd = nativeAd;
        
        MANativeAd *maxNativeAd = [[MAVerizonNativeAd alloc] initWithParentAdapter: self.parentAdapter
                                                                          adFormat: MAAdFormat.native
                                                                      builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = title;
            builder.body = body;
            builder.advertiser = advertiser;
            builder.callToAction = callToAction;
            builder.icon = iconImage;
            if ( ALSdk.versionCode >= 11040299 )
            {
                [builder performSelector: @selector(setMainImage:) withObject: mainImage];
            }
            builder.mediaView = mediaView;
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            // Introduced in 11.4.0
            if ( [builder respondsToSelector: @selector(setMediaContentAspectRatio:)] )
            {
                [builder performSelector: @selector(setMediaContentAspectRatio:) withObject: @(mediaContentAspectRatio)];
            }
#pragma clang diagnostic pop
        }];
        
        YASCreativeInfo *creativeInfo = nativeAd.creativeInfo;
        NSDictionary *extraInfo = [creativeInfo.creativeId al_isValidString] ? @{@"creative_id" : creativeInfo.creativeId} : nil;
        
        [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: extraInfo];
    });
}

- (void)nativeAdLoadDidFail:(YASNativeAd *)nativeAd withError:(YASErrorInfo *)errorInfo
{
    MAAdapterError *adapterError = [ALVerizonAdsMediationAdapter toMaxError: errorInfo];
    [self.parentAdapter log: @"Native ad (%@) failed to load with error: %@", nativeAd.placementId, adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeAdDidFail:(YASNativeAd *)nativeAd withError:(YASErrorInfo *)errorInfo
{
    MAAdapterError *adapterError = [ALVerizonAdsMediationAdapter toMaxError: errorInfo];
    [self.parentAdapter log: @"Native ad (%@) failed to load with error: %@", nativeAd.placementId, adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeAdClicked:(YASNativeAd *)nativeAd withComponent:(id<YASNativeComponent>)component
{
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)nativeAdDidLeaveApplication:(YASNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad left application"];
}

- (void)nativeAdDidClose:(YASNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad closed"];
}

- (void)nativeAd:(YASNativeAd *)nativeAd event:(NSString *)eventId source:(NSString *)source arguments:(NSDictionary<NSString *, id> *)arguments
{
    [self.parentAdapter log: @"Native event from source: %@ with event ID: %@ and arguments: %@", source, eventId, arguments];
    
    if ( [kMAAdImpressionEventId isEqualToString: eventId] )
    {
        [self.delegate didDisplayNativeAdWithExtraInfo: nil];
    }
}

- (UIViewController *)nativeAdPresentingViewController
{
    return [ALUtils topViewControllerFromKeyWindow];
}

@end

@implementation MAVerizonNativeAd

- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)adFormat builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: adFormat  builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (BOOL)isContainerClickable
{
    return YES;
}

- (void)performClick
{
    YASNativeAd *ad = self.parentAdapter.nativeAd;
    if ( !ad )
    {
        [self.parentAdapter e: @"Failed to perform click: Native ad is nil."];
        return;
    }
    
    [self.parentAdapter d: @"Performing click..."];
    [self.parentAdapter.nativeAdDelegate.delegate didClickNativeAd];
    [ad invokeDefaultAction];
}

- (void)prepareViewForInteraction:(MANativeAdView *)maxNativeAdView
{
    YASNativeAd *ad = ( self.format == MAAdFormat.native ) ? self.parentAdapter.nativeAd : self.parentAdapter.nativeAdViewAd;
    if ( !ad )
    {
        [self.parentAdapter e: @"Failed to register native ad view for interaction: Native ad is nil."];
        return;
    }
    
    id<YASNativeTextComponent> titleComponent = (id<YASNativeTextComponent>)[ad component: @"title"];
    id<YASNativeTextComponent> disclaimerComponent = (id<YASNativeTextComponent>)[ad component: @"disclaimer"];
    id<YASNativeTextComponent> bodyComponent = (id<YASNativeTextComponent>)[ad component: @"body"];
    id<YASNativeTextComponent> ctaComponent = (id<YASNativeTextComponent>)[ad component: @"callToAction"];
    id<YASNativeImageComponent> iconComponent = (id<YASNativeImageComponent>)[ad component: @"iconImage"];
    
    if ( titleComponent && maxNativeAdView.titleLabel )
    {
        [titleComponent prepareLabel: maxNativeAdView.titleLabel];
    }
    if ( disclaimerComponent && maxNativeAdView.advertiserLabel )
    {
        [disclaimerComponent prepareLabel: maxNativeAdView.advertiserLabel];
    }
    if ( bodyComponent && maxNativeAdView.bodyLabel )
    {
        [bodyComponent prepareLabel: maxNativeAdView.bodyLabel];
    }
    if ( ctaComponent && maxNativeAdView.callToActionButton )
    {
        [ctaComponent prepareButton: maxNativeAdView.callToActionButton];
    }
    if ( iconComponent && maxNativeAdView.iconImageView )
    {
        [iconComponent prepareView: maxNativeAdView.iconImageView];
    }
    
    [ad registerContainerView: maxNativeAdView];
}

@end
