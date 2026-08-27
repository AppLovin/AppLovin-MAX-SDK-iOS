//
//  HSSModularAdVC+Private.h
//  HSADXSDK
//
//  Created by 张松
//
//  VC 内部 property + 跨 category 共享方法：
//    - 以 Class Extension 形式声明，主 .m 合成 ivar + getter/setter
//    - 各 category 通过 import 此文件访问同一份状态
//    - 不可变依赖 itemModel / adFormat 通过 initializer 传入后在此 redeclare 为可写，
//      仅用于主 .m 合成 ivar；category 外不应写入
//

#import "HSSModularAdVC.h"
#import <StoreKit/SKStoreProductViewController.h>

@class HSSCreativeItemModel;
@class HSSRenderContext;
@class HSSFlowCoordinator;
@class HSSModularOMIDManager;
@class HSSRewardCoordinator;
@class HSSSegmentVC;
@class HSSWebviewOverlayView;

NS_ASSUME_NONNULL_BEGIN

@interface HSSModularAdVC () <SKStoreProductViewControllerDelegate>

#pragma mark - 不可变依赖（initializer 写一次，之后只读）

@property (nonatomic, strong) HSSCreativeItemModel *itemModel;
@property (nonatomic, assign) HSSAdFormatType adFormat;

#pragma mark - 内部核心模块

/// 组件可见的数据快照（切段时由本 VC 同步 currentSegment / currentMaterial / currentMedia 等字段）
@property (nonatomic, strong) HSSRenderContext *renderContext;

/// 段流转路由器（segmentRequestsNext / close / dismiss）
@property (nonatomic, strong) HSSFlowCoordinator *flowCoordinator;

/// OMID 管理器（首段 impression 由 VideoSegmentVC 在 viewDidAppear 建立）
@property (nonatomic, strong) HSSModularOMIDManager *omidManager;

/// 激励决策器
@property (nonatomic, strong) HSSRewardCoordinator *rewardCoordinator;

/// 当前 child segment VC（UIKit containment）；切段时由 routerRequestsTransitionToSegmentAtIndex: 替换
@property (nonatomic, strong, nullable) HSSSegmentVC *currentSegmentVC;

#pragma mark - 生命周期状态

@property (nonatomic, assign) BOOL hasAppeared;
@property (nonatomic, assign) BOOL dismissed;

#pragma mark - SKAdImpression

@property (nonatomic, assign) BOOL skAdImpressionStarted;

#pragma mark - SKOverlay

@property (nonatomic, assign) BOOL hasCheckedSKOverlay;
/// 已触发过 SKOverlay check 的视频段索引集合（对齐老"双视频每段独立 SKOverlay"）
@property (nonatomic, strong, nullable) NSMutableSet<NSNumber *> *overlayCheckedSegments;

#pragma mark - 广告展示计时

@property (nonatomic, strong, nullable) NSTimer *adShowTimer;
@property (nonatomic, assign) NSInteger adShowTimeValue;

#pragma mark - WebView Overlay（跨段宿主级浮层，对齐 1.0 HSSInterstitialVC.webviewOverlay）

/// 浮层实例：仅 Host 持有，加在 self.view 上以跨段存活，销毁权集中在 +Lifecycle 类目
/// z-order 维护：在 _performContainmentTransitionTo: 的 animations block 内 bringSubviewToFront，
/// 让 overlay 在动画开始之前就回到最上层（无 transition 异步间隙的 z-order 闪烁）
@property (nonatomic, strong, nullable) HSSWebviewOverlayView *webviewOverlay;

#pragma mark - Mediator 方法（主 .m 实现，category 可调用）

/// 统一 dismiss 流程：关 SKAd / SKOverlay，销毁计时器，dismissVC 后回调 host
- (void)handleDismissWithParams:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
