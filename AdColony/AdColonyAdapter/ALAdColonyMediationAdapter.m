//
//  ALAdColonyMediationAdapter.m
//  AppLovinSDK
//
//  Created by Thomas So on 2/16/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALAdColonyMediationAdapter.h"
#import <AdColony/AdColony.h>

#define ADAPTER_VERSION @"4.8.0.0.0"

@interface ALAdColonyInterstitialDelegate : NSObject<AdColonyInterstitialDelegate>
@property (nonatomic,   weak) ALAdColonyMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALAdColonyMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALAdColonyRewardedAdDelegate : NSObject<AdColonyInterstitialDelegate>
@property (nonatomic,   weak) ALAdColonyMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALAdColonyMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALAdColonyMediationAdapterAdViewDelegate : NSObject<AdColonyAdViewDelegate>
@property (nonatomic,   weak) ALAdColonyMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALAdColonyMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALAdColonyMediationAdapter()

// Initialize the SDK only once
@property (atomic, assign) BOOL initialized;

// Interstitial
@property (nonatomic, strong) AdColonyInterstitial *loadedInterstitialAd;
@property (nonatomic, strong) ALAdColonyInterstitialDelegate *interstitialAdDelegate;

// Rewarded
@property (nonatomic, strong) AdColonyInterstitial *loadedRewardedAd;
@property (nonatomic, strong) ALAdColonyRewardedAdDelegate *rewardedAdDelegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;

// Banner/MREC
@property (nonatomic, strong) AdColonyAdView *loadedAdViewAd;
@property (nonatomic, strong) ALAdColonyMediationAdapterAdViewDelegate *adViewDelegate;

@end

@implementation ALAdColonyMediationAdapter
static ALAtomicBoolean              *ALAdColonyInitialized;
static MAAdapterInitializationStatus ALAdColonyInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALAdColonyInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (NSString *)SDKVersion
{
    return [AdColony getSDKVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [ALAdColonyInitialized compareAndSet: NO update: YES] )
    {
        ALAdColonyInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *appID = [parameters.serverParameters al_stringForKey: @"app_id"];
        [self log: @"Initializing AdColony SDK with app id: %@...", appID];
        
        NSArray<NSString *> *zoneIDs = [parameters.serverParameters al_arrayForKey: @"zone_ids"];
        AdColonyAppOptions *options = [self optionsFromParameters: parameters];
        
        [AdColony configureWithAppID: appID zoneIDs: zoneIDs options: options completion:^(NSArray<AdColonyZone *> *zones) {
            
            [self log: @"AdColony SDK initialized with zones: %@", [self retrieveRawZoneIDs: zones]];
            
            if ( zones )
            {
                ALAdColonyInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
                completionHandler(ALAdColonyInitializationStatus, nil);
            }
            else
            {
                ALAdColonyInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALAdColonyInitializationStatus, @"no_zones");
            }
        }];
    }
    else
    {
        completionHandler(ALAdColonyInitializationStatus, nil);
    }
}

- (void)destroy
{
    if ( self.loadedRewardedAd )
    {
        AdColonyZone *zone = [AdColony zoneForID: self.loadedRewardedAd.zoneID];
        [zone setReward: nil];
    }
    
    self.loadedInterstitialAd = nil;
    self.interstitialAdDelegate = nil;
    
    self.loadedRewardedAd = nil;
    self.rewardedAdDelegate = nil;
    
    [self.loadedAdViewAd destroy];
    self.loadedAdViewAd = nil;
    self.adViewDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [AdColony collectSignals:^(NSString *token, NSError *error) {
        if ( error )
        {
            [self log: @"Signal collection failed with error: %@", error];
            [delegate didFailToCollectSignalWithErrorMessage: error.localizedDescription];
            
            return;
        }
        
        [self log: @"Signal collection successful"];
        [delegate didCollectSignal: token];
    }];
}

