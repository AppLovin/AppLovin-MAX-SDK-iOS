//
//  ALLineMediationAdapter.h
//  AppLovinSDK
//
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALLineMediationAdapter.h"
#import <FiveAd/FiveAd.h>

#define ADAPTER_VERSION @"2.8.20240612.0"

@interface ALLineMediationAdapterInterstitialAdDelegate : NSObject <FADLoadDelegate, FADInterstitialEventListener>
@property (nonatomic,   weak) ALLineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALLineMediationAdapterRewardedAdDelegate : NSObject <FADLoadDelegate, FADVideoRewardEventListener>
@property (nonatomic,   weak) ALLineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALLineMediationAdapterAdViewDelegate : NSObject <FADLoadDelegate, FADCustomLayoutEventListener>
@property (nonatomic,   weak) ALLineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@property (nonatomic, strong) MAAdFormat *adFormat;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALLineMediationAdapterNativeAdViewDelegate : NSObject <FADLoadDelegate, FADNativeEventListener>
@property (nonatomic,   weak) ALLineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@property (nonatomic, strong) MAAdFormat *adFormat;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)adFormat serverParameters:(NSDictionary<NSString *, id> *)serverParameters andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALLineMediationAdapterNativeAdDelegate : NSObject <FADLoadDelegate, FADNativeEventListener>
@property (nonatomic,   weak) ALLineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter serverParameters:(NSDictionary<NSString *, id> *)serverParameters andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MALineNativeAd : MANativeAd
@property (nonatomic, weak) ALLineMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALLineMediationAdapter ()

// Interstitial
@property (nonatomic, strong) ALLineMediationAdapterInterstitialAdDelegate *interstitialDelegate;
@property (nonatomic, strong) FADInterstitial *interstitialAd;

// Rewarded
@property (nonatomic, strong) ALLineMediationAdapterRewardedAdDelegate *rewardedDelegate;
@property (nonatomic, strong) FADVideoReward *rewardedAd;

// AdView
@property (nonatomic, strong) ALLineMediationAdapterAdViewDelegate *adViewDelegate;
@property (nonatomic, strong) ALLineMediationAdapterNativeAdViewDelegate *nativeAdViewDelegate;
@property (nonatomic, strong) FADAdViewCustomLayout *adView;

// Native
@property (nonatomic, strong) ALLineMediationAdapterNativeAdDelegate *nativeAdDelegate;
@property (nonatomic, strong) FADNative *nativeAd;
@end

@implementation ALLineMediationAdapter

static ALAtomicBoolean *ALLineInitialized;

+ (void)initialize
{
    [super initialize];
    
    ALLineInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (NSString *)SDKVersion
{
    return [FADSettings semanticVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALLineInitialized compareAndSet: NO update: YES] )
    {
        NSString *appId = [parameters.serverParameters al_stringForKey: @"app_id"];
        [self log: @"Initializing Line SDK with app id: %@...", appId];
        
        FADConfig *config = [[FADConfig alloc] initWithAppId: appId];
        [config setIsTest: [parameters isTesting]];
        
        NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
        // Overwritten by `mute_state` setting, unless `mute_state` is disabled
        if ( [serverParameters al_containsValueForKey: @"is_muted"] )
        {
            BOOL muted = [serverParameters al_numberForKey: @"is_muted"].boolValue;
            [config enableSoundByDefault: !muted];
        }
        
        //
        // GDPR options
        //
        NSNumber *hasUserConsent = [parameters hasUserConsent];
        if ( hasUserConsent != nil )
        {
            config.needGdprNonPersonalizedAdsTreatment = hasUserConsent.boolValue ? kFADNeedGdprNonPersonalizedAdsTreatmentFalse : kFADNeedGdprNonPersonalizedAdsTreatmentTrue;
        }
        
        //
        // COPPA options
        //
        NSNumber *isAgeRestrictedUser = [parameters isAgeRestrictedUser];
        if ( isAgeRestrictedUser != nil )
        {
            config.needChildDirectedTreatment = isAgeRestrictedUser.boolValue ? kFADNeedChildDirectedTreatmentTrue : kFADNeedChildDirectedTreatmentFalse;
        }
        
        [FADSettings registerConfig: config];
        completionHandler(MAAdapterInitializationStatusInitializedUnknown, nil);
    }
    else
    {
        if ( [FADSettings isConfigRegistered] )
        {
            [self log: @"Line SDK is already initialized"];
            completionHandler(MAAdapterInitializationStatusInitializedUnknown, nil);
        }
        else
        {
            [self log: @"Line SDK still initializing"];
            completionHandler(MAAdapterInitializationStatusInitializing, nil);
        }
    }
}

