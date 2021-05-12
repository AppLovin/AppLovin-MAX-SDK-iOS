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
 * This class represents a view-based ad — i.e. banner, mrec, or leader.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/banners">MAX Integration Guide ⇒ iOS ⇒ Banners</a>
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/mrecs">MAX Integration Guide ⇒ iOS ⇒ MRECs</a>
 */
@interface MAAdView : UIView

/**
 * Creates a new ad view for a given ad unit ID.
 *
 * @param adUnitIdentifier Ad unit ID to load ads for.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier;

/**
 * Creates a new ad view for a given ad unit ID.
 *
 * @param adUnitIdentifier Ad unit ID to load ads for.
 * @param sdk              SDK to use. You can obtain an instance of the SDK by calling {@link ALSdk::shared}.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier sdk:(ALSdk *)sdk;

/**
 * Creates a new ad view for a given ad unit ID and ad format.
 *
 * @param adUnitIdentifier Ad unit ID to load ads for.
 * @param adFormat         Ad format to load ads for.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat;

/**
 * Create a new ad view for a given ad unit ID, ad format, and SDK.
 *
 * @param adUnitIdentifier Ad unit id to load ads for.
 * @param adFormat         Ad format to load ads for.
 * @param sdk              SDK to use. You can obtain an instance of the SDK by calling {@link ALSdk::shared}.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat sdk:(ALSdk *)sdk;

/**
 * Use `initWithAdUnitIdentifier` to create a new ad view.
 */
- (instancetype)init NS_UNAVAILABLE;
/**
 * Use `initWithAdUnitIdentifier` to create a new ad view.
 */
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
/**
 * Use `initWithAdUnitIdentifier` to create a new ad view.
 */
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;
/**
 * Use `initWithAdUnitIdentifier` to create a new ad view.
 */
+ (instancetype)new NS_UNAVAILABLE;

/**
 * A delegate that will be notified about ad events.
 */
@property (nonatomic, weak, nullable) IBOutlet id<MAAdViewAdDelegate> delegate;

/**
 * Sets an extra parameter key/value pair for the ad.
 *
 * @param key   Parameter key.
 * @param value Parameter value.
 */
- (void)setExtraParameterForKey:(NSString *)key value:(nullable NSString *)value;

/**
 * Loads the ad for the current ad view. Set {@link delegate} to assign a delegate that should be notified about ad load state.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/banners#loading-a-banner">MAX Integration Guide ⇒ iOS ⇒ MRECs ⇒ Loading a Banner</a>
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/mrecs#loading-an-mrec">MAX Integration Guide ⇒ iOS ⇒ MRECs ⇒ Loading an MREC</a>
 */
- (void)loadAd;

/**
 * Starts or resumes auto-refreshing of the banner.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/banners#showing-a-banner">MAX Integration Guide ⇒ iOS ⇒ MRECs ⇒ Showing a Banner</a>
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/mrecs#hiding-and-showing-an-mrec">MAX Integration Guide ⇒ iOS ⇒ MRECs ⇒ Hiding and Showing an MREC</a>
 */
- (void)startAutoRefresh;

/**
 * Pauses auto-refreshing of the banner.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/banners#hiding-a-banner"MAX Integration Guide ⇒ iOS ⇒ MRECs ⇒ Hiding a Banner</a>
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/mrecs#hiding-and-showing-an-mrec">MAX Integration Guide ⇒ iOS ⇒ MRECs ⇒ Hiding and Showing an MREC</a>
 */
- (void)stopAutoRefresh;

/**
 * The placement to tie the future ad events to.
 */
@property (nonatomic, copy, nullable) NSString *placement;

/**
 * The ad unit identifier this `MAAdView` was initialized with and is loading ads for.
 */
@property (nonatomic, copy, readonly) NSString *adUnitIdentifier;

/**
 * The format of the ad view.
 */
@property (nonatomic, weak, readonly) MAAdFormat *adFormat;

@end

NS_ASSUME_NONNULL_END
