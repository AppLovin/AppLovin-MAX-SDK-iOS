//
//  HSSInnerSettings.h
//  HSADXSDK
//
//  Created by admin on 2024/11/28.
//

#import <Foundation/Foundation.h>

@class HSSEventModel;
@class HSSPlacementModel;
@class HSSInstallInfoModel;
@class HSSInstallInfoConfigModel;
@class HSSStreamSpeedRatioConfig;
@class HSSAdShowConfig;
NS_ASSUME_NONNULL_BEGIN
/**
  Sdk 内部基础设置
 */
@interface HSSInnerSettings : NSObject

+ (instancetype)shared;

/// 默认 host
+(NSString *)defaultHost;

/// 当前请求configureUrl域名
+ (NSString *)configureUrl;

/// 内部禁用 sdk 功能 ， 默认 NO
@property (nonatomic, assign) BOOL disableSdk;

/// 静音状态
@property (nonatomic, copy) NSString *mute;

/// 国家
@property (nonatomic, copy) NSString *country;

/// 当前请求域名
@property (nonatomic, copy) NSString *host;

/// 事件上报开关 YES 打开 NO 关闭， 总开关
@property (nonatomic, assign) BOOL reportEnable;

/// 广告位信息控制
@property (nonatomic, strong) NSArray<HSSPlacementModel *> *placements;
/// app相关信息
@property (nonatomic, strong) NSArray<HSSInstallInfoModel *> *installs;
/// event 事件控制
@property (nonatomic, strong) NSArray<HSSEventModel *> *events;

/// 是否切换到debug模式
@property (nonatomic, assign) BOOL debugMode;

///广告曝光链接请求重试次数
@property (nonatomic, assign) NSInteger impressionRetry;

///广告曝光链接请求重试间隔时间
@property (nonatomic, assign) NSInteger impressionRetryInterval;

/// 仅由 configure 写入的 `HSSConfigureModel.trackRetryDelays`（已在 `HSSConfigureModel` 内解析、清洗）。监测侧请用 `hss_effectiveTrackRetryDelays` 读取「当前生效」序列（无下发时用 `impressionRetry` + `impressionRetryInterval` 展开）。
@property (nonatomic, copy, nullable) NSArray *trackRetryDelays;

/// MMKV 本地上报最大重试次数
@property (nonatomic, assign) NSInteger mmkv_report_max_retry;

@property (nonatomic, assign) BOOL isForbidReport;
// 控制vast wrapper 重定向请求 使用post还是get请求 默认0是get 下发1用post请求
@property (nonatomic, assign) NSInteger isVastWrapperReqPost;

// 控制触摸追踪功能开关 默认1是开启 下发0关闭
@property (nonatomic, assign) NSInteger enableTouchTracking;

// 控制RSA公钥获取方式 默认1是开启新逻辑(SecKeyCreateWithData) 下发0使用旧逻辑(Keychain方式)
@property (nonatomic, assign) NSInteger rsaKeyOptimizationEnabled;

/// 控制ActionRouter是否走新逻辑，默认走旧逻辑
@property (nonatomic, assign) NSInteger actionRouterNew;

@property (nonatomic, assign) NSInteger displayType;

@property (nonatomic, strong) HSSInstallInfoConfigModel *ii_c;

@property (nonatomic, assign) NSInteger clickAdTime;

/// 图片监控总开关，YES: 启用新逻辑（监控+降采样），NO: 走旧逻辑
/// cfg配置字段：enable_image_monitor
@property (nonatomic, assign) BOOL enableImageMonitor;

/// 上报阈值（单位：MB），预解码后的图片超过此阈值会上报
/// 如果下发0，端上默认50M，即超过50M开始上报
/// cfg配置字段：maxImageSize
@property (nonatomic, assign) NSInteger maxImageSize;

/// 降采样阈值（单位：MB），超过此阈值开始降采样
/// 下发0时，端上不执行降采样逻辑
/// cfg配置字段：image_down_sampling_threshold
@property (nonatomic, assign) NSInteger imageDownsamplingThreshold;

/// 降采样目标尺寸（单位：像素，最长边），超过此尺寸的图片会被降采样到此尺寸
/// 下发0时，端上默认值2000，如果imageDownsamplingThreshold下发0，这个值无效
/// cfg配置字段：image_down_target_size
@property (nonatomic, assign) NSInteger imageDownsamplingMaxPixelSize;

/// 文件读到内存中的拦截大小，默认0。下发0时，端上默认50，即超过50M上报，超过50*3 = 150M拦截
/// 不为0时，例如下发30，即超过30M上报，超过30*3 = 90M就拦截
/// cfg配置字段：large_file_size
@property (nonatomic, assign) NSInteger largeFileSize;

/// 申请后台任务的开关，针对adx_sdk_resign_active和adx_sdk_enter_bg两个埋点
@property (nonatomic, assign) NSInteger backgroundTaskEnable;

/// 素材 id 黑名单
@property (nonatomic, copy) NSArray <NSString *>*crid_blacklist;

/// 白屏采样率 
@property (nonatomic, assign) NSInteger ws_sampling_rate;

///  白屏像素阀值 超过这个阀值就认为是白屏
@property (nonatomic, assign) NSInteger white_screen_threshold;

/// 白屏延迟多长时间检测
@property (nonatomic, assign) double ws_detect_delay;

/// 插屏 banner 白屏延迟多长时间检测
@property (nonatomic, assign) double inter_banner_ws_detect_delay;

/// 采样缓存
@property (nonatomic, strong) NSCache<NSString *, NSNumber *> *samplingCache;

- (void)clearSamplingCache;

