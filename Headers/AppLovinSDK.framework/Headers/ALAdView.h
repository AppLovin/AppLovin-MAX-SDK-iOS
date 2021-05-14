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
 * An object that conforms to the @code [ALAdLoadDelegate] @endcode protocol. If you provide a value for `adLoadDelegate` in your instance, the SDK will notify
 * this delegate of ad load events.
 *
 * @warning This delegate is retained strongly and might lead to retain cycles if delegate holds strong reference to this `ALAdView`.
 */
@property (nonatomic, strong, nullable) IBOutlet id<ALAdLoadDelegate> adLoadDelegate;

/**
 * An object that conforms to the @code [ALAdDisplayDelegate] @endcode protocol. If you provide a value for `adDisplayDelegate` in your instance, the SDK will
 * notify this delegate of ad show/hide events.
 *
 * @warning This delegate is retained strongly and might lead to retain cycles if delegate holds strong reference to this `ALAdView`.
 */
@property (nonatomic, strong, nullable) IBOutlet id<ALAdDisplayDelegate> adDisplayDelegate;

/**
 * An object that conforms to the @code [ALAdViewEventDelegate] @endcode protocol. If you provide a value for `adEventDelegate` in your instance, the SDK will
 * notify this delegate of `ALAdView`-specific events.
 *
 * @warning This delegate is retained strongly and might lead to retain cycles if delegate holds strong reference to this `ALAdView`.
 */
@property (nonatomic, strong, nullable) IBOutlet id<ALAdViewEventDelegate> adEventDelegate;

/**
 * @name Ad View Configuration
 */

/**
 * The size of ads to load within this `ALAdView`.
 */
@property (nonatomic, strong) ALAdSize *adSize;

/**
 * The zone identifier this `ALAdView` was initialized with and is loading ads for, if any.
 */
@property (nonatomic, copy, readonly, nullable) NSString *zoneIdentifier;

/**
 * Whether or not this ad view should automatically load the ad when iOS inflates it from a StoryBoard or from a nib file (when
 * @code -[UIView awakeFromNib] @endcode is called). The default value is `NO` which means you are responsible for loading the ad by invoking
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
 * Renders a specific ad that was loaded via @code [ALAdService] @endcode.
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
 * @param size @code [ALAdSize] @endcode that represents the size of this ad. For example, @code [ALAdSize banner] @endcode.
 *
 * @return A new instance of `ALAdView`.
 */
- (instancetype)initWithSize:(ALAdSize *)size;

/**
 * Initializes the ad view for a given size and zone.
 *
 * @param size           @code [ALAdSize] @endcode that represents the size of this ad. For example, @code [ALAdSize banner] @endcode.
 * @param zoneIdentifier Identifier for the zone this `ALAdView` should load ads for.
 *
 * @return A new instance of `ALAdView`.
 */
- (instancetype)initWithSize:(ALAdSize *)size zoneIdentifier:(nullable NSString *)zoneIdentifier;

/**
 * Initializes the ad view with a given SDK and size.
 *
 * @param sdk  Instance of @code [ALSdk] @endcode to use.
 * @param size @code [ALAdSize] @endcode that represents the size of this ad. For example, @code [ALAdSize banner] @endcode.
 *
 * @return A new instance of `ALAdView`.
 */
- (instancetype)initWithSdk:(ALSdk *)sdk size:(ALAdSize *)size;

/**
 * Initializes the ad view with a given SDK, size, and zone.
 *
 * @param sdk            Instance of @code [ALSdk] @endcode to use.
 * @param size           @code [ALAdSize] @endcode that represents the size of this ad. For example, @code [ALAdSize banner] @endcode.
 * @param zoneIdentifier Identifier for the zone that this `ALAdView` should load ads for.
 *
 * @return A new instance of `ALAdView`.
 */
- (instancetype)initWithSdk:(ALSdk *)sdk size:(ALAdSize *)size zoneIdentifier:(nullable NSString *)zoneIdentifier;

/**
 * Initializes the ad view with a given frame, ad size, and SDK instance.
 *
 * @param frame  Describes the position and dimensions of the ad.
 * @param size   @code [ALAdSize] @endcode that represents the size of this ad. For example, @code [ALAdSize banner] @endcode.
 * @param sdk    Instance of @code [ALSdk] @endcode to use.
 *
 * @return A new instance of `ALAdView`.
 */
- (instancetype)initWithFrame:(CGRect)frame size:(ALAdSize *)size sdk:(ALSdk *)sdk;

/**
 * Use @code -[ALAdView initWithSize:] @endcode, @code -[ALAdView initWithSize:zoneIdentifier:] @endcode, @code -[ALAdView initWithSdk:size:] @endcode,
 * @code -[ALAdView initWithSdk:size:zoneIdentifier:] @endcode, or @code -[ALAdView initWithFrame:size:sdk:] @endcode instead.
 */
- (instancetype)init NS_UNAVAILABLE;
/**
 * Use @code -[ALAdView initWithSize:] @endcode, @code -[ALAdView initWithSize:zoneIdentifier:] @endcode, @code -[ALAdView initWithSdk:size:] @endcode,
 * @code -[ALAdView initWithSdk:size:zoneIdentifier:] @endcode, or @code -[ALAdView initWithFrame:size:sdk:] @endcode instead.
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
