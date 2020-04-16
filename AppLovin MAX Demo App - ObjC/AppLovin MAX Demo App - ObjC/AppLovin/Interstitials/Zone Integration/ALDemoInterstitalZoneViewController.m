//
//  ALDemoInterstitalZoneViewController.m
//  iOS-SDK-Demo-ObjC
//
//  Created by Suyash Saxena on 6/19/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

#import "ALDemoInterstitalZoneViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALDemoInterstitalZoneViewController()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>
@property (nonatomic, strong) ALAd *ad;
@property (nonatomic, strong) ALInterstitialAd *interstitialAd;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *showButton;
@end

@implementation ALDemoInterstitalZoneViewController

- (IBAction)loadInterstitial:(id)sender
{
    [[ALSdk shared].adService loadNextAdForZoneIdentifier: @"YOUR_ZONE_ID" andNotify: self];
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
    self.ad = ad;
    self.showButton.enabled = YES;
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