- (void)destroy
{
    [self.interstitialAd setLoadDelegate: nil];
    [self.interstitialAd setEventListener: nil];
    self.interstitialAd = nil;
    self.interstitialDelegate.delegate = nil;
    self.interstitialDelegate = nil;
    
    [self.rewardedAd setLoadDelegate: nil];
    [self.rewardedAd setEventListener: nil];
    self.rewardedAd = nil;
    self.rewardedDelegate.delegate = nil;
    self.rewardedDelegate = nil;
    
    [self.adView setLoadDelegate: nil];
    [self.adView setEventListener: nil];
    self.adView = nil;
    self.adViewDelegate.delegate = nil;
    self.adViewDelegate = nil;
    self.nativeAdViewDelegate.delegate = nil;
    self.nativeAdViewDelegate = nil;
    
    [self.nativeAd setLoadDelegate: nil];
    [self.nativeAd setEventListener: nil];
    self.nativeAd = nil;
    self.nativeAdDelegate.delegate = nil;
    self.nativeAdDelegate = nil;
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad for slot id: %@...", slotId];
    
    self.interstitialDelegate = [[ALLineMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [[FADInterstitial alloc] initWithSlotId: slotId];
    [self.interstitialAd setLoadDelegate: self.interstitialDelegate];
    [self.interstitialAd setEventListener: self.interstitialDelegate];
    
    [self.interstitialAd loadAdAsync];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad for slot id: %@...", slotId];
    
    [self.interstitialAd showWithViewController: parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow]];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad for slot id: %@...", slotId];
    
    self.rewardedDelegate = [[ALLineMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd = [[FADVideoReward alloc] initWithSlotId: slotId];
    [self.rewardedAd setLoadDelegate: self.rewardedDelegate];
    [self.rewardedAd setEventListener: self.rewardedDelegate];
    
    [self.rewardedAd loadAdAsync];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad for slot id: %@...", slotId];
    
    [self configureRewardForParameters: parameters];

    [self.rewardedAd showWithViewController: parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow]];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    
    [self log: @"Loading %@%@ ad for slot id: %@...", isNative ? @"native " : @"", adFormat.label, slotId];
    
    dispatchOnMainQueue(^{
        
        if ( isNative )
        {
            self.nativeAdViewDelegate = [[ALLineMediationAdapterNativeAdViewDelegate alloc] initWithParentAdapter: self
                                                                                                         adFormat: adFormat
                                                                                                 serverParameters: parameters.serverParameters
                                                                                                        andNotify: delegate];
            self.nativeAd = [[FADNative alloc] initWithSlotId: slotId videoViewWidth: CGRectGetWidth([UIScreen mainScreen].bounds)];
            [self.nativeAd setLoadDelegate: self.nativeAdViewDelegate];
            [self.nativeAd setEventListener: self.nativeAdViewDelegate];
            
            // We always want to mute banners and MRECs
            [self.nativeAd enableSound: NO];
            
            [self.nativeAd loadAdAsync];
        }
        else
        {
            self.adViewDelegate = [[ALLineMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self adFormat: adFormat andNotify: delegate];
            self.adViewDelegate = [[ALLineMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self
                                                                                             adFormat: adFormat
                                                                                            andNotify: delegate];
            self.adView = [[FADAdViewCustomLayout alloc] initWithSlotId: slotId width: CGRectGetWidth([UIScreen mainScreen].bounds)];
            [self.adView setLoadDelegate: self.adViewDelegate];
            [self.adView setEventListener: self.adViewDelegate];
            self.adView.frame = CGRectMake(0, 0, adFormat.size.width, adFormat.size.height);
            
            // We always want to mute banners and MRECs
            [self.adView enableSound: NO];
            
            [self.adView loadAdAsync];
        }
    });
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading native ad for slot id: %@...", slotId];
    
    self.nativeAdDelegate = [[ALLineMediationAdapterNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                 serverParameters: parameters.serverParameters
                                                                                        andNotify: delegate];
    dispatchOnMainQueue(^{
        
        self.nativeAd = [[FADNative alloc] initWithSlotId: slotId videoViewWidth: CGRectGetWidth([UIScreen mainScreen].bounds)];
        [self.nativeAd setLoadDelegate: self.nativeAdDelegate];
        [self.nativeAd setEventListener: self.nativeAdDelegate];
        
        // We always want to mute banners and MRECs
        [self.nativeAd enableSound: NO];
        
        [self.nativeAd loadAdAsync];
    });
}

#pragma mark - Helper Methods

+ (MAAdapterError *)toMaxError:(FADErrorCode)lineAdsErrorCode
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    NSString *thirdPartySdkErrorMessage;
    switch ( lineAdsErrorCode )
    {
        case kFADErrorNetworkError:
            adapterError = MAAdapterError.noConnection;
            thirdPartySdkErrorMessage = @"Please try again in a stable network environment.";
            break;
        case kFADErrorCodeNoAd:
            adapterError = MAAdapterError.noFill;
            thirdPartySdkErrorMessage = @"Ad was not ready at display time. Please try again.";
            break;
        case kFADErrorBadAppId:
            adapterError = MAAdapterError.invalidConfiguration;
            thirdPartySdkErrorMessage = @"Check if the OS type, PackageName, and issued AppID registered in FIVE Dashboard and the application settings match. Please be careful about blanks.";
            break;
        case kFADErrorStorageError:
            adapterError = MAAdapterError.unspecified;
            thirdPartySdkErrorMessage = @"There is a problem with the device storage. Please try again with another device.";
            break;
        case kFADErrorInternalError:
            adapterError = MAAdapterError.internalError;
            thirdPartySdkErrorMessage = @"Please contact us.";
            break;
        case kFADErrorInvalidState:
            adapterError = MAAdapterError.invalidLoadState;
            thirdPartySdkErrorMessage = @"There is a problem with the implementation. Please check the following. Whether the initialization process ([FADSettings registerConfig: config]) is executed before the creation of the ad object or loadAdAsync. Are you calling loadAdAsync multiple times for one ad object?";
            break;
        case kFADErrorBadSlotId:
            adapterError = MAAdapterError.invalidConfiguration;
            thirdPartySdkErrorMessage = @"Make sure you are using the SlotID issued on the FIVE Dashboard.";
            break;
        case kFADErrorSuppressed:
        case kFADErrorPlayerError:
        case kFADErrorNone:
            adapterError = MAAdapterError.unspecified;
            thirdPartySdkErrorMessage = @"Please contact us.";
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: lineAdsErrorCode
               thirdPartySdkErrorMessage: thirdPartySdkErrorMessage];
#pragma clang diagnostic pop
}

@end

@implementation ALLineMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)fiveAdDidLoad:(id<FADAdInterface>)ad
{
    [self.parentAdapter log: @"Interstitial ad loaded for slot id: %@...", ad.slotId];
    [self.delegate didLoadInterstitialAd];
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Interstitial ad failed to load for slot id: %@ with error: %ld", ad.slotId, errorCode];
    MAAdapterError *error = [ALLineMediationAdapter toMaxError: errorCode];
    [self.delegate didFailToLoadInterstitialAdWithError: error];
}

- (void)fiveInterstitialAd:(FADInterstitial *)ad didFailedToShowAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Interstitial ad failed to show for slot id: %@ with error: %ld", ad.slotId, errorCode];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *error = [MAAdapterError errorWithCode: -4205
                                              errorString: @"Ad Display Failed"
                                   thirdPartySdkErrorCode: errorCode
                                thirdPartySdkErrorMessage: @""];
    
#pragma clang diagnostic pop
    
    [self.delegate didFailToDisplayInterstitialAdWithError: error];
}
- (void)fiveInterstitialAdDidImpression:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad impression tracked for slot id: %@...", ad.slotId];
    [self.delegate didDisplayInterstitialAd];
}

