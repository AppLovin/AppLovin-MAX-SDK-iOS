//
//  ALPrivacySettings.h
//  AppLovinSDK
//
//  Created by Basil Shikin on 3/26/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This class contains privacy settings for AppLovin.
 */
@interface ALPrivacySettings : NSObject

/**
 * Sets whether or not the user has provided consent for information-sharing with AppLovin.
 *
 * @param hasUserConsent `YES` if the user provided consent for information-sharing with AppLovin. `NO` by default.
 */
+ (void)setHasUserConsent:(BOOL)hasUserConsent;

/**
 * Checks if the user has provided consent for information-sharing with AppLovin.
 *
 * @return `YES` if the user provided consent for information-sharing.
 */
+ (BOOL)hasUserConsent;

/**
 * Marks the user as age-restricted (i.e. under 16).
 *
 * @param isAgeRestrictedUser `YES` if the user is age-restricted (i.e. under 16).
 */
+ (void)setIsAgeRestrictedUser:(BOOL)isAgeRestrictedUser;

/**
 * Checks if the user is age-restricted.
 *
 * @return `YES` if the user is age-restricted. `nil` if the age-restriction setting is not set.
 */
+ (BOOL)isAgeRestrictedUser;

/**
 * Sets whether or not the user has opted out of the sale of their personal information.
 *
 * @param doNotSell `YES` if the user opted out of the sale of their personal information.
 */
+ (void)setDoNotSell:(BOOL)doNotSell;

/**
 * Checks if the user has opted out of the sale of their personal information.
 *
 * @return `YES` if user opted out of the sale of their personal information.
 */
+ (BOOL)isDoNotSell;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
