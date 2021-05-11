//
//  MAAdFormat.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This class defines a format of an ad.
 */
@interface MAAdFormat : NSObject

/**
 * Represents a 320x50 banner advertisement.
 */
@property (nonatomic, strong, readonly, class) MAAdFormat *banner;

/**
 * Represents a 300x250 rectangular advertisement.
 */
@property (nonatomic, strong, readonly, class) MAAdFormat *mrec;

/**
 * Represents a 728x90 leaderboard advertisement (for tablets).
 */
@property (nonatomic, strong, readonly, class) MAAdFormat *leader;

/**
 * Represents a cross promo advertisement.
 */
@property (nonatomic, strong, readonly, class) MAAdFormat *crossPromo;

/**
 * Represents a full-screen advertisement.
 */
@property (nonatomic, strong, readonly, class) MAAdFormat *interstitial;

/**
 * Similar to `MAAdFormat.interstitial`, except that users are given a reward at the end of the advertisement.
 */
@property (nonatomic, strong, readonly, class) MAAdFormat *rewarded;

/**
 * Represents a fullscreen ad which the user can skip and be granted a reward upon successful completion of the ad.
 */
@property (nonatomic, strong, readonly, class) MAAdFormat *rewardedInterstitial;

/**
 * Represents a native advertisement.
 */
@property (nonatomic, strong, readonly, class) MAAdFormat *native;

/**
 * The size of the AdView format ad, or CGSizeZero otherwise.
 */
@property (nonatomic, assign, readonly) CGSize size;

/**
 * Get the adaptive banner size for the screen width (with safe areas insetted) at the current orientation.
 *
 * NOTE: The height is currently the only "adaptive" dimension and the width will span the screen.
 * NOTE: Only AdMob / Google Ad Manager currently has support for adaptive banners and the maximum height is 15% the height of the screen.
 */
@property (nonatomic, assign, readonly) CGSize adaptiveSize;

/**
 * Get the adaptive banner size for the provided width at the current orientation.
 *
 * NOTE: The height is currently the only "adaptive" dimension and the provided width will be passed back in the returned size.
 * NOTE: Only AdMob / Google Ad Manager currently has support for adaptive banners and the maximum height is 15% the height of the screen.
 *
 * @param width  The width to retrieve the adaptive banner size for.
 *
 * @return The adaptive banner size for the current orientation and width.
 */
- (CGSize)adaptiveSizeForWidth:(CGFloat)width;

/**
 * Whether or not the ad format is an interstitial, rewarded, or rewarded interstitial.
 */
@property (nonatomic, assign, readonly, getter=isFullscreenAd) BOOL fullscreenAd;

/**
 * Whether or not the ad format is a banner, leader, or MREC.
 */
@property (nonatomic, assign, readonly, getter=isAdViewAd) BOOL adViewAd;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
