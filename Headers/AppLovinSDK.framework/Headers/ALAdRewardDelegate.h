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
 * The SDK invokes this method if a user viewed a rewarded video and their reward was approved by the AppLovin server.
 *
 * If you use reward validation for incentivized videos, the SDK invokes this method if it contacted AppLovin successfully. This means the SDK believes the
 * reward is legitimate and you should award it.
 *
 * <b>Tip:</b> refresh the user’s balance from your server at this point rather than relying on local data that could be tampered with on jailbroken devices.
 *
 * The @c response @c NSDictionary will typically include the keys @c "currency" and @c "amount", which point to @c NSStrings that contain the name and amount of the
 * virtual currency that you may award.
 *
 * @param ad       Ad that was viewed.
 * @param response Dictionary that contains response data from the server, including @c "currency" and @c "amount".
 */
 // [PLP]
 // "If you use reward validation for incentivized videos..." -- how do you "use" this?
- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response;

/**
 * The SDK invokes this method if it was able to contact AppLovin, but the user has already received the maximum number of coins you allowed per day in the web
 * UI, and so is ineligible for a reward.
 *
 * @param ad       Ad that was viewed.
 * @param response Dictionary that contains response data from the server.
 */
 // [PLP]
- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response;

/**
 * The SDK invokes this method if the AppLovin server rejected the reward request. The usual cause of this is that the user fails to pass an anti-fraud check.
 *
 * @param ad       Ad that was viewed.
 * @param response Dictionary that contains response data from the server.
 */
- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response;

/**
 * The SDK invokes this method if it was unable to contact AppLovin, and so AppLovin will not issue a ping to your S2S rewarded callback server.
 *
 * @param ad           Ad that was viewed.
 * @param responseCode A failure code that corresponds to a constant defined in ALErrorCodes.h.
 */
- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode;

@end

NS_ASSUME_NONNULL_END
