//
//  NSDictionary+HSSExtension.h
//  HSADXSDK
//
//  Created by admin on 2024/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (HSSExtension)

-(NSString *)hssadx_dictionaryToJsonString;

/**
 * 安全获取 NSInteger 类型值
 * @param key 键名
 * @param defaultValue 默认值
 * @return 键对应的值或默认值
 */
- (NSInteger)hssSafeIntegerForKey:(NSString *)key default:(NSInteger)defaultValue;

/**
 * 安全获取 double 类型值
 * @param key 键名
 * @param defaultValue 默认值
 * @return 键对应的值或默认值
 */
- (double)hssSafeDoubleForKey:(NSString *)key default:(double)defaultValue;

/**
 * 安全获取 BOOL 类型值
 * @param key 键名
 * @param defaultValue 默认值
 * @return 键对应的值或默认值
 */
- (BOOL)hssSafeBoolForKey:(NSString *)key default:(BOOL)defaultValue;

/**
 * 安全获取 NSString 类型值
 * @param key 键名
 * @param defaultValue 默认值
 * @return 键对应的值或默认值
 */
- (NSString *)hssSafeStringForKey:(NSString *)key default:(NSString *)defaultValue;

/**
 * 安全获取 NSDictionary 类型值（含 NSMutableDictionary）
 * @param key 键名
 * @param defaultValue 默认值（类型不符或缺失时返回）
 * @return 键对应的字典或默认值
 */
- (NSDictionary *)hssSafeDictionaryForKey:(NSString *)key default:(nullable NSDictionary *)defaultValue;

/**
 * 安全获取 NSArray 类型值（含 NSMutableArray）
 * @param key 键名
 * @param defaultValue 默认值（类型不符或缺失时返回）
 * @return 键对应的数组或默认值
 */
- (NSArray *)hssSafeArrayForKey:(NSString *)key default:(nullable NSArray *)defaultValue;

@end

NS_ASSUME_NONNULL_END
