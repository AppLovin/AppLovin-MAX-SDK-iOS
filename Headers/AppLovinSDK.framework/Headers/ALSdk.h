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
 * The current version of the SDK. The value is in the format of &quot;<var>Major</var>.<var>Minor</var>.<var>Revision</var>&quot;.
 */
@property (class, nonatomic, copy, readonly) NSString *version;

/**
 * The current version of the SDK in numeric format.
 */
@property (class, nonatomic, assign, readonly) NSUInteger versionCode;

/**
 * This SDK's SDK key.
 */
@property (nonatomic, copy, readonly) NSString *sdkKey;

/**
 * This SDK's SDK settings.
 */
@property (nonatomic, strong, readonly) ALSdkSettings *settings;

/**
 * The SDK configuration object provided upon initialization.
 */
 // [PLP] who provided it to whom? Is this "the SDK configuration object you provided when you initialized the SDK"? If so, how do you provide it?
@property (nonatomic, strong, readonly) ALSdkConfiguration *configuration;

/**
 * Sets the plugin version for the mediation adapter or plugin.
 *
 * @param pluginVersion Some descriptive string that identifies the plugin.
 */
- (void)setPluginVersion:(NSString *)pluginVersion;

/**
 * An identifier for the current user. This identifier will be tied to SDK events and AppLovin's optional S2S postbacks.
 *
 * If you use reward validation, you can optionally set an identifier that AppLovin will include with its currency validation postbacks (for example, a username
 * or email address). AppLovin will include this in the postback when AppLovin pings your currency endpoint from our server.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/s2s-rewarded-callback-api">MAX S2S Rewarded Callback API</a>
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
 * @return Event service. Guaranteed not to be `NULL`.
 */
@property (nonatomic, strong, readonly) ALEventService *eventService;

/**
 * The service object, which performs user-related tasks.
 *
 * @return User service. Guaranteed not to be `NULL`.
 */
@property (nonatomic, strong, readonly) ALUserService *userService;

/**
 * Get an instance of the AppLovin variable service. This service is used to perform various AB tests that you have set up on your AppLovin dashboard on your users.
 *
 * @return Variable service. Guaranteed not to be `NULL`.
 */
@property (nonatomic, strong, readonly) ALVariableService *variableService;

#pragma mark - MAX

/**
 * The mediation provider. Set this either by using one of the provided strings in {@link ALMediationProvider.h}, or your own string if you do not find an
 * applicable one there.
 */
@property (nonatomic, copy, nullable) NSString *mediationProvider;

/**
 * The list of available mediation networks, as an array of {@link MAMediatedNetworkInfo} objects.
 */
@property (nonatomic, strong, readonly) NSArray<MAMediatedNetworkInfo *> *availableMediatedNetworks;

/**
 * Presents the mediation debugger UI. This debugger tool provides the status of your integration for each third-party ad network.
 *
 * Call this method after the SDK has initialized, for example in the `completionHandler` of `initializeSdkWithCompletionHandler`.
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
 */
- (void)initializeSdkWithCompletionHandler:(nullable ALSdkInitializationCompletionHandler)completionHandler;

/**
 * Initializes the default instance of AppLovin SDK.
 *
 * @warning Make sure your SDK key is set in the application's `Info.plist` under the property 'AppLovinSdkKey'.
 */
+ (void)initializeSdk;

/**
 * Initializes the default instance of AppLovin SDK.
 *
 * @warning Make sure your SDK key is set in the application's `Info.plist` under the property 'AppLovinSdkKey'.
 *
 * @param completionHandler The callback that the SDK will run on the main queue when the SDK finishes initializing.
 */
+ (void)initializeSdkWithCompletionHandler:(nullable ALSdkInitializationCompletionHandler)completionHandler;

/**
 * Gets a shared instance of AppLovin SDK.
 *
 * @warning Make sure your SDK key is set in the application's `Info.plist` under the property 'AppLovinSdkKey'.
 *
 * @return The shared instance of AppLovin's SDK, or nil if SDK key is not set in the application's Info.plist.
 */
+ (nullable ALSdk *)shared;

/**
 * Gets a shared instance of AppLovin SDK.
 *
 * @warning Make sure your SDK key is set in the application's `Info.plist` under the property 'AppLovinSdkKey'.
 *
 * @param settings An SDK settings object.
 *
 * @return The shared instance of AppLovin's SDK, or nil if SDK key is not set in the application's Info.plist.
 */
+ (nullable ALSdk *)sharedWithSettings:(ALSdkSettings *)settings;

/**
 * Gets an instance of AppLovin SDK by using an SDK key.
 *
 * @param key SDK key to use for the instance of the AppLovin SDK.
 *
 * @return An instance of AppLovinSDK, or `nil` if the SDK key is not set.
 */
 // [PLP] what does it mean for the key to be "not set"? Does this mean "if you passed in a null or empty string for the key" or something more subtle?
+ (nullable ALSdk *)sharedWithKey:(NSString *)key;

/**
 * Gets an instance of AppLovin SDK by using an SDK key and providing SDK settings.
 *
 * @param key       SDK key to use for the instance of the AppLovin SDK.
 * @param settings  An SDK settings object.
 *
 * @return An instance of AppLovinSDK, or `nil` if SDK key is not set.
 */
 // [PLP] what does it mean for the key to be "not set"? Does this mean "if you passed in a null or empty string for the key" or something more subtle?
+ (nullable ALSdk *)sharedWithKey:(NSString *)key settings:(ALSdkSettings *)settings;


/**
 * To get an instance of this SDK, use the `shared` or `sharedWithKey` methods.
 */
- (instancetype)init __attribute__((unavailable("Use +[ALSdk shared], +[ALSdk sharedWithKey:], or +[ALSdk sharedWithKey:settings:].")));
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