- (void)fiveInterstitialAdDidClick:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad clicked for slot id: %@...", ad.slotId];
    [self.delegate didClickInterstitialAd];
}

- (void)fiveInterstitialAdFullScreenDidOpen:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad shown for slot id: %@...", ad.slotId];
}

- (void)fiveInterstitialAdFullScreenDidClose:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad hidden for slot id: %@...", ad.slotId];
    [self.delegate didHideInterstitialAd];
}

- (void)fiveInterstitialAdDidPlay:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad did play for slot id: %@...", ad.slotId];
}

- (void)fiveInterstitialAdDidPause:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad did pause for slot id: %@...", ad.slotId];
}

- (void)fiveInterstitialAdDidViewThrough:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad completed for slot id: %@...", ad.slotId];
}

@end

@implementation ALLineMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)fiveAdDidLoad:(id<FADAdInterface>)ad
{
    [self.parentAdapter log: @"Rewarded ad loaded for slot id: %@...", ad.slotId];
    [self.delegate didLoadRewardedAd];
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Rewarded ad failed to load for slot id: %@ with error: %ld", ad.slotId, errorCode];
    MAAdapterError *error = [ALLineMediationAdapter toMaxError: errorCode];
    [self.delegate didFailToLoadRewardedAdWithError: error];
}

