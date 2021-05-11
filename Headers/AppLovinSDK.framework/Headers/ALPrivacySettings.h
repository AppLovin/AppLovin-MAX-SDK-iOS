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
 * Set whether or not user has provided consent for information sharing with AppLovin.
 *
 * @param hasUserConsent @c YES if the user has provided consent for information sharing with AppLovin. @c NO by default.
 */
+ (void)setHasUserConsent:(BOOL)hasUserConsent;

/**
 * Check if user has provided consent for information sharing with AppLovin.
 *
 * @return @c YES if user has provided consent for information sharing.
 */
+ (BOOL)hasUserConsent;

/**
 * Mark user as age restricted (i.e. under 16).
 *
 * @param isAgeRestrictedUser @c YES if the user is age restricted (i.e. under 16).
 */
+ (void)setIsAgeRestrictedUser:(BOOL)isAgeRestrictedUser;

/**
 * Check if user is age restricted.
 *
 * @return @c YES if user is age restricted. @c nil if not set.
 */
+ (BOOL)isAgeRestrictedUser;

/**
 * Set whether or not user has opted out of the sale of their personal information.
 *
 * @param doNotSell @c YES if the user has opted out of the sale of their personal information.
 */
+ (void)setDoNotSell:(BOOL)doNotSell;

/**
 * Check if the user has opted out of the sale of their personal information.
 *
 * @return @c YES if user has opted out of the sale of their personal information.
 */
+ (BOOL)isDoNotSell;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
