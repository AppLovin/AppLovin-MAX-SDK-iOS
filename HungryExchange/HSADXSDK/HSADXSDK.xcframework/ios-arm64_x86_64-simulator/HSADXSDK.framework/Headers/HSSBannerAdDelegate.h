//
//  HSSBannerAdDelegate.h
//  Pods
//
//  Created by biyingquan on 2025/4/8.
//

#import <Foundation/Foundation.h>

@class HSSADXBannerView;
@class HSSError;

@protocol HSSBannerAdDelegate <NSObject>

@required
/**
 * The SDK invokes this method when a Banner ad has been loaded.
 *
 * @param ad  The  Banner ad that was loaded.
 */
- (void)didLoadBannerAd:(HSSADXBannerView *)ad;

/**
 * The SDK invokes this method when an Banner ad could not be retrieved.
 *
 * @param ad  The Banner ad that was fail loaded.
 * @param error   An object that encapsulates the failure info.
 */
- (void)didFailToLoadBannerAdForAd:(HSSADXBannerView *)ad withError:(HSSError *)error;

@optional
/**
 * The SDK invokes this method when the Banner ad is clicked.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  The Banner ad that was clicked.
 */
- (void)didClickBannerAd:(HSSADXBannerView *)ad;

/**
 * The SDK invokes this method when the Banner ad is Collapsed.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  The Banner ad that was collapsed.
 */
- (void)didCollapseBannerAd:(HSSADXBannerView *)ad;

/**
 * The SDK invokes this method when the Banner ad is displayed.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  The Banner ad that was displayed.
 */
- (void)didDisplayBannerAd:(HSSADXBannerView *)ad;

/**
 * The SDK invokes this method when the Banner ad is expanded.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  The Banner ad that was expanded.
 */
- (void)didExpandBannerAd:(HSSADXBannerView *)ad;

/**
 * The SDK invokes this method when the Banner ad is hidden.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  The Banner ad that was hidden.
 */
- (void)didHideBannerAd:(HSSADXBannerView *)ad;

/**
 * The SDK invokes this method when the Banner ad failed to display.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  The Banner ad that the SDK failed to display for.
 * @param error An object that encapsulates the failure info.
 */
- (void)didFailToDisplayBannerAd:(HSSADXBannerView *)ad withError:(HSSError *)error;

@end