- (void)fiveVideoRewardAd:(FADVideoReward *)ad didFailedToShowAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Rewarded ad failed to show for slot id: %@ with error: %ld", ad.slotId, errorCode];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *error = [MAAdapterError errorWithCode: -4205
                                              errorString: @"Ad Display Failed"
                                   thirdPartySdkErrorCode: errorCode
                                thirdPartySdkErrorMessage: @""];
#pragma clang diagnostic pop
    
    [self.delegate didFailToDisplayRewardedAdWithError: error];
}

- (void)fiveVideoRewardAdDidImpression:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad impression tracked for slot id: %@...", ad.slotId];
    [self.delegate didDisplayRewardedAd];
}

- (void)fiveVideoRewardAdDidClick:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad clicked for slot id: %@...", ad.slotId];
    [self.delegate didClickRewardedAd];
}

- (void)fiveVideoRewardAdFullScreenDidClose:(FADVideoReward *)ad
{
    if ( ad.state != kFADStateError )
    {
        if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
        {
            MAReward *reward = self.parentAdapter.reward;
            
            [self.parentAdapter log: @"Rewarded ad user with reward: %@ for slot id: %@...", reward, ad.slotId];
            [self.delegate didRewardUserWithReward: reward];
        }
    }
    [self.parentAdapter log: @"Rewarded ad hidden for slot id: %@...", ad.slotId];
    [self.delegate didHideRewardedAd];
}

- (void)fiveVideoRewardAdFullScreenDidOpen:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad shown for slot id: %@...", ad.slotId];
}

- (void)fiveVideoRewardAdDidPlay:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad did play for slot id: %@...", ad.slotId];
}

- (void)fiveVideoRewardAdDidPause:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad did pause for slot id: %@...", ad.slotId];
}

- (void)fiveVideoRewardAdDidViewThrough:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad completed for slot id: %@...", ad.slotId];
}

- (void)fiveVideoRewardAdDidReward:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad did reward user for slot id: %@...", ad.slotId];
    self.grantedReward = YES;
}

@end

@implementation ALLineMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.adFormat = adFormat;
    }
    return self;
}

- (void)fiveAdDidLoad:(id<FADAdInterface>)ad
{
    [self.parentAdapter log: @"%@ ad loaded for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didLoadAdForAdView: self.parentAdapter.adView];
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"%@ ad failed to load for slot id: %@ with error: %ld", self.adFormat.label, ad.slotId, errorCode];
    MAAdapterError *error = [ALLineMediationAdapter toMaxError: errorCode];
    [self.delegate didFailToLoadAdViewAdWithError: error];
}

- (void)fiveCustomLayoutAd:(FADAdViewCustomLayout *)ad didFailedToShowAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"%@ ad failed to show for slot id: %@ with error: %ld", self.adFormat.label, ad.slotId, errorCode];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *error = [MAAdapterError errorWithCode: -4205
                                              errorString: @"Ad Display Failed"
                                   thirdPartySdkErrorCode: errorCode
                                thirdPartySdkErrorMessage: @""];
#pragma clang diagnostic pop
    
    [self.delegate didFailToDisplayAdViewAdWithError: error];
}

- (void)fiveCustomLayoutAdDidImpression:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad impression tracked for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didDisplayAdViewAd];
}

