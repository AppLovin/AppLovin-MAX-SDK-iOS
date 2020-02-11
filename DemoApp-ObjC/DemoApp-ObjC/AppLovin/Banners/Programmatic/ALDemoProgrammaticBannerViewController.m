//
//  ALDemoProgrammaticBannerViewController.m
//  iOS-SDK-Demo-ObjC
//
//  Created by Thomas So on 3/5/17.
//  Copyright © 2017 AppLovin. All rights reserved.
//

#import "ALDemoProgrammaticBannerViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALDemoProgrammaticBannerViewController()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdViewEventDelegate>
@property (nonatomic, strong) ALAdView *adView;
@property (nonatomic,   weak) IBOutlet UIBarButtonItem *loadButton;
@end

@implementation ALDemoProgrammaticBannerViewController
static const CGFloat kBannerHeight = 50.0f;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the banner view
    self.adView = [[ALAdView alloc] initWithSize: ALAdSize.banner];
    
    // Optional: Implement the ad delegates to receive ad events.
    self.adView.adLoadDelegate = self;
    self.adView.adDisplayDelegate = self;
    self.adView.adEventDelegate = self;
    self.adView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Call loadNextAd() to start showing ads
    [self.adView loadNextAd];
    
    // Center the banner and anchor it to the bottom of the screen.
    [self.view addSubview: self.adView];
    [self.view addConstraints: @[[self constraintWithAdView: self.adView andAttribute: NSLayoutAttributeLeading],
                                 [self constraintWithAdView: self.adView andAttribute: NSLayoutAttributeTrailing],
                                 [self constraintWithAdView: self.adView andAttribute: NSLayoutAttributeBottom],
                                 [NSLayoutConstraint constraintWithItem: self.adView
                                                              attribute: NSLayoutAttributeHeight
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: nil
                                                              attribute: NSLayoutAttributeNotAnAttribute
                                                             multiplier: 1.0
                                                               constant: kBannerHeight]]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    
    self.adView.adLoadDelegate = nil;
    self.adView.adDisplayDelegate = nil;
    self.adView.adEventDelegate = nil;
}

- (NSLayoutConstraint *)constraintWithAdView:(ALAdView *)adView andAttribute:(NSLayoutAttribute)attribute
{
    return [NSLayoutConstraint constraintWithItem: self.adView
                                        attribute: attribute
                                        relatedBy: NSLayoutRelationEqual
                                           toItem: self.view
                                        attribute: attribute
                                       multiplier: 1.0
                                         constant: 0.0];
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
