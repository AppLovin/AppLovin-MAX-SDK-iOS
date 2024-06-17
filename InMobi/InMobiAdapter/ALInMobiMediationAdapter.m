//
//  ALInMobiMediationAdapter.m
//  AppLovinSDK
//
//  Created by Thomas So on 2/9/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALInMobiMediationAdapter.h"
#import <InMobiSDK/InMobiSDK.h>

#define ADAPTER_VERSION @"10.7.4.0"

/**
 * Dedicated delegate object for InMobi AdView ads.
 */
@interface ALInMobiMediationAdapterAdViewDelegate : NSObject <IMBannerDelegate>

@property (nonatomic,   weak) ALInMobiMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * Dedicated delegate object for InMobi interstitial ads.
 */
@interface ALInMobiMediationAdapterInterstitialAdDelegate : NSObject <IMInterstitialDelegate>

@property (nonatomic,   weak) ALInMobiMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * Dedicated delegate object for InMobi rewarded ads.
 */
@interface ALInMobiMediationAdapterRewardedAdDelegate : NSObject <IMInterstitialDelegate>

@property (nonatomic,   weak) ALInMobiMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * Dedicated delegate object for InMobi native AdView ads.
 */
@interface ALInMobiMediationAdapterNativeAdViewDelegate : NSObject <IMNativeDelegate>

@property (nonatomic,   weak) ALInMobiMediationAdapter *parentAdapter;
@property (nonatomic,   weak) MAAdFormat *format;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@property (nonatomic,   copy) NSString *placementId;

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * Dedicated delegate object for InMobi native ads.
 */
@interface ALInMobiMediationAdapterNativeAdDelegate : NSObject <IMNativeDelegate>

@property (nonatomic,   weak) ALInMobiMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) NSString *placementId;

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface MAInMobiNativeAd : MANativeAd
@property (nonatomic, weak) ALInMobiMediationAdapter *parentAdapter;
@property (nonatomic, weak) MAAdFormat *adFormat;
- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)format
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALInMobiMediationAdapter ()

// AdView
@property (nonatomic, strong) IMBanner *adView;
@property (nonatomic, strong) ALInMobiMediationAdapterAdViewDelegate *adViewDelegate;

// Interstitial
@property (nonatomic, strong) IMInterstitial *interstitialAd;
@property (nonatomic, strong) ALInMobiMediationAdapterInterstitialAdDelegate *interstitialAdDelegate;

// Rewarded
@property (nonatomic, strong) IMInterstitial *rewardedAd;
@property (nonatomic, strong) ALInMobiMediationAdapterRewardedAdDelegate *rewardedAdDelegate;

// Native
@property (nonatomic, strong) IMNative *nativeAd;
@property (nonatomic, strong) ALInMobiMediationAdapterNativeAdDelegate *nativeAdDelegate;

// Native AdView
@property (nonatomic, strong) MANativeAd *maxNativeAdViewAd;
@property (nonatomic, strong) ALInMobiMediationAdapterNativeAdViewDelegate *nativeAdViewDelegate;

@end

@implementation ALInMobiMediationAdapter
static ALAtomicBoolean              *ALInMobiInitialized;
static MAAdapterInitializationStatus ALInMobiInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    ALInMobiInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (NSString *)SDKVersion
{
    return [IMSdk getVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALInMobiInitialized compareAndSet: NO update: YES] )
    {
        NSString *accountID = [parameters.serverParameters al_stringForKey: @"account_id"];
        [self log: @"Initializing InMobi SDK with account id: %@...", accountID];
        
        // API docs - "Debug mode is only for simulators, wont work on actual devices"
        [IMUnifiedIdService enableDebugMode: [ALUtils isSimulator] && [parameters isTesting]];
        
        ALInMobiInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSDictionary<NSString *, id> *consentDict = [self consentDictionaryForParameters: parameters];
        [IMSdk initWithAccountID: accountID consentDictionary: consentDict andCompletionHandler:^(NSError *_Nullable error) {
            if ( error )
            {
                [self log: @"InMobi SDK initialization failed with error: %@", error];
                
                ALInMobiInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALInMobiInitializationStatus, error.description);
            }
            else
            {
                [self log: @"InMobi SDK successfully initialized"];
                
                ALInMobiInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
                completionHandler(ALInMobiInitializationStatus, nil);
            }
        }];
        
        IMSDKLogLevel logLevel = [parameters isTesting] ? IMSDKLogLevelDebug : IMSDKLogLevelError;
        [IMSdk setLogLevel: logLevel];
    }
    else
    {
        [self log: @"InMobi SDK already initialized."];
        completionHandler(ALInMobiInitializationStatus, nil);
    }
}

