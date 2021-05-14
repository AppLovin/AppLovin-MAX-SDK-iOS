//
//  ALAdSize.h
//  AppLovinSDK
//
//  Created by Basil on 2/27/12.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class defines the possible sizes of an ad.
 */
@interface ALAdSize : NSObject

/**
 * Represents the size of a 320×50 banner advertisement.
 */
@property (class, nonatomic, strong, readonly) ALAdSize *banner;

/**
 * Represents the size of a 728×90 leaderboard advertisement (for tablets).
 */
@property (class, nonatomic, strong, readonly) ALAdSize *leader;

/**
 * Represents the size of a full-screen advertisement.
 */
@property (class, nonatomic, strong, readonly) ALAdSize *interstitial;

/**
 * Represents the size of a cross promo advertisement.
 */
@property (class, nonatomic, strong, readonly) ALAdSize *crossPromo;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

@interface ALAdSize(ALDeprecated)
@property (nonatomic, assign, readonly) CGFloat width __deprecated;
@property (nonatomic, assign, readonly) CGFloat height __deprecated;
@property (class, nonatomic, strong, readonly) ALAdSize *mrec __deprecated_msg("MRECs have been deprecated and will be removed in a future SDK version.");
@end

NS_ASSUME_NONNULL_END
