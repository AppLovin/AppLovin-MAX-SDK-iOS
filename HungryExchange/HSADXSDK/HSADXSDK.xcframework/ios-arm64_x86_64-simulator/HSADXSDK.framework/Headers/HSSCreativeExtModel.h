//
//  HSSCreativeExtModel.h
//  HSADXSDK
//
//  Created by admin on 2024/11/26.
//

#import "HSSBaseModel.h"

@class HSSSkadnModel;
@class HSSSKOverlayAdModel;
@class HSSSKAutoStoreModel;

NS_ASSUME_NONNULL_BEGIN


@interface HSSInstlTmplCfgModel : HSSBaseModel

/// 首次点击关闭模式
/// 0 文字触发点击，仅 x 可关闭
/// 1 文字 + x 均可关闭
/// 默认 0
@property (nonatomic, assign) NSInteger fc_close_mode;
/// video 右下角 cta 按钮动效
@property (nonatomic, copy) NSString *video_cta_lottie;

@end

@interface HSSRewardTmplCfgModel : HSSBaseModel

/// video 右下角 cta 按钮动效
@property (nonatomic, copy) NSString *video_cta_lottie;

@end

@interface HSSWebviewOverlay :HSSBaseModel
@property (nonatomic, assign) NSInteger enabled;
@property (nonatomic, assign) NSInteger delay;
@property (nonatomic, assign) NSInteger click;
@property (nonatomic, copy) NSString *landing_url;
@end

@interface HSSBtfAutoClose :HSSBaseModel
// 是否开启 btf_auto_close， 0否 1是
@property (nonatomic, assign) NSInteger enabled;
// 外部停留时间间隔阈值，大于此阈值触发自动关闭，单位 ms
@property (nonatomic, assign) NSInteger stay_interval_throttle;
@end

@interface HSSHDspAdInfo :HSSBaseModel
@property (nonatomic, copy) NSString *camp_name;
@property (nonatomic, copy) NSString *campaign_id;
@property (nonatomic, copy) NSString *adset_id;
@property (nonatomic, copy) NSString *bls_finish_url;
@end

@interface HSSCreativeExtModel : HSSBaseModel

/// 广告播放模板id，包含：图文插屏、视频插屏、激励视频
@property (nonatomic, assign) NSInteger display_tmpl;

/// 视频结束页Endcard模板id
@property (nonatomic, assign) NSInteger endcard_tmpl;

/// 是否首段点击跳过时触发点击事件（商店 or 浏览器 or dp）0否 1是
@property (nonatomic, assign) NSInteger is_skip_open;

/// is_skip_open = 1时，跳过按钮文案 客户端兜底：Open Now
@property (nonatomic, copy) NSString *skip_open_btn_txt;

/// 广告可跳过时长，0表示可直接跳过 单位秒
@property (nonatomic, assign) NSInteger play_skip_duration;

/// 激励视频激励达成时间（达到时长，可关闭或者跳过）
@property (nonatomic, assign) NSInteger rewarded_mix_play;

/// 关闭按钮延迟显示， 0表示不延时 单位秒
@property (nonatomic, assign) NSInteger close_delay;

/// 视频播放静音设置，0-不静音，1-静音播放。
@property (nonatomic, assign) NSInteger video_mute;

/// 按钮文案，默认：view more
@property (nonatomic, copy) NSString *btn;

/// 额外需要曝光的信息
@property (nonatomic, copy) NSString *ext_info;

/// 最大竞价次数，默认3次
@property (nonatomic, assign) NSInteger max_bid_cnt;

/// 默认为0，不进行loss宏替换
@property (nonatomic, assign) NSInteger enable_loss_macro_rep;

/// 对于通过skadn校验的请求，下发skadn物料
@property (nonatomic, strong) HSSSkadnModel *skadn;

/// skoverlay
@property (nonatomic, strong) HSSSKOverlayAdModel *skoverlay;

/// autoStore
@property (nonatomic, strong) HSSSKAutoStoreModel *autoStore;

/// 【交叉推广】广告计划id  端上埋点使用
@property (nonatomic, copy) NSString *campaignId;

/// 活动  Name
@property (nonatomic, copy) NSString *campaignName;

/// 交叉推广归因所需参数
@property (nonatomic, strong) NSDictionary *crossParams;

