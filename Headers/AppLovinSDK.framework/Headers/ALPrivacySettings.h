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
 * @param hasUserConsent @c YES if the user provided consent for information-sharing with AppLovin. @c NO by default.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#general-data-protection-regulation-(%E2%80%9Cgdpr%E2%80%9D)">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ General Data Protection Regulation ("GDPR")</a>
 */
+ (void)setHasUserConsent:(BOOL)hasUserConsent;

/**
 * Checks if the user has provided consent for information-sharing with AppLovin.
 *
 * @return @c YES if the user provided consent for information-sharing.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#general-data-protection-regulation-(%E2%80%9Cgdpr%E2%80%9D)">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ General Data Protection Regulation ("GDPR")</a>
 */
+ (BOOL)hasUserConsent;

/**
 * Marks the user as age-restricted (i.e. under 16).
 *
 * @param isAgeRestrictedUser @c YES if the user is age-restricted (i.e. under 16).
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#children-data">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ Children Data</a>
 */
+ (void)setIsAgeRestrictedUser:(BOOL)isAgeRestrictedUser;

/**
 * Checks if the user is age-restricted.
 *
 * @return @c YES if the user is age-restricted. @c nil if the age-restriction setting is not set.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#children-data">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ Children Data</a>
 */
+ (BOOL)isAgeRestrictedUser;

/**
 * Sets whether or not the user has opted out of the sale of their personal information.
 *
 * @param doNotSell @c YES if the user opted out of the sale of their personal information.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#california-consumer-privacy-act-(%E2%80%9Cccpa%E2%80%9D)">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ California Consumer Privacy Act ("CCPA")</a>
 */
+ (void)setDoNotSell:(BOOL)doNotSell;

/**
 * Checks if the user has opted out of the sale of their personal information.
 *
 * @return @c YES if user opted out of the sale of their personal information.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#california-consumer-privacy-act-(%E2%80%9Cccpa%E2%80%9D)">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ California Consumer Privacy Act ("CCPA")</a>
 */
+ (BOOL)isDoNotSell;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
