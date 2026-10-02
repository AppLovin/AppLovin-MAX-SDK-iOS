//
//  HSSAdTrackingContext.h
//  HSADXSDK
//
//  Created by 张松
//
//  广告埋点上下文协议 —— 由宿主 Ad 类（HSSInterstitialAd / HSSRewardedAd）实现，
//  为 HSSAdTrackingCenter 提供生成埋点所需的一切广告会话状态。
//
//  设计原则：
//    - Center 通过 Context 单向读取宿主状态；**不反向调用宿主的方法**
//    - 宿主之间的差异（Inter / Rewarded）全部通过 Context 的方法/属性吸收
//    - Manager 仍归宿主持有（Center 不接管生命周期），通过 Context 回传引用
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdFormat.h>

@class HSSAdRequestContext;
@class HSSAdsModel;
@class HSSCreativeItemModel;
@class HSSClickTrackingManager;
@class HSSCloseTrackingManager;

NS_ASSUME_NONNULL_BEGIN

@protocol HSSAdTrackingContext <NSObject>

@required

#pragma mark - 广告会话

/// 广告类型（插屏 / 激励）—— 会作为 adsRelatedStat 的 ad_type 字段
@property (nonatomic, readonly) HSSAdFormatType adFormat;

/// 本次请求的只读上下文快照（提供 sid / rid / ad_mediation / cacheBucketSnapshot）
@property (nonatomic, readonly, nullable) HSSAdRequestContext *requestContext;

/// 广告位数据模型（提供 abcfgs 以及 placementModel 查询）
@property (nonatomic, readonly, nullable) HSSAdsModel *adsModel;

/// 当前广告位 ID
@property (nonatomic, readonly, nullable) NSString *placementId;

#pragma mark - Tracking Manager（仍归宿主持有，Context 回传引用）

/// 点击追踪 Manager —— 负责有效点击计数、s_click、跳转结果上报等
@property (nonatomic, readonly, nullable) HSSClickTrackingManager *clickTrackingManager;

/// 关闭追踪 Manager —— 负责 section 耗时、关闭按钮出现时间、AppLifeCycle / AppWillTerminate 事件
@property (nonatomic, readonly, nullable) HSSCloseTrackingManager *closeTrackingManager;

#pragma mark - 广告展示会话状态

/// 是否处于 fallback 流程（VAST 解析失败 / 下载失败时从 MMKV 缓存补位的加载链路）
/// Inter / Rewarded 都维护此状态；fallback 触发时 host 内部 set YES，
/// 非 fallback 路径（含初次 load / 用户 fresh load）保持 NO
@property (nonatomic, readonly) BOOL isFallBackFlow;

/// fallback 场景标识（仅 isFallBackFlow == YES 时有意义）
///   - "1" = VAST 解析失败 fallback
///   - "2" = 下载失败 fallback（含流式下载失败）
///   - nil = 非 fallback 路径
/// Inter / Rewarded 都维护此字段
@property (nonatomic, readonly, nullable) NSString *fallbackScene;

#pragma mark - Format-specific 字段

/// 当前 creative 对应的 ad_skip_tmpl 字段来源
/// - Inter：material_type==Banner ? ext.instl_banner_tmpl : ext.instl_video_tmpl
/// - Rewarded：ext.reward_video_tmpl
- (NSInteger)adSkipTmplForCreative:(HSSCreativeItemModel *)creative;

/// 当前 creative 对应的 video_cta_lottie 字段来源
/// - Inter：ext.instl_tmpl_cfg.video_cta_lottie
/// - Rewarded：ext.reward_tmpl_cfg.video_cta_lottie
- (NSString *)videoCtaLottieForCreative:(HSSCreativeItemModel *)creative;

/// 是否需要在 adsRelatedStat 里上报 not_preload 字段
/// - Inter：YES（双 banner 场景需此字段）
/// - Rewarded：NO（激励无 is_mix 场景，原实现就没这个字段）
- (BOOL)reportsNotPreload;

@optional

#pragma mark - 展示成功埋点的尾部钩子

/// adsSuccessShowStat 发送完成后的可选回调
/// - Inter：调 HSSReadyAdInfoManager removeReadyAdInfoWithAdUnitId:associateMaxAdUnitId
/// - Rewarded：不实现
- (void)onAdShowSuccessStatWasSent:(HSSCreativeItemModel *)creativeModel;

@end

NS_ASSUME_NONNULL_END