/// 是否关闭omsdk功能，默认为false
@property (nonatomic, assign) BOOL omsdk_closed;

/// omid的js脚本地址
@property (nonatomic, copy) NSString *omid_js_url;

@property (nonatomic, assign) NSInteger vastMediaRule;
@property (nonatomic, assign) NSInteger vastMediaRuleResolution;

@property (nonatomic, assign) NSInteger vast_video_score_resolution_weight;

@property (nonatomic, assign) BOOL mraid_main_frame_only;

/// 是否禁止预加载（目前仅针对插屏banner广告位生效)
@property (nonatomic, assign) BOOL not_preload;
/// 是否显示h5加载进度条
@property (nonatomic, assign) BOOL show_h5_progress;

/// t_imp上报失败时是否解析ip
@property (nonatomic, assign) NSInteger t_imp_report_ip;
/// 上报最近展示ecpm的条数
@property (nonatomic, copy) NSDictionary *record_show_ecpm_config;

/// 是否开启流式下载
@property (nonatomic, assign) NSInteger enable_stream_player;

/// 是否开启断点续传
@property (nonatomic, assign) NSInteger enable_stream_resume;

@property (nonatomic, strong) NSArray<HSSStreamSpeedRatioConfig *> *stream_speed_ratio_config;

/// 是否上报流式完整URL（0-关闭 1-开启）
@property (nonatomic, assign) NSInteger streamReportFullUrl;

/// 是否使用新的安全加密方式（0-关闭 1-开启），默认开启
@property (nonatomic, assign) NSInteger useNewSecurityEncrypt;

/// 直连比价失败时， 丢弃缓存
@property (nonatomic, assign) BOOL bidFailDiscardCacheImmediately;

/// 上报客户端缓存的waterfall广告，比价失败的信息
@property (nonatomic, assign) BOOL reportCacheWFBidFailInfo;
/// track链接请求超时值
@property (nonatomic, assign) double tracker_upload_timeout;
/// 收集小banner加载成功信息
@property (nonatomic, copy) NSString *banner_collect_load_event;

/// 收集小banner白屏检测事件中携带 banner_html 的 dsp 名单
@property (nonatomic, copy) NSString *banner_collect_white_screen_event;

/// 是否开启vast解析失败降级
@property (nonatomic, assign) NSInteger vast_error_fallback;

/// 缓存降级等待预解析 wrapper 的最长秒数；同一轮降级只会进入一次等待。默认 3；设为 0 表示不超时（直至解析回调）
/// 可通过服务端 configure 字段 ad_cache_fallback_preparse_wait_sec 下发，或直接改 InnerSettings.shared
@property (nonatomic, assign) NSInteger ad_cache_fallback_preparse_wait_sec;

/// 收集小banner显示成功信息
@property (nonatomic, copy) NSString *banner_collect_show_event;
/// banner展示 N ms 后上报（0/负数表示使用默认值 1000ms；建议 100~10000ms）
@property (nonatomic, assign) NSInteger banner_collect_show_delay_ms;

/// 收集插屏显示 N ms 后上报（dsp名单：all 或用 "_" 分隔）
@property (nonatomic, copy) NSString *inter_collect_show_event;
/// 插屏展示 N ms 后上报（默认 1000ms）
@property (nonatomic, assign) NSInteger inter_collect_show_delay_ms;
/// 插屏 Banner（含双banner）展示 N ms 后上报（默认 1000ms）
@property (nonatomic, assign) NSInteger inter_banner_collect_show_delay_ms;

/// 收集激励显示 N ms 后上报（dsp名单：all 或用 "_" 分隔）
@property (nonatomic, copy) NSString *reward_collect_show_event;
/// 激励展示 N ms 后上报（默认 1000ms）
@property (nonatomic, assign) NSInteger reward_collect_show_delay_ms;

/// 服务端透传参数（与 configure 中 ext 一致；取出后可放入 getAd 请求的 ext 中）；未下发时为 nil
@property (nonatomic, copy, nullable) NSDictionary *ext;

/// 控制多缓存广告是否开启vast预解析
@property (nonatomic, assign) NSInteger enable_vast_pre_parse;

@property (nonatomic, assign) NSInteger vast_error_load_cache;

@property (nonatomic, assign) NSInteger download_error_load_cache;

@property (nonatomic, copy) NSString *forbiddenReportIfExpireList;
@property (nonatomic, assign) NSInteger new_vast_parse;

/// Banner 从 html_snippet 外链 script 解析 WebView baseURL（cfg: banner_snippet_script_base_url；1=开启）
@property (nonatomic, assign) NSInteger bannerSnippetScriptBaseURL;
/// 跨 pid 取缓存实验分组（cfg 字段 key 为 "0421_pid_cache"；"1"=开启跨 pid 取缓存，其它=不开启）
@property (nonatomic, copy) NSString *pid_cache_0421;
/// MRAID 广告关闭按钮是否展示（1=展示，0=不展示；默认 1）
@property (nonatomic, assign) NSInteger is_mraid_close_open;


/// 当前生效的重试间隔序列（永不为 nil，可能 count==0 表示不重试）
/// 有 configure 下发的 `trackRetryDelays` 则直接返回其拷贝；否则由 `impressionRetry` / `impressionRetryInterval` 推导（永不为 nil，count 可为 0）
- (NSArray<NSNumber *> *)hss_effectiveTrackRetryDelays;

@property (nonatomic, strong) HSSAdShowConfig *adShowConfig;

/// 视频播放x秒不算起播卡住
@property (nonatomic, assign) NSInteger video_time_reached;

@end

NS_ASSUME_NONNULL_END
