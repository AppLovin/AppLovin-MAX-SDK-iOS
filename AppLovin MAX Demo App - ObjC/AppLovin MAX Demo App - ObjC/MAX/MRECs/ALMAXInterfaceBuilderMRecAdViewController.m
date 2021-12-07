//
//  ALMAXInterfaceBuilderMRecAdViewController.m
//  DemoApp-ObjC
//
//  Created by Andrew Tian on 1/23/20.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALMAXInterfaceBuilderMRecAdViewController.h"
#import <Adjust/Adjust.h>
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXInterfaceBuilderMRecAdViewController()<MAAdViewAdDelegate, MAAdRevenueDelegate>
@property (nonatomic, strong) IBOutlet MAAdView *adView;
@end

@implementation ALMAXInterfaceBuilderMRecAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // NOTE: Must set Storyboard "User Defined Runtime Attributes" for MREC ad view
    // Key Path = ad_unit_id
    // Type     = String
    // Value    = YOUR_AD_UNIT_ID
    
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
