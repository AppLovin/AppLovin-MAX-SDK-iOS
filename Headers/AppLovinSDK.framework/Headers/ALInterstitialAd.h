//
//  ALInterstitialAd.h
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class displays full-screen ads to the user.
 */
@interface ALInterstitialAd : NSObject

#pragma mark - Ad Delegates

/**
 * An object that conforms to the @code [ALAdLoadDelegate] @endcode protocol. If you provide a value for `adLoadDelegate` in your instance, the SDK will notify
 * this delegate of ad load events.
 */
@property (nonatomic, strong, nullable) id<ALAdLoadDelegate> adLoadDelegate;

/**
 * An object that conforms to the @code [ALAdDisplayDelegate] @endcode protocol. If you provide a value for `adDisplayDelegate` in your instance, the SDK will
 * notify this delegate of ad show/hide events.
 */
@property (nonatomic, strong, nullable) id<ALAdDisplayDelegate> adDisplayDelegate;

/**
 * An object that conforms to the @code [ALAdVideoPlaybackDelegate] @endcode protocol. If you provide a value for `adVideoPlaybackDelegate` in your instance,
 * the SDK will notify this delegate of video start/finish events.
 */
@property (nonatomic, strong, nullable) id<ALAdVideoPlaybackDelegate> adVideoPlaybackDelegate;

#pragma mark - Loading and Showing Ads, Class Methods

/**
 * Shows an interstitial over the application’s key window. This loads the next interstitial and displays it.
 */
+ (instancetype)show;

/**
 * Gets a reference to the shared singleton instance.
 *
 * This method calls @code +[ALSdk shared] @endcode which requires that you have an SDK key defined in `Info.plist`.
 *
 * @warning If you use @code +[ALSdk sharedWithKey:] @endcode then you will need to use the instance methods instead.
 */
+ (instancetype)shared;

#pragma mark - Loading and Showing Ads, Instance Methods

/**
 * Shows an interstitial over the application’s key window. This loads the next interstitial and displays it.
 */
- (void)show;

/**
 * Shows the current interstitial over a given window and renders a specified ad loaded by @code [ALAdService] @endcode.
 *
 * @param ad The ad to render into this interstitial.
 */
- (void)showAd:(ALAd *)ad;

#pragma mark - Initialization

/**
 * Initializes an instance of this class with an SDK instance.
 *
 * @param sdk The AppLovin SDK instance to use.
 */
- (instancetype)initWithSdk:(ALSdk *)sdk;

/**
 * Use @code +[ALInterstitialAd shared] @endcode or @code -[ALInterstitialAd initWithSdk:] @endcode instead
 */
- (instancetype)init NS_UNAVAILABLE;
/**
 * Use @code +[ALInterstitialAd shared] @endcode or @code -[ALInterstitialAd initWithSdk:] @endcode instead
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
