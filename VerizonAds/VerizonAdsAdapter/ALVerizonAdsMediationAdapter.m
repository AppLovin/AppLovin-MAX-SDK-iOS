//
//  MAVerizonAdsMediationAdapter.m
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 4/7/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALVerizonAdsMediationAdapter.h"
#import <VerizonAdsInterstitialPlacement/VerizonAdsInterstitialPlacement.h>
#import <VerizonAdsInlinePlacement/VerizonAdsInlinePlacement.h>

#define ADAPTER_VERSION @"1.14.2.0"

/**
 * Dedicated delegate object for Verizon Ads interstitial ads.
 */
@interface ALVerizonAdsMediationAdapterInterstitialDelegate : NSObject<VASInterstitialAdFactoryDelegate, VASInterstitialAdDelegate>
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * Dedicated delegate object for Verizon Ads rewarded ads.
 */
@interface ALVerizonAdsMediationAdapterRewardedDelegate : NSObject<VASInterstitialAdFactoryDelegate, VASInterstitialAdDelegate>
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * Dedicated delegate object for Verizon Ads AdView ads.
 */
@interface ALVerizonAdsMediationAdapterInlineAdViewDelegate : NSObject<VASInlineAdFactoryDelegate, VASInlineAdViewDelegate>
@property (nonatomic,   weak) ALVerizonAdsMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerizonAdsMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;
@end

@interface ALVerizonAdsMediationAdapter()

// Interstitial
@property (nonatomic, strong) VASInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALVerizonAdsMediationAdapterInterstitialDelegate *interstitialDelegate;

// Rewarded
@property (nonatomic, strong) VASInterstitialAd *rewardedAd;
@property (nonatomic, strong) ALVerizonAdsMediationAdapterRewardedDelegate *rewardedDelegate;

// AdView
@property (nonatomic, strong) VASInlineAdView *inlineAdView;
@property (nonatomic, strong) ALVerizonAdsMediationAdapterInlineAdViewDelegate *inlineAdViewDelegate;

@end

@implementation ALVerizonAdsMediationAdapter

