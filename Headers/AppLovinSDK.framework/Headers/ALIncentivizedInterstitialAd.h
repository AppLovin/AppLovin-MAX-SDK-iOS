//
//  ALIncentivizedInterstitialAd.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALInterstitialAd.h"
#import "ALAdVideoPlaybackDelegate.h"
#import "ALAdDisplayDelegate.h"
#import "ALAdLoadDelegate.h"
#import "ALAdRewardDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class shows rewarded videos to the user. These differ from regular interstitials in that they allow you to provide your user virtual currency in
 * exchange for watching a video.
 */
@interface ALIncentivizedInterstitialAd : NSObject

#pragma mark - Ad Delegates

/**
 * An object that conforms to the @code [ALAdDisplayDelegate] @endcode protocol. If you provide a value for `adDisplayDelegate` in your instance, the SDK will
 * notify this delegate of ad show/hide events.
 */
@property (strong, nonatomic, nullable) id<ALAdDisplayDelegate> adDisplayDelegate;

/**
 * An object that conforms to the @code [ALAdVideoPlaybackDelegate] @endcode protocol. If you provide a value for `adVideoPlaybackDelegate` in your instance,
 * the SDK will notify this delegate of video start/stop events.
 */
@property (strong, nonatomic, nullable) id<ALAdVideoPlaybackDelegate> adVideoPlaybackDelegate;

#pragma mark - Integration, Class Methods

/**
 * Gets a reference to the shared instance of @c [ALIncentivizedInterstitialAd].
 *
 * This wraps the @code +[ALSdk shared] @endcode call, and will only work if you have set your SDK key in `Info.plist`.
*/
+ (ALIncentivizedInterstitialAd *)shared;

/**
 * Pre-loads an incentivized interstitial, and notifies your provided Ad Load Delegate.
 *
 * Invoke this once to pre-load, then do not invoke it again until the ad has has been closed (e.g., in the
 * @code -[ALAdDisplayDelegate ad:wasHiddenIn:] @endcode callback).
 *
 * @warning You may pass a `nil` argument to @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode if you intend to use the synchronous
 *          (@code +[ALIncentivizedIntrstitialAd isReadyForDisplay] @endcode) flow. This is <em>not</em> recommended; AppLovin <em>highly recommends</em> that
 *          you use an ad load delegate.
 * 
 * This method uses the shared instance, and will only work if you have set your SDK key in `Info.plist`.
 * 
 * Note that AppLovin tries to pull down the next ad’s resources before you need it. Therefore, this method may complete immediately in many circumstances.
 *
 * @param adLoadDelegate The delegate to notify that preloading was completed. May be `nil` (see warning).
 */
+ (void)preloadAndNotify:(nullable id<ALAdLoadDelegate>)adLoadDelegate;

/**
 * Whether or not an ad is currently ready on this object. You must first have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode in order
 * for this value to be meaningful.
 *
 * @warning It is highly recommended that you implement an asynchronous flow (using an @code [ALAdLoadDelegate] @endcode with
 *          @code -[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode) rather than checking this property. This class does not contain a queue and can
 *          hold only one preloaded ad at a time. Therefore, you should <em>not</em> simply call
 *          @code -[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode) any time this method returns `NO`; it is important to invoke only one ad load —
 *          then not invoke any further loads until the ad has been closed (e.g., in the @code -[ALAdDisplayDelegate ad:wasHiddenIn:] @endcode callback).
 *
 * @return `YES` if an ad has been loaded into this incentivized interstitial and is ready to display. `NO` otherwise.
 */
 // [PLP] the last sentence of the @warning is a bit of a labyrinth of tangled clauses and I'm not sure I understand the point it's trying to make.
 // Would this untangle it correctly?:
 //    "Therefore when isReadyForDisplay returns NO you should not respond by calling preloadAndNotify again. It is important that you only load the ad
 //     once, that you not attempt to load it multiple times. Instead, wait until the ad has been closed (e.g. ...) before loading the next ad."
+ (BOOL)isReadyForDisplay;

/**
 * Shows an incentivized interstitial over the current key window, by using the most recently pre-loaded ad.
 *
 * You must have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode before you call @code +[ALIncentivizedInterstitialAd show] @endcode.
 */
+ (void)show;

