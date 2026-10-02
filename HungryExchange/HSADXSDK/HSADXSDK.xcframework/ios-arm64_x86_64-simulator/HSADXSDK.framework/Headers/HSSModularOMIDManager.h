//
//  HSSModularOMIDManager.h
//  HSADXSDK
//
//  Created by 张松
//
//  OMID 生命周期独立模块。
//
//  设计原则：
//    - 调用方只发"媒体语义事件"（视图就绪 / 媒体开始 / 进度 / 静音变化 / 点击 / 跳过 / 关闭 / App 生命周期）
//    - OMID 协议顺序 / session 生命周期 / obstruction 注册全部由本模块内部保证
//    - 调用方不需要知道 fireAdLoaded / fireImpression / startWithDuration 的原子调用顺序
//
//  与老架构的时序对齐：
//    老架构把 OMID 触发分在两个时机（忠实保留）：
//      ① HSSVideoPlayerVC.updateViewsForVideoPlayer 时机（视频 addSubview 到 VC）
//         → 触发 fireImpression（广告视图已出现）
//      ② player readyToPlay 时机（sendOMEvent:@"start"）
//         → 触发 startWithDuration（媒体实际开始播放）
//
//    本模块对应提供两个调用入口：
//      ① prepareAndReportImpressionWithAdView:obstructions:
//      ② notifyMediaStartedWithDuration:volume:
//
//    至于 create session / startSession / fireAdLoaded / 注册 obstructions 的顺序，
//    全部封装在 ① 内部一次性完成（老架构 setItemModel 时这些都做完了，
//    但为了减少调用方的时序心智负担，合并进 ①，反正紧接着就 fireImpression）
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <HSADXSDK/HSSAdFormat.h>

@class HSSCreativeItemModel;
@protocol HSSAdComponentProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface HSSModularOMIDManager : NSObject

- (instancetype)initWithAdFormat:(HSSAdFormatType)adFormat
                       itemModel:(HSSCreativeItemModel *)itemModel;

#pragma mark - 阶段 1：视图就绪 → session 建立 + fireImpression

/// 广告视图已出现在屏幕（对齐老 HSSVideoPlayerVC.updateViewsForVideoPlayer 时机）。
/// 本方法内部按 OMID 规范原子顺序触发：
///   create session → startSession → fireAdLoaded[WithVastProperties] → 注册 obstructions → fireImpression
/// 幂等：同一次广告展示只生效一次
/// @param extraViews 额外 UIView 形式的 obstruction（如 HSSVideoMedia.progressBar），purpose 默认 MediaControls
- (void)prepareAndReportImpressionWithAdView:(UIView *)adView
                                 obstructions:(NSArray<id<HSSAdComponentProtocol>> *)obstructions
                                   extraViews:(nullable NSArray<UIView *> *)extraViews
                                  skipOffset:(NSTimeInterval)skipOffset;

/// 便捷入口：不带额外 UIView obstruction（向后兼容）
- (void)prepareAndReportImpressionWithAdView:(UIView *)adView
                                 obstructions:(NSArray<id<HSSAdComponentProtocol>> *)obstructions;

/// Banner / H5 类创意专用入口：把 webView 作为 OMID session 的 webViewContext 传入。
/// OMID SDK 据此监听 omid.js 在 H5 内部的事件（impression/viewable 等）。
/// 与基础 prepareAndReportImpressionWithAdView: 共用同一原子顺序，仅在 SessionInteractor init 时多传 webViewContext。
- (void)prepareAndReportImpressionWithAdView:(UIView *)adView
                                 obstructions:(NSArray<id<HSSAdComponentProtocol>> *)obstructions
                                       webView:(nullable WKWebView *)webView;

/// Banner / H5 专用：同时传入 webViewContext 与媒体层额外 obstruction（如 H5 加载进度条）
- (void)prepareAndReportImpressionWithAdView:(UIView *)adView
                                 obstructions:(NSArray<id<HSSAdComponentProtocol>> *)obstructions
                                   extraViews:(nullable NSArray<UIView *> *)extraViews
                                      webView:(nullable WKWebView *)webView;

/// 注册额外的 friendly obstruction 视图（非 Component 视图，如媒体层自带的 progressBar）
///   对齐老 HSSInterstitialVC 在 startAdOMID 里对 progressView / desView 等固定视图的显式注册
///   必须在 prepareAndReportImpressionWithAdView:obstructions: 之后调用
- (void)addFriendlyObstructionView:(UIView *)view
                            purpose:(NSInteger)purpose
                             reason:(nullable NSString *)reason;

#pragma mark - 阶段 2：媒体开始播放 → startWithDuration

/// 媒体实际开始播放（对齐老 HSSVideoPlayerVC.sendOMEvent:@"start" 时机）。
/// 仅在 session 已就绪且尚未触发过 start 时生效（幂等）
/// @param duration 媒体时长
/// @param volume   初始音量（0 = mute, 1.0 = full）
- (void)notifyMediaStartedWithDuration:(NSTimeInterval)duration volume:(CGFloat)volume;

#pragma mark - 阶段 3：销毁

/// 广告结束 / 关闭时调用，停止 OMID session
- (void)deactivate;

#pragma mark - 媒体事件

/// 媒体进度达到关键点（1=25% / 2=50% / 3=75%）
- (void)notifyMediaQuartile:(NSInteger)percentCode;

/// 媒体播放完成
- (void)notifyMediaCompleted;

#pragma mark - 用户交互事件

/// 音量变化（忠实对齐老架构 sendOMEvent:@"mute"/"unmute" 里传的 volume 值）
///   mute   → 调用方传 0
///   unmute → 调用方传实际 player.volume（非硬编码 1.0）
- (void)notifyVolumeChange:(CGFloat)volume;

/// 广告被点击（任何区域 / CTA 都走这里）
- (void)notifyClicked;

/// 跳过按钮被点击
- (void)notifySkipped;

#pragma mark - App 生命周期事件

/// App 进入后台
- (void)notifyAppEnteredBackground;

/// App 回到前台
- (void)notifyAppEnteredForeground;

@end

NS_ASSUME_NONNULL_END
