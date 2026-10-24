//
//  HSSViewRegister.h
//  HSADXSDK
//
//  Created by admin on 2024/12/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSViewRegister : NSObject

/**
 @param viewCls 需要注册的 view 类
 @param key 对应 view key
 */
+(void)registerViewClass:(Class)viewCls forKey:(NSString *)key;

/**
 @return 获取注册对应关系
 */
+ (NSDictionary *)registerViews;
@end

NS_ASSUME_NONNULL_END
