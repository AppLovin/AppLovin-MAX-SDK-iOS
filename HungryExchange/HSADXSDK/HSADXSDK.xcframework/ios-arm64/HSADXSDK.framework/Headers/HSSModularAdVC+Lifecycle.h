//
//  HSSModularAdVC+Lifecycle.h
//  HSADXSDK
//
//  Created by 张松
//
//  容器 VC 生命周期相关合并：
//    - Setup     : viewDidLoad 阶段的容器 view + 模块组装
//                  （renderContext / flowCoordinator / omidManager / rewardCoordinator）
//    - AdShowTime: 广告展示时长 1s 周期 Timer，3/5/10/30s 节点上报
//                  （前后台暂停/恢复由主 .m 的 onAppDidEnter/Foreground 驱动；dismiss/dealloc 时 invalidate）
//    - WebOverlay: VAST 浮层覆盖广告（对齐 1.0 HSSInterstitialVC.checkoutWebviewOverlay/
//                  bringWebOverlayToFront/destroyWebOverlayView）
//                  视频段通过 HSSSegmentVCContext @optional 上调，Host 持有跨段存活
//

#import "HSSModularAdVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSModularAdVC (Lifecycle)

#pragma mark - Setup（首次出现前的基础设施装配）

/// 设置容器 view（self.view 的 backgroundColor 等）
/// 2.0 架构不再创建独立的 mediaContainer / componentContainer，segment VC 自行维护段内容器
- (void)setupContainers;

/// 组装 renderContext / omidManager / rewardCoordinator / flowCoordinator
/// 并设置 flow.host = self（走 HSSSegmentRouterHost 协议路径）
- (void)setupModules;

#pragma mark - AdShowTime（展示时长 Timer）

- (void)startAdShowTimer;
- (void)destroyAdShowTimer;

#pragma mark - WebView Overlay（HSSSegmentVCContext @optional 实现）

- (void)checkWebviewOverlayWithPlayerDuration:(NSTimeInterval)playerDuration;
- (void)destroyWebviewOverlay;

/// z-order 维护入口：在 _performContainmentTransitionTo: 的 animations block 内调用
/// （主 .m 共享，跨 category 调用）
- (void)bringWebviewOverlayToFrontIfNeeded;

@end

NS_ASSUME_NONNULL_END
