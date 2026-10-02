//
//  HSSModularAdCoordinator.h
//  HSADXSDK
//
//  Created by 张松
//

#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSAdFormat.h>

@class HSSModularAdCoordinator;
@class HSSCreativeItemModel;
@class HSSPlacementsModel;
@class HSSAdTrackingCenter;
@class HSSVastCreativeAdModel;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Delegate

@protocol HSSModularAdCoordinatorDelegate <NSObject>

/// 广告已展示
- (void)modularAdCoordinatorDidShow:(HSSModularAdCoordinator *)coordinator;

/// 广告被点击
- (void)modularAdCoordinatorDidClick:(HSSModularAdCoordinator *)coordinator
                              params:(nullable NSDictionary *)params;

/// 广告已关闭
- (void)modularAdCoordinatorDidClose:(HSSModularAdCoordinator *)coordinator
                              params:(nullable NSDictionary *)params;

@optional

/// 激励达成（插屏忽略此回调）
- (void)modularAdCoordinatorDidReward:(HSSModularAdCoordinator *)coordinator;

/// VAST 解析成功回调（供 Session 触发 Host 写回 MMKV 缓存）
/// 对齐 1.0 hss_writeBackWinnerVastResolvedIfNeeded: 的时机
- (void)modularAdCoordinator:(HSSModularAdCoordinator *)coordinator
     didParseVastForCreative:(HSSCreativeItemModel *)creative
                    vastType:(NSString *)vastType;

@end

#pragma mark - Coordinator

/// 模版2.0 新架构协调器
/// 职责：驱动素材准备器、创建并注入 VC、事件回调转发
/// 插屏和激励共用同一协调器，通过 adFormat 参数和 delegate 处理差异
@interface HSSModularAdCoordinator : NSObject

@property (nonatomic, weak, nullable) id<HSSModularAdCoordinatorDelegate> delegate;

@property (nonatomic, assign, readonly) HSSAdFormatType adFormat;
@property (nonatomic, strong, readonly) HSSCreativeItemModel *itemModel;

/// Placement 数据（banner 素材查找等场景使用）
@property (nonatomic, strong, nullable) HSSPlacementsModel *placement;

#pragma mark - Playable 能力依赖（由 Ad 层注入，Coordinator 转给 JSGateway）

/// Ad 层持有的 TrackingCenter（Playable BLS 消息等场景需要通过 Center 取 adsRelatedStat）
@property (nonatomic, weak, nullable) HSSAdTrackingCenter *trackingCenter;

#pragma mark - 生命周期接口

/// 统一分流入口：当前广告是否应走 2.0 架构。
///
/// 通过条件：
///   - 服务端下发 tmplVersion == 2（2.0 新协议，素材走 adInfo.material 新格式；==1 或未下发都走 1.0）
///   - 非离线广告（离线广告资源获取路径差异大，强制走 1.0）
///   - 非拼接广告（placement.is_mix == 1 时整条链路走 1.0，含双 banner / 双 video 等）：
///       取值用 placement.creatives = @[c1, c2]，渲染走 1.0 各自专属视图。
///       理由：拼接广告本质是"多个独立 creative 共享一次广告生命周期"，2.0 三段式无法
///       表达，且各 creative 的点击 / 曝光 / OMID / SKAd 维度独立，归一化会污染数据。
+ (BOOL)shouldUseModularWithItemModel:(nullable HSSCreativeItemModel *)itemModel
                              placement:(nullable HSSPlacementsModel *)placement;

- (instancetype)initWithAdFormat:(HSSAdFormatType)adFormat
                       itemModel:(HSSCreativeItemModel *)itemModel;

/// 阶段 1：加载（VAST 解析 + 视频下载 + WebView 预加载，2.0 自闭环）
/// @param completion 完成回调（success: 是否全部加载成功）
- (void)loadWithCompletion:(void(^)(BOOL success, NSError * _Nullable error))completion;

/// 阶段 2：展示广告
- (void)showFromViewController:(UIViewController *)presenter;

/// 查询是否准备就绪（load 已完成）
- (BOOL)isReady;

/// 当前展示段的索引（展示阶段生效；未展示 / 已销毁时返回 -1）
/// 供 2.0 埋点适配器按段读取对应 VAST 数据
- (NSInteger)currentSegmentIndex;

/// 当前展示段对应的 VAST 对象（展示阶段生效；未展示 / 已销毁 / 非 video/endcard 段时返回 nil）
/// 供 ReportingAdapter 在埋点前按段同步 VAST 到 itemModel.video.vast
- (nullable HSSVastCreativeAdModel *)currentSegmentVast;

/// 当前段是否为全屏可点（对齐旧架构 is_full_screen_click 语义）
/// 供 Ad 层在 adsClickStat 等埋点里填入准确的全屏可点标记，取代旧架构读 interstitialVC.is_full_screen_click
- (BOOL)isFullScreenClickEnabled;

/// 展示后的内部 VC（供 Ad 层在 visibleProvider / cross-promotion 里判断 VC 存活状态）
- (nullable UIViewController *)presentedViewController;

/// 取消并释放所有资源
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
