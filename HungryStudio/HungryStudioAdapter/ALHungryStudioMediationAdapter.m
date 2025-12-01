//
//  ALHungryStudioMediationAdapter.m
//  HungryStudioAdapter
//
//  Created by HungryStudio on 2025/12/1.
//

#import "ALHungryStudioMediationAdapter.h"
#import <HSADXSDK/HSADXSDK.h>
#import <HSADXSDK/HSSInterstitialAd.h>
#import <HSADXSDK/HSSRewardedAd.h>
#import <HSADXSDK/HSSADXBannerView.h>
#import <HSADXSDK/HSSAdDelegate.h>
#import <HSADXSDK/HSSRewardedAdDelegate.h>
#import <HSADXSDK/HSSBannerAdDelegate.h>

#define ADAPTER_VERSION @"1.0.0.0."

@interface ALHungryStudioMediationAdapterInterstitialAdDelegate : NSObject <HSSAdDelegate>
@property (nonatomic,   weak) ALHungryStudioMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *placementId;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALHungryStudioMediationAdapter *)parentAdapter
                               slotId:(NSString *)placementId
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALHungryStudioMediationAdapterRewardedAdDelegate : NSObject <HSSRewardedAdDelegate>
@property (nonatomic,   weak) ALHungryStudioMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *placementId;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALHungryStudioMediationAdapter *)parentAdapter
                               slotId:(NSString *)slotId
                            andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALHungryStudioMediationAdapterAdViewDelegate : NSObject <HSSBannerAdDelegate>
@property (nonatomic,   weak) ALHungryStudioMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *placementId;
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALHungryStudioMediationAdapter *)parentAdapter
                               slotId:(NSString *)placementId
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end


@interface ALHungryStudioMediationAdapter ()
@property (nonatomic, strong) HSSInterstitialAd *interstitialAd;
@property (nonatomic, strong) HSSRewardedAd *rewardedAd;
@property (nonatomic, strong) HSSADXBannerView *adViewAd;

@property (nonatomic, strong) ALHungryStudioMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALHungryStudioMediationAdapterRewardedAdDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) ALHungryStudioMediationAdapterAdViewDelegate *adViewAdapterDelegate;
@end

@implementation ALHungryStudioMediationAdapter

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if (![HSSdk shared].initialized) {
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"HungryAdsMediationAdapterParametersKey"];
        if ([dict isKindOfClass:NSDictionary.class] && dict.count > 0) {
            [self log:@"ALHungryStudioMediationAdapter initializeWithParameters HungryAdsMediationAdapterParameters = %@, ALHungryStudioMediationAdapter = %@", dict, self];
            NSString *token = dict[@"kADXSDKKey"];
            BOOL debugMode = NO;
       #if DEBUG
            debugMode = YES;
       #endif
            [self log:@"ALHungryStudioMediationAdapter [HSSdk shared].initialized = NO, so HSSdk start initializing !!!! ALHungryStudioMediationAdapter = %@", self];
            
            HSSdkInitialConfiguration *configure = [HSSdkInitialConfiguration configurationWithSdkKey:token
                                                                                         builderBlock:^(HSSdkConfigurationBuilder * _Nonnull builder) {
                builder.settings.muted = YES;
                builder.settings.debugMode = debugMode;
            }];
            [[HSSdk shared] initializeForBiddingWithConfiguration:configure completionHandler:^(HSSdkConfiguration * _Nonnull configuration) {
                completionHandler(MAAdapterInitializationStatusInitializedSuccess, nil);
            }];
        } else {
            [self log:@"ALHungryStudioMediationAdapter [HSSdk shared].initialized = NO, Initialization StatusInitialized Failure !!!! ALHungryStudioMediationAdapter = %@", self];
            completionHandler(MAAdapterInitializationStatusInitializedFailure, nil);
        }
    } else {
        [self log:@"ALHungryStudioMediationAdapter [HSSdk shared].initialized = YES, so HSSdk already initialized ALHungryStudioMediationAdapter = %@", self];
        completionHandler(MAAdapterInitializationStatusInitializedSuccess, nil);
    }
}

