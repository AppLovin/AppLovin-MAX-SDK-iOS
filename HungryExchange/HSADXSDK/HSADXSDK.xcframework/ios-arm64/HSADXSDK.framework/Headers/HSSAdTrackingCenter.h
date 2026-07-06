//
//  HSSAdTrackingCenter.h
//  HSADXSDK
//
//  Created by 张松
//
//  广告埋点中心 —— 插屏 / 激励、1.0 / 2.0 的所有 stat 方法统一实现在此处。
//
//  使用方式：
//    宿主（HSSInterstitialAd / HSSRewardedAd）实现 HSSAdTrackingContext 协议，
//    创建一个 Center 实例（传入 context），随后原有的 adsXxxStat 方法体全部
//    改成一行转调 [self.trackingCenter adsXxxStat:...]，对外方法签名不变。
//
//  2.0 路径（HSSModularAdReportingAdapter）直接持有 Center 调用，不依赖 HSSInterstitialAd。
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HSSCreativeItemModel;
@class HSSJumpTrackingContext;
@protocol HSSAdTrackingContext;

NS_ASSUME_NONNULL_BEGIN

@interface HSSAdTrackingCenter : NSObject

/// @param context 宿主 Ad 类；弱引用持有（不延长生命周期）
- (instancetype)initWithContext:(id<HSSAdTrackingContext>)context;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/// 当前上下文（弱引用；宿主释放后为 nil）
@property (nonatomic, weak, readonly, nullable) id<HSSAdTrackingContext> context;

#pragma mark - 核心参数

/// 生成 adsRelatedStat 公共参数（几乎所有其他 stat 方法都会合并此字典）
- (NSDictionary *)adsRelatedStat:(HSSCreativeItemModel *)creativeModel;

#pragma mark - 点击计数

/// 素材切换（只递增 section_index，不重置计数器）
- (void)switchSection;

/// 是否禁止点击的 track 链接上报
- (BOOL)forbidClickUrlTrack:(nullable id)params creativeModel:(HSSCreativeItemModel *)creativeModel;

#pragma mark - 展示

- (void)adsStartShowStat:(HSSCreativeItemModel *)creativeModel;
- (void)adsSuccessShowStat:(HSSCreativeItemModel *)creativeModel;
- (void)adsShowTrackStat:(HSSCreativeItemModel *)creativeModel;

#pragma mark - 点击

- (void)adsClickStat:(nullable id)params creativeModel:(HSSCreativeItemModel *)creativeModel;
- (void)adsClickTrackStat:(HSSCreativeItemModel *)creativeModel;
- (void)adsClickTrackStatForVast:(HSSCreativeItemModel *)creativeModel;
- (void)adsClickResultState:(BOOL)result
                     linkUrl:(nullable NSString *)linkUrl
                     context:(nullable HSSJumpTrackingContext *)jumpContext
               creativeModel:(HSSCreativeItemModel *)creativeModel
                      isAuto:(BOOL)isAuto;
- (void)adsDeeplinkStat:(BOOL)result
              deeplinkUrl:(nullable NSString *)deeplinkUrl
            creativeModel:(HSSCreativeItemModel *)creativeModel;

#pragma mark - 屏幕点击（adx_sdk_s_click）

- (void)screenClickTrackingStat:(CGPoint)clickPoint
                  creativeModel:(HSSCreativeItemModel *)creativeModel;

#pragma mark - 视频