#pragma mark - Interstitial Adapter

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *zoneId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@interstitial ad for zone id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", zoneId];
    
    [AdColony setAppOptions: [self optionsFromParameters: parameters]];
    
    self.interstitialAdDelegate = [[ALAdColonyInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    [AdColony requestInterstitialInZone: zoneId options: nil andDelegate: self.interstitialAdDelegate];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( !self.loadedInterstitialAd )
    {
        [self log: @"Interstitial ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
        
        return;
    }
    
    if ( [self.loadedInterstitialAd expired] )
    {
        [self log: @"Interstitial ad is expired"];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adExpiredError];
        
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
    
    BOOL success = [self.loadedInterstitialAd showWithPresentingViewController: presentingViewController];
    if ( !success )
    {
        [self log: @"Interstitial ad failed to display"];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.unspecified];
    }
}

#pragma mark - Rewarded Adapter

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *zoneId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@rewarded ad for zone id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", zoneId];
    
    [AdColony setAppOptions: [self optionsFromParameters: parameters]];
    
    self.rewardedAdDelegate = [[ALAdColonyRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    [AdColony requestInterstitialInZone: zoneId options: nil andDelegate: self.rewardedAdDelegate];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( !self.loadedRewardedAd )
    {
        [self log: @"Rewarded ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
        
        return;
    }
    
    if ( [self.loadedRewardedAd expired] )
    {
        [self log: @"Rewarded ad is expired"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adExpiredError];
        
        return;
    }
    
    [self configureRewardForParameters: parameters];
    
    AdColonyZone *zone = [AdColony zoneForID: self.loadedRewardedAd.zoneID];
    [zone setReward:^(BOOL success, NSString *name, int amount) {
        if ( success )
        {
            [self log: @"Rewarded ad granted reward"];
            self.grantedReward = YES;
        }
        else
        {
            [self log: @"Rewarded ad failed to grant reward"];
        }
    }];
    
    UIViewController *presentingViewController;
    if ( ALSdk.versionCode >= 11020199 )
    {
        presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    }
    else
    {
        presentingViewController = [ALUtils topViewControllerFromKeyWindow];
    }
    
    BOOL success = [self.loadedRewardedAd showWithPresentingViewController: presentingViewController];
    if ( !success )
    {
        [self log: @"Rewarded ad failed to display"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.unspecified];
    }
}

#pragma mark - AdView Adapter

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *zoneId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@%@ ad for zone id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", adFormat.label, zoneId];
    
    [AdColony setAppOptions: [self optionsFromParameters: parameters]];
    
    AdColonyAdSize adSize = [self sizeFromAdFormat: adFormat];
    self.adViewDelegate = [[ALAdColonyMediationAdapterAdViewDelegate alloc] initWithParentAdapter:self andNotify: delegate];
    [AdColony requestAdViewInZone: zoneId
                         withSize: adSize
                   viewController: [ALUtils topViewControllerFromKeyWindow]
                      andDelegate: self.adViewDelegate];
}

#pragma mark - Helper Methods

- (AdColonyAdSize)sizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return kAdColonyAdSizeBanner;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return kAdColonyAdSizeLeaderboard;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return kAdColonyAdSizeMediumRectangle;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return AdColonyAdSizeMake(0, 0);
    }
}

- (NSArray<NSString *> *)retrieveRawZoneIDs:(NSArray<AdColonyZone *> *)zones
{
    NSMutableArray<NSString *> *rawZoneIDs = [NSMutableArray arrayWithCapacity: zones.count];
    
    for ( AdColonyZone *zone in zones )
    {
        [rawZoneIDs addObject: zone.identifier];
    }
    
    return rawZoneIDs;
}

+ (MAAdapterError *)toMaxError:(NSError *)adColonyError
{
    AdColonyRequestError adColonyErrorCode = adColonyError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( adColonyErrorCode )
    {
        case AdColonyRequestErrorInvalidRequest:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case AdColonyRequestErrorSkippedRequest:
            adapterError = MAAdapterError.adFrequencyCappedError;
            break;
        case AdColonyRequestErrorNoFillForRequest:
            adapterError = MAAdapterError.noFill;
            break;
        case AdColonyRequestErrorUnready:
            adapterError = MAAdapterError.adNotReady;
            break;
        case AdColonyRequestErrorFeatureUnsupported:
            adapterError = MAAdapterError.internalError;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: adColonyErrorCode
               thirdPartySdkErrorMessage: adColonyError.localizedDescription];
#pragma clang diagnostic pop
}

