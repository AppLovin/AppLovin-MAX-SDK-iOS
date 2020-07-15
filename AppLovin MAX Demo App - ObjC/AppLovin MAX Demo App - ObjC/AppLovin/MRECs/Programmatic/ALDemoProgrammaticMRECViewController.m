//
//  ALDemoProgrammaticMRECViewController.m
//  iOS-SDK-Demo-ObjC
//
//  Created by Thomas So on 3/6/17.
//  Copyright © 2017 AppLovin. All rights reserved.
//

#import "ALDemoProgrammaticMRECViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALDemoProgrammaticMRECViewController()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdViewEventDelegate>
@property (nonatomic, strong) ALAdView *adView;
@end

@implementation ALDemoProgrammaticMRECViewController
static const CGFloat kMRECHeight = 250.0f;
static const CGFloat kMRECWidth = 300.0f;

#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    // Create the MREC view
    self.adView = [[ALAdView alloc] initWithSize: ALAdSize.mrec];
    
    // Optional: Implement the ad delegates to receive ad events.
    self.adView.adLoadDelegate = self;
    self.adView.adDisplayDelegate = self;
    self.adView.adEventDelegate = self;
    self.adView.translatesAutoresizingMaskIntoConstraints = false;
    self.callbackTableView.translatesAutoresizingMaskIntoConstraints = false;
    
    // Call loadNextAd() to start showing ads
    [self.adView loadNextAd];
    
    [self.view addSubview: self.adView];
    
    [self.view addConstraints: @[
        [NSLayoutConstraint constraintWithItem: self.callbackTableView
                                     attribute: NSLayoutAttributeTop
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: self.view
                                     attribute: NSLayoutAttributeTop
                                    multiplier: 1.0
                                      constant: 0],
        [NSLayoutConstraint constraintWithItem: self.callbackTableView
                                     attribute: NSLayoutAttributeLeading
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: self.view
                                     attribute: NSLayoutAttributeLeading
                                    multiplier: 1.0
                                      constant: 0],
        [NSLayoutConstraint constraintWithItem: self.callbackTableView
                                     attribute: NSLayoutAttributeTrailing
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: self.view
                                     attribute: NSLayoutAttributeTrailing
                                    multiplier: 1.0
                                      constant: 0],
        [NSLayoutConstraint constraintWithItem: self.adView
                                     attribute: NSLayoutAttributeCenterX
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: self.view
                                     attribute: NSLayoutAttributeCenterX
                                    multiplier: 1.0
                                      constant: 0.0],
        [NSLayoutConstraint constraintWithItem: self.adView
                                     attribute: NSLayoutAttributeTop
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: self.callbackTableView
                                     attribute: NSLayoutAttributeBottom
                                    multiplier: 1.0
                                      constant: 10.0],
        [NSLayoutConstraint constraintWithItem: self.view
                                     attribute: NSLayoutAttributeBottom
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: self.adView
                                     attribute: NSLayoutAttributeBottom
                                    multiplier: 1.0
                                      constant: 10],
        [NSLayoutConstraint constraintWithItem: self.adView
                                     attribute: NSLayoutAttributeHeight
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: nil
                                     attribute: NSLayoutAttributeNotAnAttribute
                                    multiplier: 1.0
                                      constant: kMRECHeight],
        [NSLayoutConstraint constraintWithItem: self.adView
                                     attribute: NSLayoutAttributeWidth
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: nil
                                     attribute: NSLayoutAttributeNotAnAttribute
                                    multiplier: 1.0
                                      constant: kMRECWidth]]];
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
