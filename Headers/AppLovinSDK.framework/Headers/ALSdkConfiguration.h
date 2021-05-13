//
//  ALSdkConfiguration.h
//  AppLovinSDK
//
//  Created by Thomas So on 9/29/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * Object that contains various flags related to the SDK configuration.
 */
@interface ALSdkConfiguration : NSObject

/**
 * This enum represents whether or not the consent dialog should be shown for this user.
 * The state where no such determination could be made is represented by `ALConsentDialogStateUnknown`.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#general-data-protection-regulation-(%E2%80%9Cgdpr%E2%80%9D)">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ General Data Protection Regulation (“GDPR”)</a>
 */
typedef NS_ENUM(NSInteger, ALConsentDialogState)
{
    /**
     * The consent dialog state could not be determined. This is likely due to the SDK failing to initialize.
     */
    ALConsentDialogStateUnknown,
    
    /**
     * This user should be shown a consent dialog.
     */
    ALConsentDialogStateApplies,
    
    /**
     * This user should not be shown a consent dialog.
     */
    ALConsentDialogStateDoesNotApply
};

/**
 * AppLovin SDK-defined app tracking transparency status values (extended to include “unavailable” state on iOS before iOS14).
 */
typedef NS_ENUM(NSInteger, ALAppTrackingTransparencyStatus)
{
    /**
     * Device is on iOS before iOS14, AppTrackingTransparency.framework is not available.
     */
    ALAppTrackingTransparencyStatusUnavailable = -1,
    
    /**
     * The user has not yet received an authorization request to authorize access to app-related data that can be used for tracking the user or the device.
     */
    ALAppTrackingTransparencyStatusNotDetermined,
    
    /**
     * Authorization to access app-related data that can be used for tracking the user or the device is restricted.
     */
    ALAppTrackingTransparencyStatusRestricted,
    
    /**
     * The user denies authorization to access app-related data that can be used for tracking the user or the device.
     */
    ALAppTrackingTransparencyStatusDenied,
    
    /**
     * The user authorizes access to app-related data that can be used for tracking the user or the device.
     */
    ALAppTrackingTransparencyStatusAuthorized
};

/**
 * The consent dialog state for this user. If no determination could be made, the value of this property will be `ALConsentDialogStateUnknown`.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#general-data-protection-regulation-(%E2%80%9Cgdpr%E2%80%9D)">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ General Data Protection Regulation (“GDPR”)</a>
 */
@property (nonatomic, assign, readonly) ALConsentDialogState consentDialogState;

/**
 * Gets the country code for this user. The value of this property will be an empty string if no country code is available for this user.
 *
 * @warning Do not confuse this with the <em>currency</em> code which is “USD” in most cases.
 */
@property (nonatomic, copy, readonly) NSString *countryCode;

/**
 * Indicates whether or not the user authorizes access to app-related data that can be used for tracking the user or the device.
 *
 * @warning Users can revoke permission at any time through the “Allow Apps To Request To Track” privacy setting on the device.
 */
@property (nonatomic, assign, readonly) ALAppTrackingTransparencyStatus appTrackingTransparencyStatus;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
