//
//  HSSSegmentVCContext.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdFormat.h>

@class HSSCreativeItemModel;
@class HSSModularAdReportingAdapter;
@class HSSModularOMIDManager;
@class HSSMaterialProvider;
@class HSSModularPlayableJSGateway;
@class HSSRewardCoordinator;
@class HSSFlowCoordinator;
@class HSSRenderContext;

NS_ASSUME_NONNULL_BEGIN

/// 段 VC 可见的「服务门面」。
///
/// 定位：
///   给 HSSSegmentVC（段即 UIViewController）提供「使用基础设施的统一入口」，
///   段通过 context 访问埋点 / OMID / 素材 / Playable JS 桥 / 激励决策器 / 段流转路由器 等服务。
///
/// 和 HSSRenderContext 的分工：
///   - HSSRenderContext     = 组件可见的「数据快照」（itemModel / currentSegment / currentMaterial / ...）
///   - HSSSegmentVCContext  = 段 VC 可见的「服务门面」（tracker / omidManager / flow / ...）
///
/// 段 VC 内部挂组件时，基类把 self.context.renderContext 传给组件的 configureWithControlInfo:context:，
/// 组件看到的 context 类型不变（仍是 HSSRenderContext），组件接口零改动。
///
/// 实现方（通常是 HSSModularAdVC）是这些服务的所有者，用 strong 持有；段 VC 对 context 本身持 weak 引用。
/// 协议声明只约束接口类型，不约束存储语义（ownership 由实现方自决定）。
@protocol HSSSegmentVCContext <NSObject>

#pragma mark - 数据

/// 广告素材数据
@property (nonatomic, readonly, nullable) HSSCreativeItemModel *itemModel;

/// 广告类型（插屏 / 激励）
@property (nonatomic, assign, readonly) HSSAdFormatType adFormat;

/// 组件可见的数据上下文（传给组件的 configureWithControlInfo:context:）
/// 切段时由 Parent VC 更新 currentSegment / currentMaterial / currentMedia 等字段
@property (nonatomic, readonly, nullable) HSSRenderContext *renderContext;

#pragma mark - 服务

/// 埋点 Adapter（2.0 路径直接调，无 Service handler 中转）
@property (nonatomic, readonly, nullable) HSSModularAdReportingAdapter *tracker;

/// OMID 管理器（段内 impression / quartile / session reset 都通过它）
@property (nonatomic, readonly, nullable) HSSModularOMIDManager *omidManager;

/// 素材查找（段 VC 构造 Media 时用）
@property (nonatomic, readonly, nullable) HSSMaterialProvider *materialProvider;

/// Playable JS 桥（HSSPlayableSegmentVC 持有 Timer 时注册 timerHolder）
@property (nonatomic, readonly, nullable) HSSModularPlayableJSGateway *playableJSGateway;

/// 激励决策器（视频段 / 试玩段 close.count_down 结束时上报）
@property (nonatomic, readonly, nullable) HSSRewardCoordinator *rewardCoordinator;

/// 段流转路由器（段 VC 完成自身任务后调 segmentRequestsNext: 等）
@property (nonatomic, readonly, nullable) HSSFlowCoordinator *flow;

#pragma mark - Host 能力请求（段 VC → Parent VC 的单向请求，弱耦合）

@optional

/// 视频段 VC 请求 Host 触发 SKOverlay check（传段索引用于 Host 内部去重）
/// Host 实现方（HSSModularAdVC）决定是否触发、何时触发以及去重策略
/// 段 VC 不感知 SKOverlay 的具体实现
- (void)checkSKOverlayForSegmentAtIndex:(NSInteger)index;

/// 视频段请求 Host 调度 WebView Overlay（对齐 1.0 HSSInterstitialVC.checkoutWebviewOverlay:）
/// Host 实现：按 ext.webview_overlay 配置 setup + 弹出动画 + 自动 click
/// @param playerDuration 当前 Player 总时长（秒），Host 用于 delay > duration 时直接销毁
- (void)checkWebviewOverlayWithPlayerDuration:(NSTimeInterval)playerDuration;

/// 视频段请求 Host 销毁 overlay（对齐 1.0 HSSInterstitialVC.destroyWebOverlayView）
/// "段切换后是否前置" 由 Host 自动维护（不变式：overlay 存在则切段后必前置），段无需主动请求
- (void)destroyWebviewOverlay;

@end

NS_ASSUME_NONNULL_END
