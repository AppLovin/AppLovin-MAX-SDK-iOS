//
//  HSSConfigureModel.h
//  HSADXSDK
//
//  Created by admin on 2024/11/26.
//

#import "HSSBaseModel.h"
#import "HSSAdFormat.h"

@class HSSStreamSpeedRatioConfig;

NS_ASSUME_NONNULL_BEGIN

@interface HSSStreamSpeedRatioConfig : HSSBaseModel
@property (nonatomic, assign) double min_speed_kb;
@property (nonatomic, assign) double target_ratio;
@end

/// ad_host  report host
@interface HSSHostsModel : HSSBaseModel

/// 国家
@property (nonatomic, copy) NSString *country;

/// 国家需要使用的host
@property (nonatomic, copy) NSString *host;

@end

/// 基础配置
@interface HSSBaseConfigureModel : HSSBaseModel

/// 配置的 host 集合
@property (nonatomic, strong)  NSArray<HSSHostsModel *> *ad_hosts;

/// 配置事件的 host 集合
@property (nonatomic, strong)  NSArray<HSSHostsModel *> *even_hosts;

/// 请求超时事件
@property (nonatomic, assign) NSInteger ad_req_timeout;

@end

/// 广告位信息
@interface HSSPlacementModel : HSSBaseModel

/// 广告位 id
@property (nonatomic, copy) NSString *placement_id;

/// 广告类型
@property (nonatomic, assign) HSSAdFormatType ad_type;

///重试次数
@property (nonatomic, assign) NSInteger ad_retry;

///重试间隔 ms
@property (nonatomic, assign) NSInteger ad_retry_interval;

@end

@interface HSSEventModel : HSSBaseModel

/// 事件名称
@property (nonatomic, copy) NSString *event_id;

/// 事件上报状态 1.开启上报  0.关闭
@property (nonatomic, assign) NSInteger status;

/// 采样率
@property (nonatomic, assign) NSInteger sampling_rate;

@end

/// 上报配置参数
@interface HSSReportModel : HSSBaseModel

@property (nonatomic, assign) NSInteger is_report;
@property (nonatomic, strong) NSArray<HSSEventModel *> *events;

@end

/// app信息
@interface HSSInstallInfoModel : HSSBaseModel

///  bundle id
@property (nonatomic, copy) NSString *pkgName;

/// URL scheme
@property (nonatomic, copy) NSString *scheme;

@end

/// app 安装嗅探配置
@interface HSSInstallInfoConfigModel : HSSBaseModel
// 冷启动delay
@property (nonatomic, assign) NSInteger launch_delay;
// 每次嗅探数量
@property (nonatomic, assign) NSInteger per_act_quota;
// 每次嗅探间隔时间
@property (nonatomic, assign) NSInteger per_act_delay;
// 每轮嗅探间隔时间
@property (nonatomic, assign) NSInteger per_s_quota;

@end

@interface HSSConfigureModel : HSSBaseModel

/// 国家
@property (nonatomic, copy) NSString *country;

/// 该国家基础配置
@property (nonatomic, strong) HSSBaseConfigureModel *base;

/// 上报配置
@property (nonatomic, strong) HSSReportModel *report;

/// install_info_config 安装嗅探配置
@property (nonatomic, strong) HSSInstallInfoConfigModel *ii_c;

/// 广告位配置
@property (nonatomic, strong) NSArray<HSSPlacementModel *> *placements;

/// app配置
@property (nonatomic, strong) NSArray<HSSInstallInfoModel *> *installInfos;

///广告曝光链接请求重试次数
@property (nonatomic, assign) NSInteger impressionRetry;

///广告曝光链接请求重试间隔时间
@property (nonatomic, assign) NSInteger impressionRetryInterval;

/// 监测 / 上报类 GET 重试间隔数组（configure 优先 `track_retry_delays`，兼容 `report_retry_delays`、`impression_retry_delays`；与 HSSInnerSettings.trackRetryDelays 同名）
@property (nonatomic, copy, nullable) NSArray *trackRetryDelays;

/// MMKV 本地上报最大重试次数
@property (nonatomic, assign) NSInteger mmkv_report_max_retry;

/// adx崩溃上报开关
@property (nonatomic, assign) NSInteger crash_switch;

/// 是否禁止本地存储的链接进行上报 (默认不禁止)
@property (nonatomic, assign) BOOL isForbidReport;

// 控制vast wrapper 重定向请求 使用post还是get请求 默认0是get 下发1用post请求
@property (nonatomic, assign) NSInteger isVastWrapperReqPost;

// 控制触摸追踪功能开关 默认1是开启 下发0关闭
@property (nonatomic, assign) NSInteger enableTouchTracking;

// 控制RSA公钥获取方式 默认1是开启新逻辑(SecKeyCreateWithData) 下发0使用旧逻辑(Keychain方式)
@property (nonatomic, assign) NSInteger rsaKeyOptimizationEnabled;

/// 图片监控总开关，YES: 启用新逻辑（监控+降采样），NO: 走旧逻辑
@property (nonatomic, assign) BOOL enableImageMonitor;

/// 上报阈值（单位：MB）
@property (nonatomic, assign) NSInteger maxImageSize;

/// 降采样阈值（单位：MB），超过此阈值开始降采样
@property (nonatomic, assign) NSInteger imageDownsamplingThreshold;

/// 降采样目标尺寸（单位：像素，最长边），超过此尺寸的图片会被降采样到此尺寸
@property (nonatomic, assign) NSInteger imageDownsamplingMaxPixelSize;

