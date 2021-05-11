//
//  ALInterstitialAd.h
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class is used to display full-screen ads to the user.
 */
@interface ALInterstitialAd : NSObject

#pragma mark - Ad Delegates

/**
 * An object conforming to the ALAdLoadDelegate protocol, which, if set, will be notified of ad load events.
 */
@property (nonatomic, strong, nullable) id<ALAdLoadDelegate> adLoadDelegate;

/**
 * An object conforming to the ALAdDisplayDelegate protocol, which, if set, will be notified of ad show/hide events.
 */
@property (nonatomic, strong, nullable) id<ALAdDisplayDelegate> adDisplayDelegate;

/**
 * An object conforming to the ALAdVideoPlaybackDelegate protocol, which, if set, will be notified of video start/finish events.
 */
@property (nonatomic, strong, nullable) id<ALAdVideoPlaybackDelegate> adVideoPlaybackDelegate;

#pragma mark - Loading and Showing Ads, Class Methods

/**
 * Show an interstitial over the application's key window.
 * This will load the next interstitial and display it.
 */
+ (instancetype)show;

/**
 * Get a reference to the shared singleton instance.
 *
 * This method calls [ALSdk shared] which requires you to have an SDK key defined in <code>Info.plist</code>.
 * If you use <code>[ALSdk sharedWithKey: ...]</code> then you will need to use the instance methods instead.
 */
+ (instancetype)shared;

#pragma mark - Loading and Showing Ads, Instance Methods

/**
 * Show an interstitial over the application's key window.
 * This will load the next interstitial and display it.
 */
- (void)show;

/**
 * Show current interstitial over a given window and render a specified ad loaded by ALAdService.
 *
 * @param ad The ad to render into this interstitial.
 */
- (void)showAd:(ALAd *)ad;

#pragma mark - Initialization

/**
 * Initialize an instance of this class with a SDK instance.
 *
 * @param sdk The AppLovin SDK instance to use.
 */
- (instancetype)initWithSdk:(ALSdk *)sdk;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