/**
 * Shows an incentivized interstitial over the current key window, by using the most recently pre-loaded ad.
 *
 * You must have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode before you call @c showAndNotify.
 *
 * By using the @code [ALAdRewardDelegate] @endcode, you can verify with AppLovin servers that the video view is legitimate, as AppLovin will confirm whether
 * the specific ad was actually served. Then AppLovin will ping your server with a URL at which you can update the user’s balance. The Reward Validation
 * Delegate will tell you whether this service was able to reach AppLovin servers or not. If you receive a successful response, you should refresh the user’s
 * balance from your server. For more info, see the documentation.
 *
 * @param adRewardDelegate The reward delegate to notify upon validating reward authenticity with AppLovin.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/s2s-rewarded-callback-api">MAX Integration Guide ⇒ MAX S2S Rewarded Callback API</a>
 */
 // [PLP] "For more info, see the documentation". Which page discusses this? Does this refer to the MAX S2S Rewarded Callback API page in the @see link?
 // I don't see anything about setting the delegate or using showAndNotify() there.
+ (void)showAndNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate;

#pragma mark - Integration, Instance Methods

/**
 * Initializes an incentivized interstitial with a specific custom SDK.
 *
 * This is necessary if you use @code +[ALSdk sharedWithKey:] @endcode.
 *
 * @param sdk An SDK instance to use.
 */
- (instancetype)initWithSdk:(ALSdk *)sdk;

#pragma mark - Integration, zones

/**
 * Initializes an incentivized interstitial with a zone.
 *
 * @param zoneIdentifier The identifier of the zone for which to load ads.
 */
- (instancetype)initWithZoneIdentifier:(NSString *)zoneIdentifier;

/**
 * Initializes an incentivized interstitial with a zone and a specific custom SDK.
 *
 * This is necessary if you use @code +[ALSdk sharedWithKey:] @endcode.
 *
 * @param zoneIdentifier The identifier of the zone for which to load ads.
 * @param sdk            An SDK instance to use.
 */
- (instancetype)initWithZoneIdentifier:(NSString *)zoneIdentifier sdk:(ALSdk *)sdk;

/**
 *  The zone identifier this incentivized ad was initialized with and is loading ads for, if any.
 */
@property (copy, nonatomic, readonly, nullable) NSString *zoneIdentifier;

/**
 * Pre-loads an incentivized interstitial, and notifies your provided Ad Load Delegate.
 *
 * Invoke this once to pre-load, then do not invoke it again until the ad has has been closed (e.g., in the
 * @code -[ALAdDisplayDelegate ad:wasHiddenIn:] @endcode callback).
 *
 * @warning You may pass a `nil` argument to `preloadAndNotify` if you intend to use the synchronous
 *          (@code +[ALIncentivizedIntrstitialAd isReadyForDisplay] @endcode) flow. This is <em>not</em> recommended; AppLovin <em>highly recommends</em> that
 *          you use an ad load delegate.
 *
 * Note that AppLovin tries to pull down the next ad’s resources before you need it. Therefore, this method may complete immediately in many circumstances.
 *
 * @param adLoadDelegate The delegate to notify that preloading was completed. May be `nil` (see warning).
 */
- (void)preloadAndNotify:(nullable id<ALAdLoadDelegate>)adLoadDelegate;

/**
 * Whether or not an ad is currently ready on this object. You must first have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode in order
 * for this value to be meaningful.
 *
 * @warning It is highly recommended that you implement an asynchronous flow (using an @code [ALAdLoadDelegate] @endcode with
 *          @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode rather than checking this property. This class does not contain a queue and can
 *          hold only one preloaded ad at a time. Therefore, you should <em>not</em> simply call
 *          @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode any time this method returns `NO`; it is important to invoke only one ad load —
 *          then not invoke any further loads until the ad has been closed (e.g., in the @code -[ALAdDisplayDelegate ad:wasHiddenIn:] @endcode callback).
 *
 * @return `YES` if an ad has been loaded into this incentivized interstitial and is ready to display. `NO` otherwise.
 */
 // [PLP] the last sentence of the @warning is a bit of a labyrinth of tangled clauses and I'm not sure I understand the point it's trying to make.
 // Would this untangle it correctly?:
 //    "Therefore when isReadyForDisplay returns NO you should not respond by calling preloadAndNotify again. It is important that you only load the ad
 //     once, that you not attempt to load it multiple times. Instead, wait until the ad has been closed (e.g. ...) before loading the next ad."
@property (readonly, atomic, getter=isReadyForDisplay) BOOL readyForDisplay;

/**
 * Shows an incentivized interstitial over the current key window, by using the most recently pre-loaded ad.
 *
 * You must have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode before you call `show`.
 */
- (void)show;

