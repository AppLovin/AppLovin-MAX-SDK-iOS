//
//  HSSMediaVirtualProgressTicker.h
//  HSADXSDK
//
//  Created by 张松
//
//  Media 层"虚拟进度 tick"工具：
//
//  应用场景：
//    - 试玩段（HSSWebViewMedia）等无真实播放进度的 Media，需要派发 hss_mediaContinuousProgress:
//      让 HSSSegmentComponentRenderer 按 controlInfo.show=1/2 策略调度组件可见性
//    - 视频段不使用本类（HSSPlayer.addPeriodicTimeObserver 已提供真实进度）
//
//  对外 API：
//    start / suspend / resume / stop（所有方法在主线程调用）
//
//  生命周期模型：
//    - 调用方持有 ticker（典型为 HSSWebViewMedia.progressTicker），在 play 时 start，destroy 时 stop
//    - ticker 内部用 HSSADXWeakProxy 让 NSTimer 不强引用 self，自身释放时 dealloc 兜底 stop
//    - App 前后台监听由 ticker 自管（监听 NSNotification + setFireDate 暂停/恢复）
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSMediaVirtualProgressTicker : NSObject

/// 每秒回调一次累计已过秒数（从 1 开始；不会派发 0）。
/// 调用方在此 block 中派发 hss_mediaContinuousProgress:duration:0
/// 注意：block 内必须用 weak self，避免对调用方的强引用。
@property (nonatomic, copy, nullable) void (^tickHandler)(NSTimeInterval currentSeconds);

/// 启动 NSTimer + 注册 App 前后台观察者。幂等：已启动重复调用直接返回。
- (void)start;

/// 暂停 timer（setFireDate distantFuture）。
/// 显式暂停场景（如视频暂停），当前主要由内部 App 前后台观察者自动调用。
- (void)suspend;

/// 恢复 timer（setFireDate now）。
- (void)resume;

/// 停止 + 注销观察者 + invalidate timer。幂等：未启动时调用安全无效果。
- (void)stop;

@end

NS_ASSUME_NONNULL_END
