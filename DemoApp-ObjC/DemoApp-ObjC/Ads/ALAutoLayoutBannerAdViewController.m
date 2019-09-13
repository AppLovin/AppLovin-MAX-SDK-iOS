//
//  ALAutoLayoutBannerAdViewController.m
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALAutoLayoutBannerAdViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALAutoLayoutBannerAdViewController()<MAAdViewAdDelegate>
@property (nonatomic, strong) MAAdView *adView;
@end

@implementation ALAutoLayoutBannerAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.adView = [[MAAdView alloc] initWithAdUnitIdentifier: @"BANNER_AD_UNIT_ID"];
    self.adView.delegate = self;
    self.adView.translatesAutoresizingMaskIntoConstraints = NO;

    // Set background or background color for banners to be fully functional
    self.adView.backgroundColor = UIColor.blackColor;

    // Center the banner and anchor it to the top of the screen.
    CGFloat height = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 90 : 50; // Banner height on iPhone and iPad is 50 and 90, respectively
    [self.view addConstraints: @[[self constraintWithAdView: self.adView andAttribute: NSLayoutAttributeLeading],
                                 [self constraintWithAdView: self.adView andAttribute: NSLayoutAttributeTrailing],
                                 [self constraintWithAdView: self.adView andAttribute: NSLayoutAttributeTop],
                                 [NSLayoutConstraint constraintWithItem: self.adView
                                                              attribute: NSLayoutAttributeHeight
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: nil
                                                              attribute: NSLayoutAttributeNotAnAttribute
                                                             multiplier: 1.0
                                                               constant: height]]];
    [self.view addSubview: self.adView];

    // Load the first ad
    [self.adView loadAd];
}

- (NSLayoutConstraint *)constraintWithAdView:(MAAdView *)adView andAttribute:(NSLayoutAttribute)attribute
{
    return [NSLayoutConstraint constraintWithItem: self.adView
                                        attribute: attribute
                                        relatedBy: NSLayoutRelationEqual
                                           toItem: self.view
                                        attribute: attribute
                                       multiplier: 1.0
                                         constant: 0.0];
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
