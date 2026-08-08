//
//  HSSModularBaseViewController.h
//  HSADXSDK
//
//  Created by 张松
//
//  模版2.0 架构下所有 VC 的公共基类。
//  职责：
//    1. 统一状态栏 / 横竖屏配置（对齐老架构 HSSBaseViewController 的视觉行为）
//    2. 装载 HSSAllTouchTrackingGestureRecognizer 手势，收集 adx_sdk_s_click 原始数据
//    3. 统一订阅 App 生命周期通知（Terminate / DidEnterBackground / WillEnterForeground / WillResignActive）
//    4. 生命周期埋点（adx_sdk_enter_bg / adx_sdk_resign_active）走 tracker，和 1.0 对齐
//    5. 暴露子类 hook（onAppXXX），子类在 hook 里叠加业务逻辑
//
//  设计原则：
//    - 不含任何具体业务决策（不碰 FlowCoordinator / RenderEngine / Dismiss）
//    - 和 1.0 的 HSSBaseViewController 完全独立，不存在继承 / 依赖关系
//    - 共享的是 SDK 公共基础设施（HSSAllTouchTrackingGestureRecognizer）而非 1.0 基类
//

#import <UIKit/UIKit.h>

@class HSSModularAdReportingAdapter;

NS_ASSUME_NONNULL_BEGIN

@interface HSSModularBaseViewController : UIViewController

#pragma mark - 子类必须提供

/// 供 base 派发 adx_sdk_s_click / adx_sdk_*_life_cycle 等埋点
/// 子类重写此方法返回自己持有的 tracker 实例
- (nullable HSSModularAdReportingAdapter *)modularTracker;

#pragma mark - 子类可选重写（模板方法 hook，默认空实现）

/// App 进入后台（UIApplicationDidEnterBackgroundNotification）
/// 注意：base 已经派发 adx_sdk_enter_bg 埋点，子类只需要处理自己的业务（如暂停计时器）
- (void)onAppDidEnterBackground;

/// App 即将进入前台（UIApplicationWillEnterForegroundNotification）
/// 老架构未在此通知打专属埋点；新架构子类可在此做 dwell 埋点 + VAST/OMID resume
- (void)onAppWillEnterForeground;

/// App 即将取消活跃（UIApplicationWillResignActiveNotification）
/// base 已经派发 adx_sdk_resign_active 埋点，子类可以重写做自己的事
- (void)onAppWillResignActive;

/// App 即将被终止（UIApplicationWillTerminateNotification）
/// base 不派发埋点（老架构也未在此打埋点）；子类可在此做 crash flag 清理 + terminate 业务埋点
- (void)onAppWillTerminate;

@end

NS_ASSUME_NONNULL_END
