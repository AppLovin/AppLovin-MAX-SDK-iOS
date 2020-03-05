//
//  ALDemoInterfaceBuilderMRECViewController.m
//  AppLovin Demo App - ObjC
//
//  Created by Varsha Hanji on 3/5/20.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALDemoInterfaceBuilderMRECViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALDemoInterfaceBuilderMRECViewController ()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdViewEventDelegate>
@property (weak, nonatomic) IBOutlet ALAdView *adView;
@end

@implementation ALDemoInterfaceBuilderMRECViewController

#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
        
    self.adView.adLoadDelegate = self;
    self.adView.adDisplayDelegate = self;
    self.adView.adEventDelegate = self;
    
    // Call loadNextAd() to start showing ads
    self.adView.adSize = ALAdSize.mrec;
    [self.adView loadNextAd];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    
    self.adView.adLoadDelegate = nil;
    self.adView.adDisplayDelegate = nil;
    self.adView.adEventDelegate = nil;
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
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
    [self logCallback: __PRETTY_FUNCTION__];
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