- (void)destroy
{
    [self.adView cancel];
    self.adView.delegate = nil;
    self.adViewDelegate.delegate = nil;
    self.adViewDelegate = nil;
    
    [self.interstitialAd cancel];
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdDelegate.delegate = nil;
    self.interstitialAdDelegate = nil;
    
    [self.rewardedAd cancel];
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdDelegate.delegate = nil;
    self.rewardedAdDelegate = nil;
    
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdDelegate.delegate = nil;
    self.nativeAdDelegate = nil;
    
    self.maxNativeAdViewAd = nil;
    self.nativeAdViewDelegate.delegate = nil;
    self.nativeAdViewDelegate = nil;
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    if ( MAAdapterInitializationStatusInitializedFailure == ALInMobiInitializationStatus )
    {
        [delegate didFailToCollectSignalWithErrorMessage: @"InMobi SDK initialization failed."];
        return;
    }
    
    [self updatePrivacySettingsWithParameters: parameters];
    
    NSString *signal = [IMSdk getTokenWithExtras: [self extrasForParameters: parameters] andKeywords: nil];
    [delegate didCollectSignal: signal];
}

#pragma mark - AdView Adapter

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    long long placementId = parameters.thirdPartyAdPlacementIdentifier.longLongValue;
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    [self log: @"Loading%@%@ AdView ad for placement: %lld...", isNative ? @" native " : @" ", adFormat.label, placementId];
    
    [self updatePrivacySettingsWithParameters: parameters];
    
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    
    if ( isNative )
    {
        self.nativeAdViewDelegate = [[ALInMobiMediationAdapterNativeAdViewDelegate alloc] initWithParentAdapter: self
                                                                                                         format: adFormat
                                                                                                     parameters: parameters
                                                                                                      andNotify: delegate];
        self.nativeAd = [[IMNative alloc] initWithPlacementId: placementId delegate: self.nativeAdViewDelegate];
        self.nativeAd.extras = [self extrasForParameters: parameters];
        
        if ( isBiddingAd )
        {
            [self.nativeAd load: [bidResponse dataUsingEncoding: NSUTF8StringEncoding]];
        }
        else
        {
            [self.nativeAd load];
        }
    }
    else
    {
        CGRect frame = [self rectFromAdFormat: adFormat];
        self.adView = [[IMBanner alloc] initWithFrame: frame placementId: placementId];
        self.adView.extras = [self extrasForParameters: parameters];
        self.adView.transitionAnimation = UIViewAnimationTransitionNone;
        [self.adView shouldAutoRefresh: NO];
        
        self.adViewDelegate = [[ALInMobiMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        self.adView.delegate = self.adViewDelegate;
        
        if ( isBiddingAd )
        {
            [self.adView load: [bidResponse dataUsingEncoding: NSUTF8StringEncoding]];
        }
        else
        {
            [self.adView load];
        }
    }
}

#pragma mark - Interstitial Adapter

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    long long placementId = parameters.thirdPartyAdPlacementIdentifier.longLongValue;
    [self log: @"Loading interstitial ad for placement: %lld...", placementId];
    
    self.interstitialAdDelegate = [[ALInMobiMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [self loadFullscreenAdForPlacementId: placementId
                                                    parameters: parameters
                                                     andNotify: self.interstitialAdDelegate];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    BOOL success = [self showFullscreenAd: self.interstitialAd forParameters: parameters];
    if ( !success )
    {
        [self log: @"Interstitial ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205
                                                                             errorString: @"Ad Display Failed"
                                                                  thirdPartySdkErrorCode: 0
                                                               thirdPartySdkErrorMessage: @"Interstitial ad not ready"]];
#pragma clang diagnostic pop
    }
}

#pragma mark - Rewarded Adapter

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    long long placementId = parameters.thirdPartyAdPlacementIdentifier.longLongValue;
    [self log: @"Loading rewarded ad for placement: %lld...", placementId];
    
    self.rewardedAdDelegate = [[ALInMobiMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd = [self loadFullscreenAdForPlacementId: placementId
                                                parameters: parameters
                                                 andNotify: self.rewardedAdDelegate];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    // Configure reward from server.
    [self configureRewardForParameters: parameters];
    
    BOOL success = [self showFullscreenAd: self.rewardedAd forParameters: parameters];
    if ( !success )
    {
        [self log: @"Rewarded ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithCode: -4205
                                                                         errorString: @"Ad Display Failed"
                                                              thirdPartySdkErrorCode: 0
                                                           thirdPartySdkErrorMessage: @"Rewarded ad not ready"]];
#pragma clang diagnostic pop
    }
}

#pragma mark - Native Adapter

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    long long placementId = parameters.thirdPartyAdPlacementIdentifier.longLongValue;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    
    [self log: @"Loading %@native ad for placement: %lld...", ( isBiddingAd ? @"bidding " : @"" ), placementId];
    
    self.nativeAdDelegate = [[ALInMobiMediationAdapterNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                         parameters: parameters
                                                                                          andNotify: delegate];
    self.nativeAd = [[IMNative alloc] initWithPlacementId: placementId delegate: self.nativeAdDelegate];
    self.nativeAd.extras = [self extrasForParameters: parameters];
    
    [self updatePrivacySettingsWithParameters: parameters];
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        [self.nativeAd load: [bidResponse dataUsingEncoding: NSUTF8StringEncoding]];
    }
    else
    {
        [self.nativeAd load];
    }
}

