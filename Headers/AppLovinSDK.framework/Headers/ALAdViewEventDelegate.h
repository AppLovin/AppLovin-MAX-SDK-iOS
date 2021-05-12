//
//  ALAdViewEventDelegate.h
//  AppLovinSDK
//
//  Created by Thomas So on 6/23/17.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALAd.h"

@class ALAdView;

NS_ASSUME_NONNULL_BEGIN

/**
 * This enum contains possible error codes that are returned when the ad view fails to display an ad.
 */
typedef NS_ENUM(NSInteger, ALAdViewDisplayErrorCode)
{
    /**
     * The ad view failed to display an ad for an unspecified reason.
     */
    ALAdViewDisplayErrorCodeUnspecified
};

/**
 * This protocol defines a listener for ad view events.
 */
@protocol ALAdViewEventDelegate <NSObject>

@optional

/**
 * This method is invoked after the ad view presents fullscreen content.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad     Ad for which the ad view presented fullscreen content.
 * @param adView Ad view that presented fullscreen content.
 */
 // [PLP]
 // Unclear from the description whether this invocation happens only after the fullscreen content ends or as soon as the fullscreen content has begun.
- (void)ad:(ALAd *)ad didPresentFullscreenForAdView:(ALAdView *)adView;

/**
 * This method is invoked as the fullscreen content is about to be dismissed.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad     Ad for which the fullscreen content is to be dismissed.
 * @param adView Ad view that contains the ad for which the fullscreen content is to be dismissed.
 */
- (void)ad:(ALAd *)ad willDismissFullscreenForAdView:(ALAdView *)adView;

/**
 * This method is invoked after the fullscreen content is dismissed.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad     Ad for which the fullscreen content is dismissed.
 * @param adView Ad view that contains the ad for which the fullscreen content is dismissed.
 */
- (void)ad:(ALAd *)ad didDismissFullscreenForAdView:(ALAdView *)adView;

/**
 * This method is invoked when the user is about to be taken out of the application after a click.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad     Ad for which the user will be taken out of the application.
 * @param adView Ad view that contains the ad for which the user will be taken out of the application.
 */
 // [PLP] "after a click" means "after clicking on the ad" specifically?
- (void)ad:(ALAd *)ad willLeaveApplicationForAdView:(ALAdView *)adView;

/**
 * This method is invoked when the user returns to the application after a click.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad     Ad from which the user will return to the application.
 * @param adView Ad view that contains the ad from which the user will return to the application.
 */
 // [PLP] "after a click" means "after clicking on the ad" specifically?
- (void)ad:(ALAd *)ad didReturnToApplicationForAdView:(ALAdView *)adView;

/**
 * This method is invoked if the ad view fails to display an ad.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad     Ad that the ad view failed to display.
 * @param adView Ad view that failed to display the ad.
 * @param code   Error code that specifies the reason why the ad view failed to display ad.
 */
- (void)ad:(ALAd *)ad didFailToDisplayInAdView:(ALAdView *)adView withError:(ALAdViewDisplayErrorCode)code;

@end

NS_ASSUME_NONNULL_END
