//
//  NSDate+HSSExtension.h
//  HSADXSDK
//
//  Created by admin on 2024/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (HSSExtension)

/**
 @param time 时间戳
 @return 返回间隔小时
 */
+ (NSInteger)hssadx_intervalHour:(NSTimeInterval)time;

/**
 @param time 时间戳
 @return 返回间隔分钟
 */
+ (NSInteger)hssadx_intervalMinute:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
