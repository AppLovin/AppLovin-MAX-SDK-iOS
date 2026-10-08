//
//  HSSModularAdSession.h
//  HSADXSDK
//
//  Created by 张松
//
//  模版 2.0 广告展示会话（插屏 / 激励通用）。
//
//  职责：协调一次 2.0 广告"从 load 到 close"的完整生命周期 ——
//    - 驱动 HSSModularAdCoordinator（视频类展示，Coordinator 内部直接创建 Adapter）
//    - banner / 图文归一化：adInfo.material → itemModel 老字段，归一化后回调 Host 走 1.0 老链路（插屏专属）
//    - 激励达成回调转发给 Host（激励专属）
//    - 接收 Coordinator 的 delegate 回调，通过 Host 协议转发到宿主 Ad
//
//  分流前置：拼接广告（placement.is_mix == 1，含双 banner / 双 video 等）由
//  HSSModularAdCoordinator.shouldUseModular 提前拦截，整条链路走 1.0，不进 Session。
//
//  重要边界：Session 不做 Ad 的业务副作用（adShowingStatus / adDidShow / closeTrackingManager 等），
//         这些副作用仍归宿主 Ad —— Session 通过 Host 协议"通知 Ad 去做"。
//
//  通用化设计：Session 本身不区分插屏/激励，广告类型差异通过 Host 协议的 optional 方法表达：
//    - 插屏专属：banner 归一化回调（激励不下发 banner，不实现即可）
//    - 激励专属：reward 达成回调（插屏无激励概念，不实现即可）
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdFormat.h>

@class HSSCreativeItemModel;
@class HSSPlacementsModel;
@class HSSAdsModel;
@class HSSAdTrackingCenter;
@class HSSAdRequestContext;
@class HSSModularAdCoordinator;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Host 协议（Ad 实现，供 Session 反向调用）

/// Session 只通过此协议访问宿主 Ad 的能力；宿主内部状态（adsModel / delegate / Manager 等）不对 Session 暴露
@protocol HSSModularAdSessionHost <NSObject>

@required

#pragma mark - Business delegate 转发（Ad 做一行壳：self.delegate didXxx:）

- (void)modularSessionDidLoadAd;
- (void)modularSessionDidFailToLoadAdWithError:(NSError *)error;
- (void)modularSessionDidFailToDisplayAdWithError:(NSError *)error;
/// 对齐老 clickAdCompletion 2235-2269：内推非 MMP 不发 delegate / 不发通知；其他场景发 didClickAd + post 通知
- (void)modularSessionDidClickAd:(nullable NSDictionary *)params;

#pragma mark - Business 副作用委派（Ad 触发自己内部状态变更）

/// Coordinator DidShow 后的副作用（对齐老 present completion：
///   updateAdsShowingStatus + adDidShow(含 cross/dsp 分支 + payDelegate + removeAdCache + 展示 stat + nurls)
///   + resetClickCounters + recordAdShowStart/SectionStart + saveAdContext + hss_startInterShowAtNs）
/// @param visibleProvider Session 提供的 block：查询 Coordinator 管理的 VC 是否还在 window 上
- (void)modularSessionOnDidShow:(HSSCreativeItemModel *)itemModel
                visibleProvider:(BOOL (^)(void))visibleProvider;

/// Coordinator DidClose 后的副作用（对齐老 dismissCompletion：
///   hss_stopInterShowAtNs + adRelatedStat 合并 params + PageView reset + sendCloseTracking
///   + closeManager reset + cache 清理 + didHideAd + clearAdCrashFlag + clearSamplingCache）
- (void)modularSessionOnDidClose:(HSSCreativeItemModel *)itemModel
                          params:(nullable NSDictionary *)closeParams;

#pragma mark - Coordinator 同步镜像

/// Session 创建 Coordinator 后同步给 Ad 的 modularCoordinator property；
/// 1.0 stat 方法里的 `self.modularCoordinator.isFullScreenClickEnabled` 需要读它，所以 Ad 必须持有一个镜像
- (void)modularSessionSyncCoordinator:(nullable HSSModularAdCoordinator *)coordinator;

#pragma mark - 广告类型（Session 创建 Coordinator / Tracker 时需要，用于区分插屏/激励的业务分支）

/// 广告类型：插屏 Host 返回 HSSAdFormatTypeInter，激励 Host 返回 HSSAdFormatTypeReward
/// 决定 RenderEngine/Component/TrackingService 里所有 adFormat 分支
@property (nonatomic, readonly) HSSAdFormatType adFormat;

#pragma mark - 共享资源（Session 从 Ad 拿，不自建）

/// 统一埋点中心（Session 创建 ReportingAdapter 时复用；Coordinator 也需要它供 Playable BLS 取 adsRelatedStat）
@property (nonatomic, readonly) HSSAdTrackingCenter *trackingCenter;

@optional

#pragma mark - Banner 归一化后走 1.0 老链路（仅插屏实现）

/// Session 做完单 banner 归一化（adInfo.material → itemModel.banner），然后回调此方法，
/// 让 Ad 走 1.0 的 banner 预加载 + didLoadAd 通知。
/// 注：双 banner 由 shouldUseModular 提前拦截走 1.0，不会触发本回调。
- (void)modularSessionTriggerLegacyBannerLoad:(HSSAdsModel *)adsModel isRetry:(BOOL)isRetry;

/// 2.0 单 Banner 展示阶段：归一化（防御性）完成后，让 Ad 走 1.0 的 showInterstitialBannerAd
/// （对齐旧 showAd 2132-2135 行：Modular Banner 在 show 阶段也做一次归一化 + 走老 banner 展示流程）
- (void)modularSessionTriggerLegacyBannerShow:(HSSCreativeItemModel *)itemModel;

