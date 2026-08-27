//
//  HSSDeviceHelper.h
//  HSADXSDK
//
//  Created by admin on 2024/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSDeviceHelper : NSObject

///系统编译时间
+ (uint64_t)getSystemBuildTimeInMilliseconds;

/// 累计时间
+ (uint64_t)getUptimeInMilliseconds;

/// 获取设备开机时间戳
+ (uint64_t)getDeviceBootTimestampInMilliseconds;

/// 匹配机型
+ (NSString *)matchPlatform:(NSString *)platform;

/// 设备更新时间
+ (NSString *)mntid;

/// 设备文件创建时间
+ (NSString *)fileInitTime;

/// 设备启动时间
+ (NSString *)startTime;

@end

NS_ASSUME_NONNULL_END
