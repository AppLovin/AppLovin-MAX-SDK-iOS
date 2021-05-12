//
//  MAAd.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "MAAdFormat.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents an ad that has been served by AppLovin's mediation server and should be displayed to the user.
 */
@interface MAAd : NSObject

/**
 * Get format of this ad.
 */
@property (nonatomic, strong, readonly) MAAdFormat *format;

/**
 * The ad unit id for which this ad was loaded.
 */
@property (nonatomic, copy, readonly) NSString *adUnitIdentifier;

/**
 * The ad network for which this ad was loaded from.
 */
@property (nonatomic, copy, readonly) NSString *networkName;

/**
 * The creative id tied to the ad, if any. It may not be available for some ad networks until @code -[MAFullscreenAdDelegate didDisplayAd:] @endcode is called.
 * @since 6.15.0
 */
@property (nonatomic, copy, readonly, nullable) NSString *creativeIdentifier;

/**
 * The ad's revenue amount, or -1 if it does not exist.
 */
@property (nonatomic, assign, readonly) double revenue;

/**
 * The placement to tie the ad's postbacks to.
 */
@property (atomic, copy, readonly, nullable) NSString *placement;

/**
 * Get an arbitrary ad value for a given key.
 * @param key The designated key to retrieve desired value for.
 *
 * @return An arbitrary ad value for a given key - or nil if does not exist.
 */
- (nullable NSString *)adValueForKey:(NSString *)key;

/**
 * Get an arbitrary ad value for a given key.
 *
 * @param key The designated key to retrieve desired value for.
 * @param defaultValue The default value to return if the desired value for does not exist or is nil.
 *
 * @return An arbitrary ad value for a given key - or the default value if does not exist.
 */
- (nullable NSString *)adValueForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;

+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
