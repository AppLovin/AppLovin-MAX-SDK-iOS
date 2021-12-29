//
//  ALSnapMediationAdapter.m
//  SnapAdapter
//
//  Copyright © 2020 AppLovin. All rights reserved.
//

#import "ALSnapMediationAdapter.h"
#import <SAKSDK/SAKSDK.h>

#import "ALUtils.h"
#import "NSDictionary+ALUtils.h"
#import "NSString+ALUtils.h"
#import "MAAdFormat+Internal.h"

#define ADAPTER_VERSION @"2.0.0.0"

@interface ALSnapMediationAdapterInterstitialAdDelegate : NSObject<SAKInterstitialDelegate>
@property (nonatomic,   weak) ALSnapMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALSnapMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALSnapMediationAdapterRewardedAdDelegate : NSObject<SAKRewardedAdDelegate>
@property (nonatomic,   weak) ALSnapMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALSnapMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALSnapMediationAdapterAdViewDelegate : NSObject<SAKAdViewDelegate>
@property (nonatomic,   weak) ALSnapMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALSnapMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALSnapMediationAdapter()

// Interstitial
@property (nonatomic, strong) ALSnapMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) SAKInterstitial *interstitialAd;

// Rewarded
@property (nonatomic, strong) ALSnapMediationAdapterRewardedAdDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) SAKRewardedAd *rewardedAd;

// Banner
@property (nonatomic, strong) ALSnapMediationAdapterAdViewDelegate *adViewAdapterDelegate;
@property (nonatomic, strong) SAKAdView *adView;

// Keep track of current slot id adapter is showing for since Snap SDK does not forward slot id in callbacks
@property (nonatomic, copy) NSString *slotId;

@end

@implementation ALSnapMediationAdapter

static ALAtomicBoolean              *ALSnapSDKInitialized;
static MAAdapterInitializationStatus ALSnapSDKInitializationStatus = NSIntegerMin;

#pragma mark - Class Initialization

+ (void)initialize
{
    [super initialize];
    
    ALSnapSDKInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (NSString *)SDKVersion
{
    // Snap's SDK may return `nil` for version string...
    return [SAKMobileAd shared].sdkVersion ?: @"";
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [ALSnapSDKInitialized compareAndSet: NO update: YES] )
    {
        NSString *appID = [parameters.serverParameters al_stringForKey: @"app_id"];
        [self log: @"Initializing Snap SDK with app id: %@...", appID];
        
        ALSnapSDKInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        SAKRegisterRequestConfigurationBuilder *configurationBuilder = [[SAKRegisterRequestConfigurationBuilder alloc] init];
        [configurationBuilder withSnapKitAppId: appID];
        [configurationBuilder withTestModeEnabled: [parameters isTesting]];
        SAKRegisterRequestConfiguration *configuration = [configurationBuilder build];
        
        [SAKMobileAd shared].debug = [parameters isTesting];
        [[SAKMobileAd shared] startWithConfiguration: configuration completion:^(BOOL success, NSError *_Nullable error) {
            
            if ( success )
            {
                [self log: @"Snap SDK successfully finished initialization"];
                ALSnapSDKInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
                completionHandler(ALSnapSDKInitializationStatus, nil);
            }
            else
            {
                [self log: @"Snap SDK failed to finish initializion: %@", error.description];
                ALSnapSDKInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALSnapSDKInitializationStatus, error.description);
            }
        }];
    }
    else
    {
        if ( [SAKMobileAd shared].initialized )
        {
            [self log: @"Snap SDK already initialized..."];
            completionHandler(ALSnapSDKInitializationStatus, nil);
        }
        else
        {
            [self log: @"Snap SDK still initializing..."];
            completionHandler(ALSnapSDKInitializationStatus, nil);
        }
    }
}

