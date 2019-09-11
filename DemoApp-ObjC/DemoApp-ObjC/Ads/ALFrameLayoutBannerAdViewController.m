//
//  ALFrameLayoutBannerAdViewController.m
//  DemoApp-ObjC
//
//  Created by Andrew Tian on 9/10/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALFrameLayoutBannerAdViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALFrameLayoutBannerAdViewController()<MAAdViewAdDelegate>
@property (nonatomic, strong) MAAdView *adView;
@end

@implementation ALFrameLayoutBannerAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.adView = [[MAAdView alloc] initWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID"];
    self.adView.delegate = self;
    
    // Calculate dimensions
    CGFloat width = CGRectGetWidth(self.view.bounds); // Stretch to the width of the screen for banners to be fully functional
    CGFloat height = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 90 : 50; // Banner height on iPhone and iPad is 50 and 90, respectively
    CGFloat x = 0;
    CGFloat y = 0;
    
    self.adView.frame = CGRectMake(x, y, width, height);
    
    // Set background or background color for banners to be fully functional
    self.adView.backgroundColor = UIColor.blackColor;
    
    [self.view addSubview: self.adView];
    
    // Load the first ad
    [self.adView loadAd];
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad {}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode {}

- (void)didDisplayAd:(MAAd *)ad {}

- (void)didHideAd:(MAAd *)ad {}

- (void)didClickAd:(MAAd *)ad {}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode {}

#pragma mark - MAAdViewAdDelegate Protocol

- (void)didExpandAd:(MAAd *)ad {}

- (void)didCollapseAd:(MAAd *)ad {}

@end
