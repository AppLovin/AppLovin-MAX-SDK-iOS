//
//  ALMAXAppOpenAdViewController.m
//  AppLovin MAX Demo App - ObjC
//
//  Created by Avi Leung on 2/13/23.
//  Copyright © 2023 AppLovin Corporation. All rights reserved.
//

#import "ALMAXAppOpenAdViewController.h"
#import "ALBaseAdViewController.h"
#import <Adjust/Adjust.h>
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXAppOpenAdViewController ()<MAAdDelegate, MAAdRevenueDelegate>
@property (nonatomic, strong) MAAppOpenAd *appOpenAd;
@end

@implementation ALMAXAppOpenAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appOpenAd = [[MAAppOpenAd alloc] initWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID"];
    
    self.appOpenAd.delegate = self;
    self.appOpenAd.revenueDelegate = self;
    
    // Load the first ad
    [self.appOpenAd loadAd];
}

#pragma mark - IB Actions

- (IBAction)showAd
{
    if ( [self.appOpenAd isReady] )
    {
        [self.appOpenAd showAd];
    }
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    // App Open ad is ready to be shown. '[self.appOpenAd isReady]' will now return 'YES'
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

- (void)didClickAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didHideAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
    
    // App Open ad is hidden. Pre-load the next ad
    [self.appOpenAd loadAd];
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error
{
    [self logCallback: __PRETTY_FUNCTION__];
    
    // App Open ad failed to display. We recommend loading the next ad
    [self.appOpenAd loadAd];
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

