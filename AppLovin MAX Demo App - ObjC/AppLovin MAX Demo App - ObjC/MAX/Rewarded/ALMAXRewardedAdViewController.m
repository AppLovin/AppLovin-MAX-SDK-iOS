//
//  ALRewardedAdViewController.m
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALMAXRewardedAdViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXRewardedAdViewController()<MARewardedAdDelegate>
@property (nonatomic, strong) MARewardedAd *rewardedAd;
@property (nonatomic, assign) NSInteger retryAttempt;
@end

@implementation ALMAXRewardedAdViewController

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
    [self logCallback: __PRETTY_FUNCTION__];
    
    // Reset retry attempt
    self.retryAttempt = 0;
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode
{
    [self logCallback: __PRETTY_FUNCTION__];
    
    // Rewarded ad failed to load. We recommend retrying with exponentially higher delays.
    
    self.retryAttempt++;
    NSInteger delaySec = pow(2, self.retryAttempt);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delaySec * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.rewardedAd loadAd];
    });
}

- (void)didDisplayAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didClickAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didHideAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
    
    // Rewarded ad is hidden. Pre-load the next ad
    [self.rewardedAd loadAd];
}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode
{
    [self logCallback: __PRETTY_FUNCTION__];
    
    // Rewarded ad failed to display. We recommend loading the next ad
    [self.rewardedAd loadAd];
}

#pragma mark - MARewardedAdDelegate Protocol

- (void)didStartRewardedVideoForAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didCompleteRewardedVideoForAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward
{
    // Rewarded ad was displayed and user should receive the reward
    [self logCallback: __PRETTY_FUNCTION__];
}

@end
