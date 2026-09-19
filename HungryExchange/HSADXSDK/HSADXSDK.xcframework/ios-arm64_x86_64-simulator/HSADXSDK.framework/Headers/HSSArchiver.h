//
//  HSSArchiver.h
//  HSADXSDK
//
//  Created by admin on 2024/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 存储类
@interface HSSArchiver : NSObject

/// 归档存储
/// - Parameters:
///  - obj: 实例对象
///  - path: 存储位置
+(void)archiverObject:(NSObject<NSSecureCoding> *)obj toFile:(NSString *)path;

/// 解档存储
/// - Parameters:
///  - classSet: 自定义类里面所有需要解档的类
///  - path: 存储位置
+(id)unarchivedObjectOfClasses:(NSSet *)classSet fromFile:(NSString *)path;


/// 解档
/// - Parameters:
///   - classSet: 自定义类里面所有需要解档的类
///   - path: 读取路径
///   - targetCls: 最终目标类
+(id)unarchivedObjectOfClasses:(NSSet *)classSet fromFile:(NSString *)path toTarget:(Class __nullable)targetCls;


/// 移除文件
/// - Parameter filepath: 文件路径
+(void)removeArchive:(NSString *)filepath;
@end

NS_ASSUME_NONNULL_END
