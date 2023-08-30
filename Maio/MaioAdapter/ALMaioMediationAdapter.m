//
//  ALMaioMediationAdapter.m
//  MaioAdapter
//
//  Created by Harry Arakkal on 7/1/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

#import "ALMaioMediationAdapter.h"
#import <Maio/Maio-Swift.h>

#define ADAPTER_VERSION @"2.0.0.0"

@interface ALMaioMediationAdapterInterstitialAdDelegate : NSObject <MaioInterstitialLoadCallback, MaioInterstitialShowCallback>
@property (nonatomic, weak) ALMaioMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMaioMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALMaioMediationAdapterRewardedAdDelegate : NSObject <MaioRewardedLoadCallback, MaioRewardedShowCallback>
@property (nonatomic, weak) ALMaioMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALMaioMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALMaioMediationAdapter ()

@property (nonatomic) BOOL isTesting;
@property (nonatomic, strong) MaioInterstitial *maioInterstitial;
@property (nonatomic, strong) MaioRewarded *maioRewarded;

@property (nonatomic, strong) ALMaioMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALMaioMediationAdapterRewardedAdDelegate *rewardedAdapterDelegate;

@end

@implementation ALMaioMediationAdapter

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void(^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    self.isTesting = parameters.isTesting;

    // Maio SDK does not have any API for initialization.
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (NSString *)SDKVersion
{
    return [[MaioVersion shared] toString];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for adapter: %@", self];

    self.maioInterstitial = nil;
    self.interstitialAdapterDelegate.delegate = nil;
    self.interstitialAdapterDelegate = nil;

    self.maioRewarded = nil;
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *zoneID = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad: %@...", zoneID];

    self.interstitialAdapterDelegate = [[ALMaioMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter:self andNotify:delegate];

    MaioRequest *request = [[MaioRequest alloc] initWithZoneId:zoneID testMode:self.isTesting];
    self.maioInterstitial = [MaioInterstitial loadAdWithRequest:request callback:self.interstitialAdapterDelegate];
}

- (void)showInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];

    if ( self.maioInterstitial != nil )
    {
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }

        [self.maioInterstitial showWithViewContext:presentingViewController callback:self.interstitialAdapterDelegate];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];

        [delegate didFailToDisplayInterstitialAdWithError:[MAAdapterError errorWithCode:-4205
                                                                            errorString:@"Ad Display Failed"
                                                               mediatedNetworkErrorCode:0
                                                            mediatedNetworkErrorMessage:@"Interstitial ad not ready"]];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MARewardedAdapterDelegate>)delegate
{
    NSString *zoneID = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad: %@...", zoneID];

    self.rewardedAdapterDelegate = [[ALMaioMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter:self andNotify:delegate];

    MaioRequest *request = [[MaioRequest alloc] initWithZoneId:zoneID testMode:self.isTesting];
    self.maioRewarded = [MaioRewarded loadAdWithRequest:request callback:self.rewardedAdapterDelegate];
}

- (void)showRewardedAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];

    if ( self.maioRewarded != nil )
    {
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }

        [self.maioRewarded showWithViewContext:presentingViewController callback:self.rewardedAdapterDelegate];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];

        [delegate didFailToDisplayRewardedAdWithError:[MAAdapterError errorWithCode:-4205
                                                                        errorString:@"Ad Display Failed"
                                                           mediatedNetworkErrorCode:0
                                                        mediatedNetworkErrorMessage:@"Rewarded ad not ready"]];
    }
}

#pragma mark - Helper functions

- (MAAdapterError *)toMaxError:(NSInteger)maioErrorCode
{
    NSString *errorCodeString = [NSString stringWithFormat:@"%ld", maioErrorCode];
    NSString *maioErrorMessage = @"Unknown";
    MAAdapterError *adapterError = MAAdapterError.unspecified;

    if ( [errorCodeString hasPrefix:@"101"] )
    {
        maioErrorMessage = @"NoNetwork";
        adapterError = MAAdapterError.noConnection;
    }
    else if ( [errorCodeString hasPrefix:@"102"] )
    {
        maioErrorMessage = @"NetworkTimeout";
        adapterError = MAAdapterError.timeout;
    }
    else if ( [errorCodeString hasPrefix:@"103"] )
    {
        maioErrorMessage = @"AbortedDownload";
        adapterError = MAAdapterError.adNotReady;
    }
    else if ( [errorCodeString hasPrefix:@"104"] )
    {
        maioErrorMessage = @"InvalidResponse";
        adapterError = MAAdapterError.serverError;
    }
    else if ( [errorCodeString hasPrefix:@"105"] )
    {
        maioErrorMessage = @"ZoneNotFound";
        adapterError = MAAdapterError.invalidConfiguration;
    }
    else if ( [errorCodeString hasPrefix:@"106"] )
    {
        maioErrorMessage = @"UnavailableZone";
        adapterError = MAAdapterError.invalidConfiguration;
    }
    else if ( [errorCodeString hasPrefix:@"107"] )
    {
        maioErrorMessage = @"NoFill";
        adapterError = MAAdapterError.noFill;
    }
    else if ( [errorCodeString hasPrefix:@"108"] )
    {
        maioErrorMessage = @"NilArgMaioRequest";
        adapterError = MAAdapterError.badRequest;
    }
    else if ( [errorCodeString hasPrefix:@"109"] )
    {
        maioErrorMessage = @"DiskSpaceNotEnough";
        adapterError = MAAdapterError.internalError;
    }
    else if ( [errorCodeString hasPrefix:@"110"] )
    {
        maioErrorMessage = @"UnsupportedOsVer";
        adapterError = MAAdapterError.unspecified;
    }
    else if ( [errorCodeString hasPrefix:@"201"] )
    {
        maioErrorMessage = @"Expired";
        adapterError = MAAdapterError.adExpiredError;
    }
    else if ( [errorCodeString hasPrefix:@"202"] )
    {
        maioErrorMessage = @"NotReadyYet";
        adapterError = MAAdapterError.adNotReady;
    }
    else if ( [errorCodeString hasPrefix:@"203"] )
    {
        maioErrorMessage = @"AlreadyShown";
        adapterError = MAAdapterError.internalError;
    }
    else if ( [errorCodeString hasPrefix:@"204"] )
    {
        maioErrorMessage = @"FailedPlayback";
        adapterError = MAAdapterError.webViewError;
    }
    else if ( [errorCodeString hasPrefix:@"205"] )
    {
        maioErrorMessage = @"NilArgViewController";
        adapterError = MAAdapterError.missingViewController;
    }
    else
    {
        maioErrorMessage = @"Unknown";
        adapterError = MAAdapterError.unspecified;
    }

    return [MAAdapterError errorWithCode:adapterError.code
                             errorString:adapterError.message
                mediatedNetworkErrorCode:maioErrorCode
             mediatedNetworkErrorMessage:maioErrorMessage];
}

