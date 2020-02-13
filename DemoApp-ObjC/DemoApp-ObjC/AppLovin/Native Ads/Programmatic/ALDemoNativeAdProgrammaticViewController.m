//
//  ALDemoNativeAdProgrammaticViewController.m
//  iOS-SDK-Demo
//
//  Created by Thomas So on 9/24/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

#import "ALDemoNativeAdProgrammaticViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALDemoNativeAdProgrammaticViewController()<ALNativeAdLoadDelegate, ALNativeAdPrecacheDelegate, ALPostbackDelegate>
@property (nonatomic, strong) ALNativeAd *cachedNativeAd;
@property (nonatomic, strong) ALNativeAd *nativeAd;
@end

// Additional documentation - https://applovin.com/integration#iosNative

@implementation ALDemoNativeAdProgrammaticViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appIcon.layer.masksToBounds = YES;
    self.appIcon.layer.cornerRadius = 3.0f;
    
    self.ctaButton.layer.masksToBounds = YES;
    self.ctaButton.layer.cornerRadius = 3.0f;
    
    [self setUIElementsHidden: YES];
}

#pragma mark - Action Methods

- (IBAction)loadNativeAd:(id)sender
{
    self.precacheButton.enabled = NO;
    self.showButton.enabled = NO;
    
    self.impressionStatusLabel.text = @"No impression to track";
    
    [[ALSdk shared].nativeAdService loadNextAdAndNotify: self];
}

- (IBAction)precacheNativeAd:(id)sender
{
    // You can use our pre-caching to retrieve assets (app icon, ad image, ad video) locally. OR you can do it with your preferred caching framework.
    // iconURL, imageURL, videoURL needs to be retrieved manually before you can render them
    
    [[ALSdk shared].nativeAdService precacheResourcesForNativeAd: self.nativeAd andNotify: self];
}

- (IBAction)showNativeAd:(id)sender
{
    self.nativeAd = self.cachedNativeAd;
    
    self.appIcon.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: self.nativeAd.iconURL]]; // Local URL
    self.titleLabel.text = self.nativeAd.title;
    self.descriptionLabel.text = self.nativeAd.descriptionText;
    [self.ctaButton setTitle: self.nativeAd.ctaText forState: UIControlStateNormal];
    
    NSString *filename = [NSString stringWithFormat: @"Star_Sprite_%@", self.nativeAd.starRating.stringValue];
    self.rating.image = [UIImage imageNamed: filename];
    
    // NOTE - Videos have aspect ratio of 1:1.85
    [self.mediaView renderViewForNativeAd: self.nativeAd];
    
    [self setUIElementsHidden: NO];
    
    //
    // You are responsible for firing impressions
    //
    [self trackImpression: self.nativeAd];
    
    [self.view layoutIfNeeded];
}

- (IBAction)ctaPressed:(id)sender
{
    [self.nativeAd launchClickTarget];
}

#pragma mark - Impressing Tracking

- (void)trackImpression:(ALNativeAd *)ad
{
    // Callbacks may not happen on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.impressionStatusLabel.text = @"Tracking impression...";
    });
    
    [ad trackImpressionAndNotify: self];
}

- (void)postbackService:(ALPostbackService *)postbackService didExecutePostback:(NSURL *)postbackURL
{
    // Callbacks may not happen on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        // Impression tracked!
        self.impressionStatusLabel.text = @"Impression tracked";
    });
}

- (void)postbackService:(ALPostbackService *)postbackService didFailToExecutePostback:(nullable NSURL *)postbackURL errorCode:(NSInteger)errorCode
{
    // Callbacks may not happen on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        // Impression could not be tracked. Retry the postback later.
        self.impressionStatusLabel.text = [NSString stringWithFormat: @"Impression failed to track with error code %ld", errorCode];
    });
}

#pragma mark - Native Ad Load Delegate

- (void)nativeAdService:(ALNativeAdService *)service didLoadAds:(NSArray *)ads
{
    [self logCallback: __PRETTY_FUNCTION__];

    // Callbacks may not happen on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.nativeAd = [ads firstObject];
        self.precacheButton.enabled = YES;
    });
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToLoadAdsWithError:(NSInteger)code
{
    [self logCallback: __PRETTY_FUNCTION__];
}

#pragma mark - Native Ad Precache Delegate

- (void)nativeAdService:(ALNativeAdService *)service didPrecacheImagesForAd:(ALNativeAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)nativeAdService:(ALNativeAdService *)service didPrecacheVideoForAd:(ALNativeAd *)ad
{
    // This delegate method will get called whether an ad actually has a video to precache or not
    [self logCallback: __PRETTY_FUNCTION__];

    // Callbacks may not happen on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cachedNativeAd = ad;
        self.showButton.enabled = YES;
        self.precacheButton.enabled = NO;
    });
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToPrecacheImagesForAd:(ALNativeAd *)ad withError:(NSInteger)errorCode
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToPrecacheVideoForAd:(ALNativeAd *)ad withError:(NSInteger)errorCode
{
    [self logCallback: __PRETTY_FUNCTION__];
}

#pragma mark - Utility

- (void)setUIElementsHidden:(BOOL)hidden
{
    self.appIcon.hidden = hidden;
    self.titleLabel.hidden = hidden;
    self.rating.hidden = hidden;
    self.descriptionLabel.hidden = hidden;
    self.mediaView.hidden = hidden;
    self.ctaButton.hidden = hidden;
}

@end
