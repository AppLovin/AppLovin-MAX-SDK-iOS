//
//  ALDemoRewardedVideosZoneViewController.m
//  iOS-SDK-Demo-ObjC
//
//  Created by Suyash Saxena on 6/19/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

#import "ALDemoRewardedVideosZoneViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALDemoRewardedVideosZoneViewController()<ALAdLoadDelegate, ALAdRewardDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>
@property (nonatomic, strong) ALIncentivizedInterstitialAd *rewardedAd;
@end

@implementation ALDemoRewardedVideosZoneViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rewardedAd = [[ALIncentivizedInterstitialAd alloc] initWithZoneIdentifier: @"YOUR_ZONE_ID"];
}

#pragma mark - IB Action Methods

// You need to preload each rewarded video before it can be displayed
- (IBAction)preloadRewardedVideo:(id)sender
{
    [self.rewardedAd preloadAndNotify: self];
}

- (IBAction)showRewardedVideo:(id)sender
{
    // You need to preload each rewarded video before it can be displayed
    if ( [self.rewardedAd isReadyForDisplay] )
    {
        // Optional: Assign delegates
        self.rewardedAd.adDisplayDelegate = self;
        self.rewardedAd.adVideoPlaybackDelegate = self;
        
        [self.rewardedAd showAndNotify: self];
    }
    else
    {
        [self preloadRewardedVideo: nil];
    }
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    [self logCallback: __PRETTY_FUNCTION__];
}

#pragma mark - Ad Reward Delegate

- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response
{
    /* AppLovin servers validated the reward. Refresh user balance from your server.  We will also pass the number of coins
     awarded and the name of the currency.  However, ideally, you should verify this with your server before granting it. */
    
    // i.e. - "Coins", "Gold", whatever you set in the dashboard.
    // For example, "5" or "5.00" if you've specified an amount in the UI.
    NSLog(@"Received %@ %@", response[@"amount"], response[@"currencyName"]);
    
    // Do something with this information.
    // [MYCurrencyManagerClass updateUserCurrency: currencyName withChange: amountGiven];
    [self logCallback: __PRETTY_FUNCTION__];
    
    // By default we'll show a UIAlertView informing your user of the currency & amount earned.
    // If you don't want this, you can turn it off in the Manage Apps UI.
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode
{
    if (responseCode == kALErrorCodeIncentivizedUserClosedVideo)
    {
        // Your user exited the video prematurely. It's up to you if you'd still like to grant
        // a reward in this case. Most developers choose not to. Note that this case can occur
        // after a reward was initially granted (since reward validation happens as soon as a
        // video is launched).
    }
    else if (responseCode == kALErrorCodeIncentivizedValidationNetworkTimeout || responseCode == kALErrorCodeIncentivizedUnknownServerError)
    {
        // Some server issue happened here. Don't grant a reward. By default we'll show the user
        // a UIAlertView telling them to try again later, but you can change this in the
        // Manage Apps UI.
    }
    else if (responseCode == kALErrorCodeIncentiviziedAdNotPreloaded)
    {
        // Indicates that the developer called for a rewarded video before one was available.
    }
    
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response
{
    // Your user has already earned the max amount you allowed for the day at this point, so
    // don't give them any more money. By default we'll show them a UIAlertView explaining this,
    // though you can change that from the Manage Apps UI.
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response
{
    // Your user couldn't be granted a reward for this view. This could happen if you've blacklisted
    // them, for example. Don't grant them any currency. By default we'll show them a UIAlertView explaining this,
    // though you can change that from the Manage Apps UI.
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