@end

#pragma mark - ALMaioMediationAdapterInterstitialAdDelegate

@implementation ALMaioMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALMaioMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)didLoad:(MaioInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad loaded: %@", ad.request.zoneId];
    [self.delegate didLoadInterstitialAd];
}

- (void)didOpen:(MaioInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad started: %@", ad.request.zoneId];
    [self.delegate didDisplayInterstitialAd];
}

- (void)didClose:(MaioInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad closed: %@", ad.request.zoneId];
    [self.delegate didHideInterstitialAd];
}

- (void)didFail:(MaioInterstitial *)ad errorCode:(NSInteger)errorCode
{
    MAAdapterError *error = [self.parentAdapter toMaxError:errorCode];

    if ( 10000 <= errorCode && errorCode < 20000 )
    {
        // Fail to load.
        [self.parentAdapter log: @"Interstitial ad failed to load with Maio reason: %@, and MAX error: %@", error.mediatedNetworkErrorMessage, error];
        [self.delegate didFailToLoadInterstitialAdWithError:error];
    }
    else if ( 20000 <= errorCode && errorCode < 30000 )
    {
        // Fail to show.
        [self.parentAdapter log: @"Interstitial ad failed to display with Maio reason: %@ and MAX error: %@", error.mediatedNetworkErrorMessage, error];
        [self.delegate didFailToDisplayInterstitialAdWithError:error];
    }
    else
    {
        // Unknown error code
        [self.delegate didFailToLoadInterstitialAdWithError:error];
    }
}

@end

#pragma mark - ALMaioMediationAdapterRewardedAdDelegate

@implementation ALMaioMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALMaioMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)didLoad:(MaioRewarded *)ad
{
    [self.parentAdapter log: @"Rewarded ad loaded: %@", ad.request.zoneId];
    [self.delegate didLoadRewardedAd];
}

- (void)didOpen:(MaioRewarded *)ad
{
    [self.parentAdapter log: @"Rewarded ad started: %@", ad.request.zoneId];
    [self.delegate didDisplayRewardedAd];
}

- (void)didClose:(MaioRewarded *)ad
{
    [self.parentAdapter log: @"Rewarded ad closed: %@", ad.request.zoneId];
    [self.delegate didHideRewardedAd];
}

- (void)didReward:(MaioRewarded *)ad reward:(RewardData *)reward
{
    MAReward *maReward = [self.parentAdapter reward];
    [self.parentAdapter log: @"Rewarded user with reward: %@", maReward];
    [self.delegate didRewardUserWithReward:maReward];
}

- (void)didFail:(MaioRewarded *)ad errorCode:(NSInteger)errorCode
{
    MAAdapterError *error = [self.parentAdapter toMaxError:errorCode];

    if ( 10000 <= errorCode && errorCode < 20000 )
    {
        // Fail to load.
        [self.parentAdapter log: @"Rewarded ad failed to load with Maio reason: %@, and MAX error: %@", error.mediatedNetworkErrorMessage, error];
        [self.delegate didFailToLoadRewardedAdWithError:error];
    }
    else if ( 20000 <= errorCode && errorCode < 30000 )
    {
        // Fail to show.
        [self.parentAdapter log: @"Rewarded ad failed to display with Maio reason: %@ and MAX error: %@", error.mediatedNetworkErrorMessage, error];
        [self.delegate didFailToDisplayRewardedAdWithError:error];
    }
    else
    {
        // Unknown error code
        [self.delegate didFailToLoadRewardedAdWithError:error];
    }
}

@end
