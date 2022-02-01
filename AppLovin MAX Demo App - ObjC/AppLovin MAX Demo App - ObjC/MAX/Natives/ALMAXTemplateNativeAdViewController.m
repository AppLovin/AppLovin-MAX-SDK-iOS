//
//  ALMAXTemplateNativeAdViewController.m
//  AppLovin MAX Demo App - ObjC
//
//  Created by Billy Hu on 1/20/22.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMAXTemplateNativeAdViewController.h"
#import "ALBaseAdViewController.h"
#import <Adjust/Adjust.h>
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXTemplateNativeAdViewController()<MANativeAdDelegate, MAAdRevenueDelegate>
@property (nonatomic, weak) IBOutlet UIView *nativeAdContainerView;

@property (nonatomic, strong) MANativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) MAAd *nativeAd;
@property (nonatomic, strong) UIView *nativeAdView;

@end

@implementation ALMAXTemplateNativeAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nativeAdLoader = [[MANativeAdLoader alloc] initWithAdUnitIdentifier: @"YOUR_AD_UNIT"];
    self.nativeAdLoader.placement = @"Native Template Test Placement";
    [self.nativeAdLoader setExtraParameterForKey: @"test_extra_key" value: @"test_extra_value"];
    
    self.nativeAdLoader.nativeAdDelegate = self;
    self.nativeAdLoader.revenueDelegate = self;
}

#pragma mark - IB Actions

- (IBAction)showAd
{
    // Clean up any pre-existing native ad to prevent memory leaks
    if ( self.nativeAd )
    {
        [self.nativeAdLoader destroyAd: self.nativeAd];
    }

    if ( self.nativeAdView )
    {
        [self.nativeAdView removeFromSuperview];
    }
    
    [self.nativeAdLoader loadAd];
}

#pragma mark - NativeAdDelegate Protocol

- (void)didLoadNativeAd:(MANativeAdView *)nativeAdView forAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
    
    // Save ad for cleanup
    self.nativeAd = ad;
    
    // Add ad view to view
    self.nativeAdView = nativeAdView;
    [self.nativeAdContainerView addSubview: nativeAdView];
    
    // Set to false if modifying constraints after adding the ad view to your layout
    self.nativeAdContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Set ad view to span width and height of container and center the ad
    (void) [self.nativeAdContainerView.widthAnchor constraintEqualToAnchor: nativeAdView.widthAnchor];
    (void) [self.nativeAdContainerView.heightAnchor constraintEqualToAnchor: nativeAdView.heightAnchor];
    (void) [self.nativeAdContainerView.centerXAnchor constraintEqualToAnchor: nativeAdView.centerXAnchor];
    (void) [self.nativeAdContainerView.centerYAnchor constraintEqualToAnchor: nativeAdView.centerYAnchor];
}

- (void)didFailToLoadNativeAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didClickNativeAd:(MAAd *)ad
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
