//
//  ALInterstitialAdViewController.m
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALInterstitialAdViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALInterstitialAdViewController()<MAAdDelegate>
@property (nonatomic, strong) MAInterstitialAd *interstitialAd;
@end

@implementation ALInterstitialAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID"];
    self.interstitialAd.delegate = self;
    
    // Load the first ad
    [self.interstitialAd loadAd];
}

#pragma mark - IB Actions

- (IBAction)showAd
{
    if ( [self.interstitialAd isReady] )
    {
        [self.interstitialAd showAd];
    }
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    // Interstitial ad is ready to be shown. '[self.interstitialAd isReady]' will now return 'YES'
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode
{
    // Interstitial ad failed to load. We recommend re-trying in 3 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.interstitialAd loadAd];
    });
}

- (void)didDisplayAd:(MAAd *)ad {}

- (void)didClickAd:(MAAd *)ad {}

- (void)didHideAd:(MAAd *)ad
{
    // Interstitial ad is hidden. Pre-load the next ad
    [self.interstitialAd loadAd];
}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode
{
    // Interstitial ad failed to display. We recommend loading the next ad
    [self.interstitialAd loadAd];
}

@end
