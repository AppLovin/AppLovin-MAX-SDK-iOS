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
 * An object that conforms to the {@link ALAdLoadDelegate} protocol, which, if set, will be notified of ad load events.
 */
 // [PLP] how do you set a protocol or an object? who notifies?
@property (nonatomic, strong, nullable) id<ALAdLoadDelegate> adLoadDelegate;

/**
 * An object that conforms to the {@link ALAdDisplayDelegate} protocol, which, if set, will be notified of ad show/hide events.
 */
 // [PLP] how do you set a protocol or an object? who notifies?
@property (nonatomic, strong, nullable) id<ALAdDisplayDelegate> adDisplayDelegate;

/**
 * An object that conforms to the {@link ALAdVideoPlaybackDelegate} protocol, which, if set, will be notified of video start/finish events.
 */
 // [PLP] how do you set a protocol or an object? who notifies?
@property (nonatomic, strong, nullable) id<ALAdVideoPlaybackDelegate> adVideoPlaybackDelegate;

#pragma mark - Loading and Showing Ads, Class Methods

/**
 * Shows an interstitial over the application’s key window. This loads the next interstitial and displays it.
 */
+ (instancetype)show;

/**
 * Gets a reference to the shared singleton instance.
 *
 * This method calls {@link ALSdk::shared} which requires that you have an SDK key defined in `Info.plist`.
 *
 * @warning If you use {@link ALSdk::sharedWithKey:} then you will need to use the instance methods instead.
 */
+ (instancetype)shared;

#pragma mark - Loading and Showing Ads, Instance Methods

/**
 * Shows an interstitial over the application’s key window. This loads the next interstitial and displays it.
 */
- (void)show;

/**
 * Shows the current interstitial over a given window and renders a specified ad loaded by {@link ALAdService}.
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
 * Use {@link shared} or {@link initWithSdk:} instead
 */
- (instancetype)init NS_UNAVAILABLE;
/**
 * Use {@link shared} or {@link initWithSdk:} instead
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