/// 交叉推广appid
@property (nonatomic, copy) NSString *appid;

/// 1支持走af归因   0走af内推归因
@property (nonatomic, assign) NSInteger isMMPAttr;

/// OM三方验证脚本信息
@property (nonatomic, assign) BOOL omsdk_enabled;
@property (nonatomic, assign) BOOL omsdk_js_injection;
@property (nonatomic, copy) NSString *omsdk_native_vendorKey;
@property (nonatomic, copy) NSString *omsdk_native_script;
@property (nonatomic, copy) NSString *omsdk_native_param;

/// adx 模版id
@property (nonatomic, assign) NSInteger adx_tmpl_id;

/// 跳过按钮大小，没有则取客户端默认值
@property (nonatomic, assign) NSInteger skip_btn_size;

/// 关闭按钮大小，没有则取客户端默认值
@property (nonatomic, assign) NSInteger close_btn_size;

/// 跳过按钮外边距，没有则取客户端默认值
@property (nonatomic, assign) NSInteger skip_btn_margin;

/// 关闭按钮外边距，没有则取客户端默认值
@property (nonatomic, assign) NSInteger close_btn_margin;

/// 是否显示倒计时控件 0-不展示，1-展示 （仅插屏使用）
@property (nonatomic, assign) NSInteger show_count_down_tip;

/// 倒计时组件样式 1：1s   2:  广告在1s后可跳过
@property (nonatomic, assign) NSInteger show_count_tip_style;

/// 白屏检测开关， 0关 1开
@property (nonatomic, assign) NSInteger is_ws_check;

/// 白屏截图上传开关， 0关 1开
@property (nonatomic, assign) NSInteger ws_screen_upload;

/// banner 是否需要预加载
/// 1 = 预加载（webView 加载完成再回调 didLoadBannerAd，现状）
/// 0 = 不预加载（fill 后立即回调 didLoadBannerAd，业务直接展示，webView 异步加载）
/// server 未下发时端内默认 1（维持现状，灰度安全 fallback）
@property (nonatomic, assign) NSInteger is_banner_need_preload;

/// banner 真创意尺寸测量实验开关（事件驱动的"真内容媒体元素区间"测量 + y 偏移修正 + 区间内往返滚动）
/// 1 = 走新逻辑；0 或未下发 = 走旧逻辑（scrollHeight 测量 + 单向滚动，维持现状，灰度安全 fallback）
@property (nonatomic, assign) NSInteger banner_creative_measure_exp;

/// 素材 id 黑名单
@property (nonatomic, copy) NSArray <NSString *>*crid_blacklist;

/// cta_ec 样式，0默认， 1带关闭ec
@property (nonatomic, assign) NSInteger cta_ec_style;

/// banner webview baseurl 值
@property (nonatomic, copy) NSString *webview_base_url;

/// 插屏 banner 样式模板  0默认模板
@property (nonatomic, assign) NSInteger instl_banner_tmpl;

/// 插屏 video 样式模板  0默认模板  1底部进度条新UI
@property (nonatomic, assign) NSInteger instl_video_tmpl;

@property (nonatomic, assign) NSInteger vast_mf_rule;

/// 插屏 banner 样式模板  关闭按钮首次点击是否全部可点击
@property (nonatomic, strong) HSSInstlTmplCfgModel *instl_tmpl_cfg;

@property (nonatomic, strong) HSSRewardTmplCfgModel *reward_tmpl_cfg;

/// deeplink跳转结果上报，统计app安装结果
@property (nonatomic, copy) NSString *app_install_url;

/// 激励 video 样式模板  0默认模板
@property (nonatomic, assign) NSInteger reward_video_tmpl;

/// webview_overlay
@property (nonatomic, strong) HSSWebviewOverlay *webview_overlay;

@property (nonatomic, strong) HSSBtfAutoClose *btf_auto_close;

@property (nonatomic, strong) HSSHDspAdInfo *hdspAdInfo;

/// 是否开启vast解析失败后降级
@property (nonatomic, assign) NSInteger vast_error_fallback;

/// 直客策略调整
@property (nonatomic, assign) BOOL dynamic_bid_scene1_enable;
@property (nonatomic, assign) BOOL dynamic_bid_scene2_enable;
@property (nonatomic, assign) double dynamic_bid_inc;

@end

NS_ASSUME_NONNULL_END
