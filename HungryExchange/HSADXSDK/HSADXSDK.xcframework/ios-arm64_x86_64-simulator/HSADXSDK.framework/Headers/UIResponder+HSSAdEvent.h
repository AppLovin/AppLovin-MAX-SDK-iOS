//
//  UIResponder+HSSAdEvent.h
//  HSADXSDK
//
//  Created by 张松
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 广告事件响应链 Category
/// 组件/媒体通过调用这些方法发出事件，事件沿 UIResponder 链向上传递
/// VC 重写需要处理的方法作为事件终点
@interface UIResponder (HSSAdEvent)

#pragma mark - 点击类事件

/// CTA 按钮点击（明确 CTA 按钮触发）
/// @param params 点击参数（可包含 click_url、click_source 等）
- (void)hss_ctaTapped:(nullable NSDictionary *)params;

/// 广告区域点击（视频、endcard、banner 等区域点击统一走这里）
/// @param params 点击参数（至少包含 click_source: "media"/"endcard"/"banner"/...）
- (void)hss_adClicked:(nullable NSDictionary *)params;

/// 关闭按钮点击
- (void)hss_closeTapped;

/// 跳过按钮点击
- (void)hss_skipTapped;

#pragma mark - 段内 reveal 事件（独立于媒体事件，由基类段时钟派发）

/// 段时钟启动 —— 触发 reveal AtStart 组件 + 派发组件 mediaDidStart 业务回调
/// 与 hss_mediaStartedWithView 严格区分：
///   - hss_mediaStartedWithView：媒体真正开始（HSSPlayer ready 时派发，触发 OMID/VAST start）
///   - hss_segmentMediaReveal：段进入即派发（基类 viewDidAppear 启动段时钟时派发，不上报 OMID/VAST）
///
/// 解决"播放器卡死时关闭按钮被困" —— 段内组件可见性不依赖播放器真实起播
- (void)hss_segmentMediaReveal;

/// 段时钟 tick —— 基类段时钟每秒派发，按段内 elapsed 评估 AtSeconds reveal
/// @param elapsed 段进入后累计秒数（与视频真实播放进度无关）
- (void)hss_segmentMediaTickWithElapsed:(NSTimeInterval)elapsed;

#pragma mark - 媒体类事件

/// 媒体真正开始播放（仅 HSSVideoMedia 在 HSSPlayer ready 时派发）
/// 触发 OMID start / VAST start 等"跟媒体起播对齐"的上报
/// @param mediaView 媒体视图（用于 OMID 激活）
/// @param duration 总时长
/// @param volume 音量
- (void)hss_mediaStartedWithView:(UIView *)mediaView duration:(NSTimeInterval)duration volume:(CGFloat)volume;

/// 媒体播放完成
- (void)hss_mediaFinished;

/// 媒体播放进度（关键点）
/// @param percentCode 进度标识（1=25%, 2=50%, 3=75%）
- (void)hss_mediaProgress:(NSInteger)percentCode;

/// 媒体播放连续进度（供 FlowCoordinator 按 next_link 决策自动切段）
/// @param currentTime 当前播放秒数
/// @param duration    总时长（秒）
- (void)hss_mediaContinuousProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;

/// 媒体播放失败
- (void)hss_mediaFailed:(NSError *)error;

/// 媒体暂停（播放器自身进入暂停态，区别于 App 级前后台切换）
/// 对齐老 HSSVideoPlayerVC.hssplayerBackgroundPlay: 的语义
- (void)hss_mediaPaused;

/// 媒体恢复（延迟 1s 发送以对齐老 HSSPlayer 恢复时序）
/// 对齐老 HSSVideoPlayerVC.hssplayerForegroundPlay: 的语义
- (void)hss_mediaResumed;

#pragma mark - App Store 弹窗事件

/// AppStore 弹窗即将展示（对齐老 HSSVideoPlayerVC.appStorePresented: 里 videoPopupView hide）
/// 组件（如 VideoPopup 类浮层）可监听此事件自行隐藏，避免弹窗叠压
- (void)hss_appStoreWillPresent;

/// AppStore 弹窗已关闭（对齐老 productViewControllerDidFinish:）
/// 组件可监听此事件恢复展示
- (void)hss_appStoreDidDismiss;

#pragma mark - 状态类事件

/// 静音状态变化
- (void)hss_muteChanged:(BOOL)muted;

/// UI 倒计时结束（纯 UI 事实，不带业务语义）
/// 语义：某个倒计时组件的 Timer 到 0 了
/// 注意：是否触发激励由 HSSRewardCoordinator 按规则决策（当前规则下倒计时结束**不**触发激励，
/// 激励由 close.count_down 倒计时结束驱动（视频段 / 试玩段）。组件只负责发送 UI 事实，不应知道激励业务语义。
- (void)hss_countdownFinished;

#pragma mark - 埋点辅助事件

/// 视频实际尺寸已获取（OMID/埋点用）
/// 由 HSSVideoMedia 在 HSSPlayerDelegate 回调 hssplayerGotVideoSize: 中派发
- (void)hss_videoSizeReady:(CGSize)size;

/// 视频首帧真正上屏（real_play 事件源）
/// 由 HSSVideoMedia 在 HSSPlayerDelegate 回调 hssplayerReadyForDisplay: 中派发
- (void)hss_videoFirstFrameDisplayed;

/// 视频真正推进过阈值时间点（time_reached 事件源，区分有音无画 vs 起播卡死）
/// 由 HSSVideoMedia 在 HSSPlayerDelegate 回调 hssplayerDidReachPlaybackTime: 中派发
- (void)hss_videoPlaybackReached;

/// 组件首次变可见（由 RenderEngine 在 componentDidBecomeVisible 之后自动派发）
/// @param buttonType 组件类型标识（通常取 controlInfo.key 或 componentKeys 里的首个）
- (void)hss_buttonDidAppear:(NSString *)buttonType;

#pragma mark - 按钮真显示时机统一上抛入口（组件层使用）

/// 在按钮真正可见时调用本方法（如倒计时结束 / 内部按钮 hidden=NO 翻转 / 组件首次可见且按钮无倒计时）。
/// 自动按 HSSAdComponentProtocol.buttonAppearanceType 协议查询类型，类型有效才上抛 hss_buttonDidAppear:。
/// 多重守卫：
///   1) self 必须实现 buttonAppearanceType（不实现的组件直接 noop）
///   2) self.context 必须非 nil（1.0 路径下 context = nil → 自动 noop，避免向 1.0 响应链发 2.0 事件）
///   3) buttonAppearanceType 返回值必须非空（非 close/skip 类组件返回 nil → noop）
/// 子类不要直接调 hss_buttonDidAppear:，统一走本方法以避免散点逻辑。
- (void)hss_postButtonAppearIfNeeded;

@end

NS_ASSUME_NONNULL_END
