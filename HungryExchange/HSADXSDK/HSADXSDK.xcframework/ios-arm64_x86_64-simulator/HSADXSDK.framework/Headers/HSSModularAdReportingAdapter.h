//
//  HSSModularAdReportingAdapter.h
//  HSADXSDK
//
//  Created by 张松
//
//  2.0 路径埋点 API 适配器（Adapter 层）。
//
//  架构定位：
//    - Adapter 层成员之一，与 HSSModularCreativeAdapter 平级
//        * HSSModularCreativeAdapter        ：数据字段适配（2.0 adInfo.material → 1.0 itemModel 老字段）
//        * HSSModularAdReportingAdapter（本类）：API 风格适配（2.0 简洁 trackXxx → 1.0 繁杂 adsXxxStat:creativeModel:）
//    - 不是埋点中心，只是 HSSAdTrackingCenter 的 Façade；实际上报由 Center 完成
//
//  职责：
//    1) API 风格转换：把 1.0 Center 30+ 个 adsXxxStat:creativeModel: 方法
//       适配为 2.0 路径偏好的 trackXxx 简洁形式
//    2) 上下文记忆：持有 itemModel / trackingCenter / coordinator 弱引用，
//       2.0 调用方（SegmentVC / EventHandler）无需在每次埋点都重复传 itemModel
//    3) 少量复合调用预制（顺序敏感的多步操作集中预制）：
//         - trackMaterialSwitch              ：switchSection → recordSectionEnd → recordSectionStart → incrementPageIndex
//         - trackSegmentPageViewForSegmentVC: ：聚合段内 currentMedia + activeComponents 的 pageViewElements 自描述
//         - trackAppWillTerminate:           ：合并 adRelatedStat 与 caller 上传的 player_muted/volume
//
//  不做（明确边界）：
//    - VAST 切段同步：由 Coordinator/SegmentVC 在 renderContext.currentSegmentVast 切段时统一完成
//    - 数据字段归一化：归 HSSModularCreativeAdapter
//    - 实际网络上报：归 HSSAdTrackingCenter
//

#import <Foundation/Foundation.h>

@class HSSAdTrackingCenter;
@class HSSCreativeItemModel;
@class HSSModularAdCoordinator;
@class HSSJumpTrackingContext;
@class HSSSegmentVC;

NS_ASSUME_NONNULL_BEGIN

@interface HSSModularAdReportingAdapter : NSObject

/// @param trackingCenter  统一埋点中心（由宿主 Ad 创建并注入）
/// @param itemModel       当前广告素材（2.0 数据结构：含 adInfo.material）
/// @param coordinator     弱引用 Coordinator，用于查询 currentSegmentIndex 等运行时状态
- (instancetype)initWithTrackingCenter:(HSSAdTrackingCenter *)trackingCenter
                               itemModel:(HSSCreativeItemModel *)itemModel
                             coordinator:(HSSModularAdCoordinator *)coordinator;

#pragma mark - 视频

- (void)trackVideoPlay:(nullable NSDictionary *)info;
/// 视频帧尺寸已解出（adx_sdk_video_size_ready，presentationSize>0）
- (void)trackVideoSizeReady:(nullable NSDictionary *)info;
/// 首帧真正上屏（adx_sdk_video_real_play，readyForDisplay=YES）：黑屏率分子
- (void)trackVideoRealPlay:(nullable NSDictionary *)info;
/// 播放真正推进过阈值（adx_sdk_video_time_reached）：区分有音无画 vs 起播卡死
- (void)trackVideoTimeReached:(nullable NSDictionary *)info;
- (void)trackVideoEnd:(nullable NSDictionary *)info;
- (void)trackVideoProgress:(NSInteger)percent;
/// 视频起播失败（adx_sdk_video_play_failed）：info 含 video_url / video_duration（便于定位坏素材）
- (void)trackVideoFailed:(nullable NSDictionary *)info error:(nullable NSError *)error;

#pragma mark - 点击

- (void)trackClick:(nullable NSDictionary *)params;
- (void)trackClickResult:(BOOL)result
                 linkUrl:(nullable NSString *)linkUrl
                 context:(nullable HSSJumpTrackingContext *)context
                  isAuto:(BOOL)isAuto;
- (void)trackDeeplink:(BOOL)result url:(nullable NSString *)url;
- (void)trackVastEndCardClick:(nullable NSDictionary *)params;

#pragma mark - 试玩

- (void)trackPlayableEvent:(NSString *)name;
- (void)trackPlayableSkip:(NSInteger)duration endReason:(NSString *)reason;
- (void)trackPlayableProgress:(NSString *)progress;

#pragma mark - 展示时长 / dwell / 屏幕点击 / 素材切换

- (void)trackAdShowTime:(NSInteger)duration;
- (void)trackDwell:(NSInteger)duration;
- (void)trackScreenClick:(CGPoint)point element:(nullable NSString *)element;
- (void)trackMaterialSwitch;

#pragma mark - 按钮展示

/// 组件首次变可见时埋点（对齐 1.0 HSSButtonDidShowNotification → trackButtonAppear）
- (void)trackButtonAppear:(NSString *)type;

#pragma mark - PageView（段主体就绪聚合上报）

/// 段主体就绪时聚合上报 adx_sdk_page_view（对齐 1.0 reportVideoPageViewVideoSize: + 各 EndCard 整卡内自上报的合并语义）
/// 调用方：段 VC 在 viewDidAppear（或视频段叠加 hss_videoSizeReady）触发，自带去重标志保证每段只调一次
/// 聚合范围：当前段 VC 的 currentMedia + activeComponents（按 HSSPageViewElementProvider 自描述）
/// element_dict 严格按服务端契约组装（element 类型 / source 取值）
- (void)trackSegmentPageViewForSegmentVC:(HSSSegmentVC *)vc;

#pragma mark - 生命周期

- (void)trackAppLifeCycle:(NSString *)name;
- (void)trackAppWillTerminate:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