#pragma mark - Helper Methods

- (IMInterstitial *)loadFullscreenAdForPlacementId:(long long)placementId
                                        parameters:(id<MAAdapterResponseParameters>)parameters
                                         andNotify:(id<IMInterstitialDelegate>)delegate
{
    IMInterstitial *interstitial = [[IMInterstitial alloc] initWithPlacementId: placementId delegate: delegate];
    interstitial.extras = [self extrasForParameters: parameters];
    
    [self updatePrivacySettingsWithParameters: parameters]; 
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        [interstitial load: [bidResponse dataUsingEncoding: NSUTF8StringEncoding]];
    }
    else
    {
        [interstitial load];
    }
    
    return interstitial;
}

- (BOOL)showFullscreenAd:(IMInterstitial *)interstitial forParameters:(id<MAAdapterResponseParameters>)parameters
{
    if ( [interstitial isReady] )
    {
        IMInterstitialAnimationType animationType = IMInterstitialAnimationTypeAsNone;
        if ( [parameters.serverParameters al_containsValueForKey: @"animation_type"] )
        {
            NSString *value = [parameters.serverParameters al_stringForKey: @"animation_type"];
            if ( [@"cover_vertical" al_isEqualToStringIgnoringCase: value] )
            {
                animationType = IMInterstitialAnimationTypeCoverVertical;
            }
            else if ( [@"flip_horizontal" al_isEqualToStringIgnoringCase: value] )
            {
                animationType = IMInterstitialAnimationTypeFlipHorizontal;
            }
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
        
        [interstitial showFrom: presentingViewController with: animationType];
        
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSDictionary<NSString *, id> *)consentDictionaryForParameters:(id<MAAdapterParameters>)parameters
{
    NSMutableDictionary<NSString *, id> *consentDict = [NSMutableDictionary dictionaryWithCapacity: 2];
    
    // Set user consent state. Note: this must be sent as true/false.
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent != nil )
    {
        consentDict[IMCommonConstants.IM_PARTNER_GDPR_CONSENT_AVAILABLE] = hasUserConsent.boolValue ? @"true" : @"false";
    }
    
    return consentDict;
}

- (NSDictionary<NSString *, id> *)extrasForParameters:(id<MAAdapterParameters>)parameters
{
    NSMutableDictionary *extras = [@{@"tp"     : @"c_applovin",
                                     @"tp-ver" : [ALSdk version]} mutableCopy];
    
    NSNumber *isAgeRestrictedUser = [parameters isAgeRestrictedUser];
    if ( isAgeRestrictedUser != nil )
    {
        [extras setObject: isAgeRestrictedUser forKey: @"coppa"];
    }
    
    return extras;
}

- (void)updatePrivacySettingsWithParameters:(id<MAAdapterParameters>)parameters
{
    [IMSdk setPartnerGDPRConsent: [self consentDictionaryForParameters: parameters]];
    
    NSNumber *isDoNotSell = [parameters isDoNotSell];
    if ( isDoNotSell != nil )
    {
        [IMPrivacyCompliance setDoNotSell: isDoNotSell.boolValue];
    }
}

+ (MAAdapterError *)toMaxError:(IMRequestStatus *)inMobiError
{
    IMStatusCode inMobiErrorCode = inMobiError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( inMobiErrorCode )
    {
        case IMStatusCodeNetworkUnReachable:
            adapterError = MAAdapterError.noConnection;
            break;
        case IMStatusCodeNoFill:
            adapterError = MAAdapterError.noFill;
            break;
        case IMStatusCodeSdkNotInitialised:
            adapterError = MAAdapterError.notInitialized;
            break;
        case IMStatusCodeRequestInvalid:
        case IMStatusCodeInvalidBannerframe:
            adapterError = MAAdapterError.badRequest;
            break;
        case IMStatusCodeIncorrectPlacementID:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case IMStatusCodeRequestPending:
        case IMStatusCodeMultipleLoadsOnSameInstance:
        case IMStatusCodeAdActive:
        case IMStatusCodeEarlyRefreshRequest:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case IMStatusCodeRequestTimedOut:
            adapterError = MAAdapterError.timeout;
            break;
        case IMStatusCodeInternalError:
        case IMStatusCodeDroppingNetworkRequest:
        case IMStatusCodeInvalidAudioFrame:
        case IMStatusCodeAudioDisabled:
        case IMStatusCodeAudioDeviceVolumeLow:
            adapterError = MAAdapterError.internalError;
            break;
        case IMStatusCodeServerError:
            adapterError = MAAdapterError.serverError;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: inMobiErrorCode
               thirdPartySdkErrorMessage: inMobiError.localizedDescription];
#pragma clang diagnostic pop
}

- (CGRect)rectFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return CGRectMake(0, 0, 320, 50);
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return CGRectMake(0, 0, 728, 90);
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return CGRectMake(0, 0, 300, 250);
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        
        return CGRectMake(0, 0, 320, 50);
    }
}

