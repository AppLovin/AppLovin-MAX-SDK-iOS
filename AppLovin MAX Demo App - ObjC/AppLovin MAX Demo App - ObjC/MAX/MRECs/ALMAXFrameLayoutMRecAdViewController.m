//
//  ALMAXFrameLayoutMRecAdViewController.m
//  DemoApp-ObjC
//
//  Created by Andrew Tian on 1/23/20.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALMAXFrameLayoutMRecAdViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXFrameLayoutMRecAdViewController()<MAAdViewAdDelegate>
@property (nonatomic, strong) MAAdView *adView;
@end

@implementation ALMAXFrameLayoutMRecAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.adView = [[MAAdView alloc] initWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID" adFormat: MAAdFormat.mrec];
    self.adView.delegate = self;
    
    // Dimensions
    CGFloat width = 300;
    CGFloat height = 250;
    CGFloat x = self.view.center.x - 150;
    CGFloat y = 0;
    
    self.adView.frame = CGRectMake(x, y, width, height);
    
    // Set background or background color for MRECs to be fully functional
    self.adView.backgroundColor = UIColor.blackColor;
    
    [self.view addSubview: self.adView];
    
    // Load the first ad
    [self.adView loadAd];
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode
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

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode
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

@end
