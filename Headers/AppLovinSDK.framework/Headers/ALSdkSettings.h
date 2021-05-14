//
//  ALSdkSettings.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class contains settings that enable the AppLovin consent flow.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/consent-flowMAX Integration Guide ⇒ iOS ⇒ Consent Flow</a>
 */
@interface ALConsentFlowSettings : NSObject

/**
 * Set this to `YES` to enable the consent flow. You must also provide your privacy policy and terms of service URLs in this object, and you must provide a
 * `NSUserTrackingUsageDescription` string in your `Info.plist` file.
 *
 * This defaults to the value that you entered into your `Info.plist` file via `AppLovinConsentFlowInfo`⇒`AppLovinConsentFlowEnabled`.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/consent-flow#info.plist">MAX Integration Guide ⇒ iOS ⇒ Consent Flow ⇒ Info.plist</a>
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/**
 * URL for your company’s privacy policy. This is required in order to enable the consent flow.
 *
 * This defaults to the value that you entered into your `Info.plist` file via `AppLovinConsentFlowInfo`⇒`AppLovinConsentFlowPrivacyPolicy`.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/consent-flow#info.plist">MAX Integration Guide ⇒ iOS ⇒ Consent Flow ⇒ Info.plist</a>
 */
@property (nonatomic, copy, nullable) NSURL *privacyPolicyURL;

/**
 * URL for your company’s terms of service. This is optional; you can enable the consent flow with or without it.
 *
 * This defaults to the value that you entered into your `Info.plist` file via `AppLovinConsentFlowInfo`⇒`AppLovinConsentFlowTermsOfService`.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/consent-flow#info.plist">MAX Integration Guide ⇒ iOS ⇒ Consent Flow ⇒ Info.plist</a>
 */
@property (nonatomic, copy, nullable) NSURL *termsOfServiceURL;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * This class contains settings for the AppLovin SDK.
 */
@interface ALSdkSettings : NSObject

/**
 * Settings relating to the AppLovin consent flow.
 */
@property (nonatomic, strong, readonly) ALConsentFlowSettings *consentFlowSettings;

/**
 * A toggle for verbose logging for the SDK. This is set to `NO` by default. Set it to `NO` if you want the SDK to be silent (this is recommended for App Store
 * submissions).
 *
 * If set to `YES` AppLovin messages will appear in the standard application log which is accessible via the console. All AppLovin log messages are prefixed
 * with the `/AppLovinSdk: [AppLovinSdk]` tag.
 *
 * Verbose logging is <em>disabled</em> (`NO`) by default.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/advanced-settings#enable-verbose-logging">MAX Integration Guide ⇒ iOS ⇒ Advanced Settings ⇒ Enable Verbose Logging</a>
 */
@property (nonatomic, assign) BOOL isVerboseLogging;

/**
 * Whether to begin video ads in a muted state or not. Defaults to `NO` unless you change this in the dashboard.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/advanced-settings#mute-audio">MAX Integration Guide ⇒ iOS ⇒ Advanced Settings ⇒ Mute Audio</a>
 */
 // [PLP] @see the part of the dashboard where you can change this?
@property (nonatomic, assign) BOOL muted;

/**
 * Whether the creative debugger will be displayed on fullscreen ads after flipping the device screen down twice. Defaults to `YES`.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/testing-networks/creative-debugger">MAX Integration Guide ⇒ iOS ⇒ Testing Networks ⇒ Creative Debugger</a>
 */
@property (nonatomic, assign) BOOL creativeDebuggerEnabled;

/**
 * Enable devices to receive test ads by passing in the advertising identifier (IDFA) of each test device.
 * Refer to AppLovin logs for the IDFA of your current device.
 */
@property (nonatomic, copy) NSArray<NSString *> *testDeviceAdvertisingIdentifiers;

/**
 * The MAX ad unit IDs that you will use for this instance of the SDK. This initializes third-party SDKs with the credentials configured for these ad unit IDs.
 */
@property (nonatomic, copy) NSArray<NSString *> *initializationAdUnitIdentifiers;

/**
 * Whether or not the AppLovin SDK listens to exceptions. Defaults to `YES`.
 */
@property (nonatomic, assign, getter=isExceptionHandlerEnabled) BOOL exceptionHandlerEnabled;

@end

NS_ASSUME_NONNULL_END
