//
//  HSSMediaProtocol.h
//  HSADXSDK
//
//  Created by 张松
//

#import <UIKit/UIKit.h>

@class HSSRenderContext;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HSSMediaType) {
    HSSMediaTypeNone = 0,
    HSSMediaTypeVideo,
    HSSMediaTypeWebView,
    HSSMediaTypeImage,
};

/// 媒体层统一协议（视频播放器 / WebView / 大图 / Banner）
///
/// 装配范式（Material 即接口）：每个 Media 子类暴露自己的
///   - (instancetype)initWithMaterial:(HSSXxxMaterial *)material context:(HSSRenderContext *)context;
/// 一步装配；本协议不再约束 init 签名，只约束运行时行为。
@protocol HSSMediaProtocol <NSObject>

@required

/// 媒体类型
- (HSSMediaType)mediaType;

/// 媒体视图（用于添加到容器）
- (UIView *)mediaView;

/// 开始播放/展示
- (void)play;

/// 暂停
- (void)pause;

/// 恢复
- (void)resume;

/// 销毁
- (void)destroy;

@optional

/// UIKit-aware 时序点：mediaView 已 addSubview 到容器、frame 已就绪。
///
/// Media 子类可在此做"依赖 frame 的初始化"——典型如 HSSVideoMedia 在此创建 AVPlayer 并锁定 playerLayer.frame。
/// 不依赖 frame 的 Media（HSSWebViewMedia / HSSEndCardMedia）可不实现。
///
/// 由基类 HSSSegmentVC.mountMedia: 在 addSubview 完成后调用，调用方无需手动触发。
- (void)didAttachToContainer;

/// 设置静音
- (void)setMuted:(BOOL)muted;

/// 当前是否静音
- (BOOL)isMuted;

/// 当前实际音量（用于 OMID volumeChangeTo 上报真实 volume 值，而非硬编码 1.0）
/// 非视频类 Media（webview / image / endcard）可不实现，默认按 1.0 处理
- (CGFloat)volume;

/// Native → JS 的音量同步（Playable 场景）：
///   视频 mute 切换时，若 currentMedia 是 Playable webview，需要 emit audioVolumeChange 给 JS
///   非 webview Media 不实现此方法（响应链层会判空）
/// @param volume 0=mute, 1.0=full（实现方内部决定如何映射到 JS 规范的 0/100）
- (void)notifyVolumeChange:(CGFloat)volume;

/// 当前播放时间（秒）
- (NSTimeInterval)currentPlayTime;

/// 总时长（秒）
- (NSTimeInterval)duration;

/// 视频开始播放埋点信息（对齐老 HSSVideoPlayerVC.buildVideoPlayInfo:）
/// 供 EventHandler 在 handleMediaStarted 时塞给 trackVideoPlay:
///   - video_url：原始视频 URL
///   - video_duration：总时长（秒）
- (nullable NSDictionary *)videoPlayInfo;

/// 视频结束埋点信息（对齐老 HSSVideoPlayerVC.buildVideoEndInfo:endType:player:）
/// 供 EventHandler 在 handleMediaFinished / handleSkipTapped 时塞给 trackVideoEnd:
/// @param endType  @"0"=播完 @"1"=跳过 @"2"=提前关闭
///   - end_type / video_url / video_duration / video_play_duration（保留 1 位小数，且 ≤ duration）
- (nullable NSDictionary *)videoEndInfoWithEndType:(NSString *)endType;

/// Media 层自带需要声明为 OMID friendly obstruction 的视图（如视频底部进度条）
/// 对齐老 HSSInterstitialVC.startAdOMID 对 progressView / bottomBgView 等固定视图的注册
/// 默认按 MediaControls purpose 处理；返回 nil / 空数组表示无额外 obstruction
- (nullable NSArray<UIView *> *)omidObstructionViews;

/// OMID 测量目标 view（语义对齐 1.0：注册视频创意承载层而非外包容器）
/// 对齐老 HSSVideoPlayerVC.activateOpenMeasureWithAdView:player.contentView 范式：
///   - 视频 Media 实现：返回 player.contentView（视频实际承载层）
///   - 非视频 Media（webview / image / endcard）不实现 → 调用方 fallback 到 mediaView
/// 注：mediaView / omidAdView 在 window 坐标系下 frame 完全一致，OMID 数据等价；
///     此 getter 仅用于"语义/约定层面"的 1.0 对齐，便于未来 HSSPlayer 内部演进时双端同步。
- (UIView *)omidAdView;

/// SK AppStore 弹窗已关闭：由 Host VC（HSSModularAdVC）通过 SKStoreProductViewControllerDelegate
/// 收到关闭回调后，沿 Host → SegmentVC → Media 链路下发到本方法。
/// 视频 Media 实现：恢复播放（对齐老 HSSVideoPlayerVC.productViewControllerDidFinish: → [_player play]）。
/// 非视频 Media（webview / image / endcard）可不实现，调用方有 respondsToSelector: 守卫。
- (void)handleAppStoreDidDismiss;

#pragma mark - PageView 埋点（媒体自声明本媒体贡献的 element 列表）

/// 本媒体在 adx_sdk_page_view 上报时贡献的 element 列表。
/// 框架在段主体就绪时通过 currentMedia 收集（respondsToSelector: 守卫）。
/// 已知实现：
///   - HSSVideoMedia    → [{element:video, source:2, w/h/url}, {icon}, {cta_text}]
///   - HSSWebViewMedia  → [{element:playable, source:1, url}]
///   - HSSEndCardMedia  → companion 资源（HTML → img source=3 / Static → img source=2）
- (nullable NSArray<NSDictionary *> *)pageViewElements;

@end

NS_ASSUME_NONNULL_END
