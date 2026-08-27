//
//  HSSAdDelegate.h
//  HSADXSDK
//
//  Created by admin on 2024/11/27.
//
#import <Foundation/Foundation.h>

@class HSSAd;
@class HSSError;
NS_ASSUME_NONNULL_BEGIN

@protocol HSSAdDelegate <NSObject>

/**
 * The SDK invokes this method when a new ad has been loaded.
 *
 * @param ad  The ad that was loaded.
 */
- (void)didLoadAd:(HSSAd *)ad;

/**
 * The SDK invokes this method when an ad could not be retrieved.
 *
 * @param ad  The ad that was fail loaded.
 * @param error   An object that encapsulates the failure info.
 */
- (void)didFailToLoadAdForAd:(HSSAd *)ad withError:(HSSError *)error;

/**
 * The SDK invokes this method when a full-screen ad is displayed.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @warning This method is deprecated for MRECs. It will only be called for full-screen ads.
 *
 * @param ad  The ad that was displayed.
 */
- (void)didDisplayAd:(HSSAd *)ad;

/**
 * The SDK invokes this method when a full-screen ad is hidden.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @warning This method is deprecated for MRECs. It will only be called for full-screen ads.
 *
 * @param ad  The ad that was hidden.
 */
- (void)didHideAd:(HSSAd *)ad;

/**
 * The SDK invokes this method when the ad is clicked.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  The ad that was clicked.
 */
- (void)didClickAd:(HSSAd *)ad;

/**
 * The SDK invokes this method when the ad failed to display.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad       The ad that the SDK failed to display for.
 * @param error An object that encapsulates the failure info.
 */
- (void)didFailToDisplayAd:(HSSAd *)ad withError:(HSSError *)error;

/**
 * The SDK invokes this method when the cross promotion ad is clicked.
 */
- (void)didClickAd:(HSSAd *)ad crossPromotionBlock:(void (^)(NSURLSession *urlSession, NSURL *clickURL))block;

/**
 * The SDK invokes this method when a full-screen cross ad is displayed.
 *
 * @param ad  The cross ad that was displayed.
 */
- (void)didDisplayCrossAd:(HSSAd *)ad;

@optional

- (void)hss_adxAdapterTracker:(NSString *)eventName params:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
