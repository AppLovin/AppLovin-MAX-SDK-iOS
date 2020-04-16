//
//  ALDemoInterfaceBuilderBannerViewController.m
//  iOS-SDK-Demo-ObjC
//
//  Created by Thomas So on 3/6/17.
//  Copyright © 2017 AppLovin. All rights reserved.
//

#import "ALDemoInterfaceBuilderBannerViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALDemoInterfaceBuilderBannerViewController()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdViewEventDelegate>
@property (nonatomic, weak) IBOutlet ALAdView *adView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *loadButton;
@end

@implementation ALDemoInterfaceBuilderBannerViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.adView.adLoadDelegate = self;
    self.adView.adDisplayDelegate = self;
    self.adView.adEventDelegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    
    self.adView.adLoadDelegate = nil;
    self.adView.adDisplayDelegate = nil;
    self.adView.adEventDelegate = nil;
}

#pragma mark - IB Action

- (IBAction)loadNextAd
{
    [self.adView loadNextAd];

    self.loadButton.enabled = NO;
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    // Look at ALErrorCodes.h for list of error codes
    [self logCallback: __PRETTY_FUNCTION__];

    self.loadButton.enabled = YES;
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
    [self logCallback: __PRETTY_FUNCTION__];

    self.loadButton.enabled = YES;
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
    [self logCallback: __PRETTY_FUNCTION__];
}

#pragma mark - Ad View Event Delegate

- (void)ad:(ALAd *)ad didPresentFullscreenForAdView:(ALAdView *)adView
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)ad:(ALAd *)ad willDismissFullscreenForAdView:(ALAdView *)adView
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)ad:(ALAd *)ad didDismissFullscreenForAdView:(ALAdView *)adView
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)ad:(ALAd *)ad willLeaveApplicationForAdView:(ALAdView *)adView
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)ad:(ALAd *)ad didFailToDisplayInAdView:(ALAdView *)adView withError:(ALAdViewDisplayErrorCode)code
{
    [self logCallback: __PRETTY_FUNCTION__];
}

@end
