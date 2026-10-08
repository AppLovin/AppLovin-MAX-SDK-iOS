//
//  HSSFileManager.h
//  HSADXSDK
//
//  Created by admin on 2024/11/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSFileManager : NSObject

/// 获取 Library 文件夹
+(NSString *)pathForLibraryDirectory;

/// Library 文件夹下创建文件
+(NSString *)pathForLibraryDirectoryWithPath:(NSString *)path;

/// 文件路径是否存在
+(BOOL)existsItemAtPath:(NSString *)path;

/// 创建空文件
+(BOOL)createFileAtPath:(NSString *)path;

/// 移除文件
+(BOOL)removeItemAtPath:(NSString *)path;

/// 获取文件大小
+(unsigned long long)fileSizeAtPath:(NSString *)path;

/// sdk path
+(NSString *)sdkPathForLibraryDirectory;

/// SDk 文件存储路径
+(NSString *)sdkPathForLibraryDirectoryWithPath:(NSString *)path;

/// 移除Sdk 下面所有文件
+(void)sdkRemoveAllItems;

/// 检查离线资源是否过期
+ (void)sdkRemoveAllOfflineItems;

/// sdk  Offline path
+ (NSString *)sdkPathForOfflineLibraryDirectory;

/// SDk 离线文件存储路径
+ (NSString *)sdkPathForOfflineLibraryDirectoryWithPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
