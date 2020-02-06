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
@property (nonatomic, weak) IBOutlet UIBarButtonItem *showButton;
@end

@implementation ALDemoInterstitialBasicIntegrationViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Alternatively, you can create an instance of `ALInterstitialAd`, but you must store it in a strong property
    [ALInterstitialAd shared].adLoadDelegate = self;
    [ALInterstitialAd shared].adDisplayDelegate = self;
    [ALInterstitialAd shared].adVideoPlaybackDelegate = self;
}

#pragma mark - IB Action Methods

- (IBAction)showInterstitial:(id)sender
{
    self.showButton.enabled = NO;
    
    [self log: @"Showing..."];
    [[ALInterstitialAd shared] show];
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    [self log: @"Interstitial Loaded"];
    self.showButton.enabled = YES;
}

- (void) adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    // Look at ALErrorCodes.h for list of error codes
    [self log: @"Interstitial failed to load with error code = %d", code];
    
    self.showButton.enabled = YES;
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
