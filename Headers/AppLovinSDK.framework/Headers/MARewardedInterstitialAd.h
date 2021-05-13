//
//  MARewardedInterstitialAd.h
//  AppLovinSDK
//
//  Created by Thomas So on 6/3/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents a fullscreen ad that the user can skip or be granted a reward upon successful completion of the ad.
 */
@interface MARewardedInterstitialAd : NSObject

/**
 * Create a new MAX rewarded interstitial.
 *
 * @param adUnitIdentifier Ad unit ID to load ads for.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier;

/**
 * Create a new MAX rewarded interstitial.
 *
 * @param adUnitIdentifier Ad unit ID to load ads for.
 * @param sdk              SDK to use. You can obtain an instance of the SDK by calling {@link ALSdk::shared}.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier sdk:(ALSdk *)sdk;

/**
 * Use {@link initWithAdUnitIdentifier:} or {@link initWithAdUnitIdentifier:sdk:} to create a fullscreen ad instance.
 */
- (instancetype)init NS_UNAVAILABLE;
/**
 * Use {@link initWithAdUnitIdentifier:} or {@link initWithAdUnitIdentifier:sdk:} to create a fullscreen ad instance.
 */
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
 * Load the current rewarded interstitial. Set {@link delegate} to assign a delegate that should be notified about ad load state.
 */
- (void)loadAd;

/**
 * Show the loaded interstitial.
 * <ul>
 * <li>Use {@link delegate} to assign a delegate that should be notified about display events.</li>
 * <li>Use {@link ready} to check if an ad was successfully loaded.</li>
 * </ul>
 */
- (void)showAd;

/**
 * Show the loaded interstitial for a given placement to tie ad events to.
 * <ul>
 * <li>Use {@link delegate} to assign a delegate that should be notified about display events.</li>
 * <li>Use {@link ready} to check if an ad was successfully loaded.</li>
 * </ul>
 *
 * @param placement The placement to tie the showing ad’s events to.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/advanced-settings#ad-placements">MAX Integration Guide ⇒ iOS ⇒ Advanced Settings ⇒ Ad Placements</a>
 */
 // [PLP] what does it mean to "tie" events to a placement? who ties them?
- (void)showAdForPlacement:(nullable NSString *)placement;

/**
 * Whether or not this ad is ready to be shown.
 */
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;

@end

NS_ASSUME_NONNULL_END