- (NSString *)SDKVersion
{
    return HSSdk.shared.version;
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for adapter %@", self];
    
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdapterDelegate.delegate = nil;
    self.interstitialAdapterDelegate = nil;
    
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;
    
    self.adViewAd.delegate = nil;
    self.adViewAd = nil;
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
        
    NSString *signal = [HSSMaxBiddingManager getBiddingToken];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"ALHungryStudioMediationAdapter Loading interstitial ad: %@...", placementIdentifier];
        
    self.interstitialAd = [[HSSInterstitialAd alloc] initWithAdPlacement:placementIdentifier];
    self.interstitialAdapterDelegate = [[ALHungryStudioMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter:self slotId:placementIdentifier andNotify:delegate];
    self.interstitialAd.delegate = self.interstitialAdapterDelegate;
    
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"ALHungryStudioMediationAdapter Loading bidding interstitial ad...,bid=%@",bidResponse];
    [self.interstitialAd loadAdWithMaxBidResponse:bidResponse];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"ALHungryStudioMediationAdapter Showing interstitial: %@...", parameters.thirdPartyAdPlacementIdentifier];
    if (![self.interstitialAd isReady] ) {
        [self log:@"ALHungryAdsMediationAdapter showInterstitialAdForParameters Interstitial ad failed to load - ad not ready !!!! "];
        if (delegate && [delegate respondsToSelector:@selector(didFailToDisplayInterstitialAdWithError:)]) {
            [delegate didFailToDisplayInterstitialAdWithError:[MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                            mediatedNetworkErrorCode: 0
                                                                         mediatedNetworkErrorMessage: @"Interstitial ad not ready"]];
        }
        return;
    }
    [self.interstitialAd showAdFromAdapter:YES];
}


#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"ALHungryStudioMediationAdapter Loading rewarded ad: %@...", placementIdentifier];
    
//    [self updateAdSettingsWithParameters: parameters];
    
    self.rewardedAd = [HSSRewardedAd sharedWithAdPlacement:placementIdentifier];
    self.rewardedAdapterDelegate = [[ALHungryStudioMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter:self slotId:placementIdentifier andNotify:delegate];
    self.rewardedAd.delegate = self.rewardedAdapterDelegate;
    
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"ALHungryStudioMediationAdapter Loading bidding rewarded ad...,bid=%@",bidResponse];
    [self.rewardedAd loadAdWithMaxBidResponse:bidResponse];
    
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log:@"ALHungryStudioMediationAdapter showRewardedAdForParameters Showing rewarded ad !!!!"];
    if (![self.rewardedAd isReady]) {
        [self log:@"ALHungryStudioMediationAdapter showRewardedAdForParameters Rewarded ad failed to load - ad not ready !!!"];
        if (delegate && [delegate respondsToSelector:@selector(didFailToDisplayRewardedAdWithError:)]) {
            [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                        mediatedNetworkErrorCode: 0
                                                                     mediatedNetworkErrorMessage: @"Rewarded ad not ready"]];
        }
        return;
    }
    [self.rewardedAd showAdFromAdapter:YES];
}

#pragma mark - MAAdViewAdapter Methods
- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    CGSize adSize = [self sizeFromAdFormat:adFormat];
    self.adViewAd = [[HSSADXBannerView alloc] initWithPlacementId:placementIdentifier adSize:adSize];
    
    self.adViewAdapterDelegate = [[ALHungryStudioMediationAdapterAdViewDelegate alloc] initWithParentAdapter:self
                                                                                                 slotId:placementIdentifier adFormat:adFormat
                                                                                              andNotify:delegate];
    self.adViewAd.delegate = self.adViewAdapterDelegate;
    
    NSString *bidResponse = parameters.bidResponse;
    [self.adViewAd loadAdWithMaxBidResponse:bidResponse];
    [self log:@"ALHungryStudioMediationAdapter loadAdViewAdForParameters adView loadAd !!!! bidResponse = %@", bidResponse];
}

#pragma mark - Shared Methods

- (CGSize)sizeFromAdFormat:(MAAdFormat *)adFormat {
    if ([adFormat isEqual:MAAdFormat.banner]) {
        return CGSizeMake(320, 50);
    } else if ([adFormat isEqual:MAAdFormat.leader]) {
        return CGSizeMake(728, 90);
    } else if ([adFormat isEqual:MAAdFormat.mrec]) {
        return CGSizeMake(300, 250);
    }
    return CGSizeMake(320, 50);
}

- (MAAdapterError *)toMaxError:(NSError *)error {
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch (error.code) {
        case -9001003:
            adapterError = MAAdapterError.noFill;
            break;
        case -1005:
            adapterError = MAAdapterError.noConnection;
            break;
        case -1001:
            adapterError = MAAdapterError.timeout;
            break;
    }
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: error.code
                     mediatedNetworkErrorMessage: (error.localizedDescription.length > 0) ? error.localizedDescription : @""];
}
@end

