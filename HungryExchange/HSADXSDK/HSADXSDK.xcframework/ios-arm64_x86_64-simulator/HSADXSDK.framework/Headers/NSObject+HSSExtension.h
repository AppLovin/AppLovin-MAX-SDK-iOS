//
//  NSObject+HSSExtension.h
//  HSADXSDK
//
//  Created by biyingquan on 2024/12/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (HSSExtension)

- (NSInteger)hssadx_safeIntegerValue:(NSInteger)defaultVal;

- (double)hssadx_safeDoubleValue:(double)defaultVal;

- (NSInteger)hssadx_safeBoolValue:(BOOL)defaultVal;

- (NSString *)hssadx_safeStringValue:(NSString *)defaultVal;

- (NSArray *)hssadx_safeArrayValue:(nullable NSArray *)defaultVal;

@end

NS_ASSUME_NONNULL_END