#pragma mark - 图文归一化后走 1.0 老链路（仅插屏实现，激励不下发图文）

/// Session 做完图文归一化（adInfo.material 里的 HSSMaterialNative → itemModel.title/desc/images/icon/ext.btn）
/// 然后回调此方法，让 Ad 走 1.0 的图文预加载 + didLoadAd 通知
- (void)modularSessionTriggerLegacyImageTextLoad:(HSSAdsModel *)adsModel isRetry:(BOOL)isRetry;

/// 2.0 图文展示阶段：归一化（防御性）完成后，让 Ad 绕过 2.0 分流走 1.0 原 showAd 路径
/// （图文和 Video/VAST 共用 HSSInterstitialVC，没有专用 show 方法，需要 bypass flag 避开分流循环）
- (void)modularSessionTriggerLegacyImageTextShow:(HSSCreativeItemModel *)itemModel;

#pragma mark - 激励达成（仅激励实现）

/// close.count_down 倒计时结束时触发（视频段 / 试玩段）；Ad 在此回调里完成 delegate 通知 + adsRewardStat 埋点
/// 2.0 架构下激励是"达成即触发"，与老架构倒计时结束即触发语义一致
- (void)modularSessionDidEarnReward;

#pragma mark - 缓存协同（插屏/激励共用）

/// VAST 解析成功后写回 MMKV（对齐 1.0 hss_writeBackWinnerVastResolvedIfNeeded:）
/// Ad 实现内部调 HSSAdCacheCompareModule.writeBackWinnerVastResolvedIfNeededWithCreative:
- (void)modularSessionShouldWriteBackVastForCreative:(HSSCreativeItemModel *)creative
                                              vastType:(NSString *)vastType;

#pragma mark - Load 失败 fallback（插屏/激励共用）
//
// 设计：编排（调 HSSAdCacheCompareModule.notifyDisplaySuccessRemoveCache + asyncFallbackForPlacementId）
//      全部在 Session 内部完成，Ad 只需：
//        ① allowFallback: 读自己的开关/状态，决定是否允许 fallback
//        ② adType / adLoad: 提供编排所需的基础数据
//        ③ applyFallback: 拿到 fallback adsModel 后接管（set state + continueWithAdsModel:isRetry:YES）
//

/// 询问是否允许对该 failureReason 做 fallback
/// Ad 内部判断 vast_error_load_cache / download_error_load_cache / isBidFailureRetry / download_error_fallback 等
/// Ad 需要在此方法返回 YES 前做好状态标记（如 download_error_fallback = YES），避免重复 fallback
/// @param reason @"vast" 或 @"download"
/// @return YES 允许 Session 执行 fallback 编排；NO Session 直接走常规 didFailToLoadAd
- (BOOL)modularSessionAllowFallbackForReason:(NSString *)reason;

/// 广告类型：@"1" 插屏 / @"2" 激励（Session 编排时作为 CacheCompare 接口参数）
- (NSString *)modularSessionAdType;

/// 当前 Ad 的请求上下文快照（Session 需要 cacheBucketSnapshot / ad_mediation 等字段）
- (nullable HSSAdRequestContext *)modularSessionRequestContext;

/// Session 异步拿到 fallback adsModel 后调用此方法，Ad 接管后续流程
/// （set isFallBackFlow / fallbackScene + continueWithAdsModel:isRetry:YES）
/// @param adsModel fallback 的 adsModel
/// @param scene @"1" VAST 失败 fallback / @"2" 下载失败 fallback
- (void)modularSessionApplyFallbackAdsModel:(HSSAdsModel *)adsModel
                                        scene:(NSString *)scene;

@end


#pragma mark - Session

/// 2.0 广告展示会话。生命周期：由 Ad 创建，Ad 释放时 Session 也释放。
@interface HSSModularAdSession : NSObject

/// 分流判断：当前广告是否应走 2.0 路径。
/// 透传给 HSSModularAdCoordinator.shouldUseModularWithItemModel:placement:。
/// placement 用于双视频识别等业务守卫；调用方应传入广告所属 placement，传 nil 时仅按 itemModel 判断。
+ (BOOL)shouldUseModularForItemModel:(nullable HSSCreativeItemModel *)itemModel
                             placement:(nullable HSSPlacementsModel *)placement;

/// 判断是否为 2.0 段化 banner（tmpl.segments 中含 HSSBannerSegment）。
/// 供 Ad 层 show 分流在调用 Session 之前使用：
///   material_type==6 且本方法返回 YES → 2.0 段化 banner，不走 showInterstitialBannerAd，由 Session 路由到 Coordinator
///   material_type==6 且本方法返回 NO  → 1.0 老协议 banner，继续走 showInterstitialBannerAd
+ (BOOL)isTmplBannerForItemModel:(nullable HSSCreativeItemModel *)itemModel;

/// 构造：由宿主 Ad 创建，弱引用 Host
- (instancetype)initWithHost:(id<HSSModularAdSessionHost>)host;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

#pragma mark - 阶段接口（Ad 在分流后调）

/// 2.0 Load 入口：按 material_type 路由（单 banner / 图文 / 视频类）。
/// 拼接广告（is_mix == 1）由 shouldUseModular 提前拦截，不会进入此方法。
- (void)loadWithItemModel:(HSSCreativeItemModel *)itemModel
                placement:(HSSPlacementsModel *)placement
                 adsModel:(HSSAdsModel *)adsModel
                  isRetry:(BOOL)isRetry;

/// 2.0 Show 入口
- (void)showWithItemModel:(HSSCreativeItemModel *)itemModel;

/// 是否 ready（Coordinator 是否加载完成）
- (BOOL)isReady;

/// 取消并清理（Ad.dealloc / 业务侧强制释放时调）
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
