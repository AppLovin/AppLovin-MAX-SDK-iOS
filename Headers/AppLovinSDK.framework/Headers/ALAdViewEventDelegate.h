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
 * The SDK invokes this method after the ad view begins to present fullscreen content.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * Note: Some banners, when clicked, will expand into fullscreen content, whereupon the SDK will call this method.
 *
 * @param ad     Ad for which the ad view presented fullscreen content.
 * @param adView Ad view that presented fullscreen content.
 */
- (void)ad:(ALAd *)ad didPresentFullscreenForAdView:(ALAdView *)adView;

/**
 * The SDK invokes this method as the fullscreen content is about to be dismissed.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad     Ad for which the fullscreen content is to be dismissed.
 * @param adView Ad view that contains the ad for which the fullscreen content is to be dismissed.
 */
- (void)ad:(ALAd *)ad willDismissFullscreenForAdView:(ALAdView *)adView;

/**
 * The SDK invokes this method after the fullscreen content is dismissed.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad     Ad for which the fullscreen content is dismissed.
 * @param adView Ad view that contains the ad for which the fullscreen content is dismissed.
 */
- (void)ad:(ALAd *)ad didDismissFullscreenForAdView:(ALAdView *)adView;

/**
 * The SDK invokes this method when the user is about to be taken out of the application after the user clicks on the ad.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad     Ad for which the user will be taken out of the application.
 * @param adView Ad view that contains the ad for which the user will be taken out of the application.
 */
- (void)ad:(ALAd *)ad willLeaveApplicationForAdView:(ALAdView *)adView;

/**
 * The SDK invokes this method when the user returns to the application after the user clicks on the ad.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad     Ad from which the user will return to the application.
 * @param adView Ad view that contains the ad from which the user will return to the application.
 */
- (void)ad:(ALAd *)ad didReturnToApplicationForAdView:(ALAdView *)adView;

/**
 * The SDK invokes this method if the ad view fails to display an ad.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad     Ad that the ad view failed to display.
 * @param adView Ad view that failed to display the ad.
 * @param code   Error code that specifies the reason why the ad view failed to display the ad.
 */
- (void)ad:(ALAd *)ad didFailToDisplayInAdView:(ALAdView *)adView withError:(ALAdViewDisplayErrorCode)code;

@end

NS_ASSUME_NONNULL_END