// Event IDs
static NSString *const kMAVideoCompleteEventId = @"onVideoComplete";

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters withCompletionHandler:(void (^)(void))completionHandler
{
    if ( ![[VASAds sharedInstance] isInitialized] )
    {
        NSString *siteID = [parameters.serverParameters al_stringForKey: @"site_id"];
        [self log: @"Initializing Verizon Ads SDK with site id: %@...", siteID];
        
        [VASAds initializeWithSiteId: siteID];
        
        // ...GDPR settings, which is part of verizon Ads SDK data, should be established after initialization and prior to making any ad requests... (https://sdk.verizonmedia.com/gdpr-coppa.html)
        [self updateVerizonAdsSDKDataWithAdapterParameters: parameters];
    }
    
    completionHandler();
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    MAAdapterInitializationStatus status;
    if ( ![[VASAds sharedInstance] isInitialized] )
    {
        [self log: @"Initializing Verizon Ads SDK..."];
        
        NSString *siteID = [parameters.serverParameters al_stringForKey: @"site_id"];
        BOOL initialized = [VASAds initializeWithSiteId: siteID];
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
    // NOTE: Verizon Ads SDK returns an empty string if attempting to retrieve if not initialized.
    return [[VASAds sharedInstance].configuration stringForDomain: @"com.verizon.ads" key: @"editionVersion" withDefault: @""];
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
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad for placement: '%@'...", placementIdentifier];
    
    self.interstitialDelegate = [[ALVerizonAdsMediationAdapterInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    VASInterstitialAdFactory *interstitialFactory = [[VASInterstitialAdFactory alloc] initWithPlacementId: placementIdentifier
                                                                                                   vasAds: [VASAds sharedInstance]
                                                                                                 delegate: self.interstitialDelegate];
    interstitialFactory.requestMetadata = [self createRequestMetadataForForServerParameters: parameters.serverParameters andBidResponse: parameters.bidResponse];
    
    [self updateVerizonAdsSDKDataWithAdapterParameters: parameters];
    
    [self log: @"Loading %@ interstitial ad...", [parameters.bidResponse al_isValidString] ? @"Bidding" : @"mediated"];
    [interstitialFactory load: self.interstitialDelegate];
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
    
    [self.interstitialAd showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad for placement: '%@'...", placementIdentifier];
    
    self.rewardedDelegate = [[ALVerizonAdsMediationAdapterRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    VASInterstitialAdFactory *rewardedFactory = [[VASInterstitialAdFactory alloc] initWithPlacementId: placementIdentifier
                                                                                               vasAds: [VASAds sharedInstance]
                                                                                             delegate: self.rewardedDelegate];
    rewardedFactory.requestMetadata = [self createRequestMetadataForForServerParameters: parameters.serverParameters andBidResponse: parameters.bidResponse];
    
    [self updateVerizonAdsSDKDataWithAdapterParameters: parameters];
    
    [self log: @"Loading %@ rewarded ad...", [parameters.bidResponse al_isValidString] ? @"Bidding" : @"mediated"];
    [rewardedFactory load: self.interstitialDelegate];
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
    [self.rewardedAd showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@%@ for placement: %@...", ( [bidResponse al_isValidString] ? @"bidding " : @""), adFormat.label, placementIdentifier];
    
    VASInlineAdSize *adSize = [self adSizeFromAdFormat: adFormat];
    self.inlineAdViewDelegate = [[ALVerizonAdsMediationAdapterInlineAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    VASInlineAdFactory *inlineAdFactory = [[VASInlineAdFactory alloc] initWithPlacementId: placementIdentifier
                                                                                  adSizes: @[adSize]
                                                                                   vasAds: [VASAds sharedInstance]
                                                                                 delegate: self.inlineAdViewDelegate];
    inlineAdFactory.requestMetadata = [self createRequestMetadataForForServerParameters: parameters.serverParameters andBidResponse: bidResponse];
    
    [self updateVerizonAdsSDKDataWithAdapterParameters: parameters];
    
    [inlineAdFactory load: self.inlineAdViewDelegate];
}

#pragma mark - Signal Provider Protocol

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *token = [[VASAds sharedInstance] biddingToken];
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
    VASLogLevel logLevel = [parameters isTesting] ? VASLogLevelVerbose : VASLogLevelError;
    [VASAds setLogLevel: logLevel];
    
    VASDataPrivacyBuilder *builder = [[VASDataPrivacyBuilder alloc] initWithDataPrivacy: VASAds.sharedInstance.dataPrivacy];
    
    NSNumber *isAgeRestrictedUser = [self privacySettingForSelector: @selector(isAgeRestrictedUser) fromParameters: parameters];
    if ( isAgeRestrictedUser )
    {
        builder.coppa.applies = isAgeRestrictedUser.boolValue;
    }
    
    //
    // For more GDPR info please see: https://sdk.verizonmedia.com/gdpr-coppa.html
    //
    if ( [parameters.serverParameters al_containsValueForKey: @"consent_string"] )
    {
        builder.gdpr.consent = [parameters.serverParameters al_stringForKey: @"consent_string"];
    }
    
    [[VASAds sharedInstance] setDataPrivacy: [builder build]];
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

- (VASRequestMetadata *)createRequestMetadataForForServerParameters:(NSDictionary<NSString *, id> *)serverParameters andBidResponse:(NSString *)bidResponse
{
    VASRequestMetadataBuilder *builder = [[VASRequestMetadataBuilder alloc] init];
    
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
    
    if ( [serverParameters al_containsValueForKey: @"user_income"] )
    {
        builder.userIncome = [serverParameters al_numberForKey: @"user_income"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_education"] )
    {
        builder.userEducation = [serverParameters al_stringForKey: @"user_education"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_ethnicity"] )
    {
        builder.userEthnicity = [serverParameters al_stringForKey: @"user_ethnicity"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_gender"] )
    {
        builder.userGender = [serverParameters al_stringForKey: @"user_gender" ];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_marital_status"] )
    {
        builder.userMaritalStatus = [serverParameters al_stringForKey: @"user_marital_status"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_politics"] )
    {
        builder.userPolitics = [serverParameters al_stringForKey: @"user_politics"];
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

+ (MAAdapterError *)toMaxError:(VASErrorInfo *)verizonAdsError
{
    VASCoreError verizonErrorCode = verizonAdsError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( verizonErrorCode )
    {
        case VASCoreErrorAdNotAvailable:
            adapterError = MAAdapterError.noFill;
            break;
        case VASCoreErrorAdFetchFailure:
        case VASCoreErrorUnexpectedServerError:
        case VASCoreErrorBadServerResponseCode:
            adapterError = MAAdapterError.serverError;
            break;
        case VASCoreErrorTimeout:
            adapterError = MAAdapterError.timeout;
            break;
        case VASCoreErrorNotImplemented:
        case VASCoreErrorAdAdapterNotFound:
        case VASCoreErrorAdPrepareFailure:
        case VASCoreErrorWaterfallFailure:
        case VASCoreErrorBidsNotAvailable:
        case VASCoreErrorPluginNotEnabled:
        case VASCoreErrorAdFetchFailureApplicationInBackground:
        case VASCoreErrorEmptyExchangeServerResponse:
            adapterError = MAAdapterError.unspecified;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: verizonErrorCode
               thirdPartySdkErrorMessage: verizonAdsError.localizedDescription];
#pragma clang diagnostic pop
}

- (VASInlineAdSize *)adSizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return [[VASInlineAdSize alloc] initWithWidth: 320 height: 50];
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return [[VASInlineAdSize alloc] initWithWidth: 300 height: 250];
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return [[VASInlineAdSize alloc] initWithWidth: 728 height: 90];
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        
        return [[VASInlineAdSize alloc] initWithWidth: 320 height: 50];
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

- (void)interstitialAdFactory:(VASInterstitialAdFactory *)adFactory didLoadInterstitialAd:(VASInterstitialAd *)interstitialAd
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

- (void)interstitialAdFactory:(VASInterstitialAdFactory *)adFactory didFailWithError:(VASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"Interstitial ad (AdFactory) failed with error: %@", errorInfo.description];
    [self.delegate didFailToLoadInterstitialAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)interstitialAdDidFail:(VASInterstitialAd *)interstitialAd withError:(VASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"Interstitial ad failed with error: %@", errorInfo.description];
    [self.delegate didFailToLoadInterstitialAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)interstitialAdDidShow:(VASInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad shown"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialAdClicked:(VASInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialAdDidLeaveApplication:(VASInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad left application"];
}

- (void)interstitialAdDidClose:(VASInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad closed"];
    [self.delegate didHideInterstitialAd];
}

- (void)interstitialAdEvent:(VASInterstitialAd *)interstitialAd source:(NSString *)source eventId:(NSString *)eventId arguments:(NSDictionary<NSString *, id> *)arguments
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

- (void)interstitialAdFactory:(VASInterstitialAdFactory *)adFactory didLoadInterstitialAd:(VASInterstitialAd *)rewardedAd
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

- (void)interstitialAdFactory:(VASInterstitialAdFactory *)adFactory didFailWithError:(VASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"Rewarded ad (AdFactory) failed with error: %@", errorInfo.description];
    [self.delegate didFailToLoadRewardedAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)interstitialAdDidFail:(VASInterstitialAd *)rewardedAd withError:(VASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"Rewarded ad failed with error: %@", errorInfo.description];
    [self.delegate didFailToLoadRewardedAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)interstitialAdDidShow:(VASInterstitialAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad shown"];
    
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)interstitialAdClicked:(VASInterstitialAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)interstitialAdDidLeaveApplication:(VASInterstitialAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad left application"];
}

- (void)interstitialAdDidClose:(VASInterstitialAd *)rewardedAd
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

- (void)interstitialAdEvent:(VASInterstitialAd *)rewardedAd source:(NSString *)source eventId:(NSString *)eventId arguments:(NSDictionary<NSString *, id> *)arguments
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

- (void)inlineAdFactory:(VASInlineAdFactory *)adFactory didLoadInlineAd:(VASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView loaded"];
    
    // Disable AdView ad refresh by setting the refresh interval to max value.
    inlineAd.refreshInterval = NSUIntegerMax;
    
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

- (void)inlineAdFactory:(VASInlineAdFactory *)adFactory didFailWithError:(VASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"AdView (AdFactory) failed to load with error: %@", errorInfo];
    [self.delegate didFailToLoadAdViewAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)inlineAdDidFail:(VASInlineAdView *)inlineAd withError:(VASErrorInfo *)errorInfo
{
    [self.parentAdapter log: @"AdView failed to load with error: %@", errorInfo];
    [self.delegate didFailToLoadAdViewAdWithError: [ALVerizonAdsMediationAdapter toMaxError: errorInfo]];
}

- (void)inlineAdClicked:(VASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)inlineAdDidLeaveApplication:(VASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView left application"];
}

- (void)inlineAdDidExpand:(VASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView expanded"];
    [self.delegate didExpandAdViewAd];
}

- (void)inlineAdDidCollapse:(VASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView collapsed"];
    [self.delegate didCollapseAdViewAd];
}

- (void)inlineAdDidRefresh:(VASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView refreshed"];
}

- (void)inlineAdDidResize:(VASInlineAdView *)inlineAd
{
    [self.parentAdapter log: @"AdView resized"];
}

- (void)inlineAd:(VASInlineAdView *)inlineAd event:(NSString *)eventId source:(NSString *)source arguments:(NSDictionary<NSString *,id> *)arguments
{
    [self.parentAdapter log: @"AdView event from source: %@ with event ID: %@ and arguments: %@", source, eventId, arguments];
}

@end