/// 文件读到内存中的拦截大小，默认0，不拦截，否则直接拦截，不读取
@property (nonatomic, assign) NSInteger largeFileSize;

/// 控制ActionRouter是否走新逻辑
@property (nonatomic, assign) NSInteger actionRouterNew;

@property (nonatomic, assign) NSInteger backgroundTaskEnable;

/// 白屏采样率 默认30%
@property (nonatomic, assign) NSInteger ws_sampling_rate;

/// 是否上报流式完整URL（0-关闭 1-开启）
@property (nonatomic, assign) NSInteger streamReportFullUrl;

/// 是否使用新的安全加密方式（0-关闭 1-开启），默认开启
@property (nonatomic, assign) NSInteger useNewSecurityEncrypt;

///  白屏像素阀值 超过这个阀值就认为是白屏
@property (nonatomic, assign) NSInteger white_screen_threshold;

/// 白屏延迟多长时间检测
@property (nonatomic, assign) double ws_detect_delay;

/// 插屏 banner 白屏延迟多长时间检测
@property (nonatomic, assign) double inter_banner_ws_detect_delay;

/// 是否关闭omsdk监测，默认为false
@property (nonatomic, assign) BOOL omsdk_closed;

/// omidScript的地址(服务器存储在cdn上)
@property (nonatomic, copy) NSString *omid_js_url;

@property (nonatomic, assign) NSInteger vastMediaRuleResolution;
@property (nonatomic, assign) NSInteger vast_video_score_resolution_weight;

@property (nonatomic, assign) BOOL mraid_main_frame_only;
@property (nonatomic, assign) BOOL show_h5_progress;

@property (nonatomic, assign) NSInteger t_imp_report_ip;
@property (nonatomic, copy) NSDictionary *record_show_ecpm_config;


@property (nonatomic, assign) NSInteger enable_stream_player;
@property (nonatomic, assign) NSInteger enable_stream_resume;

@property (nonatomic, copy) NSArray<HSSStreamSpeedRatioConfig *> *stream_speed_ratio_config;
/// 直连比价失败时， 丢弃缓存
@property (nonatomic, assign) BOOL bidFailDiscardCacheImmediately;
/// 上报客户端缓存的waterfall广告，比价失败的信息
@property (nonatomic, assign) BOOL reportCacheWFBidFailInfo;
/// track链接请求超时值
@property (nonatomic, assign) double tracker_upload_timeout;
/// 缓存降级等待预解析的最长秒数（0=不超时）；未下发时端上默认 5
@property (nonatomic, assign) NSInteger ad_cache_fallback_preparse_wait_sec;
/// 收集小banner加载成功信息
@property (nonatomic, copy) NSString *banner_collect_load_event;

/// 收集小banner白屏检测事件中携带 banner_html 的 dsp 名单
@property (nonatomic, copy) NSString *banner_collect_white_screen_event;

/// 收集小banner显示成功信息（dsp名单：all 或用 "," 分隔）
@property (nonatomic, copy) NSString *banner_collect_show_event;
/// banner展示 N ms 后上报（默认 1000ms）
@property (nonatomic, assign) NSInteger banner_collect_show_delay_ms;
/// 收集插屏显示 N ms 后上报（dsp名单：all 或用 "," 分隔）
@property (nonatomic, copy) NSString *inter_collect_show_event;
/// 插屏展示 N ms 后上报（默认 2000ms）
@property (nonatomic, assign) NSInteger inter_collect_show_delay_ms;
/// 插屏 Banner（含双banner）展示 N ms 后上报（默认 2000ms）
@property (nonatomic, assign) NSInteger inter_banner_collect_show_delay_ms;
/// 收集激励显示 N ms 后上报（dsp名单：all 或用 "," 分隔）
@property (nonatomic, copy) NSString *reward_collect_show_event;
/// 激励展示 N ms 后上报（默认 2000ms）
@property (nonatomic, assign) NSInteger reward_collect_show_delay_ms;
/// 服务端透传参数（取出后放入 getAd 请求的 ext 中）；未下发时为 nil
@property (nonatomic, copy, nullable) NSDictionary *ext;

/// 控制多缓存广告是否开启vast预解析
@property (nonatomic, assign) NSInteger enable_vast_pre_parse;

@property (nonatomic, assign) NSInteger vast_error_load_cache;

@property (nonatomic, assign) NSInteger download_error_load_cache;

@property (nonatomic, copy) NSString *forbiddenReportIfExpireList;
@property (nonatomic, assign) NSInteger new_vast_parse;

/// Banner html_snippet 是否从外链 script src 解析 loadHTMLString 的 baseURL（1=开启，0=保持 nil；默认 0）
@property (nonatomic, assign) NSInteger bannerSnippetScriptBaseURL;
/// 跨 pid 取缓存实验分组（cfg 字段 key 为 "0421_pid_cache"；"1"=开启跨 pid 取缓存，其它=不开启）
@property (nonatomic, copy) NSString *pid_cache_0421;
/// MRAID 广告关闭按钮是否展示（1=展示，0=不展示；默认 1）
@property (nonatomic, assign) NSInteger is_mraid_close_open;
/// 只有adx参与竞价时的控制逻辑
@property (nonatomic, copy) NSDictionary *only_adx_bid;

/// 视频播放x秒不算起播卡住
@property (nonatomic, assign) NSInteger video_time_reached;
@end

NS_ASSUME_NONNULL_END
