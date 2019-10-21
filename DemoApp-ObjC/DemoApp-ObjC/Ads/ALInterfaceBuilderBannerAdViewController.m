//
//  ALInterfaceBuilderBannerAdViewController.m
//  DemoApp-ObjC
//
//  Created by Andrew Tian on 9/10/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALInterfaceBuilderBannerAdViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALInterfaceBuilderBannerAdViewController()<MAAdViewAdDelegate>
@property (nonatomic, strong) IBOutlet MAAdView *adView;
@end

@implementation ALInterfaceBuilderBannerAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // NOTE: Must set Storyboard "User Defined Runtime Attributes" for banner ad view
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
