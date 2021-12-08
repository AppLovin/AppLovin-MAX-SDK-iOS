//
//  ALMAXAutoLayoutMRecAdViewController.m
//  DemoApp-ObjC
//
//  Created by Andrew Tian on 1/14/20.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALMAXAutoLayoutMRecAdViewController.h"
#import <Adjust/Adjust.h>
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXAutoLayoutMRecAdViewController()<MAAdViewAdDelegate, MAAdRevenueDelegate>
@property (nonatomic, strong) MAAdView *adView;
@end

@implementation ALMAXAutoLayoutMRecAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.adView = [[MAAdView alloc] initWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID" adFormat: MAAdFormat.mrec];
    
    self.adView.delegate = self;
    self.adView.revenueDelegate = self;
    
    self.adView.translatesAutoresizingMaskIntoConstraints = NO;

    // Set background or background color for MRECs to be fully functional
    self.adView.backgroundColor = UIColor.blackColor;

    [self.view addSubview: self.adView];

    // Center the MREC and anchor it to the top of the screen.
    [[self.adView.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor] setActive: YES];
    [[self.adView.topAnchor constraintEqualToAnchor: self.view.topAnchor] setActive: YES];
    
    [[self.adView.widthAnchor constraintEqualToConstant: 300] setActive: YES];
    [[self.adView.heightAnchor constraintEqualToConstant: 250] setActive: YES];
    
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
    
    ADJAdRevenue *adjustAdRevenue = [[ADJAdRevenue alloc] initWithSource: ADJAdRevenueSourceAppLovinMAX];
    [adjustAdRevenue setRevenue: ad.revenue currency: @"USD"];
    [adjustAdRevenue setAdRevenueNetwork: ad.networkName];
    [adjustAdRevenue setAdRevenueUnit: ad.adUnitIdentifier];
    [adjustAdRevenue setAdRevenuePlacement: ad.placement];
        
    [Adjust trackAdRevenue: adjustAdRevenue];
}

@end
