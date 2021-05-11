//
//  ALVariableService.h
//  AppLovinSDK
//
//  Created by Thomas So on 10/7/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@class ALVariableService;

/**
 * This service allows for retrieval of variables pre-defined on AppLovin's dashboard.
 */
@interface ALVariableService : NSObject

/**
 * Returns the variable value associated with the given key, or false if
 * no mapping of the desired type exists for the given key.
 *
 * @param key The variable name to retrieve the value for.
 *
 * @return The variable value to be used for the given key, or nil if no value was found.
 */
- (BOOL)boolForKey:(NSString *)key;

/**
 * Returns the variable value associated with the given key, or the specified default value if
 * no mapping of the desired type exists for the given key.
 *
 * @param key          The variable name to retrieve the value for.
 * @param defaultValue The value to be returned if the variable name does not exist.
 *
 * @return The variable value to be used for the given key, or the default value if no value was found.
 */
- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;

/**
 * Returns the variable value associated with the given key, or nil if
 * no mapping of the desired type exists for the given key.
 *
 * @param key The variable name to retrieve the value for.
 *
 * @return The variable value to be used for the given key, or nil if no value was found.
 */
- (nullable NSString *)stringForKey:(NSString *)key;

/**
 * Returns the variable value associated with the given key, or the specified default value if
 * no mapping of the desired type exists for the given key.
 *
 * @param key          The variable name to retrieve the value for.
 * @param defaultValue The value to be returned if the variable name does not exist.
 *
 * @return The variable value to be used for the given key, or the default value if no value was found.
 */
- (nullable NSString *)stringForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

__attribute__ ((deprecated))
@protocol ALVariableServiceDelegate<NSObject>
- (void)variableService:(ALVariableService *)variableService didUpdateVariables:(NSDictionary<NSString *, id> *)variables __deprecated_msg("This API has been deprecated. Please use our SDK's initialization callback to retrieve variables instead.");
@end

@interface ALVariableService(ALDeprecated)
@property (nonatomic, weak, nullable) id<ALVariableServiceDelegate> delegate __deprecated_msg("This API has been deprecated. Please use our SDK's initialization callback to retrieve variables instead.");
- (void)loadVariables __deprecated_msg("This API has been deprecated. Please use our SDK's initialization callback to retrieve variables instead.");
@end

NS_ASSUME_NONNULL_END