- (void)fiveCustomLayoutAdDidClick:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad clicked for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didClickAdViewAd];
}

- (void)fiveCustomLayoutAdViewDidRemove:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad hidden for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didHideAdViewAd];
}

- (void)fiveCustomLayoutAdDidPlay:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad did play for slot id: %@...", self.adFormat.label, ad.slotId];
}

- (void)fiveCustomLayoutAdDidPause:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad did pause for slot id: %@...", self.adFormat.label, ad.slotId];
}

- (void)fiveCustomLayoutAdDidViewThrough:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad completed for slot id: %@...", self.adFormat.label, ad.slotId];
}

@end

@implementation ALLineMediationAdapterNativeAdViewDelegate

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)adFormat serverParameters:(NSDictionary<NSString *, id> *)serverParameters andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.adFormat = adFormat;
        self.serverParameters = serverParameters;
    }
    return self;
}

- (void)fiveAdDidLoad:(id<FADAdInterface>)ad
{
    [self.parentAdapter log: @"Native %@ ad loaded for slot id: %@...", self.adFormat.label, ad.slotId];
    [self renderCustomNativeBanner];
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Native %@ ad loaded for slot id: %@... with error: %ld", self.adFormat.label, ad.slotId, errorCode];
    MAAdapterError *error = [ALLineMediationAdapter toMaxError: errorCode];
    [self.delegate didFailToLoadAdViewAdWithError: error];
}

- (void)fiveNativeAd:(FADNative *)ad didFailedToShowAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Native %@ ad showed for slot id: %@... with error: %ld", self.adFormat.label, ad.slotId, errorCode];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *error = [MAAdapterError errorWithCode: -4205
                                              errorString: @"Ad Display Failed"
                                   thirdPartySdkErrorCode: errorCode
                                thirdPartySdkErrorMessage: @""];
#pragma clang diagnostic pop
    [self.delegate didFailToDisplayAdViewAdWithError: error];
}

- (void)fiveNativeAdDidImpression:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad impression tracked for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didDisplayAdViewAd];
}

- (void)fiveNativeAdDidClick:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad clicked for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didClickAdViewAd];
}

- (void)fiveNativeAdViewDidRemove:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad hidden for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didHideAdViewAd];
}

- (void)fiveNativeAdDidPlay:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad did play for slot id: %@...", self.adFormat.label, ad.slotId];
}

- (void)fiveNativeAdDidPause:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad did pause for slot id: %@...", self.adFormat.label, ad.slotId];
}

- (void)fiveNativeAdDidViewThrough:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad completed for slot id: %@...", self.adFormat.label, ad.slotId];
}

- (void)renderCustomNativeBanner
{
    [self.parentAdapter.nativeAd loadIconImageAsyncWithBlock:^(UIImage *iconImage) {
        // Ensure UI rendering is done on main queue
        dispatchOnMainQueue(^{
            
            FADNative *nativeAd = self.parentAdapter.nativeAd;
            if ( !nativeAd )
            {
                [self.parentAdapter log: @"Ad destroyed before assets finished load"];
                [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.invalidLoadState];
                
                return;
            }
            
            MANativeAd *maxNativeAd = [[MANativeAd alloc] initWithFormat: self.adFormat builderBlock:^(MANativeAdBuilder *builder) {
                builder.title = nativeAd.getAdTitle;
                builder.body = nativeAd.getDescriptionText;
                builder.callToAction = nativeAd.getButtonText;
                builder.icon = [[MANativeAdImage alloc] initWithImage: iconImage];
                builder.mediaView = nativeAd.getAdMainView;
            }];
            
            // Backend will pass down `vertical` as the template to indicate using a vertical native template
            NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
            if ( [templateName containsString: @"vertical"] && ALSdk.versionCode < 6140500 )
            {
                [self.parentAdapter log: @"Vertical native banners are only supported on MAX SDK 6.14.5 and above. Default native template will be used."];
            }
            
            MANativeAdView *maxNativeAdView;
            // Fallback case to be removed when backend sends down full template names for vertical native ads
            if ( [templateName isEqualToString: @"vertical"] )
            {
                NSString *verticalTemplateName = ( self.adFormat == MAAdFormat.leader ) ? @"vertical_leader_template" : @"vertical_media_banner_template";
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: verticalTemplateName];
            }
            else
            {
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: templateName];
            }
            
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
            
            [nativeAd registerViewForInteraction: maxNativeAdView withInformationIconView: maxNativeAdView.iconImageView withClickableViews: clickableViews];
            [self.delegate didLoadAdForAdView: maxNativeAdView];
        });
    }];
}

