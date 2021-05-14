//
//  ALAdLoadDelegate.h
//  AppLovinSDK
//
//  Created by Basil on 3/23/12.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALAd.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This service loads an ad.
 */
@class ALAdService;

/**
 * This protocol defines a listener for ad load events.
 */
@protocol ALAdLoadDelegate <NSObject>

/**
 * This method is invoked when an ad is loaded by the AdService.
 *
 * This method is invoked on the main UI thread.
 *
 * @param adService AdService that loaded the ad.
 * @param ad        Ad that was loaded.
 */
- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad;

/**
 * This method is invoked when an ad load fails.
 *
 * This method is invoked on the main UI thread.
 *
 * @param adService AdService that failed to load an ad.
 * @param code      An error code that corresponds to one of the constants defined in {@link ALErrorCodes.h}.
 */
- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code;

@end

NS_ASSUME_NONNULL_END