- (AdColonyAppOptions *)optionsFromParameters:(id<MAAdapterParameters >)parameters
{
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    AdColonyAppOptions *options = [[AdColonyAppOptions alloc] init];
    
    //
    // Basic options
    //
    options.testMode = [parameters isTesting];
    options.mediationNetwork = @"AppLovin";
    options.mediationNetworkVersion = ALSdk.version;
    
    //
    // GDPR options
    //
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        [options setPrivacyFrameworkOfType: ADC_GDPR isRequired: YES];
        
        NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
        if ( hasUserConsent )
        {
            [options setPrivacyConsentString: hasUserConsent.boolValue ? @"1" : @"0" forType: ADC_GDPR];
        }
    }
    else if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateDoesNotApply )
    {
        [options setPrivacyFrameworkOfType: ADC_GDPR isRequired: NO];
    }
    
    //
    // CCPA options
    //
    if ( ALSdk.versionCode >= 61100 )
    {
        NSNumber *isDoNotSell = [self privacySettingForSelector: @selector(isDoNotSell) fromParameters: parameters];
        if ( isDoNotSell )
        {
            [options setPrivacyFrameworkOfType: ADC_CCPA isRequired: YES];
            [options setPrivacyConsentString: isDoNotSell.boolValue ? @"0" : @"1" forType: ADC_CCPA]; // isDoNotSell means user has opted out of selling data.
        }
        else
        {
            [options setPrivacyFrameworkOfType: ADC_CCPA isRequired: NO];
        }
    }
    
    //
    // COPPA options
    //
    NSNumber *isAgeRestrictedUser = [self privacySettingForSelector: @selector(isAgeRestrictedUser) fromParameters: parameters];
    if ( isAgeRestrictedUser )
    {
        [options setPrivacyFrameworkOfType: ADC_COPPA isRequired: isAgeRestrictedUser.boolValue];
    }
    
    //
    // Bidding options
    //
    
    // If AdColony wins the auction, network adapters need to send any .adm content via ad_options to the AdColony SDK when making the ad request
    if ( [parameters conformsToProtocol: @protocol(MAAdapterResponseParameters)] )
    {
        NSString *bidResponse = ((id<MAAdapterResponseParameters>)parameters).bidResponse;
        if ( [bidResponse al_isValidString] )
        {
            [options setOption: @"adm" withStringValue: bidResponse];
        }
    }
    
    //
    // Other options
    //
    
    if ( [serverParameters al_containsValueForKey: @"plugin"] && [serverParameters al_containsValueForKey: @"plugin_version"] )
    {
        options.plugin = [serverParameters al_stringForKey: @"plugin"];
        options.pluginVersion = [serverParameters al_stringForKey: @"plugin_version"];
    }
    
    if ( [serverParameters al_containsValueForKey: @"user_id"] )
    {
        options.userID = [serverParameters al_stringForKey: @"user_id"];
    }
    
    return options;
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

@end

#pragma mark - ALAdColonyInterstitialDelegate

@implementation ALAdColonyInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALAdColonyMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial loaded"];
    
    self.parentAdapter.loadedInterstitialAd = interstitial;
    
    [self.delegate didLoadInterstitialAd];
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError *)error
{
    [self.parentAdapter log: @"Interstitial failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALAdColonyMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial shown"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)adColonyInterstitialExpired:(AdColonyInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial expiring: %@", interstitial.zoneID];
}

- (void)adColonyInterstitialWillLeaveApplication:(AdColonyInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial will leave application"];
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

@end

#pragma mark - ALAdColonyRewardedAdDelegate

@implementation ALAdColonyRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALAdColonyMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    
    self.parentAdapter.loadedRewardedAd = interstitial;
    
    [self.delegate didLoadRewardedAd];
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError *)error
{
    [self.parentAdapter log: @"Rewarded failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALAdColonyMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad shown"];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial *)interstitial
{
    [self.delegate didCompleteRewardedAdVideo];
    
    if ( [self.parentAdapter hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden"];
    [self.delegate didHideRewardedAd];
}

- (void)adColonyInterstitialExpired:(AdColonyInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad expiring: %@", interstitial.zoneID];
}

- (void)adColonyInterstitialWillLeaveApplication:(AdColonyInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad will leave application"];
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial *)interstitial
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

@end

@implementation ALAdColonyMediationAdapterAdViewDelegate : NSObject

- (instancetype)initWithParentAdapter:(ALAdColonyMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adColonyAdViewDidLoad:(AdColonyAdView *)adView
{
    [self.parentAdapter log: @"Ad View loaded"];
    
    self.parentAdapter.loadedAdViewAd = adView;
    [self.delegate didLoadAdForAdView: adView];
}

- (void)adColonyAdViewDidFailToLoad:(AdColonyAdRequestError *)error
{
    [self.parentAdapter log: @"Ad View failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALAdColonyMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)adColonyAdViewWillLeaveApplication:(AdColonyAdView *)adView
{
    [self.parentAdapter log: @"Ad View ad will leave application"];
}

- (void)adColonyAdViewDidReceiveClick:(AdColonyAdView *)adView
{
    [self.parentAdapter log: @"Ad View ad clicked"];
    [self.delegate didClickAdViewAd];
}

@end
