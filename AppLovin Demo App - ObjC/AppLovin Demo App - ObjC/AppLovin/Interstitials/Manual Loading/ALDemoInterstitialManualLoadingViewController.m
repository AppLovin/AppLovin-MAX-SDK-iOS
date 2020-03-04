//
//  ALDemoInterstitialManualLoadingViewController.m
//  iOS-SDK-Demo
//
//  Created by Thomas So on 9/25/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

#import "ALDemoInterstitialManualLoadingViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALDemoInterstitialManualLoadingViewController()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>
@property (nonatomic, strong) ALAd *ad;
@property (nonatomic, strong) ALInterstitialAd *interstitialAd;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *showButton;
@end

@implementation ALDemoInterstitialManualLoadingViewController

- (IBAction)loadInterstitial:(id)sender
{
    [[ALSdk shared].adService loadNextAd: ALAdSize.interstitial andNotify: self];
}

- (IBAction)showInterstitial:(id)sender
{
    // Optional: Assign delegates
    self.interstitialAd = [ALInterstitialAd shared];
    self.interstitialAd.adDisplayDelegate = self;
    self.interstitialAd.adVideoPlaybackDelegate = self;

    [self.interstitialAd showAd: self.ad];
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];

    self.ad = ad;
    self.showButton.enabled = YES;
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
