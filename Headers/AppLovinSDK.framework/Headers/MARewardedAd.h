//
//  MARewardedAd.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/9/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALSdk.h"
#import "MARewardedAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents a full-screen rewarded ad.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/rewarded-ads">MAX Integration Guide ⇒ iOS ⇒ Rewarded Ads</a>
 */
@interface MARewardedAd : NSObject

/**
 * Gets an instance of a MAX rewarded ad.
 *
 * @param adUnitIdentifier Ad unit ID for which to get the ad instance.
 *
 * @return An instance of a rewarded ad tied to the specified ad unit ID.
 */
+ (instancetype)sharedWithAdUnitIdentifier:(NSString *)adUnitIdentifier;

/**
 * Get an instance of a MAX rewarded ad.
 *
 * @param adUnitIdentifier Ad unit ID for which to get the ad instance.
 * @param sdk              SDK to use.
 *
 * @return An instance of a rewarded ad tied to the specified ad unit ID.
 */
+ (instancetype)sharedWithAdUnitIdentifier:(NSString *)adUnitIdentifier sdk:(ALSdk *)sdk;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * A delegate that will be notified about ad events.
 */
@property (nonatomic, weak, nullable) id<MARewardedAdDelegate> delegate;

/**
 * Set an extra key/value parameter for the ad.
 *
 * @param key   Parameter key.
 * @param value Parameter value.
 */
- (void)setExtraParameterForKey:(NSString *)key value:(nullable NSString *)value;

/**
 * Load the current rewarded ad. Use {@link delegate} to assign a delegate that should be notified about ad load state.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/rewarded-ads#loading-a-rewarded-ad">MAX Integration Guide ⇒ iOS ⇒ Rewarded Ads ⇒ Loading a Rewarded Ad</a>
 */
- (void)loadAd;

/**
 * Show the loaded rewarded ad.
 * <ul>
 * <li>Use {@link delegate} to assign a delegate that should be notified about display events.</li>
 * <li>Use {@link ready} to check if an ad was successfully loaded.</li>
 * </ul>
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/rewarded-ads#showing-a-rewarded-ad">MAX Integration Guide ⇒ iOS ⇒ Rewarded Ads ⇒ Showing a Rewarded Ad</a>
 */
- (void)showAd;

/**
 * Show the loaded rewarded ad for a given placement to tie ad events to.
 * <ul>
 * <li>Use {@link delegate} to assign a delegate that should be notified about display events.</li>
 * <li>Use {@link ready} to check if an ad was successfully loaded.</li>
 * </ul>
 *
 * @param placement The placement to tie the showing ad's events to.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/advanced-settings#ad-placements">MAX Integration Guide ⇒ iOS ⇒ Advanced Settings ⇒ Ad Placements</a>
 * @see <a href="https://dash.applovin.com/documentation/mediation/s2s-rewarded-callback-api#setting-an-ad-placement-name">MAX Integration Guide ⇒ MAX S2S Rewarded Callback API ⇒ Setting an Ad Placement Name</a>
 */
 // [PLP] what does it mean to tie a placement to events? who ties it?
- (void)showAdForPlacement:(nullable NSString *)placement;

/**
 * The ad unit identifier this `MARewardedAd` was initialized with and is loading ads for.
 */
@property (nonatomic, copy, readonly) NSString *adUnitIdentifier;

/**
 * Whether or not this ad is ready to be shown.
 */
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;

@end

NS_ASSUME_NONNULL_END
