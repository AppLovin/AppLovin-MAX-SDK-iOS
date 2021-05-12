//
//  MAAdView.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/9/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALSdk.h"
#import "MAAdViewAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents a view-based ad - i.e. banner, mrec or leader.
 */
@interface MAAdView : UIView

/**
 * Create a new ad view for a given ad unit id.
 *
 * @param adUnitIdentifier Ad unit id to load ads for.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier;

/**
 * Create a new ad view for a given ad unit id.
 *
 * @param adUnitIdentifier Ad unit id to load ads for.
 * @param sdk                              SDK to use. An instance of the SDK may be obtained by calling +[ALSdk shared].
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier sdk:(ALSdk *)sdk;

/**
 * Create a new ad view for a given ad unit id and ad format.
 *
 * @param adUnitIdentifier Ad unit id to load ads for.
 * @param adFormat                   Ad format to load ads for.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat;

/**
 * Create a new ad view for a given ad unit id, ad format, and sdk.
 *
 * @param adUnitIdentifier Ad unit id to load ads for.
 * @param adFormat                   Ad format to load ads for.
 * @param sdk                              SDK to use. An instance of the SDK may be obtained by calling +[ALSdk shared].
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat sdk:(ALSdk *)sdk;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * Set a delegate that will be notified about ad events.
 */
@property (nonatomic, weak, nullable) IBOutlet id<MAAdViewAdDelegate> delegate;

/**
 * Set an extra parameter for the ad.
 *
 * @param key     Parameter key.
 * @param value Parameter value.
 */
- (void)setExtraParameterForKey:(NSString *)key value:(nullable NSString *)value;

/**
 * Load ad for the current ad view. Use {@link MAAdView:delegate} to assign a delegate that should be
 * notified about ad load state.
 */
- (void)loadAd;

/**
 * Starts or resumes auto-refreshing of the banner.
 */
- (void)startAutoRefresh;

/**
 * Pauses auto-refreshing of the banner.
 */
- (void)stopAutoRefresh;

/**
 * The placement to tie the future ad events to.
 */
@property (nonatomic, copy, nullable) NSString *placement;

/**
 * The ad unit identifier this @c MAAdView was initialized with and is loading ads for.
 */
@property (nonatomic, copy, readonly) NSString *adUnitIdentifier;

/**
 * The format of the ad view.
 */
@property (nonatomic, weak, readonly) MAAdFormat *adFormat;

@end

NS_ASSUME_NONNULL_END
