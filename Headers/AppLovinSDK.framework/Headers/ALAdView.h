//
//  ALAdView.h
//  AppLovinSDK
//
//  Created by Basil on 3/1/12.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ALSdk.h"
#import "ALAdService.h"
#import "ALAdViewEventDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This interface represents a view-based ad — i.e. banner, MREC, or leader.
 */
@interface ALAdView : UIView

/**
 * @name Ad Delegates
 */

/**
 * An object that conforms to the @c ALAdLoadDelegate protocol. If you provide a value for @c adLoadDelegate in your instance, the SDK will notify
 * this delegate of ad load events.
 *
 * @warning This delegate is retained strongly and might lead to retain cycles if delegate holds strong reference to this @c ALAdView.
 */
@property (nonatomic, strong, nullable) IBOutlet id<ALAdLoadDelegate> adLoadDelegate;

/**
 * An object that conforms to the @c ALAdDisplayDelegate protocol. If you provide a value for @c adDisplayDelegate in your instance, the SDK will
 * notify this delegate of ad show/hide events.
 *
 * @warning This delegate is retained strongly and might lead to retain cycles if delegate holds strong reference to this @c ALAdView.
 */
@property (nonatomic, strong, nullable) IBOutlet id<ALAdDisplayDelegate> adDisplayDelegate;

/**
 * An object that conforms to the @c ALAdViewEventDelegate protocol. If you provide a value for @c adEventDelegate in your instance, the SDK will
 * notify this delegate of @c ALAdView -specific events.
 *
 * @warning This delegate is retained strongly and might lead to retain cycles if delegate holds strong reference to this @c ALAdView.
 */
@property (nonatomic, strong, nullable) IBOutlet id<ALAdViewEventDelegate> adEventDelegate;

/**
 * @name Ad View Configuration
 */

/**
 * The size of ads to load within this @c ALAdView.
 */
@property (nonatomic, strong) ALAdSize *adSize;

/**
 * The zone identifier this @c ALAdView was initialized with and is loading ads for, if any.
 */
@property (nonatomic, copy, readonly, nullable) NSString *zoneIdentifier;

/**
 * Whether or not this ad view should automatically load the ad when iOS inflates it from a StoryBoard or from a nib file (when
 * @code -[UIView awakeFromNib] @endcode is called). The default value is @c NO which means you are responsible for loading the ad by invoking
 * @code -[ALAdView loadNextAd] @endcode.
 */
@property (nonatomic, assign, getter=isAutoloadEnabled, setter=setAutoloadEnabled:) BOOL autoload;

/**
 * @name Loading and Rendering Ads
 */

/**
 * Loads <em>and</em> displays an ad into the view. This method returns immediately.
 *
 * <b>Note:</b> To load the ad but not display it, use @code +[ALSdk shared] @endcode ⇒ @code [ALSDK adService] @endcode
 *              ⇒ @code -[ALAdService loadNextAd:andNotify:] @endcode, then @code -[ALAdView render:] @endcode to render it.
 */
- (void)loadNextAd;

/**
 * Renders a specific ad that was loaded via @c ALAdService.
 *
 * @param ad Ad to render.
 */
- (void)render:(ALAd *)ad;

/**
 * @name Initialization
 */

/**
 * Initializes the ad view with a given size.
 *
 * @param size @c ALAdSize that represents the size of this ad. For example, @code [ALAdSize banner] @endcode.
 *
 * @return A new instance of @c ALAdView.
 */
- (instancetype)initWithSize:(ALAdSize *)size;

/**
 * Initializes the ad view for a given size and zone.
 *
 * @param size           @c ALAdSize that represents the size of this ad. For example, @code [ALAdSize banner] @endcode.
 * @param zoneIdentifier Identifier for the zone this @c ALAdView should load ads for.
 *
 * @return A new instance of @c ALAdView.
 */
- (instancetype)initWithSize:(ALAdSize *)size zoneIdentifier:(nullable NSString *)zoneIdentifier;

/**
 * Initializes the ad view with a given SDK and size.
 *
 * @param sdk  Instance of @c ALSdk to use.
 * @param size @c ALAdSize that represents the size of this ad. For example, @code [ALAdSize banner] @endcode.
 *
 * @return A new instance of @c ALAdView.
 */
- (instancetype)initWithSdk:(ALSdk *)sdk size:(ALAdSize *)size;

/**
 * Initializes the ad view with a given SDK, size, and zone.
 *
 * @param sdk            Instance of @c ALSdk to use.
 * @param size           @c ALAdSize that represents the size of this ad. For example, @code [ALAdSize banner] @endcode.
 * @param zoneIdentifier Identifier for the zone that this @c ALAdView should load ads for.
 *
 * @return A new instance of @c ALAdView.
 */
- (instancetype)initWithSdk:(ALSdk *)sdk size:(ALAdSize *)size zoneIdentifier:(nullable NSString *)zoneIdentifier;

/**
 * Initializes the ad view with a given frame, ad size, and SDK instance.
 *
 * @param frame  Describes the position and dimensions of the ad.
 * @param size   @c ALAdSize that represents the size of this ad. For example, @code [ALAdSize banner] @endcode.
 * @param sdk    Instance of @c ALSdk to use.
 *
 * @return A new instance of @c ALAdView.
 */
- (instancetype)initWithFrame:(CGRect)frame size:(ALAdSize *)size sdk:(ALSdk *)sdk;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
