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
@property (nonatomic, weak) IBOutlet UIBarButtonItem *showButton;
@end

@implementation ALDemoInterstitialManualLoadingViewController

- (IBAction)loadInterstitial:(id)sender
{
    [self log: @"Interstitial loading..."];
    [[ALSdk shared].adService loadNextAd: ALAdSize.interstitial andNotify: self];
}

- (IBAction)showInterstitial:(id)sender
{
    // Optional: Assign delegates
    [ALInterstitialAd shared].adDisplayDelegate = self;
    [ALInterstitialAd shared].adVideoPlaybackDelegate = self;
    
    [[ALInterstitialAd shared] showAd: self.ad];
    
    [self log: @"Interstitial Shown"];
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    [self log: @"Interstitial ad Loaded"];
    
    self.ad = ad;
    self.showButton.enabled = YES;
}

- (void) adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    // Look at ALErrorCodes.h for list of error codes
    [self log: @"Interstitial failed to load with error code = %d", code];
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
    [self log: @"Interstitial Displayed"];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    [self log: @"Interstitial Dismissed"];
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
    [self log: @"Interstitial Clicked"];
}

#pragma mark - Ad Video Playback Delegate

- (void)videoPlaybackBeganInAd:(ALAd *)ad
{
    [self log: @"Video Started"];
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched
{
    [self log: @"Video Ended"];
}

@end
