//
//  ALSdk.h
//  AppLovinSDK
//
//  Created by Basil Shikin on 2/1/12.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALSdkSettings.h"
#import "ALAdService.h"
#import "ALEventService.h"
#import "ALVariableService.h"
#import "ALUserService.h"
#import "ALSdkConfiguration.h"
#import "ALErrorCodes.h"
#import "ALMediationProvider.h"
#import "ALUserSegment.h"
#import "MAMediatedNetworkInfo.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This is a base class for the AppLovin iOS SDK.
 */
@interface ALSdk : NSObject


#pragma mark - High Level SDK Properties

/**
 * The current version of the SDK. The value is in the format of "<var>Major</var>.<var>Minor</var>.<var>Revision</var>".
 */
@property (class, nonatomic, copy, readonly) NSString *version;

/**
 * The current version of the SDK in numeric format.
 */
@property (class, nonatomic, assign, readonly) NSUInteger versionCode;

/**
 * This SDK’s SDK key.
 */
@property (nonatomic, copy, readonly) NSString *sdkKey;

/**
 * This SDK’s SDK settings.
 */
@property (nonatomic, strong, readonly) ALSdkSettings *settings;

/**
 * The SDK configuration object that the SDK creates when you initialize the SDK.
 */
@property (nonatomic, strong, readonly) ALSdkConfiguration *configuration;

/**
 * Sets the plugin version for the mediation adapter or plugin.
 *
 * @param pluginVersion Some descriptive string that identifies the plugin.
 */
- (void)setPluginVersion:(NSString *)pluginVersion;

/**
 * An identifier for the current user. This identifier will be tied to SDK events and AppLovin’s optional S2S postbacks.
 *
 * If you use reward validation, you can optionally set an identifier that AppLovin will include with its currency validation postbacks (for example, a username
 * or email address). AppLovin will include this in the postback when AppLovin pings your currency endpoint from our server.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/s2s-rewarded-callback-api#setting-an-internal-user-id">MAX Integration Guide ⇒ MAX S2S Rewarded Callback API ⇒ Setting an Internal User ID</a>
 */
@property (nonatomic, copy, nullable) NSString *userIdentifier;

/**
 * A user segment allows AppLovin to serve ads by using custom-defined rules that are based on which segment the user is in. The user segment is a custom string
 * of 32 alphanumeric characters or less.
 */
@property (nonatomic, strong, readonly) ALUserSegment *userSegment;

#pragma mark - SDK Services

/**
 * The ad service, which loads and displays ads from AppLovin servers.
 */
@property (nonatomic, strong, readonly) ALAdService *adService;

/**
 * The AppLovin event service, which tracks post-install user events.
 *
 * @return Event service. Guaranteed not to be @c NULL.
 */
@property (nonatomic, strong, readonly) ALEventService *eventService;

/**
 * The service object, which performs user-related tasks.
 *
 * @return User service. Guaranteed not to be @c NULL.
 */
@property (nonatomic, strong, readonly) ALUserService *userService;

/**
 * Get an instance of the AppLovin variable service. This service is used to perform various A/B tests that you have set up on your AppLovin dashboard on your
 * users.
 *
 * @return Variable service. Guaranteed not to be @c NULL.
 */
@property (nonatomic, strong, readonly) ALVariableService *variableService;

#pragma mark - MAX

/**
 * The mediation provider. Set this either by using one of the provided strings in ALMediationProvider.h, or your own string if you do not find an
 * applicable one there.
 */
@property (nonatomic, copy, nullable) NSString *mediationProvider;

/**
 * The list of available mediation networks, as an array of @c MAMediatedNetworkInfo objects.
 */
@property (nonatomic, strong, readonly) NSArray<MAMediatedNetworkInfo *> *availableMediatedNetworks;

