//
//  ALDataseatMediationAdapter.m
//  AppLovinSDK
//
//  Created by Ashley Kulasxa on 8/23/21.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALDataseatMediationAdapter.h"
#import <DataseatSDK/Dataseat.h>
#import <DataseatSDK/DSErrorCode.h>
#import "ALMediationAdapterRouter.h"
#import "ALUtils.h"
#import "NSDictionary+ALUtils.h"
#import "MAAdFormat+Internal.h"

#define ADAPTER_VERSION @"1.0.5.1"

@interface ALDataseatMediationAdapterRouter : ALMediationAdapterRouter<DSSDKDelegate>
@end

@interface ALDataseatMediationAdapter()
@property (nonatomic, strong, readonly) ALDataseatMediationAdapterRouter *router;
@property (nonatomic, copy) NSString *routerPlacementIdentifer;
@end

@implementation ALDataseatMediationAdapter
@dynamic router;

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self log: @"Initializing Dataseat SDK..."];
        [[Dataseat shared] initializeSDK: self.router];
    });
    
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (NSString *)SDKVersion
{
    return [Dataseat version];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self.router removeAdapter: self forPlacementIdentifier: self.routerPlacementIdentifer];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self.routerPlacementIdentifer = parameters.thirdPartyAdPlacementIdentifier;
    
    NSDictionary *customParameters = [parameters.serverParameters al_dictionaryForKey: @"custom_parameters"];
    float bidFloor = [customParameters al_numberForKey: @"bid_floor"].floatValue;
    
    [self log: @"Loading interstitial ad for tag: %@ and bid floor: %f", self.routerPlacementIdentifer, bidFloor];
    
    [self.router addInterstitialAdapter: self
                               delegate: delegate
                 forPlacementIdentifier: self.routerPlacementIdentifer];
    
    [[Dataseat shared] preloadInterstitial: NO tag: self.routerPlacementIdentifer bidfloor: bidFloor completion:^(NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALDataseatMediationAdapter toMaxError: error];
            [self log: @"Interstitial ad failed to load for tag: %@ with error: %@", self.routerPlacementIdentifer, adapterError];
            
            [self.router didFailToLoadAdForPlacementIdentifier: self.routerPlacementIdentifer error: adapterError];
            
            return;
        }
        
        [self log: @"Interstitial ad loaded for tag: %@", self.routerPlacementIdentifer];
        [self.router didLoadAdForPlacementIdentifier: self.routerPlacementIdentifer];
    }];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad with tag: %@...", self.routerPlacementIdentifer];
    
    [self.router addShowingAdapter: self];
    
    if ( [[Dataseat shared] hasInterstitialAdAvailable] )
    {
        [[Dataseat shared] showInterstitialAd: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Unable to show interstitial - ad not ready"];
        [self.router didFailToDisplayAdForPlacementIdentifier: self.routerPlacementIdentifer error: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self.routerPlacementIdentifer = parameters.thirdPartyAdPlacementIdentifier;
    
    NSDictionary *customParameters = [parameters.serverParameters al_dictionaryForKey: @"custom_parameters"];
    float bidFloor = [customParameters al_numberForKey: @"bid_floor"].floatValue;
    
    [self log: @"Loading rewarded ad for tag: %@ and bid floor: %f", self.routerPlacementIdentifer, bidFloor];
    
    [self.router addRewardedAdapter: self
                           delegate: delegate
             forPlacementIdentifier: self.routerPlacementIdentifer];
    
    [[Dataseat shared] preloadInterstitial: YES tag: self.routerPlacementIdentifer bidfloor: bidFloor completion:^(NSError *_Nullable error) {

        if ( error )
        {
            MAAdapterError *adapterError = [ALDataseatMediationAdapter toMaxError: error];
            [self log: @"Rewarded ad failed to load for tag: %@ with error: %@", self.routerPlacementIdentifer, adapterError];
            
            [self.router didFailToLoadAdForPlacementIdentifier: self.routerPlacementIdentifer error: adapterError];
            
            return;
        }
        
        [self log: @"Rewarded ad loaded for tag: %@", self.routerPlacementIdentifer];
        [self.router didLoadAdForPlacementIdentifier: self.routerPlacementIdentifer];
    }];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad with tag: %@...", self.routerPlacementIdentifer];
    
    [self.router addShowingAdapter: self];
    
    if ( [[Dataseat shared] hasRewardedAdAvailable] )
    {
        [self configureRewardForParameters: parameters];
        
        [[Dataseat shared] showRewardedAd: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Unable to show rewarded ad with tag: %@", self.routerPlacementIdentifer];
        [self.router didFailToDisplayAdForPlacementIdentifier: self.routerPlacementIdentifer error: MAAdapterError.adNotReady];
    }
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(NSError *)dataseatError
{
    if ( !dataseatError ) return MAAdapterError.unspecified;
    
    NSInteger dataseatErrorCode = dataseatError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
    switch ( dataseatErrorCode )
    {
        case ErrorUnknown:
            adapterError = MAAdapterError.unspecified;
            break;
        case ErrorVideoPlayerFailedToPlay:
        case ErrorFullScreenAdAlreadyShown:
            adapterError = MAAdapterError.internalError;
            break;
        case ErrorNetworkConnectionFailed:
            adapterError = MAAdapterError.noConnection;
            break;
        case ErrorNetworkNoResponse:
            adapterError = MAAdapterError.serverError;
            break;
        case ErrorNetworkInvalidRequest:
            adapterError = MAAdapterError.badRequest;
            break;
        case ErrorNoBid:
        case ErrorNetworkEmptyResponse:
            adapterError = MAAdapterError.noFill;
            break;
    }
    
    // If the Dataseat SDK is not fully initialized, it returns an NSError object that will crash the app if we call `description` or `localizedDescription` on it. This will hopefully be fixed in a future SDK release.
    return [MAAdapterError errorWithCode: adapterError.code
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: dataseatErrorCode
               thirdPartySdkErrorMessage: @""];
}

#pragma mark - Dynamic Properties

- (ALDataseatMediationAdapterRouter *)router
{
    return [ALDataseatMediationAdapterRouter sharedInstance];
}

@end

@implementation ALDataseatMediationAdapterRouter

- (void)fullScreenAdDidFailToLoadWithError:(NSError *)error forTag:(NSString *)tag
{
    MAAdapterError *adapterError = [ALDataseatMediationAdapter toMaxError: error];
    [self log: @"Ad with tag %@ failed to load with error: %@", tag, adapterError];
    [self didFailToLoadAdForPlacementIdentifier: tag error: adapterError];
}

- (void)fullscreenAdWillAppearForTag:(NSString *)tag
{
    [self log: @"Ad will show with tag: %@", tag];
}

- (void)fullscreenAdDidAppearForTag:(NSString *)tag
{
    [self log: @"Ad is shown with tag: %@", tag];
    
    [self didDisplayAdForPlacementIdentifier: tag];
    [self didStartRewardedVideoForPlacementIdentifier: tag];
}

- (void)fullscreenAdWillDisappearForTag:(NSString *)tag
{
    [self log: @"Ad will hide with tag: %@", tag];
}

- (void)fullscreenAdDidDisappearForTag:(NSString *)tag
{
    [self log: @"Ad did hide with tag: %@", tag];
}

- (void)fullscreenAdWillDismissForTag:(NSString *)tag
{
    [self log: @"Ad will dismiss with tag: %@", tag];
}

- (void)fullscreenAdDidDismissForTag:(NSString *)tag
{
    [self log: @"Ad did dismiss with tag: %@", tag];
    
    [self didCompleteRewardedVideoForPlacementIdentifier: tag];
    
    if ( [self shouldAlwaysRewardUserForPlacementIdentifier: tag] )
    {
        MAReward *reward = [self rewardForPlacementIdentifier: tag];
        [self log: @"Rewarded ad rewarded user with reward: %@ for tag: %@", reward, tag];
        [self didRewardUserForPlacementIdentifier: tag withReward: reward];
    }
    
    [self didHideAdForPlacementIdentifier: tag];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [ALUtils topViewControllerFromKeyWindow];
}

- (void)bannerAdDidCollapseForTag:(NSString *)tag
{
    // Not used for fullscreen ads
}

- (void)bannerAdDidFailToLoadWithError:(NSError *)error forTag:(NSString *)tag
{
    // Not used for fullscreen ads
}

- (void)bannerAdWillExpandForTag:(NSString *)tag
{
    // Not used for fullscreen ads
}

- (void)bannerDidClickForTag:(NSString *)tag
{
    // Not used for fullscreen ads
}

- (void)bannerDidLoadInWebViewForTag:(NSString *)tag
{
    // Not used for fullscreen ads
}

@end
