//
//  HSSCreativeItemModel.h
//  HSADXSDK
//
//  Created by admin on 2024/11/26.
//

#import "HSSBaseModel.h"
#import <HSADXSDK/HSSAdFormat.h>

@class HSSCreativeExtModel;
@class HSSVastAdModel;
@class HSSVastCreativeAdModel;
@class HSSPlayableModel;
@class HSSPlayUniTmplModel;
@class HSSItemDoubleECModel;
@class HSSAdxUniTmplModel;
@class HSSControlBtnModel;
@class HSSTmplInfo;
@class HSSAdInfo;

typedef void(^HSSVastAdsBuilderParseCompletionBlock)(NSString *_Nullable vastXml, NSError *_Nullable error);

typedef void(^HSSNewVastAdsBuilderParseCompletionBlock)(NSString *_Nullable vastXml, NSString *_Nullable vastTypeStr, NSError *_Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface HSSItemImageModel : HSSBaseModel

/// 图片地址
@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *btnTxt;

/// 图片宽 px
@property (nonatomic, assign) NSInteger width;

/// 图片高 px
@property (nonatomic, assign) NSInteger height;


@property (nonatomic, assign) BOOL isAdxUniTmp;

/// 是否开启可点热区
@property (nonatomic, assign) NSInteger clickable_area_pct;

/// 关闭按钮延迟显示， 0表示不延时 单位秒
@property (nonatomic, assign) NSInteger close_delay;

@property (nonatomic, strong) HSSControlBtnModel *controlBtn;

@end

@interface HSSItemDoubleECModel :HSSBaseModel

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *btn_txt;

@end

@interface HSSItemVideoModel : HSSBaseModel

/// 视频地址
@property (nonatomic, copy) NSString *url;

/// 视频宽 px
@property (nonatomic, assign) NSInteger width;

/// 视频高 px
@property (nonatomic, assign) NSInteger height;

/// ec降级样式模板 空或0：默认样式 1：展示视屏截图样式
@property (nonatomic, assign) NSInteger ec_fallback_tmpl;

/// 是否强制使用兜底 ec，0否1是
@property (nonatomic, assign) NSInteger ec_fallback_force;

/// EndCard CTA 按钮 Lottie 动效类型，如 neon、glowing_border
@property (nonatomic, copy) NSString *ec_cta_lottie;

/// vast xml
@property (nonatomic, strong) HSSVastCreativeAdModel *vast;

@property (nonatomic, strong) HSSItemDoubleECModel *doubleEC;

/// 以下手动添加
@property (nonatomic, copy) NSArray *videoUrls;

/// 记录 vast 解析失败信息,保存原始数据, 成功该属性 nil
@property (nonatomic, copy) NSString *failureVastXml;

/// 记录  vast  inline 解析失败error信息, 成功该属性 nil
@property (nonatomic, strong) NSError * error;
/// 记录 vast 解析失败的错误对象
@property (nonatomic, strong) NSError *failureVastError;

/// vast 解析结果的回调 （里面可能涉及到重定向）
@property (nonatomic, copy) HSSVastAdsBuilderParseCompletionBlock parseCompletionBlock;

/// vast 解析结果的回调 （里面可能涉及到重定向）
@property (nonatomic, copy) HSSNewVastAdsBuilderParseCompletionBlock newParseCompletionBlock;

@property (nonatomic, copy) NSString *vastXml;

/// 设置vast_type：Inline or Wrapper
@property (nonatomic, copy) NSString *vastTypeString;

/// 手动开始vast解析
- (void)beginParseVast;

-(BOOL)isValidVast;
@end

@interface HSSBannerModel : HSSBaseModel
/// banner html_snippet 内容，type = 1 时取此值
@property (nonatomic, copy) NSString *htmlSnippet;

/// Banner Type
@property (nonatomic, assign) HSSAdBannerType type;

/// 视Banner宽 px
@property (nonatomic, assign) NSInteger width;

/// Banner高 px
@property (nonatomic, assign) NSInteger height;

/// is_transform
@property (nonatomic, assign) NSInteger is_transform;

/// Banner 是否有效
- (BOOL)isValidBanner;

@end


/// 展示监测链接存在性（3bit 位图）：adx / adm / burl
typedef NS_OPTIONS(NSUInteger, HSSAdImpressionTrackLinkMask) {
    HSSAdImpressionTrackLinkMaskNone = 0,
    /// adx 展示追踪（`impression_urls`）
    HSSAdImpressionTrackLinkMaskAdx  = 1 << 0,
    /// adm 展示追踪（`admImpressionUrls`）
    HSSAdImpressionTrackLinkMaskAdm  = 1 << 1,
    /// burl billing notification（`burls`）
    HSSAdImpressionTrackLinkMaskBurl = 1 << 2,
};

@interface HSSCreativeItemModel : HSSBaseModel

@property (nonatomic, assign, readonly) BOOL loadDone;

/// 广告 id
@property (nonatomic, copy) NSString *a_id;

/// 第三方广告广告 id
@property (nonatomic, copy) NSString *tagId;

/// 标题
@property (nonatomic, copy) NSString *title;

/// 描述
@property (nonatomic, copy) NSString *desc;

/// 素材类型:1. 图文 2. 原生视频 3. VAST 4. MRAID 5. HTML
@property (nonatomic, assign) HSSAdMaterialType material_type;

/// 透传 dsp的crid,素材 id
@property (nonatomic, copy) NSString *crid;

/// 透传dsp的domain，域名
@property (nonatomic, copy) NSString *domain;

/// 透传dsp的bundled_id，包名
@property (nonatomic, copy) NSString *dsp_bundle_id;

/// 小图
@property (nonatomic, strong) HSSItemImageModel *icon;

/// 大图
@property (nonatomic, strong) NSArray <HSSItemImageModel *> *images;

/// 视频
@property (nonatomic, strong) HSSItemVideoModel *video;

/// 试玩
@property (nonatomic, strong) HSSPlayableModel *playable;

/// 试玩uniTmpl
@property (nonatomic, strong) HSSPlayUniTmplModel *uniTmpl;

/// adx uniTmpl
@property (nonatomic, strong) HSSAdxUniTmplModel *adxUniTmpl;

#pragma mark - 模版2.0 新架构字段（仅在服务端下发 tmpl / ad 时有值）

/// 模板版本（服务端下发 tmpl_version 字段）
///   1 = 模版 2.0（素材从 adInfo 取；视频/试玩走新 ModularVC，banner 走老 BannerVC + 归一化）
///   0 / 缺省 = 1.0（老逻辑）
@property (nonatomic, assign) NSInteger tmplVersion;

/// 模板 2.0 模板配置信息（服务端下发 tmpl 字段）
@property (nonatomic, strong, nullable) HSSTmplInfo *tmplInfo;

/// 模板 2.0 广告素材信息（服务端下发 ad 字段）
@property (nonatomic, strong, nullable) HSSAdInfo *adInfo;

/// banner
@property (nonatomic, strong) HSSBannerModel *banner;

/// MRAID或者HTML素材
@property (nonatomic, copy) NSString *web_html;

/// dsp名称networkname
@property (nonatomic, copy) NSString *dsp_name;

/// dsp名称 服务端 * 1e6
@property (nonatomic, assign) double bid_price;

///// 只给交叉推广广告使用的ecpm ，dsp广告禁用
//@property (nonatomic, assign) double ecpm;

/// 过期时间，单位：分钟
@property (nonatomic, assign) NSInteger expired_interval;

/// deeplink跳转地址
@property (nonatomic, copy) NSString *deeplink_url;

/// 落地页地址
@property (nonatomic, copy) NSString *landing_url;

/// 打开目标app名称
@property (nonatomic, copy) NSString *open_app;


@property (nonatomic, copy) NSString *open_app_id;

@property (nonatomic, copy) NSString *open_app_scheme;

/// 展示追踪链接
@property (nonatomic, strong) NSArray<NSString *> *impression_urls;

/// billing notification URL
@property (nonatomic, strong) NSArray<NSString *> *burls;

/// adm 展示追踪链接
@property (nonatomic, strong) NSArray<NSString *> *admImpressionUrls;

/// 点击追踪链接
@property (nonatomic, strong) NSArray<NSString *> *click_urls;

/// win notification URL
@property (nonatomic, strong) NSArray<NSString *> *nurls;

/// loss notification URL
@property (nonatomic, strong) NSArray<NSString *> *lurls;

/// 计算展示监测链接存在性位图（0~7）
- (HSSAdImpressionTrackLinkMask)hssadx_impressionTrackLinkMask;

/// 把 self.video.vast.trackingURLs 里的 impression / clickTracking 回填到 admImpressionUrls / click_urls
- (void)mergeAdmImpressionAndClickUrlsFromVideoVast;

/// 扩展字段
@property (nonatomic, strong) HSSCreativeExtModel *ext;

/// 是否是内推广告  0：否 1：是
@property (nonatomic, assign) NSInteger isCrossAd;

/// 素材是否为全屏点击。0: 否（默认），1：是
@property (nonatomic, assign) NSInteger isFSClick;

/// 素材是否是离线广告。 0：否 1：是
@property (nonatomic, assign) NSInteger isOfflineAd;

/// 离线广告是否下载成功
@property (nonatomic, assign) NSInteger isOfflineAdDone;

@property (nonatomic, assign) NSTimeInterval itemCreateTime;
@property (nonatomic, assign) NSTimeInterval itemLoadTime;

// 广告请求返回的素材是否自adapter请求返回的素材
@property (nonatomic, assign) BOOL fromAdapter;

// 仅插屏banner使用 判断banner的html是否加载成功
@property (nonatomic, assign) BOOL bannerDone;

@property (nonatomic, assign) NSInteger displayCount;

@property (nonatomic, assign) BOOL isLocal;

/// 是否支持内置浏览器打开     ● 0：使用外部浏览器打开 - 客户端默认，● 1：使用内置浏览器打开。服务端当前保持默认0，后续根据不同的广告按需下发不同的打开方式
@property (nonatomic, assign) NSInteger web_type;

/// 使用内置浏览器打开landing_url跳转以后，是否自动关闭Webview
@property (nonatomic, assign) NSInteger web_inner_close;

/// 本地使用，用来判断VAST点击的是素材还是EndCard
@property (nonatomic, copy, nullable) NSString *vastClickURL;
@property (nonatomic, copy, nullable) NSString *vast_type;

@property (nonatomic, assign) BOOL isFirst;

/// 该素材是否需要预加载
@property (nonatomic, assign) BOOL not_preload;

/// 该素材是否取自缓存
@property (nonatomic, assign) BOOL is_from_cache;

/// 比价缓存行主键，回写 hss_vast_resolved 至 MMKV 时使用（HSSAdCacheCompareModule 注入）
@property (nonatomic, copy, nullable) NSString *hss_lock_token;

// 当前广告关联的来自max的adUnitId;
@property (nonatomic, copy) NSString *associateMaxAdUnitId;

/// 透传的埋点字段
@property (nonatomic, copy) NSDictionary *c_log;

/// 对外真实ecpm
@property (nonatomic, assign) double realEcpm;

// 展示时的竞价环境信息
@property (nonatomic, copy, nullable) NSArray<NSDictionary *> *bidContext;

/// item 是否有效
-(BOOL)isItemValid;

/// 是否准备好了
-(BOOL)isReady;

/// 是否过期
- (BOOL)isItemExpired;

///  下载素材资源
/// - Parameter sucess: YES 完成  NO 至少有一个失败
- (void)loadMaterial:(void (^)(BOOL done))sucess;

- (void)streamLoadDone;

@end

NS_ASSUME_NONNULL_END
