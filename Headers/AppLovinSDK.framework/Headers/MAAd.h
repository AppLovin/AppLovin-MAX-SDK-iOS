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
 * This class represents an ad that has been served by AppLovin’s mediation server and that should be displayed to the user.
 */
@interface MAAd : NSObject

/**
 * The format of this ad.
 */
@property (nonatomic, strong, readonly) MAAdFormat *format;

/**
 * The ad unit ID for which this ad was loaded.
 */
@property (nonatomic, copy, readonly) NSString *adUnitIdentifier;

/**
 * The ad network from which this ad was loaded.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/testing-networks/creative-debugger#network-name">MAX Integration Guide ⇒ iOS ⇒ Testing Networks ⇒ Creative Debugger ⇒ Network Name</a>
 */
@property (nonatomic, copy, readonly) NSString *networkName;

/**
 * The creative ID tied to the ad, if any. It may not be available for some ad networks until {@link MAAdDelegate::didDisplayAd:} is called.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/testing-networks/creative-debugger#creative-id">MAX Integration Guide ⇒ iOS ⇒ Testing Networks ⇒ Creative Debugger ⇒ Creative ID</a>
 *
 * @since 6.15.0
 */
@property (nonatomic, copy, readonly, nullable) NSString *creativeIdentifier;

/**
 * The ad’s revenue amount, or −1 if it does not exist.
 */
 // [PLP] "it" meaning the ad, or the amount?
@property (nonatomic, assign, readonly) double revenue;

/**
 * The placement to tie the ad’s postbacks to.
 */
 // [PLP] what does it mean to tie postbacks to a placement? who ties them?
@property (atomic, copy, readonly, nullable) NSString *placement;

/**
 * Gets an arbitrary ad value for a given key.
 *
 * @param key The key for the value you want to retrieve.
 *
 * @return An arbitrary ad value for a given key, or `nil` if does not exist.
 */
 // [PLP] what makes an ad value arbitrary or not?
 // [PLP] nil if a value does not exist for the key or if the key itself does not exist?
- (nullable NSString *)adValueForKey:(NSString *)key;

/**
 * Gets an arbitrary ad value for a given key.
 *
 * @param key          The key for the value you want to retrieve.
 * @param defaultValue The default value to return if the value for `key` does not exist or is `nil`.
 *
 * @return An arbitrary ad value for a given key, or the default value if does not exist.
 */
 // [PLP] what makes an ad value arbitrary or not?
 // [PLP] the default value if a value does not exist for the key or if the key itself does not exist?
- (nullable NSString *)adValueForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;

+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
