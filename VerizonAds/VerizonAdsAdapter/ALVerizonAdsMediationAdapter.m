//
//  MAVerizonAdsMediationAdapter.m
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 4/7/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALVerizonAdsMediationAdapter.h"
#import <YahooAds/YahooAds.h>

#define ADAPTER_VERSION @"1.14.2.5"
#define SDK_VERSION @"1.14.2"

/**
 * Dedicated delegate object for Verizon Ads interstitial ads.
 */
@interface ALVerizonAdsMediationAdapterInterstitialDelegate : NSObject<YASInterstitialAdDelegate>
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * Dedicated delegate object for Verizon Ads rewarded ads.
 */
@interface ALVerizonAdsMediationAdapterRewardedDelegate : NSObject<YASInterstitialAdDelegate>
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * Dedicated delegate object for Verizon Ads AdView ads.
 */
@interface ALVerizonAdsMediationAdapterInlineAdViewDelegate : NSObject<YASInlineAdViewDelegate>
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * Dedicated delegate object for Verizon Ads native ads.
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
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
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

// Native
@property (nonatomic, strong) YASNativeAd *nativeAd;
@property (nonatomic, strong) ALVerizonAdsMediationAdapterNativeAdDelegate *nativeAdDelegate;
@property (nonatomic,   weak) MANativeAdView *nativeAdView;

@end

@implementation ALVerizonAdsMediationAdapter
static NSTimeInterval const kDefaultImageTaskTimeoutSeconds = 10.0;

// Event IDs
static NSString *const kMAVideoCompleteEventId = @"onVideoComplete";
static NSString *const kMAAdImpressionEventId = @"adImpression";

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters withCompletionHandler:(void (^)(void))completionHandler
{
    if ( ![[YASAds sharedInstance] isInitialized] )
    {
        NSString *siteID = [parameters.serverParameters al_stringForKey: @"site_id"];
        [self log: @"Initializing Verizon Ads SDK with site id: %@...", siteID];
        
        [YASAds initializeWithSiteId: siteID];
        
        // ...GDPR settings, which is part of verizon Ads SDK data, should be established after initialization and prior to making any ad requests... (https://sdk.verizonmedia.com/gdpr-coppa.html)
        [self updateVerizonAdsSDKDataWithAdapterParameters: parameters];
    }
    
    completionHandler();
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    MAAdapterInitializationStatus status;
    if ( ![[YASAds sharedInstance] isInitialized] )
    {
        [self log: @"Initializing Verizon Ads SDK..."];
        
        NSString *siteID = [parameters.serverParameters al_stringForKey: @"site_id"];
        BOOL initialized = [YASAds initializeWithSiteId: siteID];
        status = initialized ? MAAdapterInitializationStatusInitializedSuccess : MAAdapterInitializationStatusInitializedFailure;
        
        // ...GDPR settings, which is part of verizon Ads SDK data, should be established after initialization and prior to making any ad requests... (https://sdk.verizonmedia.com/gdpr-coppa.html)
        [self updateVerizonAdsSDKDataWithAdapterParameters: parameters];
    }
    else
    {
        status = MAAdapterInitializationStatusInitializedSuccess;
    }
    
    completionHandler(status, nil);
}

