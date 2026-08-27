//
//  HSSSegmentComponentRenderer.h
//  HSADXSDK
//
//  Created by 张松
//
//  段内组件渲染器：负责把 HSSAdComponentProtocol 组件挂到段容器上，并按 controlInfo.show 策略
//  调度组件可见性 + 入场动画。
//
//  和 1.5 HSSRenderEngine 的本质区别：
//    - 归属：段级（HSSSegmentVC 创建 + 持有 + 随段销毁），不是广告级外挂组件
//    - 生命周期：等于一段（段 VC 换一次就换一个 renderer）
//    - 职责：**只做组件调度 + 动画**，不做段类型分支（挂什么组件由段 VC 决定）
//    - 不感知 Flow / Media / 段切换（它是一个纯粹的"段内容器管理器"）
//
//  调用流（由 HSSSegmentVC 基类触发）：
//    段 VC.viewDidLoad
//      └─ renderer.mountComponentWithKey:... （N 次）       → 组件初始 hidden=YES，加入 pending 队列
//
//    段 VC.viewDidAppear → 基类段时钟启动 → hss_segmentMediaReveal
//      └─ renderer.notifyMediaStarted                     → strategy=1 组件 reveal + 所有组件 mediaDidStart
//
//    段 VC.hss_segmentMediaTickWithElapsed:               （基类段时钟每秒派发）
//      └─ renderer.revealAtSecondsComponentsForElapsed:   → strategy=2 组件到点 reveal
//
//    段 VC.hss_mediaContinuousProgress:duration:           （视频 player 真实进度派发）
//      └─ renderer.notifyMediaProgressToTime:duration:    → strategy=3/4 组件到点 reveal
//
//    段 VC.performSegmentTearDown（Parent VC 切段/dismiss completion 显式调）
//      └─ renderer.tearDown                                → 遍历组件 destroy + removeFromSuperview
//

#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSAdFormat.h>

@class HSSControlInfo;
@class HSSRenderContext;
@protocol HSSAdComponentProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface HSSSegmentComponentRenderer : NSObject

/// 当前活跃的组件（供段 VC 查询，OMID friendly obstruction 列表来自这里）
@property (nonatomic, strong, readonly) NSMutableArray<id<HSSAdComponentProtocol>> *activeComponents;

#pragma mark - 初始化

/// @param container 组件挂载的容器 view（段 VC 的 componentContainer）
/// @param adFormat  广告类型（插屏 / 激励，影响 instl_video_tmpl_0 的 show 策略例外规则）
- (instancetype)initWithComponentContainer:(UIView *)container
                                    adFormat:(HSSAdFormatType)adFormat;

#pragma mark - 挂载

/// 按 HSSControlInfo 挂组件（key 从 info.key 取）
- (void)mountComponentWithControlInfo:(HSSControlInfo *)info
                                context:(nullable HSSRenderContext *)context;

/// 按指定 key 挂组件（供 CTA / EndCard 等无 controlInfo.key 的场景使用）
- (void)mountComponentWithKey:(NSString *)key
                   controlInfo:(nullable HSSControlInfo *)info
                       context:(nullable HSSRenderContext *)context;

#pragma mark - 媒体事件派发（由段 VC 转发）

/// 段时钟启动：pending 中 strategy=Unknown/AtStart 的组件翻转可见；所有活跃组件派发 mediaDidStart
/// 由 HSSSegmentVC 响应 hss_segmentMediaReveal 时调用
- (void)notifyMediaStarted;

/// 媒体连续进度：pending 中 strategy=AtPercent/BeforeEnd 的组件到点则翻转可见
/// 注：AtSeconds 由 -revealAtSecondsComponentsForElapsed: 处理（段时钟驱动）
- (void)notifyMediaProgressToTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;

/// 段时钟 tick：仅处理 strategy=AtSeconds 的组件（按段进入累计秒数 reveal）
/// 与 notifyMediaProgressToTime: 的区别：
///   - 输入是"段进入 elapsed"（视频段/试玩段/EndCard 段都按段时钟走），不是"视频播放 currentTime"
///   - 不处理 AtPercent/BeforeEnd（这两类必须用真实视频时长，仍由 player.progress 驱动）
/// 由 HSSSegmentVC 响应 hss_segmentMediaTickWithElapsed: 时调用
- (void)revealAtSecondsComponentsForElapsed:(NSTimeInterval)elapsed;

#pragma mark - 销毁

/// 遍历活跃组件 destroy + removeFromSuperview + 清空 pending 队列
/// 由 HSSSegmentVC.performSegmentTearDown 调用
- (void)tearDown;

@end

NS_ASSUME_NONNULL_END
