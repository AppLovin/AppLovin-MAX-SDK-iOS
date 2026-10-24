//
//  HSSMaterialItem.h
//  HSADXSDK
//
//  Created by 张松
//

#import "HSSBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 素材类型枚举（与 tmpl.segments.type 对齐，用于 material.type 字段）
extern NSString *const HSSMaterialTypeVideo;         // "video"
extern NSString *const HSSMaterialTypePlayable;      // "playable"
extern NSString *const HSSMaterialTypeEndCard;       // "end_card"（文字型：title/desc/icon_url）
extern NSString *const HSSMaterialTypeEndCardImage;  // "end_card_image"（图片型：url）
extern NSString *const HSSMaterialTypeBanner;        // 服务端下发值: "html"（常量名保留 Banner 语义；OC 类继续用 HSSMaterialBanner）
extern NSString *const HSSMaterialTypeNative;        // "native"

#pragma mark - 素材基类

@interface HSSMaterialItem : HSSBaseModel

/// 素材类型标识（与 segment.type 完全一致）
@property (nonatomic, copy) NSString *type;

+ (nullable HSSMaterialItem *)materialWithDictionary:(NSDictionary *)dict;

/// 素材最小有效性校验（关键字段非空即有效）
/// 基类默认 NO，子类按自身关键字段覆盖
/// 供 HSSCreativeItemModel.isItemValid 在 2.0 场景下做候选过滤用
- (BOOL)isValidMaterial;

@end

@class HSSVastCreativeAdModel;
@class HSSStreamVideoLoader;
@class HSSEndCardWebViewHost;
@class WKWebView;

#pragma mark - MaterialVideo

@interface HSSMaterialVideo : HSSMaterialItem

/// 视频直链 URL
@property (nonatomic, copy, nullable) NSString *url;

/// VAST XML 数据
@property (nonatomic, copy, nullable) NSString *data;

/// 视频段配套图标资源 URL（服务端下发；框架层仅解析，由组件层按需读取使用）
/// JSON key: "icon_url"
@property (nonatomic, copy, nullable) NSString *iconUrl;

/// 视频段配套按钮文案（服务端下发；框架层仅解析，由组件层按需读取使用）
/// JSON key: "btn"
@property (nonatomic, copy, nullable) NSString *btn;

@property (nonatomic, assign) NSInteger btnSource;


@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *desc;

/// VAST 解析后的结果（由 Coordinator 在 load 阶段填入）
@property (nonatomic, strong, nullable) HSSVastCreativeAdModel *vast;

/// VAST 类型（"Inline" / "Wrapper" / ""），解析时由 XML 字符串匹配得出
/// 用于埋点 vast_type 字段及 Wrapper 的特殊处理逻辑
@property (nonatomic, copy, nullable) NSString *vastType;

/// 端侧产物：load 阶段预加载的流式下载器（由 Coordinator 写入）
/// HSSVideoMedia 优先复用此对象，未命中时再自行创建
@property (nonatomic, strong, nullable) HSSStreamVideoLoader *preloadedStreamLoader;

/// 是否走 VAST 流程（Coordinator 用来做业务分流：VAST 路径 vs 直链路径）
/// YES：命中预解析（vast.videoFileURL 非空）或存在 VAST XML（data 非空）
/// 注：本方法是"业务流程分流"判断，包含"已解析"和"待解析"两种状态。
/// 仅判断"VAST 是否已 resolved 可用"请改用 hasResolvedVast。
- (BOOL)hasVast;

/// VAST 是否已解析为可用产物（vast.videoFileURL 非空）。
/// 与 hasVast 的区别：
///   hasVast        = "原本是 VAST 形式 OR 已 resolved"（业务流程分流用）
///   hasResolvedVast = "VAST 已解析可用"（命中预解析判断 / 跳过现场解析判断用）
/// 4 状态语义表：
///   直链视频          (data="", vast.videoFileURL="")    → hasVast=NO,  hasResolvedVast=NO
///   VAST 未解析       (data="<XML>", vast.videoFileURL="") → hasVast=YES, hasResolvedVast=NO
///   VAST 已解析       (data="<XML>", vast.videoFileURL=URL) → hasVast=YES, hasResolvedVast=YES
///   VAST 解析失败兜底 (data="<XML>", vast 为空对象)         → hasVast=YES, hasResolvedVast=NO
- (BOOL)hasResolvedVast;

@end

#pragma mark - MaterialPlayable

@interface HSSMaterialPlayable : HSSMaterialItem

/// 试玩 H5 URL
@property (nonatomic, copy) NSString *url;

/// 端侧产物：load 阶段下载到本地的文件路径（由 Coordinator 写入）
/// 命中后 HSSWebViewMedia 优先 loadFileURL: 加载（而非走 URL 远端加载）
@property (nonatomic, copy, nullable) NSString *localFilePath;

/// 端侧产物：load 阶段预加载的 WKWebView（由 Coordinator 写入）
/// 已注入 Playable JS 桥（open / event / BLS）；HSSWebViewMedia 直接复用此对象
@property (nonatomic, strong, nullable) WKWebView *preloadedWebView;

//0,未知； 1,有自动跳转能力；2,无自动跳转能力
@property (nonatomic, assign) NSInteger auto_jump;

