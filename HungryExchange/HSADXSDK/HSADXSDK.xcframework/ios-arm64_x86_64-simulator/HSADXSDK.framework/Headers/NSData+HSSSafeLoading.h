//
//  NSData+HSSSafeLoading.h
//  HSADXSDK
//
//  Created by 张松 on 2025/11/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * NSData 安全加载分类
 * 用于防止加载超大文件导致OOM崩溃
 */
@interface NSData (HSSSafeLoading)

/**
 * 安全地从文件加载数据（自动检查文件大小）
 * 如果文件过大，返回nil并上报
 * @param path 文件路径
 * @return NSData对象，如果文件过大返回nil
 */
+ (nullable instancetype)hss_safeDataWithContentsOfFile:(NSString *)path;

@end

NS_ASSUME_NONNULL_END