@implementation ALHungryStudioMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALHungryStudioMediationAdapter *)parentAdapter slotId:(NSString *)placementId andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    if (self = [super init]) {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - HSSAdDelegate

- (void)didLoadAd:(HSSAd *)ad {
    NSDictionary *customData = @{
        @"dsp_name": (ad.adMaterial.dspName.length > 0) ? ad.adMaterial.dspName : @"",
    };
    NSDictionary *extraDict = @{@"creative_id": (ad.adMaterial.cRid.length > 0) ? ad.adMaterial.cRid : @"",
                                @"publisher_extra_info": customData
    };
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadInterstitialAd)]) {
        [self.delegate didLoadInterstitialAd];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadInterstitialAdWithExtraInfo:)]) {
        [self.delegate didLoadInterstitialAdWithExtraInfo:extraDict];
    }
    
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterInterstitialAdDelegate didLoadInterstitialAd !!!"];
}

- (void)didFailToLoadAdForAd:(HSSAd *)ad withError:(HSSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToLoadInterstitialAdWithError:)]) {
        MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
        [self.delegate didFailToLoadInterstitialAdWithError:adapterError];
    }
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterInterstitialAdDelegate didFailToLoadAdForAd error = %@", error];
}

- (void)didDisplayAd:(HSSAd *)ad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisplayInterstitialAd)]) {
        [self.delegate didDisplayInterstitialAd];
    }
    
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterInterstitialAdDelegate didDisplayAd !!!"];
}

- (void)didHideAd:(HSSAd *)ad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHideInterstitialAd)]) {
        [self.delegate didHideInterstitialAd];
    }
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterInterstitialAdDelegate didHideAd !!!"];
}

- (void)didClickAd:(HSSAd *)ad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickInterstitialAd)]) {
        [self.delegate didClickInterstitialAd];
    }
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterInterstitialAdDelegate didClickAd !!!"];
}

- (void)didFailToDisplayAd:(HSSAd *)ad withError:(HSSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToDisplayInterstitialAdWithError:)]) {
        MAAdapterError *adapterError = [MAAdapterError errorWithCode:0 errorString:@"display ad fail"];
        [self.delegate didFailToDisplayInterstitialAdWithError:adapterError];
    }
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterInterstitialAdDelegate didFailToDisplayAd error = %@", error];
}

- (void)didClickAd:(nonnull HSSAd *)ad crossPromotionBlock:(nonnull void (^)(NSURLSession * _Nonnull, NSURL * _Nonnull))block {
    
}


- (void)didDisplayCrossAd:(nonnull HSSAd *)ad {
}

@end

@implementation ALHungryStudioMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALHungryStudioMediationAdapter *)parentAdapter slotId:(NSString *)placementId andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    if (self = [super init]) {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - HSSAdDelegate

- (void)didLoadAd:(HSSAd *)ad {
    NSDictionary *customData = @{
        @"dsp_name": (ad.adMaterial.dspName.length > 0) ? ad.adMaterial.dspName : @"",
    };
    NSDictionary *extraDict = @{@"creative_id": (ad.adMaterial.cRid.length > 0) ? ad.adMaterial.cRid : @"",
                                @"publisher_extra_info": customData
    };
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadRewardedAd)]) {
        [self.delegate didLoadRewardedAd];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadRewardedAdWithExtraInfo:)]) {
        [self.delegate didLoadRewardedAdWithExtraInfo:extraDict];
    }
    
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterRewardedAdDelegate didLoadInterstitialAd !!!"];
}

- (void)didFailToLoadAdForAd:(HSSAd *)ad withError:(HSSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToLoadRewardedAdWithError:)]) {
        MAAdapterError *adapterError = [self.parentAdapter toMaxError: error];
        [self.delegate didFailToLoadRewardedAdWithError:adapterError];
    }
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterRewardedAdDelegate didFailToLoadAdForAd error = %@", error];
}

- (void)didDisplayAd:(HSSAd *)ad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisplayRewardedAd)]) {
        [self.delegate didDisplayRewardedAd];
    }
    
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterRewardedAdDelegate didDisplayAd !!!"];
}

- (void)didHideAd:(HSSAd *)ad {
    if ([self hasGrantedReward]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRewardUserWithReward:)]) {
            MAReward *reward = [self.parentAdapter reward];
            [self.delegate didRewardUserWithReward:reward];
            [self.parentAdapter log:@"ALHungryStudioMediationAdapterRewardedAdDelegate didRewardUserWithReward !!! reward: %@", reward];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHideRewardedAd)]) {
        [self.delegate didHideRewardedAd];
    }
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterRewardedAdDelegate Rewarded ad closed !!!"];
}

