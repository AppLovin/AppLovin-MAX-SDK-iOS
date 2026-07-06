//
//  HSSSegmentEventHandler.h
//  HSADXSDK
//
//  Created by 张松
//
//  段事件处理器协议族（基于协议继承精确表达每段事件集）。
//
//    - HSSSegmentEventHandler         （根协议）：所有段共有的"用户操作"+"系统弹窗"+"销毁"事件
//    - HSSVideoSegmentEventHandler    （继承根）：视频段独有的 media* / mute / videoSize 事件
//    - HSSPlayableSegmentEventHandler （继承根）：试玩段独有的 playableProgress / mute 事件
//    - EndCard / EndCardImage 段无独有事件，直接用根协议
//
//  与 HSSSegmentVC 的协作：
//    - 基类 HSSSegmentVC 持有 id<HSSSegmentEventHandler> eventHandler
//    - 基类自动 forward 通用事件（hss_closeTapped / hss_skipTapped / hss_adClicked / ...）
//    - 段子类 cast 为具体协议类型 forward 段专有事件
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 根协议：所有段共有的事件

@protocol HSSSegmentEventHandler <NSObject>

@required
/// 段销毁时调用：清理 EventHandler 自身持有的资源（webview / timer / 注册的通知等）
- (void)tearDown;

@optional

#pragma mark 用户操作
- (void)handleCloseTapped;
- (void)handleSkipTapped;
- (void)handleCtaTapped:(nullable NSDictionary *)params;
- (void)handleAdClicked:(nullable NSDictionary *)params;

#pragma mark 倒计时 / 系统
- (void)handleCountdownFinished;
- (void)handleAppStoreWillPresent;
- (void)handleAppStoreDidDismiss;
- (void)handleButtonDidAppear:(NSString *)type;

@end

#pragma mark - 视频段事件协议

@protocol HSSVideoSegmentEventHandler <HSSSegmentEventHandler>

@optional
- (void)handleMediaStartedWithView:(UIView *)mediaView duration:(NSTimeInterval)duration volume:(CGFloat)volume;
- (void)handleMediaFinished;
- (void)handleMediaProgress:(NSInteger)quartile;
- (void)handleMediaContinuousProgress:(NSTimeInterval)current duration:(NSTimeInterval)duration;
- (void)handleMediaFailed:(NSError *)error;
- (void)handleMediaPaused;
- (void)handleMediaResumed;
- (void)handleMuteChanged:(BOOL)muted;
- (void)handleVideoSizeReady:(CGSize)size;
/// 首帧真正上屏（real_play 事件源，readyForDisplay=YES）
- (void)handleVideoFirstFrameDisplayed;
/// 播放真正推进过阈值（time_reached 事件源，区分有音无画 vs 起播卡死）
- (void)handleVideoPlaybackReached;

@end

#pragma mark - 试玩段事件协议

@protocol HSSPlayableSegmentEventHandler <HSSSegmentEventHandler>

@optional
/// JS 端 game 进度节点（15/30/45/60s → "1"/"2"/"3"/"4"），由 HSSModularPlayableGameTimer 触发
- (void)handlePlayableProgress:(NSString *)progress;

/// 静音切换：HSSPlayableSegmentVC 在 hss_muteChanged: 内 forward 给本方法，
/// EventHandler 内做 OMID volumeChange + JS 音量同步（emitAudioVolumeChange）
- (void)handleMuteChanged:(BOOL)muted;

@end

#pragma mark - Banner 段事件协议

@protocol HSSBannerSegmentEventHandler <HSSSegmentEventHandler>

@optional
/// 段时钟启动（hss_segmentMediaReveal）：由 HSSBannerSegmentVC 在 [super hss_segmentMediaReveal] 后 forward
/// 与 1.0 HSSInterstitialBannerView.didMoveToWindow(window!=nil) 时机等价，
/// 用于在段刚展示时启动白屏检测（SKAd / adx_sdk_show_duration 由 HSSModularAdVC 统一处理）
- (void)handleSegmentMediaReveal;

/// banner 加载完成（webView didFinishNavigation）：由 HSSBannerSegmentVC 在 readyHandler 内 forward
/// 用于 OMID 之外的 ready 时机相关副作用（当前 OMID prepareAndReport 已由 SegmentVC 自行触发）
- (void)handleBannerMediaDidFinishLoad;

@end

NS_ASSUME_NONNULL_END
