//
//  ALSdkConfiguration.h
//  AppLovinSDK
//
//  Created by Thomas So on 9/29/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * Object containing various flags related to the SDK configuration.
 */
@interface ALSdkConfiguration : NSObject

/**
 * This enum represents whether or not the consent dialog should be shown for this user.
 * The state where no such determination could be made is represented by `ALConsentDialogStateUnknown`.
 */
typedef NS_ENUM(NSInteger, ALConsentDialogState)
{
    /**
     * The consent dialog state could not be determined. This is likely due to SDK failing to initialize.
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
 * AppLovin SDK defined app tracking transparency status values (extended to include "unavailable" state on < iOS14).
 */
typedef NS_ENUM(NSInteger, ALAppTrackingTransparencyStatus)
{
    /**
     * Device is on < iOS14, AppTrackingTransparency.framework is not available.
     */
    ALAppTrackingTransparencyStatusUnavailable = -1,
    
    /**
     * The value returned if a user has not yet received an authorization request to authorize access to app-related data that can be used for tracking the user or the device.
     */
    ALAppTrackingTransparencyStatusNotDetermined,
    
    /**
     * The value returned if authorization to access app-related data that can be used for tracking the user or the device is restricted.
     */
    ALAppTrackingTransparencyStatusRestricted,
    
    /**
     * The value returned if the user denies authorization to access app-related data that can be used for tracking the user or the device.
     */
    ALAppTrackingTransparencyStatusDenied,
    
    /**
     * The value returned if the user authorizes access to app-related data that can be used for tracking the user or the device.
     */
    ALAppTrackingTransparencyStatusAuthorized
};

/**
 * Get the consent dialog state for this user. If no such determination could be made, `ALConsentDialogStateUnknown` will be returned.
 */
@property (nonatomic, assign, readonly) ALConsentDialogState consentDialogState;

/**
 * Get the country code for this user. Returns an empty string if not available.
 */
@property (nonatomic, copy, readonly) NSString *countryCode;

/**
 * Whether or not the user authorizes access to app-related data that can be used for tracking the user or the device. Note, end users can revoke permission at any time through the Allow Apps To Request To Track privacy setting on the device.
 */
@property (nonatomic, assign, readonly) ALAppTrackingTransparencyStatus appTrackingTransparencyStatus;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
