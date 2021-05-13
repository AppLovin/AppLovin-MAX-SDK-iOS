//
//  ALAd.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALAdSize.h"
#import "ALAdType.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents an ad that has been served from the AppLovin server.
 */
@interface ALAd : NSObject<NSCopying>

/**
 * The size category of this ad.
 */
@property (nonatomic, strong, readonly) ALAdSize *size;

/**
 * The type of this ad (regular or incentivized/rewarded).
 */
@property (nonatomic, strong, readonly) ALAdType *type;

/**
 * The zone ID for the ad, if any.
 */
@property (nonatomic, copy, readonly, nullable) NSString *zoneIdentifier;

/**
 * Whether or not the current ad is a video advertisement.
 */
@property (nonatomic, assign, readonly, getter=isVideoAd) BOOL videoAd;

/**
 * Gets an arbitrary ad value for a given key. The list of keys may be found in the AppLovin documentation online.
 *
 * @param key The key for which you want to retrieve the ad value.
 *
 * @return The arbitrary ad value corresponding to `key`, or `nil` if no such value exists for `key`.
 */
 // [PLP]
 // "The list of keys may be found in the AppLovin documentation online."
 // It would be nice to {@see} out to the specific page you can find them on.
 // also, what's an "ad value"? what makes it "arbitrary" or not?
- (nullable NSString *)adValueForKey:(NSString *)key;

/**
 * Gets an arbitrary ad value for a given key, or a default value if no such value exists. The list of keys may be found in AppLovin documentation online.
 *
 * @param key          The key for which you want to retrieve the ad value.
 * @param defaultValue The default value to return if the value of `key` does not exist or is `nil`.
 *
 * @return The arbitrary ad value corresponding to `key`, or the value of `defaultValue` if no such value exists for `key`.
 */
 // [PLP]
 // "The list of keys may be found in the AppLovin documentation online."
 // It would be nice to {@see} out to the specific page you can find them on.
 // also, what's an "ad value"? what makes it "arbitrary" or not?
- (nullable NSString *)adValueForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;

/**
 * A unique ID that identifies this advertisement.
 *
 * If you need to report a broken ad to AppLovin support, please include this number’s `longValue`.
 */
@property (nonatomic, strong, readonly) NSNumber *adIdNumber;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
