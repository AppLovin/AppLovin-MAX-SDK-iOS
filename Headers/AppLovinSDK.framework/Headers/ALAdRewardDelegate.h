//
//  ALAdRewardDelegate.h
//  AppLovinSDK
//
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALAd.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines a listener that listens to rewarded video events.
 */
@protocol ALAdRewardDelegate <NSObject>

@required

/**
 * This method is invoked if a user viewed a rewarded video and their reward was approved by the AppLovin server.
 *
 * If you are using reward validation for incentivized videos, this method will be invoked if we contacted AppLovin successfully. This means that we believe the
 * reward is legitimate and you should award it.
 *
 * <b>Tip:</b> refresh the user’s balance from your server at this point rather than relying on local data that could be tampered with on jailbroken devices.
 *
 * The `response` `NSDictionary` will typically include the keys `"currency"` and `"amount"`, which point to `NSStrings` that contain the name and amount of the
 * virtual currency that you may award.
 *
 * @param ad       Ad that was viewed.
 * @param response Dictionary that contains response data from the server, including `"currency"` and `"amount"`.
 */
 // [PLP]
 // "If you are using reward validation for incentivized videos..." -- how do you "use" this?
 // "...will be invoked..." -- who invokes it?
 // "...if we contacted AppLovin successfully" ... "we believe" -- who is "we"?
 // "...to prevent tampering..." -- who may tamper?
- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response;

/**
 * This method is invoked if we were able to contact AppLovin, but the user has already received the maximum number of coins you allowed per day in the web UI,
 * and so is ineligible for a reward.
 *
 * @param ad       Ad that was viewed.
 * @param response Dictionary that contains response data from the server.
 */
 // [PLP]
 // "...if we were able to contact AppLovin..." -- who is "we"?
- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response;

/**
 * This method is invoked if the AppLovin server rejected the reward request. The usual cause of this is that the user fails to pass an anti-fraud check.
 *
 * @param ad       Ad that was viewed.
 * @param response Dictionary that contains response data from the server.
 */
- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response;

/**
 * This method is invoked if were unable to contact AppLovin, and so no ping will be issued to your S2S rewarded callback server.
 *
 * @param ad           Ad that was viewed.
 * @param responseCode A failure code that corresponds to a constant defined in {@link ALErrorCodes.h}.
 */
 // [PLP]
 // "...if were unable to contact AppLovin..." -- if who were unable to contact AppLovin?
- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode;

@end

NS_ASSUME_NONNULL_END