@end

#pragma mark - MaterialEndCardBase

/// EndCard 素材基类：承载图片型与文字型 endcard 的公共字段（vast 回填），
/// 便于 Coordinator / MaterialProvider 统一识别"这是一个 endcard 素材"。
@interface HSSMaterialEndCardBase : HSSMaterialItem

/// VAST 解析结果（由 Coordinator 在 load 阶段从同序号视频 material 回填）
/// 服务端不下发 VAST companion 数据；VAST 场景下图片/文字信息均从这里取
@property (nonatomic, strong, nullable) HSSVastCreativeAdModel *vast;

/// 端侧产物：load 阶段预加载的 EndCard WebView 宿主（由 Coordinator 写入）
/// 仅 VAST companion 为 HTML/IFrame 类型时填入；HSSEndCardMedia 展示时直接复用
/// Host 从创建起即持有 webview 并作为 delegate，全生命周期不换 delegate（与 1.0 同构）
@property (nonatomic, strong, nullable) HSSEndCardWebViewHost *preloadedWebViewHost;

@end

#pragma mark - MaterialEndCardImage（图片型）

/// 图片型 endcard：一张大图铺满主体（url 来自服务端下发，或 VAST companion.url）
@interface HSSMaterialEndCardImage : HSSMaterialEndCardBase

/// EndCard 图片 URL
@property (nonatomic, copy, nullable) NSString *url;

/// url 文案的来源（page_view 契约 img source 取值）：
///   1 = 服务端下发（dict[@"url"] 有值）
///   0 = 服务端未下发（VAST companion 来源由渲染层决定，标 source=2）
@property (nonatomic, assign) NSInteger urlSource;

/// 按钮文案（服务端下发，缺失时客户端兜底为 HSSLocalizedString(@"ViewTips")）
@property (nonatomic, copy, nullable) NSString *btn;

/// btn 文案的来源（page_view 契约 cta_text source 取值）：
///   1 = 服务端下发（btn_text 字段有值）
///   3 = 客户端 default 兜底（HSSLocalizedString @"ViewTips"）
/// 装配时由 init 填好，组件层（HSSFullScreenImageEndCardView 等）pageViewElements 直接读
@property (nonatomic, assign) NSInteger btnSource;

@end

#pragma mark - MaterialEndCard（文字型）

/// 文字型 endcard：icon / title / description 由独立组件按 segment 布局拼装
@interface HSSMaterialEndCard : HSSMaterialEndCardBase

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *desc;
@property (nonatomic, copy, nullable) NSString *iconUrl;
/// 视频段配套按钮文案（服务端下发，缺失时客户端兜底为 HSSLocalizedString(@"ViewTips")）
/// JSON key: "btn"
@property (nonatomic, copy, nullable) NSString *btn;

#pragma mark - PageView source 自描述（装配阶段填 1/3，VAST 来源由渲染层标 2）
/// 各字段的来源（page_view 契约 source 取值）：
///   - title/desc/iconUrl/btn：1=服务端下发 / 0=未下发（btn 例外：3=客户端 default 兜底）
/// 装配阶段由 init 按"服务端有值=1，无值=0/3"填好；VAST 解析后若被渲染层选用，渲染层标 source=2
@property (nonatomic, assign) NSInteger titleSource;
@property (nonatomic, assign) NSInteger descSource;
@property (nonatomic, assign) NSInteger iconUrlSource;
@property (nonatomic, assign) NSInteger btnSource;

@end

#pragma mark - MaterialHTML

@interface HSSMaterialHTML : HSSMaterialItem

/// HTML 内容（Banner 等）
@property (nonatomic, copy) NSString *data;

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

/// 1 需要客户端做变换适配；0 不做
@property (nonatomic, assign) NSInteger isTransform;

@end

#pragma mark - MaterialBanner（2.0 段化 banner 段素材）

/// 与 HSSMaterialHTML 字段集一致（data/width/height/isTransform），新增端侧预加载产物字段。
/// 1.0 老协议 banner（material_type=6）继续走 HSSMaterialHTML（不改 1.0 行为）；
/// 2.0 段化 banner 段使用 HSSMaterialBanner（material.type="banner"），与 HSSBannerSegment 一一对应。
@interface HSSMaterialBanner : HSSMaterialHTML

/// 端侧产物：load 阶段预加载的 WKWebView（由 Coordinator 写入；when !itemModel.not_preload）
/// 已 loadHTMLString 完成；HSSBannerMedia 直接复用此对象，避免 show 阶段二次加载
@property (nonatomic, strong, nullable) WKWebView *preloadedWebView;

@end

#pragma mark - MaterialNativeIcon

@interface HSSMaterialNativeIcon : HSSBaseModel

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

@end

#pragma mark - MaterialNativeImages

@interface HSSMaterialNativeImages : HSSBaseModel

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

@end

#pragma mark - MaterialNative

@interface HSSMaterialNative : HSSMaterialItem

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *desc;
@property (nonatomic, copy, nullable) NSString *btn;
@property (nonatomic, strong, nullable) HSSMaterialNativeImages *images;
@property (nonatomic, strong, nullable) HSSMaterialNativeIcon *icon;

@end

NS_ASSUME_NONNULL_END