- (void)destroy 
{
    self.interstitialAd = nil;
    self.interstitialAdapterDelegate = nil;
    
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate = nil;
    
    self.adView = nil;
    self.adViewAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *signal = [SAKMobileAd.shared biddingToken];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self.slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@interstitial ad for slot id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", self.slotId];
    
    self.interstitialAdapterDelegate = [[ALSnapMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [[SAKInterstitial alloc] init];
    self.interstitialAd.delegate = self.interstitialAdapterDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        NSData *bidResponseData = [[NSData alloc] initWithBase64EncodedString: bidResponse options: 0];
        [self.interstitialAd loadAdWithBidPayload: bidResponseData publisherSlotId: self.slotId];
    }
    else
    {
        SAKAdRequestConfigurationBuilder *configurationBuilder = [[SAKAdRequestConfigurationBuilder alloc] init];
        [configurationBuilder withPublisherSlotId: self.slotId];
        SAKAdRequestConfiguration *configuration = [configurationBuilder build];
        
        [self.interstitialAd loadRequest: configuration];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self.slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad for slot id: %@...", self.slotId];
    
    if ( [self.interstitialAd isReady] )
    {
        // Overwritten by `mute_state` setting, unless `mute_state` is disabled
        if ( [parameters.serverParameters al_containsValueForKey: @"is_muted"] )
        {
            [SAKMobileAd shared].silentModeAudioEnabled = [parameters.serverParameters al_numberForKey: @"is_muted"].boolValue;
        }
        
        [self.interstitialAd presentFromRootViewController: [ALUtils topViewControllerFromKeyWindow] dismissTransition: CGRectZero];
    }
    else
    {
        [self log: @"Interstitial ad not ready for slot id: %@...", self.slotId];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self.slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@rewarded ad for slot id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", self.slotId];
    
    self.rewardedAdapterDelegate = [[ALSnapMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd = [[SAKRewardedAd alloc] init];
    self.rewardedAd.delegate = self.rewardedAdapterDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        NSData *bidResponseData = [[NSData alloc] initWithBase64EncodedString: bidResponse options: 0];
        [self.rewardedAd loadAdWithBidPayload: bidResponseData publisherSlotId: self.slotId];
    }
    else
    {
        SAKAdRequestConfigurationBuilder *configurationBuilder = [[SAKAdRequestConfigurationBuilder alloc] init];
        [configurationBuilder withPublisherSlotId: self.slotId];
        SAKAdRequestConfiguration *configuration = [configurationBuilder build];
        
        [self.rewardedAd loadRequest: configuration];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self.slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad for slot id: %@...", self.slotId];
    
    if ( [self.rewardedAd isReady] )
    {
        // Overwritten by `mute_state` setting, unless `mute_state` is disabled
        if ( [parameters.serverParameters al_containsValueForKey: @"is_muted"] )
        {
            [SAKMobileAd shared].silentModeAudioEnabled = [parameters.serverParameters al_numberForKey: @"is_muted"].boolValue;
        }
        
        [self configureRewardForParameters: parameters];
        [self.rewardedAd presentFromRootViewController: [ALUtils topViewControllerFromKeyWindow] dismissTransition: CGRectZero];
    }
    else
    {
        [self log: @"Rewarded ad not ready for slot id: %@...", self.slotId];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self.slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading %@%@ ad for slot id \"%@\"...", [bidResponse al_isValidString] ? @"bidding " : @"", adFormat.label, self.slotId];
    
    self.adViewAdapterDelegate = [[ALSnapMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.adView = [[SAKAdView alloc] initWithFormat: [self adSizeForAdFormat: adFormat]];
    self.adView.delegate = self.adViewAdapterDelegate;
    
    if ( [bidResponse al_isValidString] )
    {
        NSData *bidResponseData = [[NSData alloc] initWithBase64EncodedString: bidResponse options: 0];
        [self.adView loadAdWithBidPayload: bidResponseData publisherSlotId: self.slotId];
    }
    else
    {
        SAKAdRequestConfigurationBuilder *configurationBuilder = [[SAKAdRequestConfigurationBuilder alloc] init];
        [configurationBuilder withPublisherSlotId: self.slotId];
        SAKAdRequestConfiguration *configuration = [configurationBuilder build];
        
        [self.adView loadRequest: configuration];
    }
}

+ (MAAdapterError *)toMaxError:(NSError *)snapError
{
    SAKErrorCode snapErrorCode = snapError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( snapErrorCode )
    {
        case SAKErrorNetworkError:
            adapterError = MAAdapterError.noConnection;
            break;
        case SAKErrorFailedToParse:
        case SAKErrorCodeNoCreativeEndpoint:
        case SAKErrorCodeMediaDownloadError:
            adapterError = MAAdapterError.serverError;
            break;
        case SAKErrorSDKNotInitialized:
            adapterError = MAAdapterError.notInitialized;
            break;
        case SAKErrorNoAdAvailable:
            adapterError = MAAdapterError.noFill;
            break;
        case SAKErrorFailedToRegister:
        case SAKErrorAdsDisabled:
        case SAKErrorAdNotVisible:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case SAKErrorGeneric:
        case SAKErrorNotEligible:
            adapterError = MAAdapterError.unspecified;
            break;
    }
    
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: snapErrorCode
               thirdPartySdkErrorMessage: snapError.description];
}

- (SAKAdViewFormat)adSizeForAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader )
    {
        return SAKAdViewFormatBanner;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return SAKAdViewFormatMediumRectangle;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return SAKAdViewFormatBanner;
    }
}

@end

@implementation ALSnapMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALSnapMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialDidLoad:(SAKInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad loaded for slot id: %@...", self.parentAdapter.slotId];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitial:(SAKInterstitial *)ad didFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Interstitial ad failed to load for slot id: %@ with error: %@...", self.parentAdapter.slotId, error];
    MAAdapterError *adapterError = [ALSnapMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialDidTrackImpression:(SAKInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad impression tracked for slot id: %@...", self.parentAdapter.slotId];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialWillAppear:(SAKInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad will show for slot id: %@...", self.parentAdapter.slotId];
}

- (void)interstitialDidAppear:(SAKInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad shown for slot id: %@", self.parentAdapter.slotId];
}

- (void)interstitialDidShowAttachment:(SAKInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad clicked for slot id: %@...", self.parentAdapter.slotId];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialWillDisappear:(SAKInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad will be hidden for slot id: %@...", self.parentAdapter.slotId];
}

- (void)interstitialDidDisappear:(SAKInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad hidden for slot id: %@...", self.parentAdapter.slotId];
    [self.delegate didHideInterstitialAd];
}

- (void)interstitialDidExpire:(SAKInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad is expired for slot id: %@...", self.parentAdapter.slotId];
}

@end

@implementation ALSnapMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALSnapMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedAdDidLoad:(SAKRewardedAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad loaded for slot id: %@...", self.parentAdapter.slotId];
    [self.delegate didLoadRewardedAd];
}

- (void)rewardedAd:(SAKRewardedAd *)ad didFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded ad failed to load for slot id: %@ with error: %@...", self.parentAdapter.slotId, error];
    MAAdapterError *adapterError = [ALSnapMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedAdWillAppear:(SAKRewardedAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad will show for slot id: %@...", self.parentAdapter.slotId];
}

- (void)rewardedAdDidAppear:(SAKRewardedAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad shown for slot id: %@...", self.parentAdapter.slotId];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)rewardedAdDidExpire:(SAKRewardedAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad is expired for slot id: %@...", self.parentAdapter.slotId];
}

- (void)rewardedAdDidEarnReward:(SAKRewardedAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad completed for slot id: %@...", self.parentAdapter.slotId];
    
    [self.delegate didCompleteRewardedAdVideo];
    self.grantedReward = YES;
}

- (void)rewardedAdWillDisappear:(SAKRewardedAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad will be hidden for slot id: %@...", self.parentAdapter.slotId];
}

- (void)rewardedAdDidDisappear:(SAKRewardedAd *)ad
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = self.parentAdapter.reward;
        
        [self.parentAdapter log: @"Rewarded ad user with reward: %@ for slot id: %@...", reward, self.parentAdapter.slotId];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden for slot id: %@...", self.parentAdapter.slotId];
    [self.delegate didHideRewardedAd];
}

- (void)rewardedAdDidShowAttachment:(SAKRewardedAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad clicked for slot id: %@...", self.parentAdapter.slotId];
    [self.delegate didClickRewardedAd];
}

@end

@implementation ALSnapMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALSnapMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adViewDidLoad:(SAKAdView *)adView
{
    [self.parentAdapter log: @"Ad View loaded for slot id: %@...", self.parentAdapter.slotId];
    [self.delegate didLoadAdForAdView: adView];
}

- (void)adView:(SAKAdView *)adView didFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Ad View failed to load for slot id: %@ with error: %@...", self.parentAdapter.slotId, error];
    MAAdapterError *adapterError = [ALSnapMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)adViewDidTrackImpression:(SAKAdView *)adView
{
    [self.parentAdapter log: @"Ad View shown for slot id: %@", self.parentAdapter.slotId];
    [self.delegate didDisplayAdViewAd];
}

- (void)adViewDidClick:(SAKAdView *)adView
{
    [self.parentAdapter log: @"Ad View ad clicked for slot id: %@", self.parentAdapter.slotId];
    [self.delegate didClickAdViewAd];
}

@end
