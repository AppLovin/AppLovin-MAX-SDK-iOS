//
//  ALMAXAutoLayoutBannerAdViewController.m
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALMAXAutoLayoutBannerAdViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXAutoLayoutBannerAdViewController()<MAAdViewAdDelegate, MAAdRevenueDelegate>
@property (nonatomic, strong) MAAdView *adView;
@end

@implementation ALMAXAutoLayoutBannerAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.adView = [[MAAdView alloc] initWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID"];
    
    self.adView.delegate = self;
    self.adView.revenueDelegate = self;
    
    self.adView.translatesAutoresizingMaskIntoConstraints = NO;

    // Set background or background color for banners to be fully functional
    self.adView.backgroundColor = UIColor.blackColor;

    [self.view addSubview: self.adView];

    // Anchor the banner to the left, right, and top of the screen.
    [[self.adView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor] setActive: YES];
    [[self.adView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor] setActive: YES];
    [[self.adView.topAnchor constraintEqualToAnchor: self.view.topAnchor] setActive: YES];
    
    [[self.adView.widthAnchor constraintEqualToAnchor: self.view.widthAnchor] setActive: YES];
    [[self.adView.heightAnchor constraintEqualToConstant: UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 90 : 50 ] setActive: YES];
    
    // Load the first ad
    [self.adView loadAd];
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didDisplayAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didHideAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didClickAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error
{
    [self logCallback: __PRETTY_FUNCTION__];
}

#pragma mark - MAAdViewAdDelegate Protocol

- (void)didExpandAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didCollapseAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

#pragma mark - MAAdRevenueDelegate Protocol

- (void)didPayRevenueForAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

@end