- (void)didClickAd:(HSSAd *)ad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickRewardedAd)]) {
        [self.delegate didClickRewardedAd];
    }
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterRewardedAdDelegate didClickAd !!!"];
}

- (void)didFailToDisplayAd:(HSSAd *)ad withError:(HSSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToDisplayRewardedAdWithError:)]) {
        MAAdapterError *adapterError = [MAAdapterError errorWithCode:0 errorString:@"display ad fail"];
        [self.delegate didFailToDisplayRewardedAdWithError:adapterError];
    }
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterRewardedAdDelegate didFailToDisplayAd error = %@", error];
}

#pragma mark - HSSRewardedAdDelegate

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward {
    self.grantedReward = YES;
    [self.parentAdapter log:@"ALHungryStudioMediationAdapterRewardedAdDelegate Rewarded ad reward granted"];
}

- (void)didClickAd:(nonnull HSSAd *)ad crossPromotionBlock:(nonnull void (^)(NSURLSession * _Nonnull, NSURL * _Nonnull))block {
    
}


- (void)didDisplayCrossAd:(nonnull HSSAd *)ad {
}

@end

@implementation ALHungryStudioMediationAdapterAdViewDelegate
- (instancetype)initWithParentAdapter:(ALHungryStudioMediationAdapter *)parentAdapter
                               slotId:(NSString *)placementId
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    if (self = [super init]) {
        self.parentAdapter = parentAdapter;
        self.placementId = placementId;
        self.delegate = delegate;
        self.adFormat = adFormat;
    }
    return self;
}

#pragma mark - HSSBannerAdDelegate

- (void)didLoadBannerAd:(HSSADXBannerView *)ad {
    NSDictionary *customData = @{
        @"dsp_name": (ad.dspName.length > 0) ? ad.dspName : @"",
    };
    NSDictionary *extraDict = @{@"creative_id": (ad.crid.length > 0) ? ad.crid : @"",
                                @"publisher_extra_info": customData,
    };
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadAdForAdView:withExtraInfo:)]) {
        [self.delegate didLoadAdForAdView:ad withExtraInfo:extraDict];
        
        [self.parentAdapter log:@"ALHungryStudioMediationAdapterAdViewDelegate didLoadAdForAdView creative_id = %@ , dsp_name = %@", ad.crid, ad.dspName];
    }
}

- (void)didFailToLoadBannerAdForAd:(HSSADXBannerView *)ad withError:(HSSError *)error {
    NSString *errorString = @"";
    if (error.userInfo && [error.userInfo isKindOfClass:NSDictionary.class] && NSLocalizedDescriptionKey && [NSLocalizedDescriptionKey isKindOfClass:NSString.class]) {
        errorString = error.userInfo[NSLocalizedDescriptionKey];
    }
    MAAdapterError *adapterError = [MAAdapterError errorWithCode:error.code errorString:errorString];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToLoadAdViewAdWithError:)]) {
        [self.delegate didFailToLoadAdViewAdWithError:adapterError];
        [self.parentAdapter log:@"ALHungryStudioMediationAdapterAdViewDelegate didFailToLoadAdViewAdWithError adapterError = %@", adapterError];
    }
}

- (void)didClickBannerAd:(HSSADXBannerView *)ad {
    NSDictionary *extraDict = @{@"creative_id": ad.crid?:@""};
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAdViewAdWithExtraInfo:)]) {
        [self.delegate didClickAdViewAdWithExtraInfo:extraDict];
        [self.parentAdapter log:@"ALHungryStudioMediationAdapterAdViewDelegate didClickAdViewAdWithExtraInfo creative_id = %@", ad.crid];
    }
}

- (void)didDisplayBannerAd:(HSSADXBannerView *)ad {
    NSDictionary *extraDict = @{@"creative_id": ad.crid?:@""};
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisplayAdViewAdWithExtraInfo:)]) {
        [self.delegate didDisplayAdViewAdWithExtraInfo:extraDict];
        [self.parentAdapter log:@"ALHungryStudioMediationAdapterAdViewDelegate didDisplayAdViewAdWithExtraInfo creative_id = %@", ad.crid];
    }
}

- (void)didHideBannerAd:(HSSADXBannerView *)ad {
    NSDictionary *extraDict = @{@"creative_id": ad.crid?:@""};
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHideAdViewAdWithExtraInfo:)]) {
        [self.delegate didHideAdViewAdWithExtraInfo:extraDict];
        [self.parentAdapter log:@"ALHungryStudioMediationAdapterAdViewDelegate didHideAdViewAdWithExtraInfo creative_id = %@", ad.crid];
    }
}


@end