- (NSString *)SDKVersion
{
    return SDK_VERSION;
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self.inlineAdView destroy];
    self.inlineAdView = nil;
    self.inlineAdViewDelegate = nil;
    
    [self.interstitialAd destroy];
    self.interstitialAd = nil;
    self.interstitialDelegate = nil;
    
    [self.rewardedAd destroy];
    self.rewardedAd = nil;
    self.rewardedDelegate = nil;
    
    [self.nativeAd destroy];
    self.nativeAd = nil;
    self.nativeAdDelegate = nil;
    
    self.nativeAdView = nil;
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad for placement: '%@'...", placementIdentifier];
    
    self.interstitialDelegate = [[ALVerizonAdsMediationAdapterInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    self.interstitialAd = [[YASInterstitialAd alloc] initWithPlacementId: placementIdentifier];
    self.interstitialAd.delegate = self.interstitialDelegate;
    
    [self updateVerizonAdsSDKDataWithAdapterParameters: parameters];
    
    [self log: @"Loading %@ interstitial ad...", [parameters.bidResponse al_isValidString] ? @"Bidding" : @"mediated"];
    
    YASRequestMetadata *requestMetadata = [self createRequestMetadataForForServerParameters: parameters.serverParameters andBidResponse: parameters.bidResponse];
    YASInterstitialPlacementConfig *placementConfig = [[YASInterstitialPlacementConfig alloc] initWithPlacementId: placementIdentifier requestMetadata: requestMetadata];
    [self.interstitialAd loadWithPlacementConfig: placementConfig];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad: '%@'...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( !self.interstitialAd )
    {
        [self log: @"Unable to show interstitial - no ad loaded"];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
        
        return;
    }
    
    __block UIViewController *presentingViewController;
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
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad for placement: '%@'...", placementIdentifier];
    
    self.rewardedDelegate = [[ALVerizonAdsMediationAdapterRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    self.rewardedAd = [[YASInterstitialAd alloc] initWithPlacementId: placementIdentifier];
    self.rewardedAd.delegate = self.rewardedDelegate;

    [self updateVerizonAdsSDKDataWithAdapterParameters: parameters];
    
    [self log: @"Loading %@ rewarded ad...", [parameters.bidResponse al_isValidString] ? @"Bidding" : @"mediated"];
    
    YASRequestMetadata *requestMetadata = [self createRequestMetadataForForServerParameters: parameters.serverParameters andBidResponse: parameters.bidResponse];
    YASInterstitialPlacementConfig *placementConfig = [[YASInterstitialPlacementConfig alloc] initWithPlacementId: placementIdentifier requestMetadata: requestMetadata];
    [self.rewardedAd loadWithPlacementConfig: placementConfig];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad: '%@'...", parameters.thirdPartyAdPlacementIdentifier];
    
    if ( !self.rewardedAd )
    {
        [self log: @"Unable to show rewarded ad - no ad loaded"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
        
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
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@%@ for placement: %@...", ( [bidResponse al_isValidString] ? @"bidding " : @""), adFormat.label, placementIdentifier];
    
    self.inlineAdViewDelegate = [[ALVerizonAdsMediationAdapterInlineAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.inlineAdView = [[YASInlineAdView alloc] initWithPlacementId: placementIdentifier];
    self.inlineAdView.delegate = self.inlineAdViewDelegate;
    
    [self updateVerizonAdsSDKDataWithAdapterParameters: parameters];
    
    YASRequestMetadata *requestMetadata = [self createRequestMetadataForForServerParameters: parameters.serverParameters andBidResponse: bidResponse];
    YASInlineAdSize *adSize = [self adSizeFromAdFormat: adFormat];
    YASInlinePlacementConfig *placementConfig = [[YASInlinePlacementConfig alloc] initWithPlacementId: placementIdentifier
                                                                                      requestMetadata: requestMetadata
                                                                                              adSizes: @[adSize]];
    
    [self.inlineAdView loadWithPlacementConfig: placementConfig];
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading native %@for placement: %@...", ( [bidResponse al_isValidString] ? @"bidding " : @""), placementIdentifier];
    
    self.nativeAdDelegate = [[ALVerizonAdsMediationAdapterNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                       serverParameters: parameters.serverParameters
                                                                                              andNotify: delegate];
    
    self.nativeAd = [[YASNativeAd alloc] initWithPlacementId: placementIdentifier];
    self.nativeAd.delegate = self.nativeAdDelegate;
    
    [self updateVerizonAdsSDKDataWithAdapterParameters: parameters];
    

    YASRequestMetadata *requestMetadata = [self createRequestMetadataForForServerParameters: parameters.serverParameters andBidResponse: bidResponse];
    YASNativePlacementConfig *placementConfig = [[YASNativePlacementConfig alloc] initWithPlacementId: placementIdentifier
                                                                                      requestMetadata: requestMetadata
                                                                                        nativeAdTypes: @[@"simpleImage", @"simpleVideo"]];
    
    
    [self.nativeAd loadWithPlacementConfig: placementConfig];
}

#pragma mark - Signal Provider Protocol

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *token = [[YASAds sharedInstance] biddingTokenTrimmedToSize: 4000];
    if ( !token )
    {
        NSString *errorMessage = @"VerizonAds SDK not initialized; failed to return a bid.";
        [delegate didFailToCollectSignalWithErrorMessage: errorMessage];
        
        return;
    }
    
    [delegate didCollectSignal: token];
}

#pragma mark - Shared Methods

- (void)updateVerizonAdsSDKDataWithAdapterParameters:(id<MAAdapterParameters>)parameters
{
    YASLogLevel logLevel = [parameters isTesting] ? YASLogLevelVerbose : YASLogLevelError;
    [YASAds setLogLevel: logLevel];
    
    NSNumber *isAgeRestrictedUser = [self privacySettingForSelector: @selector(isAgeRestrictedUser) fromParameters: parameters];
    if ( isAgeRestrictedUser )
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

- (YASRequestMetadata *)createRequestMetadataForForServerParameters:(NSDictionary<NSString *, id> *)serverParameters andBidResponse:(NSString *)bidResponse
{
    YASRequestMetadataBuilder *builder = [[YASRequestMetadataBuilder alloc] init];
    
    if ( [bidResponse al_isValidString] )
    {
        NSMutableDictionary<NSString *, id> *placementData = [@{@"adContent" : bidResponse,
                                                                @"overrideWaterfallProvider"  : @"waterfallprovider/sideloading"} mutableCopy];
        [builder setPlacementData: placementData];
    }
    
    builder.mediator = self.mediationTag;
    
    if ( [serverParameters al_containsValueForKey: @"user_age"] )
    {
        builder.userAge = [serverParameters al_numberForKey: @"user_age"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_children"] )
    {
        builder.userChildren = [serverParameters al_numberForKey: @"user_children"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_education"] )
    {
        builder.userEducation = [serverParameters al_stringForKey: @"user_education"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_gender"] )
    {
        builder.userGender = [serverParameters al_stringForKey: @"user_gender" ];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_marital_status"] )
    {
        builder.userMaritalStatus = [serverParameters al_stringForKey: @"user_marital_status"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"dob"] )
    {
        NSDate *DOB = [NSDate dateWithTimeIntervalSince1970: [serverParameters al_numberForKey: @"dob"].al_timeIntervalValue];
        builder.userDOB = DOB;
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_state"] )
    {
        builder.userState = [serverParameters al_stringForKey: @"user_state"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_country"] )
    {
        builder.userCountry = [serverParameters al_stringForKey: @"user_country"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_postal_code"] )
    {
        builder.userPostalCode = [serverParameters al_stringForKey: @"user_postal_code"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_dma"] )
    {
        builder.userDMA = [serverParameters al_stringForKey: @"user_dma"];
    }
    
    return [builder build];
}

+ (MAAdapterError *)toMaxError:(YASErrorInfo *)yahooAdsError
{
    YASCoreError verizonErrorCode = yahooAdsError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( verizonErrorCode )
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
        case YASCoreErrorNotImplemented:
        case YASCoreErrorAdAdapterNotFound:
        case YASCoreErrorAdPrepareFailure:
        case YASCoreErrorWaterfallFailure:
        case YASCoreErrorPluginNotEnabled:
        case YASCoreErrorAdFetchFailureApplicationInBackground:
        case YASCoreErrorEmptyExchangeServerResponse:
            adapterError = MAAdapterError.unspecified;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: yahooAdsError
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
    
    if ( [kMAVideoCompleteEventId isEqualToString: eventId] )
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

- (void)inlineAd:(YASInlineAdView *)inlineAd event:(NSString *)eventId source:(NSString *)source arguments:(NSDictionary<NSString *,id> *)arguments
{
    [self.parentAdapter log: @"AdView event from source: %@ with event ID: %@ and arguments: %@", source, eventId, arguments];
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
    [self.parentAdapter log: @"Native ad loaded: %@", nativeAd.placementId];

    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    BOOL missingRequiredAssets = NO;
    
    id<YASNativeTextComponent> titleComponent = (id<YASNativeTextComponent>)[nativeAd component: @"title"];
    id<YASNativeTextComponent> ctaComponent = (id<YASNativeTextComponent>)[nativeAd component: @"callToAction"];
    id mediaComponent = (id<YASNativeVideoComponent>)[nativeAd component: @"video"] ?: (id<YASNativeImageComponent>)[nativeAd component: @"mainImage"];
    
    if ( isTemplateAd && ![titleComponent.text al_isValidString] )
    {
        missingRequiredAssets = YES;
    }
    else if ( ![titleComponent.text al_isValidString] ||
              ![ctaComponent.text al_isValidString] ||
              mediaComponent == nil )
    {
        missingRequiredAssets = YES;
    }
    
    if ( missingRequiredAssets )
    {
        [self.parentAdapter e: @"Custom native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    self.parentAdapter.nativeAd = nativeAd;
    
    MANativeAd *maxNativeAd = [[MAVerizonNativeAd alloc] initWithParentAdapter: self.parentAdapter
                                                                     andNotify: self.delegate
                                                                  builderBlock:^(MANativeAdBuilder *builder) {
    }];
    
    YASCreativeInfo *creativeInfo = nativeAd.creativeInfo;
    NSDictionary *extraInfo = [creativeInfo.creativeId al_isValidString] ? @{@"creative_id" : creativeInfo.creativeId} : nil;
    
    [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: extraInfo];
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

- (void)nativeAd:(YASNativeAd *)nativeAd event:(NSString *)eventId source:(NSString *)source arguments:(NSDictionary<NSString *,id> *)arguments
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

- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)prepareViewForInteraction:(MANativeAdView *)nativeAdView
{
    if ( !self.parentAdapter.nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad view for interaction: Native ad is nil."];
        return;
    }
    
    dispatchOnMainQueue(^{
        
        id<YASNativeViewComponent> component = (id<YASNativeViewComponent>)[self.parentAdapter.nativeAd component: @"title"];
        if ([component conformsToProtocol: @protocol(YASNativeTextComponent)]) {
            [(id<YASNativeTextComponent>)component prepareLabel: nativeAdView.titleLabel];
        }
        
        component = (id<YASNativeViewComponent>)[self.parentAdapter.nativeAd component: @"disclaimer"];
        if ([component conformsToProtocol: @protocol(YASNativeTextComponent)]) {
            [(id<YASNativeTextComponent>)component prepareLabel: nativeAdView.advertiserLabel];
        }
        
        component = (id<YASNativeViewComponent>)[self.parentAdapter.nativeAd component: @"body"];
        if ([component conformsToProtocol: @protocol(YASNativeTextComponent)]) {
            [(id<YASNativeTextComponent>)component prepareLabel: nativeAdView.bodyLabel];
        }
        
        component = (id<YASNativeTextComponent>)[self.parentAdapter.nativeAd component: @"callToAction"];
        if ([component conformsToProtocol: @protocol(YASNativeTextComponent)]) {
            [(id<YASNativeTextComponent>)component prepareButton: nativeAdView.callToActionButton];
        }
        
        component = (id<YASNativeViewComponent>)[self.parentAdapter.nativeAd component: @"iconImage"];
        if ([component conformsToProtocol: @protocol(YASNativeImageComponent)]) {
            [(id<YASNativeImageComponent>)component prepareView: nativeAdView.iconImageView];
        }
        
        UIView *mediaView;
        component = (id<YASNativeVideoComponent>)[self.parentAdapter.nativeAd component: @"video"] ?: (id<YASNativeVideoComponent>)[self.parentAdapter.nativeAd component: @"mainImage"];
        if ([component conformsToProtocol: @protocol(YASNativeVideoComponent)]) {
            mediaView = [[YASYahooVideoPlayerView alloc] init];
            [(id<YASNativeVideoComponent>)component prepareView: mediaView];
        } else if([component conformsToProtocol: @protocol(YASNativeImageComponent)]) {
            mediaView = [[UIImageView alloc] init];
            [(id<YASNativeImageComponent>)component prepareView: mediaView];
        }
        [self attachView: mediaView toView: nativeAdView.mediaContentView];
        
        [self.parentAdapter.nativeAd registerContainerView: nativeAdView];
    });
}

- (void)attachView:(UIView *)view toView:(UIView *)parentView
{
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [parentView addSubview:view];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:parentView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:parentView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:parentView
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0
                                                                           constant:0];
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:parentView
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0
                                                                          constant:0];
    
    [NSLayoutConstraint activateConstraints:@[topConstraint, bottomConstraint, trailingConstraint, leadingConstraint]];
}

@end
