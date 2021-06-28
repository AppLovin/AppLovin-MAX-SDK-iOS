//
//  MAAdDelegate.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "MAAd.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines a listener to be notified about ad events.
 */
@protocol MAAdDelegate<NSObject>

/**
 * The SDK invokes this method when a new ad has been loaded.
 *
 * @param ad  The ad that was loaded.
 */
- (void)didLoadAd:(MAAd *)ad;

/**
 * The SDK invokes this method when an ad could not be retrieved.
 *
 * <b>Common error codes:</b><table>
 * <tr><td>204</td><td>no ad is available</td></tr>
 * <tr><td>5xx</td><td>internal server error</td></tr>
 * <tr><td>negative number</td><td>internal errors</td></tr></table>
 *
 * @param adUnitIdentifier  The ad that was requested.
 * @param errorCode         Represents the failure reason. Common error codes are defined in {@link MAErrorCodes.h}.
 */
- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode;

/**
 * The SDK invokes this method when a full-screen ad is displayed.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @warning This method is deprecated for MRECs. It will only be called for full-screen ads.
 *
 * @param ad  The ad that was displayed.
 */
- (void)didDisplayAd:(MAAd *)ad;

/**
 * The SDK invokes this method when a full-screen ad is hidden.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @warning This method is deprecated for MRECs. It will only be called for full-screen ads.
 *
 * @param ad  The ad that was hidden.
 */
- (void)didHideAd:(MAAd *)ad;

/**
 * The SDK invokes this method when the ad is clicked.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  The ad that was clicked.
 */
- (void)didClickAd:(MAAd *)ad;

/**
 * The SDK invokes this method when the ad failed to display.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad        The ad that failed to display.
 * @param errorCode The failure reason. Common error codes are defined in {@link MAErrorCodes.h}.
 */
- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode;

@end

NS_ASSUME_NONNULL_END
