//
//  ALGoogleRewardedInterstitialDelegate.m
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Thomas So on 7/21/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALGoogleRewardedInterstitialDelegate.h"

@interface ALGoogleRewardedInterstitialDelegate()
@property (nonatomic, weak) ALGoogleMediationAdapter *parentAdapter;
@property (nonatomic, copy) NSString *placementIdentifier;
@property (nonatomic, strong) id<MARewardedInterstitialAdapterDelegate> delegate;
@end

@implementation ALGoogleRewardedInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MARewardedInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementIdentifier = placementIdentifier;
        self.delegate = delegate;
    }
    return self;
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded interstitial ad shown: %@", self.placementIdentifier];
    [self.delegate didStartRewardedInterstitialAdVideo];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *adapterError = [MAAdapterError errorWithCode: -4205
                                                     errorString: @"Ad Display Failed"
                                          thirdPartySdkErrorCode: error.code
                                       thirdPartySdkErrorMessage: error.localizedDescription];
#pragma clang diagnostic pop
    
    [self.parentAdapter log: @"Rewarded interstitial ad (%@) failed to show: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToDisplayRewardedInterstitialAdWithError: adapterError];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded interstitial ad impression recorded: %@", self.placementIdentifier];
    [self.delegate didDisplayRewardedInterstitialAd];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded interstitial ad click recorded: %@", self.placementIdentifier];
    [self.delegate didClickRewardedInterstitialAd];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.delegate didCompleteRewardedInterstitialAdVideo];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded interstitial ad rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded interstitial ad hidden: %@", self.placementIdentifier];
    [self.delegate didHideRewardedInterstitialAd];
}

@end
