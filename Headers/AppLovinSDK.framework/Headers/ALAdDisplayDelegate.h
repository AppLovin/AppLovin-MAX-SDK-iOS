//
//  ALAdDisplayDelegate.h
//  AppLovinSDK
//
//  Created by Basil on 3/23/12.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <UIKit/UIView.h>
#import "ALAd.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines a listener for ad display events. 
 */
@protocol ALAdDisplayDelegate <NSObject>

/**
 * This method is invoked when the ad is displayed in the view.
 *
 * This method is invoked on the main UI thread.
 * 
 * @param ad    Ad that was just displayed.
 * @param view  Ad view in which the ad was displayed.
 */
- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view;

/**
 * This method is invoked when the ad is hidden from the view. This occurs when the user “X”es out of an interstitial.
 *
 * This method is invoked on the main UI thread.
 * 
 * @param ad    Ad that was just hidden.
 * @param view  Ad view in which the ad was hidden.
 */
- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view;

/**
 * This method is invoked when the ad is clicked in the view.
 * 
 * This method is invoked on the main UI thread.
 *
 * @param ad    Ad that was just clicked.
 * @param view  Ad view in which the ad was clicked.
 */
- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
