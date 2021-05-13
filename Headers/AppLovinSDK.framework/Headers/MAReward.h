//
//  MAReward.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This object represents a reward given to the user.
 */
@interface MAReward : NSObject

/**
 * The label that is used when a label is not given by the third-party network.
 */
@property (nonatomic, copy, readonly, class) NSString *defaultLabel;

/**
 * The amount that is used when no amount is given by the third-party network.
 */
// [PLP] what are the units of "amount"?
@property (nonatomic, assign, readonly, class) NSInteger defaultAmount;

/**
 * The reward label or {@link defaultLabel} if none specified.
 */
@property (nonatomic, copy, readonly) NSString *label;

/**
 * The rewarded amount or {@link defaultAmount} if none specified.
 */
// [PLP] what are the units of "amount"?
@property (nonatomic, assign, readonly) NSInteger amount;


/**
 * Create a reward object.
 */
+ (instancetype)reward;

/**
 * Create a reward object, with a label and an amount.
 *
 * @param amount  The rewarded amount.
 * @param label   The reward label.
 */
// [PLP] what are the units of "amount"?
+ (instancetype)rewardWithAmount:(NSInteger)amount label:(NSString *)label;

/**
 * Use {@link reward} or {@link rewardWithAmount:label:} to create a reward object.
 */
- (instancetype)init NS_UNAVAILABLE;
/**
 * Use {@link reward} or {@link rewardWithAmount:label:} to create a reward object.
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