- (void)adsVideoPlayStat:(HSSCreativeItemModel *)creativeModel videoPlayInfo:(nullable NSDictionary *)videoPlayInfo;
/// 视频帧尺寸已解出（adx_sdk_video_size_ready，presentationSize>0）
- (void)adsVideoSizeReadyStat:(HSSCreativeItemModel *)creativeModel videoPlayInfo:(nullable NSDictionary *)videoPlayInfo;
/// 首帧真正上屏（adx_sdk_video_real_play，readyForDisplay=YES）：黑屏率分子。
/// 黑屏率 = 1 - real_play / 视频类 show_success（覆盖加载失败 / 解码失败 / 渲染失败所有黑屏）。
- (void)adsVideoRealPlayStat:(HSSCreativeItemModel *)creativeModel videoPlayInfo:(nullable NSDictionary *)videoPlayInfo;
/// 播放真正推进过阈值（adx_sdk_video_time_reached）：区分"有音无画(time到)"vs"起播卡死(time未到)"。
- (void)adsVideoTimeReachedStat:(HSSCreativeItemModel *)creativeModel videoPlayInfo:(nullable NSDictionary *)videoPlayInfo;
- (void)adsVideoPlayFailed:(HSSCreativeItemModel *)creativeModel
            videoPlayInfo:(nullable NSDictionary *)videoPlayInfo
                    error:(nullable NSError *)error;
- (void)adsVideoEndStat:(HSSCreativeItemModel *)creativeModel videoEndInfo:(nullable NSDictionary *)videoEndInfo;
- (void)adsVideoPlayProgressStat:(NSInteger)percent creativeModel:(HSSCreativeItemModel *)creativeModel;

#pragma mark - 试玩

- (void)playableAdEventStat:(NSString *)eventName creativeModel:(HSSCreativeItemModel *)creativeModel;
- (void)playableAdProgressEventStat:(NSString *)progress creativeModel:(HSSCreativeItemModel *)creativeModel;
- (void)playableAdSkipStat:(NSInteger)duration endReason:(NSString *)endReason creativeModel:(HSSCreativeItemModel *)creativeModel;

#pragma mark - 展示时长 / 点击 dwell

- (void)adShowTimeProgressStat:(NSInteger)duration creativeModel:(HSSCreativeItemModel *)creativeModel;
- (void)clickAdDwellStat:(NSInteger)duration creativeModel:(HSSCreativeItemModel *)creativeModel;

#pragma mark - 激励专属

/// 激励视频奖励达成打点（Inter 不应调用）
- (void)adsRewardStat:(HSSCreativeItemModel *)creativeModel;

#pragma mark - Load 阶段埋点（2.0 路径由 Coordinator 调用；1.0 路径仍由 Ad 自身 stat 方法触发）

/// 素材开始下载打点（adx_sdk_load_start）
- (void)adsDownloadStartStat:(HSSCreativeItemModel *)creativeModel;

/// VAST 解析开始打点（adx_sdk_vast_start）
- (void)adsVastParseStartStat:(HSSCreativeItemModel *)creativeModel;

/// VAST 解析结果打点（adx_sdk_vast_parse，成功/失败都上报）
/// 失败时追加 error_code / error_message / http_code / wrapper_depth / wrapper_url
- (void)adsVastParseResultStat:(NSString *)vastXml
                       vastType:(NSString *)vastType
                      vastError:(nullable NSError *)vastError
                      successed:(BOOL)successed
                   creativeModel:(HSSCreativeItemModel *)creativeModel;

/// 素材下载结果打点（adx_sdk_load）
/// 漏斗模型：只在"进入下载阶段"后触发，和 adx_sdk_load_start 严格配对。
/// VAST 解析失败时不触发（漏斗在 vast_parse 截断）。
/// @param success  下载是否成功
/// @param stats    视频下载统计字典（可选：isHitCache / isReused / speedKbps / sizeMB / ...）
- (void)adsLoadStat:(HSSCreativeItemModel *)creativeModel
            success:(BOOL)success
              stats:(nullable NSDictionary *)stats;

/// 下载超时打点（adx_sdk_download_timeout）
/// 2.0 HSSStreamVideoLoader 无 timeout 机制，此方法对齐 1.0 接口保留；当前无触发点
- (void)adsDownloadTimeoutStat:(HSSCreativeItemModel *)creativeModel
                     timeoutMs:(NSTimeInterval)timeoutMs
                     extraInfo:(nullable NSDictionary *)extraInfo;

@end

NS_ASSUME_NONNULL_END
