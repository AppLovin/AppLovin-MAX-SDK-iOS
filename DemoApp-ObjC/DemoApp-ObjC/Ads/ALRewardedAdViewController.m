//
//  ALRewardedAdViewController.m
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALRewardedAdViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALRewardedAdViewController()<MARewardedAdDelegate>
@property (nonatomic, strong) MARewardedAd *rewardedAd;
@end

@implementation ALRewardedAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rewardedAd = [MARewardedAd sharedWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID"];
    self.rewardedAd.delegate = self;
    
    // Load the first ad
    [self.rewardedAd loadAd];
}

#pragma mark - IB Actions

- (IBAction)showAd
{
    if ( [self.rewardedAd isReady] )
    {
        [self.rewardedAd showAd];
    }
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    // Rewarded ad is ready to be shown. '[self.rewardedAd isReady]' will now return 'YES'
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode
{
    // Rewarded ad failed to load. We recommend re-trying in 3 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.rewardedAd loadAd];
    });
}

- (void)didDisplayAd:(MAAd *)ad {}

- (void)didClickAd:(MAAd *)ad {}

- (void)didHideAd:(MAAd *)ad
{
    // Rewarded ad is hidden. Pre-load the next ad
    [self.rewardedAd loadAd];
}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode
{
    // Rewarded ad failed to display. We recommend loading the next ad
    [self.rewardedAd loadAd];
}

#pragma mark - MARewardedAdDelegate Protocol

- (void)didStartRewardedVideoForAd:(MAAd *)ad {}

- (void)didCompleteRewardedVideoForAd:(MAAd *)ad {}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward
{
    // Rewarded ad was displayed and user should receive the reward
}

@end