/**
 * Presents the mediation debugger UI. This debugger tool provides the status of your integration for each third-party ad network.
 *
 * Call this method after the SDK has initialized, for example in the @c completionHandler of @code -[ALSdk initializeSdkWithCompletionHandler:] @endcode.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/testing-networks/mediation-debugger">MAX Integration Guide ⇒ iOS ⇒ Testing Networks ⇒ Mediation Debugger</a>
 */
- (void)showMediationDebugger;

#pragma mark - SDK Initialization

/**
 * The sort of callback that the SDK calls when it finishes initializing.
 */
typedef void (^ALSdkInitializationCompletionHandler)(ALSdkConfiguration *configuration);

/**
 * Initializes the SDK.
 */
- (void)initializeSdk;

/**
 * Initializes the SDK with a given completion block.
 *
 * The SDK invokes the callback on the main thread.
 *
 * @param completionHandler The callback that the SDK will call when the SDK finishes initializing.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/integration#initialize-the-sdk">MAX Integration Guide ⇒ iOS ⇒ Integration ⇒ Initialize the SDK</a>
 */
- (void)initializeSdkWithCompletionHandler:(nullable ALSdkInitializationCompletionHandler)completionHandler;

/**
 * Initializes the default instance of AppLovin SDK.
 *
 * @warning Make sure your SDK key is set in the application’s @code Info.plist @endcode under the property @c AppLovinSdkKey.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/integration#initialize-the-sdk">MAX Integration Guide ⇒ iOS ⇒ Integration ⇒ Initialize the SDK</a>
 */
+ (void)initializeSdk;

/**
 * Initializes the default instance of AppLovin SDK.
 *
 * @warning Make sure your SDK key is set in the application’s @code Info.plist @endcode under the property @c AppLovinSdkKey.
 *
 * @param completionHandler The callback that the SDK will run on the main queue when the SDK finishes initializing.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/integration#initialize-the-sdk">MAX Integration Guide ⇒ iOS ⇒ Integration ⇒ Initialize the SDK</a>
 */
+ (void)initializeSdkWithCompletionHandler:(nullable ALSdkInitializationCompletionHandler)completionHandler;

/**
 * Gets a shared instance of AppLovin SDK.
 *
 * @warning Make sure your SDK key is set in the application’s @code Info.plist @endcode under the property @c AppLovinSdkKey.
 *
 * @return The shared instance of AppLovin’s SDK, or @c nil (indicating an error) if the SDK key is not set in the application’s @code Info.plist @endcode.
 */
+ (nullable ALSdk *)shared;

/**
 * Gets a shared instance of AppLovin SDK.
 *
 * @warning Make sure your SDK key is set in the application’s @code Info.plist @endcode under the property @c AppLovinSdkKey.
 *
 * @param settings An SDK settings object.
 *
 * @return The shared instance of AppLovin’s SDK, or @c nil (indicating an error) if the SDK key is not set in the application’s @code Info.plist @endcode.
 */
+ (nullable ALSdk *)sharedWithSettings:(ALSdkSettings *)settings;

/**
 * Gets an instance of AppLovin SDK by using an SDK key.
 *
 * @param key SDK key to use for the instance of the AppLovin SDK.
 *
 * @return An instance of AppLovin’s SDK, or @c nil (indicating an error) if @c key is not set.
 */
+ (nullable ALSdk *)sharedWithKey:(NSString *)key;

/**
 * Gets an instance of AppLovin SDK by using an SDK key and providing SDK settings.
 *
 * @param key       SDK key to use for the instance of the AppLovin SDK.
 * @param settings  An SDK settings object.
 *
 * @return An instance of AppLovin’s SDK, or @c nil (indicating an error) if @c key is not set.
 */
+ (nullable ALSdk *)sharedWithKey:(NSString *)key settings:(ALSdkSettings *)settings;

- (instancetype)init __attribute__((unavailable("Use +[ALSdk shared], +[ALSdk sharedWithKey:], or +[ALSdk sharedWithKey:settings:].")));
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