- (NSArray<UIView *> *)clickableViewsForNativeAdView:(MANativeAdView *)maxNativeAdView
{
    // We don't add CTA button here to avoid duplicate click callbacks
    NSMutableArray *clickableViews = [NSMutableArray array];
    if ( maxNativeAdView.titleLabel )
    {
        [clickableViews addObject: maxNativeAdView.titleLabel];
    }
    if ( maxNativeAdView.advertiserLabel )
    {
        [clickableViews addObject: maxNativeAdView.advertiserLabel];
    }
    if ( maxNativeAdView.bodyLabel )
    {
        [clickableViews addObject: maxNativeAdView.bodyLabel];
    }
    if ( maxNativeAdView.callToActionButton )
    {
        [clickableViews addObject: maxNativeAdView.callToActionButton];
    }
    if ( maxNativeAdView.iconImageView )
    {
        [clickableViews addObject: maxNativeAdView.iconImageView];
    }
    
    return clickableViews;
}

@end

@implementation ALInMobiMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)bannerDidFinishLoading:(IMBanner *)banner
{
    [self.parentAdapter log: @"AdView loaded"];
    
    // Passing extra info such as creative id supported in 6.15.0+
    if ( ALSdk.versionCode >= 6150000 && [banner.creativeId al_isValidString] )
    {
        [self.delegate performSelector: @selector(didLoadAdForAdView:withExtraInfo:)
                            withObject: banner
                            withObject: @{@"creative_id" : banner.creativeId}];
    }
    else
    {
        [self.delegate didLoadAdForAdView: banner];
    }
}

- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error
{
    MAAdapterError *adapterError = [ALInMobiMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"AdView failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)bannerAdImpressed:(IMBanner *)banner
{
    [self.parentAdapter log: @"AdView impression tracked"];
    [self.delegate didDisplayAdViewAd];
}

- (void)banner:(IMBanner *)banner didInteractWithParams:(NSDictionary *)params
{
    [self.parentAdapter log: @"AdView clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)bannerDidPresentScreen:(IMBanner *)banner
{
    [self.parentAdapter log: @"AdView expanded"]; // Pretty much StoreKit presented
    [self.delegate didExpandAdViewAd];
}

- (void)bannerDidDismissScreen:(IMBanner *)banner
{
    [self.parentAdapter log: @"AdView collapse"]; // Pretty much StoreKit dismissed
    [self.delegate didCollapseAdViewAd];
}

- (void)userWillLeaveApplicationFromBanner:(IMBanner *)banner
{
    [self.parentAdapter log: @"AdView will leave application"];
}

@end

@implementation ALInMobiMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitial:(IMInterstitial *)interstitial didReceiveWithMetaInfo:(IMAdMetaInfo *)metaInfo
{
    // Assets are not done caching
    [self.parentAdapter log: @"Interstitial request succeeded"];
}

- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial loaded"];
    
    // Passing extra info such as creative id supported in 6.15.0+
    if ( ALSdk.versionCode >= 6150000 && [interstitial.creativeId al_isValidString] )
    {
        [self.delegate performSelector: @selector(didLoadInterstitialAdWithExtraInfo:)
                            withObject: @{@"creative_id" : interstitial.creativeId}];
    }
    else
    {
        [self.delegate didLoadInterstitialAd];
    }
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error
{
    MAAdapterError *adapterError = [ALInMobiMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error
{
    [self.parentAdapter log: @"Interstitial failed to display with error: %@", error];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *adapterError = [MAAdapterError errorWithCode: -4205
                                                     errorString: @"Ad Display Failed"
                                          thirdPartySdkErrorCode: error.code
                                       thirdPartySdkErrorMessage: error.localizedDescription];
#pragma clang diagnostic pop
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial will show"];
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial did show"];
}

- (void)interstitialAdImpressed:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial impression tracked"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial will leave application"];
}

@end

@implementation ALInMobiMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitial:(IMInterstitial *)interstitial didReceiveWithMetaInfo:(IMAdMetaInfo *)metaInfo
{
    // Assets are not done caching
    [self.parentAdapter log: @"Rewarded ad request succeeded"];
}

- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    
    // Passing extra info such as creative id supported in 6.15.0+
    if ( ALSdk.versionCode >= 6150000 && [interstitial.creativeId al_isValidString] )
    {
        [self.delegate performSelector: @selector(didLoadRewardedAdWithExtraInfo:)
                            withObject: @{@"creative_id" : interstitial.creativeId}];
    }
    else
    {
        [self.delegate didLoadRewardedAd];
    }
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error
{
    MAAdapterError *adapterError = [ALInMobiMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error
{
    [self.parentAdapter log: @"Rewarded ad failed to display with error: %@", error];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *adapterError = [MAAdapterError errorWithCode: -4205
                                                     errorString: @"Ad Display Failed"
                                          thirdPartySdkErrorCode: error.code
                                       thirdPartySdkErrorMessage: error.localizedDescription];
#pragma clang diagnostic pop
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad will show"];
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad did show"];
}

- (void)interstitialAdImpressed:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad impression tracked"];
    [self.delegate didDisplayRewardedAd];
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial
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

- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad will leave application"];
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards
{
    [self.parentAdapter log: @"Rewarded ad granted reward"];
    self.grantedReward = YES;
}

@end

@implementation ALInMobiMediationAdapterNativeAdViewDelegate

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.format = format;
        self.serverParameters = parameters.serverParameters;
        self.delegate = delegate;
        self.placementId = parameters.thirdPartyAdPlacementIdentifier;
    }
    return self;
}

- (void)nativeDidFinishLoading:(IMNative *)nativeAd
{
    if ( !nativeAd )
    {
        [self.parentAdapter log: @"Native %@ ad failed to load: no fill", self.format.label];
        [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
        
        return;
    }
    
    if ( ![nativeAd.adTitle al_isValidString] )
    {
        [self.parentAdapter e: @"Native %@ ad (%@) does not have required assets.", self.format.label, self.placementId];
        [self.delegate didFailToLoadAdViewAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    [self.parentAdapter log: @"Native %@ ad loaded: %@", self.format.label, self.placementId];
    
    dispatchOnMainQueue(^{
        
        // Need a strong reference of MAInMobiNativeAd in parentAdapter to make gesture recognizers work
        self.parentAdapter.maxNativeAdViewAd = [[MAInMobiNativeAd alloc] initWithParentAdapter: self.parentAdapter
                                                                                      adFormat: self.format
                                                                                  builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = nativeAd.adTitle;
            builder.body = nativeAd.adDescription;
            builder.callToAction = nativeAd.adCtaText;
            builder.icon = [[MANativeAdImage alloc] initWithImage: nativeAd.adIcon];
            builder.mediaView = [[UIView alloc] init];
        }];
        
        // Backend will pass down `vertical` as the template to indicate using a vertical native template
        MANativeAdView *maxNativeAdView;
        NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
        if ( [templateName containsString: @"vertical"] )
        {
            if ( ALSdk.versionCode < 6140500 )
            {
                [self.parentAdapter log: @"Vertical native banners are only supported on MAX SDK 6.14.5 and above. Default native template will be used."];
            }
            
            if ( [templateName isEqualToString: @"vertical"] )
            {
                NSString *verticalTemplateName = ( self.format == MAAdFormat.leader ) ? @"vertical_leader_template" : @"vertical_media_banner_template";
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: self.parentAdapter.maxNativeAdViewAd withTemplate: verticalTemplateName];
            }
            else
            {
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: self.parentAdapter.maxNativeAdViewAd withTemplate: templateName];
            }
        }
        else if ( ALSdk.versionCode < 6140500 )
        {
            maxNativeAdView = [MANativeAdView nativeAdViewFromAd: self.parentAdapter.maxNativeAdViewAd withTemplate: [templateName al_isValidString] ? templateName : @"no_body_banner_template"];
        }
        else
        {
            maxNativeAdView = [MANativeAdView nativeAdViewFromAd: self.parentAdapter.maxNativeAdViewAd withTemplate: [templateName al_isValidString] ? templateName : @"media_banner_template"];
        }
        
        [self.parentAdapter.maxNativeAdViewAd prepareForInteractionClickableViews: [self.parentAdapter clickableViewsForNativeAdView: maxNativeAdView] withContainer: maxNativeAdView];
        
        if ( ALSdk.versionCode >= 6150000 && [nativeAd.creativeId al_isValidString] )
        {
            NSDictionary *extraInfo = [nativeAd.creativeId al_isValidString] ? @{@"creative_id" : nativeAd.creativeId} : nil;
            [self.delegate didLoadAdForAdView: maxNativeAdView withExtraInfo: extraInfo];
        }
        else
        {
            [self.delegate didLoadAdForAdView: maxNativeAdView];
        }
    });
}

- (void)native:(IMNative *)native didFailToLoadWithError:(IMRequestStatus *)error
{
    MAAdapterError *adapterError = [ALInMobiMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native %@ ad failed to load with error: %@", self.format.label, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)nativeWillPresentScreen:(IMNative *)native
{
    [self.parentAdapter log: @"Native %@ ad will present", self.format.label];
}

- (void)nativeDidPresentScreen:(IMNative *)native
{
    [self.parentAdapter log: @"Native %@ ad did present", self.format.label];
}

- (void)nativeWillDismissScreen:(IMNative *)native
{
    [self.parentAdapter log: @"Native %@ ad will dismiss the screen", self.format.label];
}

- (void)nativeDidDismissScreen:(IMNative *)native
{
    [self.parentAdapter log: @"Native %@ ad did dismiss the screen", self.format.label];
}

- (void)userWillLeaveApplicationFromNative:(IMNative *)native
{
    [self.parentAdapter log: @"Native %@ ad will leave the application", self.format.label];
}

- (void)nativeAdImpressed:(IMNative *)native
{
    [self.parentAdapter log: @"Native %@ ad did show", self.format.label];
    [self.delegate didDisplayAdViewAdWithExtraInfo: nil];
}

- (void)native:(IMNative *)native didInteractWithParams:(NSDictionary *)params
{
    [self.parentAdapter log: @"Native %@ ad clicked", self.format.label];
    [self.delegate didClickAdViewAd];
}

- (void)nativeDidFinishPlayingMedia:(IMNative *)native
{
    [self.parentAdapter log: @"Native %@ ad did finish playing media", self.format.label];
}

- (void)userDidSkipPlayingMediaFromNative:(IMNative *)native
{
    [self.parentAdapter log: @"Native %@ ad user skipped media", self.format.label];
}

- (void)native:(IMNative *)native adAudioStateChanged:(BOOL)audioStateMuted
{
    [self.parentAdapter log: @"Native %@ ad audio state changed", self.format.label];
}

@end

@implementation ALInMobiMediationAdapterNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.serverParameters = parameters.serverParameters;
        self.delegate = delegate;
        self.placementId = parameters.thirdPartyAdPlacementIdentifier;
    }
    return self;
}

- (void)nativeDidFinishLoading:(IMNative *)nativeAd
{
    if ( !nativeAd )
    {
        [self.parentAdapter log: @"Native ad failed to load: no fill"];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
        
        return;
    }
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    if ( isTemplateAd && ![nativeAd.adTitle al_isValidString] )
    {
        [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    [self.parentAdapter log: @"Native ad loaded: %@", self.placementId];
    
    dispatchOnMainQueue(^{
        
        MANativeAd *maxNativeAd = [[MAInMobiNativeAd alloc] initWithParentAdapter: self.parentAdapter
                                                                         adFormat: MAAdFormat.native
                                                                     builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = nativeAd.adTitle;
            builder.body = nativeAd.adDescription;
            builder.callToAction = nativeAd.adCtaText;
            builder.icon = [[MANativeAdImage alloc] initWithImage: nativeAd.adIcon];
            builder.mediaView = [[UIView alloc] init];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            // Introduced in 11.7.0
            if ( [builder respondsToSelector: @selector(setStarRating:)] )
            {
                // NOTE: `nativeAd.adRating` is an NSString(ex: @"1.0"). Using .doubleValue any invalid value, 0 -> 0.0
                [builder performSelector: @selector(setStarRating:) withObject: @(nativeAd.adRating.doubleValue)];
            }
#pragma clang diagnostic pop
        }];
        
        NSDictionary *extraInfo = [nativeAd.creativeId al_isValidString] ? @{@"creative_id" : nativeAd.creativeId} : nil;
        [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: extraInfo];
    });
}

- (void)native:(IMNative *)native didFailToLoadWithError:(IMRequestStatus *)error
{
    MAAdapterError *adapterError = [ALInMobiMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeWillPresentScreen:(IMNative *)native
{
    [self.parentAdapter log: @"Native ad will present"];
}

- (void)nativeDidPresentScreen:(IMNative *)native
{
    [self.parentAdapter log: @"Native ad did present"];
}

- (void)nativeWillDismissScreen:(IMNative *)native
{
    [self.parentAdapter log: @"Native ad will dismiss the screen"];
}

- (void)nativeDidDismissScreen:(IMNative *)native
{
    [self.parentAdapter log: @"Native ad did dismiss the screen"];
}

- (void)userWillLeaveApplicationFromNative:(IMNative *)native
{
    [self.parentAdapter log: @"Native ad will leave the application"];
}

- (void)nativeAdImpressed:(IMNative *)native
{
    [self.parentAdapter log: @"Native ad did show"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)native:(IMNative *)native didInteractWithParams:(NSDictionary *)params
{
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)nativeDidFinishPlayingMedia:(IMNative *)native
{
    [self.parentAdapter log: @"Native ad did finish playing media"];
}

- (void)userDidSkipPlayingMediaFromNative:(IMNative *)native
{
    [self.parentAdapter log: @"Native ad user skipped media"];
}

- (void)native:(IMNative *)native adAudioStateChanged:(BOOL)audioStateMuted
{
    [self.parentAdapter log: @"Native ad audio state changed"];
}

@end

@implementation MAInMobiNativeAd

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)format
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: format builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.adFormat = format;
    }
    return self;
}

- (void)prepareViewForInteraction:(MANativeAdView *)maxNativeAdView
{
    [self prepareForInteractionClickableViews: [self.parentAdapter clickableViewsForNativeAdView: maxNativeAdView] withContainer: maxNativeAdView];
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container
{
    IMNative *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    UIView *mediaView = self.mediaView;
    CGFloat primaryViewWidth = CGRectGetWidth(mediaView.frame);
    
    // NOTE: InMobi's SDK returns primary view with a height that does not fit a banner, so scale media smaller specifically for horizontal banners (and not leaders/MRECs)
    if ( self.adFormat == MAAdFormat.banner && CGRectGetWidth(mediaView.frame) > CGRectGetHeight(mediaView.frame) )
    {
        primaryViewWidth = CGRectGetHeight(mediaView.frame) * 16 / 9;
    }
    
    UIView *primaryView = [self.parentAdapter.nativeAd primaryViewOfWidth: primaryViewWidth];
    UIView *inMobiContentView = primaryView.subviews[0];
    
    [mediaView addSubview: primaryView];
    // Pin to super view to make it clickable and centered
    [primaryView al_pinToSuperview];
    [inMobiContentView al_pinToSuperview];
    
    // InMobi does not provide a method to bind views with landing url, so we need to do it manually
    for ( UIView *clickableView in clickableViews )
    {
        UITapGestureRecognizer *clickGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(clickNativeView)];
        [clickableView addGestureRecognizer: clickGesture];
    }
    
    return YES;
}

- (void)clickNativeView
{
    [self.parentAdapter log: @"Native ad clicked from gesture recognizer"];
    
    [self.parentAdapter.nativeAd reportAdClickAndOpenLandingPage];
}

@end
