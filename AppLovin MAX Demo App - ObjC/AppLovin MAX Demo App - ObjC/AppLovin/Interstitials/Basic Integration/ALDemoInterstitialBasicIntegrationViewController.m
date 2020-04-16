//
//  ALDemoInterstitialBasicIntegrationViewController.m
//  iOS-SDK-Demo
//
//  Created by Thomas So on 9/23/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

#import "ALDemoInterstitialBasicIntegrationViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALDemoInterstitialBasicIntegrationViewController()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>
@property (nonatomic, strong) ALInterstitialAd *interstitialAd;
@end

@implementation ALDemoInterstitialBasicIntegrationViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.interstitialAd = [ALInterstitialAd shared];
    self.interstitialAd.adLoadDelegate = self;
    self.interstitialAd.adDisplayDelegate = self;
    self.interstitialAd.adVideoPlaybackDelegate = self;
}

#pragma mark - IB Actions

- (IBAction)showAd:(id)sender
{
    [self.interstitialAd show];
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void) adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
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

#pragma mark - Ad Video Playback Delegate

- (void)videoPlaybackBeganInAd:(ALAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched
{
    [self logCallback: __PRETTY_FUNCTION__];
}

@end
