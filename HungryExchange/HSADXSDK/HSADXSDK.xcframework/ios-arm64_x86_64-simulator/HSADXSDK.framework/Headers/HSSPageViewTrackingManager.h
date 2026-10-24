//
//  HSSPageViewTrackingManager.h
//  HSADXSDK
//
//  Created by 张松 on 2025/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 页面展示追踪管理器（单例）
 * 负责管理广告素材段展示相关的埋点
 */

typedef  NSDictionary * _Nullable(^configAdCommonParams)(void);
@interface HSSPageViewTrackingManager : NSObject

#pragma mark - 单例

/// 获取单例实例
+ (instancetype)sharedInstance;

#pragma mark - 只读属性

/// 当前页面索引（从 1 开始）
@property (nonatomic, assign, readonly) NSInteger currentPageIndex;

@property (nonatomic, copy) configAdCommonParams configAdCommonParams;
#pragma mark - 状态管理方法
/// 递增页面索引（素材切换时调用）
/// @note 元素清空由上报方法自动处理，此方法仅递增索引
- (void)incrementPageIndex;

/// 重置管理器状态（包括清空公共参数）
- (void)reset;

#pragma mark - 埋点上报方法

/// 上报 adx_sdk_page_view 埋点（自动使用已保存的公共参数）
/// @param elements 元素列表（主素材 + 辅助素材）
/// @note 与 reportPageViewWithElements:extraParams: 等价（extraParams 传 nil）
- (void)reportPageViewWithElements:(NSArray<NSDictionary *> *)elements;

/// 上报 adx_sdk_page_view 埋点（2.0 路径专用：允许追加额外参数，如 page_type）
/// @param elements 元素列表（主素材 + 辅助素材）
/// @param extraParams 额外参数字典（如 @{ @"page_type": @"video" }），合并进上报 params；可为 nil
/// @note 1.0 调用方继续用单参数版本，行为零变化
- (void)reportPageViewWithElements:(NSArray<NSDictionary *> *)elements
                       extraParams:(nullable NSDictionary *)extraParams;

@end

NS_ASSUME_NONNULL_END
