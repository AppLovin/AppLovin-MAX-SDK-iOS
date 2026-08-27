//
//  HSSCloseTrackingManager.h
//  HSADXSDK
//
//  Created by 张松 on 2025/11/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 广告关闭埋点管理器
 * 
 * @discussion 用于管理 adx_sdk_ad_close 埋点的复杂时序追踪，包括：
 * - 跟踪每一段内容的实际观看时长（section_X_duration）
 * - 跟踪跳过按钮出现的累计时间（skip_X_duration）
 * - 跟踪关闭按钮出现的累计时间（close_icon_duration）
 * - 跟踪用户当前所在第几段（page_index）
 * 
 * @warning 所有时间单位为毫秒（ms），保留0位小数
 */
@interface HSSCloseTrackingManager : NSObject

#pragma mark - 初始化

/**
 * 初始化方法
 * @param logPrefix 日志前缀，用于区分不同广告类型（如 "InterstitialAd", "RewardedAd"）
 */
- (instancetype)initWithLogPrefix:(NSString *)logPrefix;

#pragma mark - 记录时间节点

/**
 * 记录广告展示开始时间
 * @discussion 在广告成功展示时调用（adDidShow），作为所有累计时间的基准点
 */
- (void)recordAdShowStart;

/**
 * 记录新的一段内容开始
 * @discussion 每次新的内容段开始时调用，会自动递增内部的 sectionIndex
 *
 */
- (void)recordSectionStart;

/**
 * 记录当前段内容结束
 * @discussion 当前内容段结束时调用，用于计算实际观看时长
 * 
 * 调用时机：
 * - 视频播放完成时
 * - 试玩结束时
 * - 切换到下一段内容时
 */
- (void)recordSectionEnd;

/**
 * 记录跳过按钮实际出现
 * 
 * @discussion 当跳过按钮倒计时结束、真正显示在屏幕上时调用
 * 内部会自动分配 skipButtonIndex（按出现顺序：1, 2, 3...）
 *
 */
- (void)recordSkipButtonAppear;

/**
 * 记录关闭按钮实际出现
 * 
 * @discussion 当关闭按钮倒计时结束、真正显示在屏幕上时调用
 *
 */
- (void)recordCloseButtonAppear;

#pragma mark - 埋点上报

/**
 * 发送 adx_sdk_ad_close 埋点（统一上报方法）
 * @param adShowTime 广告展示开始时间（CACurrentMediaTime），用于计算 duration
 * @param adRelatedParams 广告相关参数（从 adsRelatedStat 获取）
 * 
 * @discussion 内部会自动：
 * 1. 调用 buildCloseTrackingParams 生成时序参数（page_index, section_X_duration, skip_X_duration, close_icon_duration）
 * 2. 计算 duration（广告总观看时长 = 当前时间 - adShowTime）
 * 3. 合并所有参数并发送 HSSdkTracker
 * 
 * @warning 在广告关闭时（dismissCompletion）调用
 */
- (void)sendCloseTracking:(NSTimeInterval)adShowTime 
          adRelatedParams:(NSDictionary *)adRelatedParams;


/**
 * 发送 app生命周期相关 埋点（统一上报方法）
 * @param eventName 埋点名
 * @param adRelatedParams 广告相关参数（从 adsRelatedStat 获取）
 *
 * @discussion 内部会自动：
 * 1. 调用 buildCloseTrackingParams 生成时序参数（page_index, section_X_duration, skip_X_duration, close_icon_duration）
 * 2. 计算 duration（广告总观看时长 = 当前时间 - adShowTime）
 * 3. 合并所有参数并发送 HSSdkTracker
 *
 * @warning appWillResignActive和appDidEnterBackground时上报
 */
- (void)sendAppLifeCycleTracking:(NSString *)eventName
                 adRelatedParams:(NSDictionary *)adRelatedParams;

/**
 * 保存 app 即将终止（kill）的埋点参数，供下次启动时补发 AdxSdkAppWillTerminateEvent
 *
 * @param adRelatedParams 广告相关参数（从 adsRelatedStat 获取）
 *
 * @discussion
 *   老架构下，VC 自己维护一份 section_X_duration / skip_X_duration / close_icon_duration 等字段，
 *   在 UIApplicationWillTerminateNotification 时上抛 block → Ad 层存盘。
 *   新架构（模板 2.0）统一由本方法处理：数据源 = snapshotCurrentState，
 *   使 Ad 层不再需要维护冗余统计字段。
 *
 *   字段对齐：
 *     - page_index / duration / section_X_duration / skip_X_duration / close_icon_duration
 *       → 由 snapshotCurrentState 提供
 *     - break_index（老字段，值 = page_index）→ 本方法自动填充
 *
 *   调用时机：UIApplicationWillTerminateNotification（app kill 前）
 *
 *   存盘路径：HSSTrackUrlReportManager.saveAppWillTerminateParams:forEvent:@"AdxSdkAppWillTerminateEvent"
 */
- (void)sendAppWillTerminateTracking:(NSDictionary *)adRelatedParams;

#pragma mark - 重置

/**
 * 重置所有状态
 * @discussion 在新广告展示前调用，清空所有记录的时间节点
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END

