//
//  ALAdVideoPlaybackDelegate.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALAd.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This service defines a listener for ad video playback events. Ads that do not contain videos will not trigger these callbacks.
 */
@class ALAdService;

/**
 * This protocol defines a listener for ad video playback events. Ads that do not contain videos will not trigger these callbacks.
 */
@protocol ALAdVideoPlaybackDelegate <NSObject>

/**
 * The SDK invokes this method when a video starts playing in an ad.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  Ad in which video playback began.
 */
- (void)videoPlaybackBeganInAd:(ALAd *)ad;

/**
 * The SDK invokes this method when a video stops playing in an ad.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad                Ad in which video playback ended.
 * @param percentPlayed     How much of the video was watched, as a percent, between 0 and 100.
 * @param wasFullyWatched   Whether or not the video was watched to 95% or more of completion.
 */
- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched;

@end

NS_ASSUME_NONNULL_END
