//
//  HSSAdContextManager.h
//  HSADXSDK
//
//  Created by 张松 on 2025/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary * _Nullable (^HSSAdInfoProvider)(void);

/**
 * 广告上下文管理器
 * 用于在底层图片/文件加载时，自动关联广告信息到埋点上报
 */
@interface HSSAdContextManager : NSObject

/**
 * 获取单例实例
 */
+ (instancetype)sharedManager;

/// 设置广告参数
- (void)registerAdInfoProvider:(HSSAdInfoProvider)provider;

/// 获取广告参数
- (nullable NSDictionary *)currentAdContext;

@end

NS_ASSUME_NONNULL_END
