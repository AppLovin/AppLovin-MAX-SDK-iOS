//
//  HSSModularAdVC.h
//  HSADXSDK
//
//  Created by 张松
//
//  模版 2.0 广告展示 VC（插屏 + 激励统一使用）。
//
//  职责（2.0 "段即 VC" 架构）：
//    - UIKit 容器：持有 child HSSSegmentVC，借鉴 UIPageViewController 的 Child VC Containment 模式
//    - 实现 HSSSegmentRouterHost：按 Flow 决策创建 / 切换 SegmentVC 子类
//    - 实现 HSSSegmentVCContext：向段 VC 暴露服务门面（tracker / omidManager / flow 等）
//    - 广告级资源：SKAdImpression / AdShowTimer / Dismiss 编排 / App 生命周期埋点
//    - 广告级响应链终点：hss_ctaTapped / hss_adClicked → onClick 回调（段内业务已由段 VC 处理）
//
//  不做：
//    - 段内业务分支（OMID reset / SKOverlay / 视频埋点 / Playable Timer 等归段 VC）
//
//  业务按 category 拆分：
//    - +Lifecycle  模块装配 + Flow.host 绑定 + 每秒展示时长埋点
//    - +SKKit      Apple StoreKit 集成（SKAdNetwork 归因 + SKOverlay 推荐弹窗）
//

#import "HSSModularBaseViewController.h"
#import <HSADXSDK/HSSAdFormat.h>
#import <HSADXSDK/HSSSegmentVCContext.h>
#import <HSADXSDK/HSSSegmentRouterHost.h>

@class HSSCreativeItemModel;
@class HSSModularAdReportingAdapter;
@class HSSMaterialProvider;
@class HSSModularPlayableJSGateway;
@class HSSVastCreativeAdModel;

NS_ASSUME_NONNULL_BEGIN

/// 模版 2.0 容器 VC：实现 HSSSegmentVCContext（服务门面）+ HSSSegmentRouterHost（路由目标）
@interface HSSModularAdVC : HSSModularBaseViewController <HSSSegmentVCContext, HSSSegmentRouterHost>

#pragma mark - 不可变依赖（构造时一次性传入）

/// 指定初始化器：itemModel / adFormat 在 VC 生命周期内不可变
- (instancetype)initWithItemModel:(HSSCreativeItemModel *)itemModel
                         adFormat:(HSSAdFormatType)adFormat NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

#pragma mark - 运行时依赖（Coordinator 装配好注入）

/// 埋点 Adapter（2.0 路径直接调，段 VC 通过 context.tracker 使用；Service handler 中转已废弃）
@property (nonatomic, strong, nullable) HSSModularAdReportingAdapter *tracker;

/// 素材匹配服务（Coordinator 注入；段 VC 通过 context.materialProvider 取 Material → Media.initWithMaterial: 一步装配）
/// 端侧产物（streamLoader / webView / endCardWebView）由 load 阶段直接写入对应 Material 字段，不经 Provider 中转
@property (nonatomic, strong, nullable) HSSMaterialProvider *materialProvider;

/// Playable JS 桥（Coordinator 注入，段 VC 通过 context.playableJSGateway 注册 timerHolder）
@property (nonatomic, weak, nullable) HSSModularPlayableJSGateway *playableJSGateway;

#pragma mark - 事件回调（VC 触发，Coordinator 订阅）

/// 广告被点击
@property (nonatomic, copy, nullable) void(^onClick)(NSDictionary * _Nullable params);

/// 广告关闭
@property (nonatomic, copy, nullable) void(^onDismiss)(NSDictionary * _Nullable params);

/// 激励达成
@property (nonatomic, copy, nullable) void(^onReward)(void);

#pragma mark - 展示状态 Query（封装内部结构，避免 Coordinator 穿透 VC 内部模块）

/// 当前段索引（VC 未展示 / 未装配 → -1）
- (NSInteger)currentSegmentIndex;

/// 当前段对应的 VAST（用于埋点 VAST 事件）
- (nullable HSSVastCreativeAdModel *)currentSegmentVast;

/// 当前段是否启用全屏点击（对齐 HSSRenderEngine.isFullScreenClickArea: 判定规则）
- (BOOL)isFullScreenClickEnabled;

@end

NS_ASSUME_NONNULL_END
