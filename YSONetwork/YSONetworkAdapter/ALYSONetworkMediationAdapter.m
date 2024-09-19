//
//  ALYSONetworkMediationAdapter.m
//  Adapters
//
//  Created by Kenny Bui on 6/26/24.
//  Copyright © 2024 AppLovin. All rights reserved.
//

#import "ALYSONetworkMediationAdapter.h"
#import <YsoNetwork/YsoNetwork.h>
#import <YsoNetwork/YsoNetwork-Swift.h>

#define ADAPTER_VERSION @"1.1.28.0"

// NOTE: YSO initially named their adapter ALYsoNetworkMediationAdapter but iOS/Apple convention should be ALYSONetworkMediationAdapter. We will support both naming conventions.
@interface ALYsoNetworkMediationAdapter : ALYSONetworkMediationAdapter

@end

@implementation ALYSONetworkMediationAdapter
static ALAtomicBoolean               *ALYSONetworkInitialized;
static MAAdapterInitializationStatus ALYSONetworkInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    ALYSONetworkInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALYSONetworkInitialized compareAndSet: NO update: YES] )
    {
        [self log: @"Initializing YSO Network"];
        ALYSONetworkInitializationStatus = MAAdapterInitializationStatusInitializing;
        [YsoNetwork initializeWithViewController: [ALUtils topViewControllerFromKeyWindow]];
        
        if ( [YsoNetwork isInitialized] )
        {
            [self log: @"YSO Network successfully initialized"];
            ALYSONetworkInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
        }
        else
        {
            [self log: @"YSO Network failed to initialize"];
            ALYSONetworkInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
        }
        
        completionHandler(ALYSONetworkInitializationStatus, nil);
    }
    else
    {
        [self log: @"YSO Network attempted initialization already"];
        completionHandler(ALYSONetworkInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [YsoNetwork getSdkVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy {}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *signal = [YsoNetwork getSignal];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *key = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading interstitial ad for key: %@...", key];
    
    [YsoNetwork interstitialLoadWithKey: key
                                   json: bidResponse
                                 onLoad:^(e_ActionError error) {
        if ( error == e_ActionErrorNone )
        {
            [self log: @"Interstitial ad successfully loaded for key: %@", key];
            [delegate didLoadInterstitialAd];
            return;
        }
        
        MAAdapterError *adapterError = [ALYSONetworkMediationAdapter toMaxError: error];
        [self log: @"Interstitial ad failed to load for key: %@ and error: %ld", key, adapterError];
        [delegate didFailToLoadInterstitialAdWithError: adapterError];
    }];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *key = parameters.thirdPartyAdPlacementIdentifier;
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self log: @"Showing interstitial ad for key: %@...", key];
    
    [YsoNetwork interstitialShowWithKey: key
                         viewController: presentingViewController
                              onDisplay:^(YNWebView *view) {
        [self log: @"Interstitial ad displayed for key: %@", key];
        [delegate didDisplayInterstitialAd];
    } onClick:^{
        [self log: @"Interstitial ad clicked for key: %@", key];
        [delegate didClickInterstitialAd];
    } onClose:^(BOOL display, BOOL complete) {
        if ( !display )
        {
            [self log: @"Interstitial ad failed to display for key: %@", key];
            [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adDisplayFailedError];
            return;
        }
        
        [self log: @"Interstitial ad closed for key: %@", key];
        [delegate didHideInterstitialAd];
    }];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *key = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading rewarded ad for key: %@...", key];
    
    [YsoNetwork rewardedLoadWithKey: key
                               json: bidResponse
                             onLoad:^(e_ActionError error) {
        if ( error == e_ActionErrorNone )
        {
            [self log: @"Rewarded ad successfully loaded for key: %@", key];
            [delegate didLoadRewardedAd];
            return;
        }
        
        MAAdapterError *adapterError = [ALYSONetworkMediationAdapter toMaxError: error];
        [self log: @"Rewarded ad failed to load for key: %@ and error: %ld", key, adapterError];
        [delegate didFailToLoadRewardedAdWithError: adapterError];
    }];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *key = parameters.thirdPartyAdPlacementIdentifier;
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self log: @"Showing rewarded ad for key: %@...", key];
    
    [self configureRewardForParameters: parameters];
    
    [YsoNetwork rewardedShowWithKey: key
                     viewController: presentingViewController
                          onDisplay:^(YNWebView *view) {
        [self log: @"Rewarded ad displayed for key: %@", key];
        [delegate didDisplayRewardedAd];
    } onClick:^{
        [self log: @"Rewarded ad clicked for key: %@", key];
        [delegate didClickRewardedAd];
    } onClose:^(BOOL display, BOOL complete) {
        if ( !display )
        {
            [self log: @"Rewarded ad failed to display for key: %@", key];
            [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adDisplayFailedError];
            return;
        }
        
        if ( complete || [self shouldAlwaysRewardUser] )
        {
            MAReward *reward = [self reward];
            [self log: @"Rewarded user with reward: %@", reward];
            [delegate didRewardUserWithReward: reward];
        }
        
        [self log: @"Rewarded ad closed for key: %@", key];
        [delegate didHideRewardedAd];
    }];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *key = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    [self log: @"Loading ad view ad for key: %@...", key];
    
    [YsoNetwork bannerLoadWithKey: key
                             json: bidResponse
                           onLoad:^(e_ActionError error) {
        if ( error != e_ActionErrorNone )
        {
            MAAdapterError *adapterError = [ALYSONetworkMediationAdapter toMaxError: error];
            [self log: @"Ad view ad failed to load for key: %@ and error: %ld", key, adapterError];
            [delegate didFailToLoadAdViewAdWithError: adapterError];
            return;
        }
        
        [self log: @"Ad view ad successfully loaded for key: %@", key];
        [self log: @"Showing ad view ad for key: %@...", key];
        
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [YsoNetwork bannerShowWithKey: key
                       viewController: presentingViewController
                            onDisplay:^(YNWebView *view) {
            [self log: @"Ad view ad displayed for key: %@", key];
            // TODO: Decouple load and show logic
            [delegate didLoadAdForAdView: view];
            [delegate didDisplayAdViewAd];
        } onClick:^{
            [self log: @"Ad view ad clicked for key: %@", key];
            [delegate didClickAdViewAd];
        } onClose:^(BOOL display, BOOL complete) {
            if ( !display )
            {
                [self log: @"Ad view ad failed to display for key: %@", key];
                return;
            }
            
            [self log: @"Ad view ad closed for key: %@", key];
        }];
    }];
}

#pragma mark - Helper Methods

+ (MAAdapterError *)toMaxError:(e_ActionError)error
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( error )
    {
        case e_ActionErrorSdkNotInitialized:
            adapterError = MAAdapterError.notInitialized;
            break;
        case e_ActionErrorInvalidRequest:
            adapterError = MAAdapterError.badRequest;
            break;
        case e_ActionErrorInvalidConfig:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case e_ActionErrorTimeout:
            adapterError = MAAdapterError.timeout;
            break;
        case e_ActionErrorLoad:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case e_ActionErrorServer:
            adapterError = MAAdapterError.serverError;
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: error
                     mediatedNetworkErrorMessage: @""];
}

@end

@implementation ALYsoNetworkMediationAdapter

@end
