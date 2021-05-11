//
//  ALSdkSettings.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class contains settings for enabling the AppLovin consent flow.
 */
@interface ALConsentFlowSettings : NSObject

/**
 * Whether or not the flow should be enabled. You must also provide your privacy policy and terms of service URLs in this object, as well as the the NSUserTrackingUsageDescription string in the Info.plist.
 *
 * Defaults to the value entered into your Info.plist via AppLovinConsentFlowInfo->AppLovinConsentFlowEnabled.
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/**
 * URL for your company's privacy policy. Required in order to enable the consent flow. Defaults to the value entered into your Info.plist via AppLovinConsentFlowInfo->AppLovinConsentFlowPrivacyPolicy.
 */
@property (nonatomic, copy, nullable) NSURL *privacyPolicyURL;

/**
 * URL for your company's terms of service. Optional in order to enable the consent flow. Defaults to the value entered into your Info.plist via AppLovinConsentFlowInfo->AppLovinConsentFlowTermsOfService.
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
 * Toggle verbose logging for the SDK. This is set to NO by default. Set to NO if SDK should be silent (recommended for App Store submissions).
 *
 * If enabled AppLovin messages will appear in standard application log accessible via console.
 * All log messages will be prefixed by the "AppLovinSdk" tag.
 *
 * Verbose logging is <i>disabled</i> by default.
 */
@property (nonatomic, assign) BOOL isVerboseLogging;

/**
 * Determines whether to begin video ads in a muted state or not. Defaults to NO unless changed in the dashboard.
 */
@property (nonatomic, assign) BOOL muted;

/**
 * Determines whether the creative debugger will be displayed on fullscreen ads after flipping the device screen down twice. Defaults to YES.
 */
@property (nonatomic, assign) BOOL creativeDebuggerEnabled;

/**
 * Enable devices to receive test ads, by passing in the advertising identifier (IDFA) of each test device.
 * Refer to AppLovin logs for the IDFA of your current device.
 */
@property (nonatomic, copy) NSArray<NSString *> *testDeviceAdvertisingIdentifiers;

/**
 * The MAX ad unit ids that will be used for this instance of the SDK. 3rd-party SDKs will be initialized with the credentials configured for these ad unit ids.
 */
@property (nonatomic, copy) NSArray<NSString *> *initializationAdUnitIdentifiers;

/**
 * Whether or not the AppLovin SDK listens to exceptions. Defaults to YES.
 */
@property (nonatomic, assign, getter=isExceptionHandlerEnabled) BOOL exceptionHandlerEnabled;

@end

NS_ASSUME_NONNULL_END
