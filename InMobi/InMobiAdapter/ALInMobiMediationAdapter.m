//
//  ALInMobiMediationAdapter.m
//  AppLovinSDK
//
//  Created by Thomas So on 2/9/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALInMobiMediationAdapter.h"
#import <InMobiSDK/InMobiSDK.h>

#define ADAPTER_VERSION @"10.0.1.1"

/**
 * Dedicated delegate object for InMobi AdView ads.
 */
@interface ALInMobiMediationAdapterAdViewDelegate : NSObject<IMBannerDelegate>

@property (nonatomic,   weak) ALInMobiMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * Dedicated delegate object for InMobi interstitial ads.
 */
@interface ALInMobiMediationAdapterInterstitialAdDelegate : NSObject<IMInterstitialDelegate>

@property (nonatomic,   weak) ALInMobiMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * Dedicated delegate object for InMobi rewarded ads.
 */
@interface ALInMobiMediationAdapterRewardedAdDelegate : NSObject<IMInterstitialDelegate>

@property (nonatomic,   weak) ALInMobiMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;

- (instancetype)initWithParentAdapter:(ALInMobiMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface ALInMobiMediationAdapter()

// AdView
@property (nonatomic, strong) IMBanner *adView;
@property (nonatomic, strong) ALInMobiMediationAdapterAdViewDelegate *adViewDelegate;

// Interstitial
@property (nonatomic, strong) IMInterstitial *interstitialAd;
@property (nonatomic, strong) ALInMobiMediationAdapterInterstitialAdDelegate *interstitialAdDelegate;

// Rewarded
@property (nonatomic, strong) IMInterstitial *rewardedAd;
@property (nonatomic, strong) ALInMobiMediationAdapterRewardedAdDelegate *rewardedAdDelegate;

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

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [ALInMobiInitialized compareAndSet: NO update: YES] )
    {
        NSString *accountID = [parameters.serverParameters al_stringForKey: @"account_id"];
        [self log: @"Initializing InMobi SDK with account id: %@...", accountID];
        
        ALInMobiInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSDictionary<NSString *, id> *consentDict = [self consentDictionaryForParameters: parameters];
        [IMSdk initWithAccountID: accountID consentDictionary: consentDict andCompletionHandler:^(NSError * _Nullable error) {
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
        
        IMSDKLogLevel logLevel = [parameters isTesting] ? kIMSDKLogLevelDebug : kIMSDKLogLevelError;
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
    self.adViewDelegate = nil;
    
    self.interstitialAd.delegate = nil;
    self.interstitialAdDelegate = nil;
    
    self.rewardedAd.delegate = nil;
    self.rewardedAdDelegate = nil;
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    if ( MAAdapterInitializationStatusInitializedFailure == ALInMobiInitializationStatus )
    {
        [delegate didFailToCollectSignalWithErrorMessage: @"InMobi SDK initialization failed."];
        return;
    }
    
    NSString *signal = [IMSdk getTokenWithExtras: [self extrasForParameters: parameters] andKeywords: nil];
    [delegate didCollectSignal: signal];
}

#pragma mark - AdView Adapter

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    long long placementId = parameters.thirdPartyAdPlacementIdentifier.longLongValue;
    [self log: @"Loading %@ AdView ad for placement: %lld...", adFormat.label, placementId];
    
    CGRect frame = [self rectFromAdFormat: adFormat];
    self.adView = [[IMBanner alloc] initWithFrame: frame placementId: placementId];
    self.adView.extras = [self extrasForParameters: parameters];
    self.adView.transitionAnimation = UIViewAnimationTransitionNone;
    [self.adView shouldAutoRefresh: NO];
    
    self.adViewDelegate = [[ALInMobiMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.adView.delegate = self.adViewDelegate;
    
    // Update GDPR states
    [IMSdk setPartnerGDPRConsent: [self consentDictionaryForParameters: parameters]];
    
    NSString *bidResponse = parameters.bidResponse;
    if ( [bidResponse al_isValidString] )
    {
        [self.adView load: [bidResponse dataUsingEncoding: NSUTF8StringEncoding]];
    }
    else
    {
        [self.adView load];
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
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
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
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - Helper Methods

- (IMInterstitial *)loadFullscreenAdForPlacementId:(long long)placementId
                                        parameters:(id<MAAdapterResponseParameters>)parameters
                                         andNotify:(id<IMInterstitialDelegate>)delegate
{
    IMInterstitial *interstitial = [[IMInterstitial alloc] initWithPlacementId: placementId delegate: delegate];
    interstitial.extras = [self extrasForParameters: parameters];
    
    // Update GDPR states
    [IMSdk setPartnerGDPRConsent: [self consentDictionaryForParameters: parameters]];
    
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
        IMInterstitialAnimationType animationType = kIMInterstitialAnimationTypeNone;
        if ( [parameters.serverParameters al_containsValueForKey: @"animation_type"] )
        {
            NSString *value = [parameters.serverParameters al_stringForKey: @"animation_type"];
            if ( [@"cover_vertical" al_isEqualToStringIgnoringCase: value] )
            {
                animationType = kIMInterstitialAnimationTypeCoverVertical;
            }
            else if ( [@"flip_horizontal" al_isEqualToStringIgnoringCase: value] )
            {
                animationType = kIMInterstitialAnimationTypeFlipHorizontal;
            }
        }
        
        [interstitial showFromViewController: [ALUtils topViewControllerFromKeyWindow] withAnimation: animationType];
        
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
    
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        consentDict[IM_PARTNER_GDPR_APPLIES] = @"1";

        // Set user consent state. Note: this must be sent as true/false.
        NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
        if ( hasUserConsent )
        {
            consentDict[IM_PARTNER_GDPR_CONSENT_AVAILABLE] = hasUserConsent.boolValue ? @"true" : @"false";
        }
    }
    else if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateDoesNotApply )
    {
        consentDict[IM_PARTNER_GDPR_APPLIES] = @"0";
    }
    
    return consentDict;
}

- (NSDictionary<NSString *, id> *)extrasForParameters:(id<MAAdapterParameters>)parameters
{
    NSMutableDictionary *extras = [@{@"tp"     : @"c_applovin",
                                     @"tp-ver" : [ALSdk version]} mutableCopy];
    
    NSNumber *isAgeRestrictedUser = [self privacySettingForSelector: @selector(isAgeRestrictedUser) fromParameters: parameters];
    if ( isAgeRestrictedUser )
    {
        [extras setObject: isAgeRestrictedUser forKey: @"coppa"];
    }
    
    return extras;
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

+ (MAAdapterError *)toMaxError:(IMRequestStatus *)inMobiError
{
    IMStatusCode inMobiErrorCode = inMobiError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( inMobiErrorCode )
    {
        case kIMStatusCodeNetworkUnReachable:
            adapterError = MAAdapterError.noConnection;
            break;
        case kIMStatusCodeNoFill:
            adapterError = MAAdapterError.noFill;
            break;
        case kIMStatusCodeRequestInvalid:
            adapterError = MAAdapterError.badRequest;
            break;
        case kIMStatusCodeRequestPending:
        case kIMStatusCodeMultipleLoadsOnSameInstance:
        case kIMStatusCodeAdActive:
        case kIMStatusCodeEarlyRefreshRequest:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case kIMStatusCodeRequestTimedOut:
            adapterError = MAAdapterError.timeout;
            break;
        case kIMStatusCodeInternalError:
        case kIMStatusCodeDroppingNetworkRequest:
            adapterError = MAAdapterError.internalError;
            break;
        case kIMStatusCodeServerError:
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
    
    // InMobi track impressions in the `bannerDidFinishLoading:` callback
    [self.delegate didDisplayAdViewAd];
}

- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error
{
    [self.parentAdapter log: @"AdView failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALInMobiMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
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
    [self.parentAdapter log: @"Interstitial failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALInMobiMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error
{
    [self.parentAdapter log: @"Interstitial failed to display with error: %@", error];
    
    MAAdapterError *adapterError = [ALInMobiMediationAdapter toMaxError: error];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial will show"];
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial did show"];
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
    [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALInMobiMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error
{
    [self.parentAdapter log: @"Rewarded ad failed to display with error: %@", error];
    
    MAAdapterError *adapterError = [ALInMobiMediationAdapter toMaxError: error];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad will show"];
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad did show"];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial
{
    [self.delegate didCompleteRewardedAdVideo];
    
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
