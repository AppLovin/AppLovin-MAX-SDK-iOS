//
//  ALVerveMediationAdapter.m
//  AppLovinSDK
//
//  Created by Ashley on 7/30/21.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALVerveMediationAdapter.h"
#import <HyBid.h>

#define ADAPTER_VERSION @"2.11.1.2"

@interface ALVerveMediationAdapterInterstitialAdDelegate : NSObject<HyBidInterstitialAdDelegate>
@property (nonatomic, weak) ALVerveMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALVerveMediationAdapterRewardedAdsDelegate : NSObject<HyBidRewardedAdDelegate>
@property (nonatomic, weak) ALVerveMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALVerveMediationAdapterAdViewDelegate : NSObject<HyBidAdViewDelegate>
@property (nonatomic, weak) ALVerveMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALVerveMediationAdapter()

// Interstitial
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALVerveMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;

// Rewarded
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property (nonatomic, strong) ALVerveMediationAdapterRewardedAdsDelegate *rewardedAdapterDelegate;

// AdView
@property (nonatomic, strong) HyBidAdView *adViewAd;
@property (nonatomic, strong) ALVerveMediationAdapterAdViewDelegate *adViewAdapterDelegate;

@end

@implementation ALVerveMediationAdapter
static ALAtomicBoolean *ALVerveInitialized;
static MAAdapterInitializationStatus ALVerveInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    ALVerveInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [ALVerveInitialized compareAndSet: NO update: YES] )
    {
        ALVerveInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *appToken = [parameters.serverParameters al_stringForKey: @"app_token" defaultValue: @""];
        [self log: @"Initializing Verve SDK with app token: %@...", appToken];
        
        if ( [parameters isTesting] )
        {
            [HyBid setTestMode: YES];
            [HyBidLogger setLogLevel: HyBidLogLevelDebug];
        }
        
        [HyBid initWithAppToken: appToken completion:^(BOOL success) {
            if ( success )
            {
                [self log: @"Verve SDK initialized"];
                ALVerveInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            }
            else
            {
                [self log: @"Verve SDK failed to initialize"];
                ALVerveInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
            }
            
            completionHandler(ALVerveInitializationStatus, nil);
        }];
    }
    else
    {
        [self log: @"Verve attempted to intialize already - marking initialization as %ld", ALVerveInitializationStatus];
        completionHandler(ALVerveInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [HyBid getSDKVersionInfo];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.interstitialAdapterDelegate = nil;
    self.interstitialAd = nil;
    
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate = nil;
    
    self.adViewAd.delegate = nil;
    self.adViewAd = nil;
    
    self.adViewAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    // Update local params, since not available on init
    [self updateLocationCollectionEnabled: parameters];
    
    NSString *signal = [HyBid getCustomRequestSignalData];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdpater Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading interstitial ad"];
    
    [self updateLocationCollectionEnabled: parameters];
    [self updateConsentWithParameters: parameters];
    [self updateMuteStateForParameters: parameters];
    
    self.interstitialAdapterDelegate = [[ALVerveMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [[HyBidInterstitialAd alloc] initWithDelegate: self.interstitialAdapterDelegate];
    
    [self.interstitialAd prepareAdWithContent: parameters.bidResponse];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( [self.interstitialAd isReady] )
    {
        [self.interstitialAd showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Loading rewarded ad"];
    
    [self updateLocationCollectionEnabled: parameters];
    [self updateConsentWithParameters: parameters];
    [self updateMuteStateForParameters: parameters];
    
    self.rewardedAdapterDelegate = [[ALVerveMediationAdapterRewardedAdsDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd = [[HyBidRewardedAd alloc] initWithDelegate: self.rewardedAdapterDelegate];
    
    [self.rewardedAd prepareAdWithContent: parameters.bidResponse];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( [self.rewardedAd isReady] )
    {
        [self configureRewardForParameters: parameters];
        [self.rewardedAd showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self log: @"Loading %@ ad view ad...", adFormat.label];
    
    [self updateLocationCollectionEnabled: parameters];
    [self updateConsentWithParameters: parameters];
    [self updateMuteStateForParameters: parameters];
    
    self.adViewAd = [[HyBidAdView alloc] initWithSize: [self sizeFromAdFormat: adFormat]];
    self.adViewAdapterDelegate = [[ALVerveMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.adViewAd.delegate = self.adViewAdapterDelegate;
    
    [self.adViewAd renderAdWithContent: parameters.bidResponse withDelegate: self.adViewAdapterDelegate];
}

#pragma mark - Shared Methods

- (void)updateLocationCollectionEnabled:(id<MAAdapterParameters>)parameters
{
    if ( ALSdk.versionCode >= 11000000 )
    {
        NSDictionary<NSString *, id> *localExtraParameters = parameters.localExtraParameters;
        NSNumber *isLocationCollectionEnabled = [localExtraParameters al_numberForKey: @"is_location_collection_enabled"];
        if ( isLocationCollectionEnabled )
        {
            // NOTE: iOS disables by defualt, whereas Android enables by default
            [HyBid setLocationUpdates: isLocationCollectionEnabled.boolValue];
        }
    }
}

- (void)updateConsentWithParameters:(id<MAAdapterParameters>)parameters
{
    // From PubNative: "HyBid SDK is TCF v2 compliant, so any change in the IAB consent string will be picked up by the SDK."
    // Because of this, they requested that we don't update consent values if one is already set.
    // As a side effect, pubs that use the MAX consent flow will not be able to update consent values mid-session.
    // Full context in this PR: https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/pull/57
    
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = parameters.hasUserConsent;
        NSString *verveGDPRConsentString = [[HyBidUserDataManager sharedInstance] getIABGDPRConsentString];
        if ( hasUserConsent && (!verveGDPRConsentString || [verveGDPRConsentString isEqualToString: @""]) )
        {
            [[HyBidUserDataManager sharedInstance] setIABGDPRConsentString: hasUserConsent.boolValue ? @"1" : @"0"];
        }
        else { /* Don't do anything if huc value not set */ }
    }
    
    NSNumber *isAgeRestrictedUser = parameters.ageRestrictedUser;
    if ( isAgeRestrictedUser )
    {
        [HyBid setCoppa: isAgeRestrictedUser.boolValue];
    }
    
    NSString *verveUSPrivacyString = [[HyBidUserDataManager sharedInstance] getIABUSPrivacyString];
    if ( ALSdk.versionCode >= 61100 && (!verveUSPrivacyString || [verveUSPrivacyString isEqualToString: @""]) )
    {
        NSNumber *isDoNotSell = parameters.doNotSell;
        if ( isDoNotSell && isDoNotSell.boolValue )
        {
            // NOTE: PubNative suggested this US Privacy String, so it does not match other adapters.
            [[HyBidUserDataManager sharedInstance] setIABUSPrivacyString: @"1NYN"];
        }
    }
}

- (HyBidAdSize *)sizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return HyBidAdSize.SIZE_320x50;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return HyBidAdSize.SIZE_728x90;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return HyBidAdSize.SIZE_300x250;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format: %@", adFormat];
        return HyBidAdSize.SIZE_320x50;
    }
}

- (void)updateMuteStateForParameters:(id<MAAdapterResponseParameters>)parameters
{
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    if ( [serverParameters al_containsValueForKey: @"is_muted"] )
    {
        BOOL muted = [serverParameters al_numberForKey: @"is_muted"].boolValue;
        if ( muted )
        {
            [HyBid setVideoAudioStatus: HyBidAudioStatusMuted];
        }
        else
        {
            [HyBid setVideoAudioStatus: HyBidAudioStatusDefault];
        }
    }
}

+ (MAAdapterError *)toMaxError:(NSError *)verveError
{
    NSInteger verveErrorCode = verveError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( verveErrorCode )
    {
        case 1: // No Fill
        case 6: // Null Ad
            adapterError = MAAdapterError.noFill;
            break;
        case 2: // Parse Error
        case 3: // Server Error
            adapterError = MAAdapterError.serverError;
            break;
        case 4: // Invalid Asset
        case 5: // Unsupported Asset
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 7: // Invalid Ad
        case 8: // Invalid Zone ID
        case 9: // Invalid Signal Data
            adapterError = MAAdapterError.badRequest;
            break;
        case 10: // Not Initialized
            adapterError = MAAdapterError.notInitialized;
            break;
        case 11: // Auction No Ad
        case 12: // Rendering Banner
        case 13: // Rendering Interstitial
        case 14: // Rendering Rewarded
            adapterError = MAAdapterError.adNotReady;
            break;
        case 15: // Mraid Player
        case 16: // Vast Player
        case 17: // Tracking URL
        case 18: // Tracking JS
        case 19: // Invalid URL
        case 20: // Internal
            adapterError = MAAdapterError.internalError;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: verveErrorCode
               thirdPartySdkErrorMessage: verveError.localizedDescription];
#pragma clang diagnostic pop
}

@end

@implementation ALVerveMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialDidLoad
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitialDidFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Interstitial ad failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALVerveMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialDidTrackImpression
{
    [self.parentAdapter log: @"Interstitial did track impression"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialDidTrackClick
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialDidDismiss
{
    [self.parentAdapter log: @"Interstitial hidden"];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALVerveMediationAdapterRewardedAdsDelegate

- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedDidLoad
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)rewardedDidFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALVerveMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedDidTrackImpression
{
    [self.parentAdapter log: @"Rewarded ad did track impression"];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)rewardedDidTrackClick
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)onReward
{
    [self.parentAdapter log: @"Rewarded ad reward granted"];
    self.grantedReward = YES;
}

- (void)rewardedDidDismiss
{
    [self.parentAdapter log: @"Rewarded ad did disappear"];
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

@end

@implementation ALVerveMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adViewDidLoad:(HyBidAdView *)adView
{
    [self.parentAdapter log: @"AdView ad loaded"];
    [self.delegate didLoadAdForAdView: adView];
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"AdView failed to load: %@", error];
    
    MAAdapterError *adapterError = [ALVerveMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView
{
    [self.parentAdapter log: @"AdView did track impression: %@", adView];
    [self.delegate didDisplayAdViewAd];
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView
{
    [self.parentAdapter log: @"AdView clicked: %@", adView];
    [self.delegate didClickAdViewAd];
}

@end
