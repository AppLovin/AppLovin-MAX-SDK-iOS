//
//  HSSTmplSegment.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import "HSSBaseModel.h"
#import "HSSControlInfo.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const HSSTmplSegmentTypeVideo;
extern NSString *const HSSTmplSegmentTypePlayable;
/// 文字型 EndCard 段（icon/title/desc/btn 由整卡组件自渲染）
extern NSString *const HSSTmplSegmentTypeEndCard;
/// 图片型 EndCard 段（一张大图铺满主体）
/// 服务端 type=end_card_image，仅会下发大图 styleKey（ec_fallback_tmpl_2/_3）；
/// 客户端通过段子类 HSSEndCardImageSegment 表达，与 HSSMaterialEndCardImage 一一对应
extern NSString *const HSSTmplSegmentTypeEndCardImage;
/// 插屏单 Banner 段（H5 物料：banner.htmlSnippet）
/// 服务端 2.0 段化协议：material_type=11 + tmpl.segments[i].type="banner" + ad.material[i].type="banner"
/// 与 1.0 老协议 material_type=6（HSSMaterialTypeBanner="html"）独立并行，互不影响
extern NSString *const HSSTmplSegmentTypeBanner;

@class HSSNextLink;
@class HSSControlArea;

#pragma mark - 段基类

@interface HSSTmplSegment : HSSBaseModel

/// 段类型：video / playable / end_card
@property (nonatomic, copy) NSString *type;

/// 段在 tmplInfo.segments 数组中的位置（由 HSSTmplInfo 反序列化时注入；游离 segment 默认 0）
@property (nonatomic, assign) NSInteger index;

/// 段间流转配置（所有段通用，服务端按需下发）
@property (nonatomic, strong, nullable) HSSNextLink *nextLink;

/// 关闭/跳过控件配置（所有段通用）
@property (nonatomic, strong, nullable) HSSControlArea *controlArea;

/// Overlay 小卡配置（所有段通用）
@property (nonatomic, strong, nullable) HSSOverlayArea *overlayArea;

/// 广告标识配置（所有段通用）
@property (nonatomic, strong, nullable) HSSAdArea *adArea;

/// 点击热区配置（所有段通用）
@property (nonatomic, strong, nullable) HSSClickArea *clickArea;

/// 是否首段（index == 0）。
/// 用于段内做"主体段 vs 附属段"分流：
///   - 主体段（首段）通常用带 countDown 的 close 兜底（保证用户看够最少时长）
///   - 附属段（非首段）通常直接用 defaultFallbackClose（立即可点）
@property (nonatomic, assign, readonly) BOOL isFirstSegment;

+ (nullable HSSTmplSegment *)segmentWithDictionary:(NSDictionary *)dict;

@end

#pragma mark - ControlArea（Video / Playable / EndCard 三种段通用）

/// 服务端约定：只下发 close；close 组件内部按 HSSControlInfo.show/value 决定显示时机
/// 原 HSSVideoControlArea / HSSPlayableControlArea / HSSEndCardControlArea 三类字段完全一致，合并为此类
@interface HSSControlArea : HSSBaseModel

/// 关闭/跳过入口（具体形态由 close.key 决定；服务端按段位置自行决定 key 样式）
@property (nonatomic, strong, nullable) HSSControlInfo *close;

@end

#pragma mark - VideoTmpl（视频段）

@interface HSSVideoSegment : HSSTmplSegment

/// 静音控件配置（Video / Playable 独有）
@property (nonatomic, strong, nullable) HSSAudioArea *audioArea;

/// 底部细进度条（Video 独有）
/// JSON key: "progress"（段顶层字段，与 controlArea / audioArea 等平级）
@property (nonatomic, strong, nullable) HSSControlInfo *progressBar;

@end

#pragma mark - PlayableTmpl（试玩段）

@interface HSSPlayableSegment : HSSTmplSegment

/// 静音控件配置（Video / Playable 独有）
@property (nonatomic, strong, nullable) HSSAudioArea *audioArea;

@end

#pragma mark - EndCardTmpl（文字型尾卡段：按 styleKey 挂载整体组件，组件内部画 icon/title/desc/cta）

/// 两层结构设计：
///   - styleKey：服务端下发的整体 endcard 组件标识（一个 key 对应一个视觉样式子类）
///   - 整体组件内部自行布局 icon/title/desc/cta；Segment 层只挂"整体组件 + 段级 close/skip + 点击层"
///   - 旧字段 cta / overlayArea 现由整体组件内部决定（保留 model 字段用于组件读取）
@interface HSSEndCardSegment : HSSTmplSegment

/// 整体 endcard 组件的 key（EndCard 独有，用于按样式挂载对应组件子类）
/// 未下发时 SegmentVC 会跳过整体组件挂载，仅展示段级控件
@property (nonatomic, copy, nullable) NSString *key;

/// EndCard CTA 配置（EndCard 独有）
@property (nonatomic, strong, nullable) HSSEndCardCta *cta;

/// 服务端漏配 key 时的兜底 styleKey（按段类分发：文字段 ec_fallback_tmpl_0 / 图片段 ec_fallback_tmpl_2）
/// 子类按需重写；调用方：HSSEndCardSegmentVC 在 seg.key 为空时使用
+ (NSString *)defaultFallbackStyleKey;

@end

#pragma mark - EndCardImageTmpl（图片型尾卡段：一张大图铺满主体）

/// 与 HSSEndCardSegment 字段集完全一致，仅作为类型语义边界存在：
///   - 服务端 type=end_card_image 时落到此子类
///   - HSSMaterialProvider 据此精准对齐 HSSMaterialEndCardImage（不再依赖 styleKey 字符串推断）
///   - HSSEndCardSegmentVC / EventHandler 用 isKindOfClass:HSSEndCardSegment.class 判断，子类天然命中
@interface HSSEndCardImageSegment : HSSEndCardSegment
@end

#pragma mark - BannerSegment（插屏单 Banner 段：H5 物料 + 关闭入口）

/// 字段集与基类一致（complete inherits controlArea / clickArea / nextLink），
/// 段内仅作为类型语义边界存在：
///   - 服务端 type="banner" 时落到此子类
///   - HSSMaterialProvider 据此精准对齐 HSSMaterialBanner
///   - HSSBannerSegmentVC / EventHandler 用 isKindOfClass:HSSBannerSegment.class 判断
@interface HSSBannerSegment : HSSTmplSegment
@end

NS_ASSUME_NONNULL_END
