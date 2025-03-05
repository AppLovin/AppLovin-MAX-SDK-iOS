//
//  ALGoogleRewardedDelegate.m
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Thomas So on 7/21/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALGoogleRewardedDelegate.h"

@interface ALGoogleRewardedDelegate ()
@property (nonatomic,   weak) ALGoogleMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@end

@implementation ALGoogleRewardedDelegate

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MARewardedAdapterDelegate>)delegate
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
    [self.parentAdapter log: @"Rewarded ad shown: %@", self.placementIdentifier];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.localizedDescription];
    [self.parentAdapter log: @"Rewarded ad (%@) failed to show: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded ad impression recorded: %@", self.placementIdentifier];
    [self.delegate didDisplayRewardedAd];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded ad click recorded: %@", self.placementIdentifier];
    [self.delegate didClickRewardedAd];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden: %@", self.placementIdentifier];
    [self.delegate didHideRewardedAd];
}

@end
