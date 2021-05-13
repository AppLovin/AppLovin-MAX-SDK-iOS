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
 * This method is invoked when a video starts playing in an ad.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad  Ad in which video playback began.
 */
- (void)videoPlaybackBeganInAd:(ALAd *)ad;

/**
 * This method is invoked when a video stops playing in an ad.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad                Ad in which video playback ended.
 * @param percentPlayed     How much of the video was watched, as a percent.
 * @param wasFullyWatched   Whether or not the video was watched to, or very near to, completion.
 */
 // [PLP]
 // "as a percent" is potentially ambiguous. It could be an integer "25" or a decimal "0.25"
 // do we want to give more precise guidance about what "wasFullyWatched" means (e.g. whose criteria applies to determine how much is "fully")?
- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched;

@end

NS_ASSUME_NONNULL_END