@end

@implementation ALLineMediationAdapterNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter serverParameters:(NSDictionary<NSString *, id> *)serverParameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.serverParameters = serverParameters;
    }
    return self;
}

- (void)fiveAdDidLoad:(id<FADAdInterface>)ad
{
    [self.parentAdapter log: @"Native ad loaded for slot id: %@...", ad.slotId];
    
    FADNative *loadedNativeAd = self.parentAdapter.nativeAd;
    if ( !loadedNativeAd )
    {
        [self.parentAdapter log: @"Native ad destroyed before the ad successfully loaded: %@...", ad.slotId];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.invalidLoadState];
        
        return;
    }
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    if ( isTemplateAd && ![loadedNativeAd.getAdTitle al_isValidString] )
    {
        [self.parentAdapter e: @"Native ad (%@) does not have required assets.", loadedNativeAd];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    [loadedNativeAd loadIconImageAsyncWithBlock:^(UIImage *iconImage) {
        // Ensure UI rendering is done on main queue
        dispatchOnMainQueue(^{
            
            FADNative *nativeAd = self.parentAdapter.nativeAd;
            if ( !nativeAd )
            {
                [self.parentAdapter log: @"Native ad destroyed before assets finished load for slot id: %@", ad.slotId];
                [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.invalidLoadState];
                
                return;
            }
            
            MANativeAd *maxNativeAd = [[MALineNativeAd alloc] initWithParentAdapter: self.parentAdapter builderBlock:^(MANativeAdBuilder *builder) {
                builder.title = nativeAd.getAdTitle;
                builder.body = nativeAd.getDescriptionText;
                builder.callToAction = nativeAd.getButtonText;
                builder.icon = [[MANativeAdImage alloc] initWithImage: iconImage];
                builder.mediaView = nativeAd.getAdMainView;
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                // Introduced in 10.4.0
                if ( [builder respondsToSelector: @selector(setAdvertiser:)] )
                {
                    [builder performSelector: @selector(setAdvertiser:) withObject: nativeAd.getAdvertiserName];
                }
#pragma clang diagnostic pop
            }];
            
            [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
        });
    }];
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Native ad failed to load for slot id: %@ with error: %ld", ad.slotId, errorCode];
    MAAdapterError *error = [ALLineMediationAdapter toMaxError: errorCode];
    [self.delegate didFailToLoadNativeAdWithError: error];
}

- (void)fiveNativeAd:(FADNative *)ad didFailedToShowAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Native ad failed to show ad for slot id: %@... with error: %ld", ad.slotId, errorCode];
}

- (void)fiveNativeAdDidImpression:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad impression tracked for slot id: %@...", ad.slotId];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)fiveNativeAdDidClick:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad clicked for slot id: %@...", ad.slotId];
    [self.delegate didClickNativeAd];
}

- (void)fiveNativeAdViewDidRemove:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad hidden for slot id: %@...", ad.slotId];
}

- (void)fiveNativeAdDidPlay:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad did play for slot id: %@...", ad.slotId];
}

- (void)fiveNativeAdDidPause:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad did pause for slot id: %@...", ad.slotId];
}

- (void)fiveNativeAdDidViewThrough:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad completed for slot id: %@...", ad.slotId];
}

@end

@implementation MALineNativeAd

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
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
    
    [self prepareForInteractionClickableViews: clickableViews withContainer: maxNativeAdView];
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container
{
    FADNative *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    UIImageView *iconImageView = nil;
    for ( UIView *clickableView in clickableViews )
    {
        if( [clickableView isKindOfClass: [UIImageView class]] )
        {
            iconImageView = (UIImageView *)clickableView;
            break;
        }
    }
    
    [self.parentAdapter d: @"Preparing views for interaction: %@ with container: %@", clickableViews, container];
    
    [nativeAd registerViewForInteraction: container withInformationIconView: iconImageView withClickableViews: clickableViews];
    
    return YES;
}

@end