/**
 * Shows an incentivized interstitial over the current key window, by using the most recently pre-loaded ad.
 *
 * You must have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode before you call `showAndNotify`.
 *
 * By using the @code [ALAdRewardDelegate] @endcode, you can verify with AppLovin servers that the video view is legitimate, as AppLovin will confirm whether
 * the specific ad was actually served. Then AppLovin will ping your server with a URL at which you can update the user’s balance. The Reward Validation
 * Delegate will tell you whether this service was able to reach AppLovin servers or not. If you receive a successful response, you should refresh the user’s
 * balance from your server. For more info, see the documentation.
 *
 * @param adRewardDelegate The reward delegate to notify upon validating reward authenticity with AppLovin.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/s2s-rewarded-callback-api">MAX Integration Guide ⇒ MAX S2S Rewarded Callback API</a>
 */
 // [PLP] "For more info, see the documentation" a @see would be nice, or a page title at least. Which page discusses this?
 // I don't see anything about setting the delegate or using showAndNotify() at https://dash.applovin.com/documentation/mediation/s2s-rewarded-callback-api
- (void)showAndNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate;

/**
 * Shows an incentivized interstitial, by using the most recently pre-loaded ad.
 *
 * You must have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode before you call `showAd`.
 *
 * By using the @code [ALAdRewardDelegate] @endcode, you can verify with AppLovin servers that the video view is legitimate, as AppLovin will confirm whether
 * the specific ad was actually served. Then AppLovin will ping your server with a URL at which you can update the user’s balance. The Reward Validation
 * Delegate will tell you whether this service was able to reach AppLovin servers or not. If you receive a successful response, you should refresh the user’s
 * balance from your server. For more info, see the documentation.
 *
 * @param ad               The ad to render into this incentivized ad.
 * @param adRewardDelegate The reward delegate to notify upon validating reward authenticity with AppLovin.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/s2s-rewarded-callback-api">MAX Integration Guide ⇒ MAX S2S Rewarded Callback API</a>
 */
 // [PLP] "For more info, see the documentation" a @see would be nice, or a page title at least. Which page discusses this?
 // I don't see anything about setting the delegate or using showAd->andNotify at https://dash.applovin.com/documentation/mediation/s2s-rewarded-callback-api
- (void)showAd:(ALAd *)ad andNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate;

- (instancetype)init __attribute__((unavailable("Use initWithSdk:, initWithZoneIdentifier:, or [ALIncentivizedInterstitialAd shared] instead.")));
+ (instancetype)new NS_UNAVAILABLE;

@end

@interface ALIncentivizedInterstitialAd(ALDeprecated)
+ (void)showOverPlacement:(nullable NSString *)placement
__deprecated_msg("Placements have been deprecated and will be removed in a future SDK version. Please configure zones from the UI and use them instead.");
+ (void)showOverPlacement:(nullable NSString *)placement andNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate
__deprecated_msg("Placements have been deprecated and will be removed in a future SDK version. Please configure zones from the UI and use them instead.");
+ (void)showOver:(UIWindow *)window placement:(nullable NSString *)placement andNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate
__deprecated_msg("Placements have been deprecated and will be removed in a future SDK version. Please configure zones from the UI and use them instead.");
- (void)showOver:(UIWindow *)window placement:(nullable NSString *)placement andNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate
__deprecated_msg("Placements have been deprecated and will be removed in a future SDK version. Please configure zones from the UI and use them instead.");
- (instancetype)initIncentivizedInterstitialWithSdk:(ALSdk *)sdk __deprecated_msg("Use initWithSdk:, initWithZoneIdentifier: or [ALIncentivizedInterstitialAd shared] instead.");

+ (void)showOver:(UIWindow *)window andNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate __deprecated_msg("Explicitly passing in an UIWindow to show an ad is deprecated as all cases show over the application's key window. Use showAndNotify: instead.");
- (void)showOver:(UIWindow *)window andNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate __deprecated_msg("Explicitly passing in an UIWindow to show an ad is deprecated as all cases show over the application's key window. Use showAndNotify: instead.");
- (void)showOver:(UIWindow *)window renderAd:(ALAd *)ad andNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate __deprecated_msg("Explicitly passing in an UIWindow to show an ad is deprecated as all cases show over the application's key window. Use showAd:andNotify: instead.");
@property (nonatomic, copy, nullable, class) NSString *userIdentifier __deprecated_msg("Please use -[ALSdk userIdentifier] instead to properly identify your users in our system. This property is now deprecated and will be removed in a future SDK version.");

@end

NS_ASSUME_NONNULL_END
