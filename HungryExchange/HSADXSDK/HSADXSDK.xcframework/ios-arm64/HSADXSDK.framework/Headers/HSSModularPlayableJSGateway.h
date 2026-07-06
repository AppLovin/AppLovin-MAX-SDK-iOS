//
//  HSSModularPlayableJSGateway.h
//  HSADXSDK
//
//  Created by 张松
//
//  Playable JS 桥 + 业务分发独立模块。
//
//  职责：
//    - 创建带 MRAID / window.open override 的 WKWebView（用 HSSAdWebViewBridgeKit）
//    - 作为 WKScriptMessageHandler 接收 JS → Native 消息
//    - 分发：open 事件 → 转发段侧 HSSPlayableTimerHolder；event 事件 → game 生命周期 / BLS
//    - Native → JS 同步（emitAudioVolumeChange）
//    - 实现 HSSBlsMessageContext，复用老 HSSBlsMessageHandler 不改动
//
//  生命周期：
//    由 Coordinator 持有。Coordinator 初始化时创建 Gateway（不含 tracker/vc）；
//    show 阶段 Coordinator 把 tracker 和 VC 注入给 Gateway。
//    webView 创建在 Load 阶段：Coordinator 在 preparePlayable 完成后切主线程调
//    -[Gateway createWebViewWithLocalFilePath:] 现场创建（带 JS 桥）。
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <HSADXSDK/HSSBlsMessageHandler.h>

@class HSSCreativeItemModel;
@class HSSModularAdReportingAdapter;
@class HSSAdTrackingCenter;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HSSPlayableTimerHolder

/// Playable 段 JS 业务持有者协议（Timer / open 点击等）。
///
/// 设计动机：
///   2.0 架构下段级业务（Timer、埋点、ActionRouter）归属于 HSSPlayableSegmentEventHandlerImpl，
///   Gateway 不引用 Material / 段对象，通过 weak Holder 转发 JS 消息。
@protocol HSSPlayableTimerHolder <NSObject>

/// JS gameStart 消息到达：Holder 启动 Timer
- (void)playableGameStart;

/// JS gameEnd / BLS skip 等"Playable 段结束"消息到达：Holder 停止 Timer 并上报 skip
/// @param endReason "3"=正常 gameEnd / "1"=BLS skip 或用户主动跳过
- (void)playableGameEndWithReason:(NSString *)endReason;

/// JS mraid.open / autoJump：Holder 处理点击埋点 + ActionRouter（可读 Material 拼参）
/// @param userClick YES=mraid.open 用户触发；NO=autoJump 自动跳转
- (void)playableJSOpenWithUserClick:(BOOL)userClick;

@end

#pragma mark - HSSModularPlayableJSGateway

@interface HSSModularPlayableJSGateway : NSObject <WKScriptMessageHandler, HSSBlsMessageContext>

- (instancetype)initWithItemModel:(HSSCreativeItemModel *)itemModel
                   trackingCenter:(nullable HSSAdTrackingCenter *)trackingCenter;

/// show 阶段由 Coordinator 注入（load 阶段 tracker 尚未创建）
@property (nonatomic, weak, nullable) HSSModularAdReportingAdapter *tracker;

/// show 阶段注入：用于 BlsContext 取 adShowTimeValue
@property (nonatomic, weak, nullable) UIViewController *vc;

/// 创建带 JS 桥的 WKWebView 并加载本地 HTML（load 阶段由 Coordinator 调）
/// @return 已配置好 MRAID 桥 + messageHandler 的 WKWebView
- (WKWebView *)createWebViewWithLocalFilePath:(NSString *)localFilePath;

/// Native → JS：同步当前音量给 Playable 页面的 JS 逻辑
/// 对齐老架构 VC.playableActionMute: → emitAudioVolumeChange:webView:
/// @param volume 0=mute, 100=full volume（老架构语义）
- (void)emitAudioVolumeChange:(NSInteger)volume;

#pragma mark - HSSPlayableTimerHolder 绑定（2.0 段 VC 路径）

/// 由 HSSPlayableSegmentEventHandlerImpl 在 init 时调用，声明自己为 JS 业务持有者。
/// bind 后 Gateway 收到的 JS open / gameStart / gameEnd 消息全部转发给 Holder。
- (void)bindTimerHolder:(id<HSSPlayableTimerHolder>)holder;

/// 由 HSSPlayableSegmentVC 在 performSegmentTearDown 时调用，解绑。
- (void)unbindTimerHolder:(id<HSSPlayableTimerHolder>)holder;

/// 销毁：注销 MessageHandler、停止加载
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
