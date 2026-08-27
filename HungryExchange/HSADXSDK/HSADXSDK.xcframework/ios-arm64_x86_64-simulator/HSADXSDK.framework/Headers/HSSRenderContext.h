//
//  HSSRenderContext.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSAdFormat.h>
#import "HSSMediaProtocol.h"

@class HSSCreativeItemModel;
@class HSSTmplInfo;
@class HSSTmplSegment;
@class HSSMaterialItem;
@class HSSVastCreativeAdModel;

NS_ASSUME_NONNULL_BEGIN

/// 用户主动静音状态（跨段持久化）
/// 对齐 1.0 HSSAdMuteUserStatus 语义：用户一旦点过 mute / unmute，优先级永远高于服务端 / 段配置
typedef NS_ENUM(NSInteger, HSSMuteUserStatus) {
    HSSMuteUserStatusUnknown = 0,   // 用户未主动设置（按服务端 audioArea / 全局静音决定）
    HSSMuteUserStatusMute    = 1,   // 用户主动设为静音
    HSSMuteUserStatusUnMute  = 2,   // 用户主动设为不静音
};

/// 渲染上下文：纯数据对象，贯穿整个渲染链路
@interface HSSRenderContext : NSObject

/// 广告素材数据
@property (nonatomic, strong) HSSCreativeItemModel *itemModel;

/// 模板配置数据
@property (nonatomic, strong) HSSTmplInfo *tmplInfo;

/// 当前正在展示的段模板配置（RenderEngine 切段时更新）
@property (nonatomic, strong, nullable) HSSTmplSegment *currentSegment;

/// 当前段索引
@property (nonatomic, assign) NSInteger currentSegmentIndex;

/// 当前段对应的素材（RenderEngine 切段时更新）
/// 组件/EventHandler/Adapter 可通过此字段访问素材层所有字段（url / vast / mimeType 等）
/// 无需再绕 HSSModularVastResolver 做"段 → material"的 ordinal 匹配（MaterialProvider 已做）
@property (nonatomic, strong, nullable) HSSMaterialItem *currentMaterial;

/// 广告类型（插屏/激励）
@property (nonatomic, assign) HSSAdFormatType adFormat;

/// 当前媒体层引用
@property (nonatomic, weak, nullable) id<HSSMediaProtocol> currentMedia;

/// 用户主动静音状态（跨段持久化）
/// 默认 HSSMuteUserStatusUnknown；用户在任意段点击 mute/unmute 切换后由 SegmentVC 写入；
/// HSSVideoMedia 在 -initWithMaterial:initialMuted:context: 中读取，优先级高于 initialMuted 参数
/// 对齐 1.0 HSSVideoPlayerVC.muteUserStatus 在 playerMuted 计算中的"最高优先级"语义
@property (nonatomic, assign) HSSMuteUserStatus muteUserStatus;
/// 段间共享的"上一段视频最后一帧截图"。
/// 写入：HSSVideoSegmentVC 在 hss_skipTapped / hss_mediaFinished 时按
///       itemModel.video.ec_fallback_tmpl == 1 || ec_fallback_force > 0 条件捕获
/// 读取：HSSEndCard 段下挂载的 `ec_fallback_tmpl_1` 整卡组件（HSSTVShowEndcardView）
///       拿来做视频帧 → 55% 的过渡动画
/// 对齐 1.0 HSSInterstitialVC.currentFrameImage 的字段语义
@property (nonatomic, strong, nullable) UIImage *lastVideoFrameImage;

#pragma mark - 便利访问

/// 当前段 VAST 的便利访问（仅用于读 VAST 元数据填充字段，如 icon/title/desc/btn）：
///   - Video 段   → 返回 HSSMaterialVideo.vast（完整 VAST）
///   - EndCard 段 → 返回 HSSMaterialEndCardBase.vast；为 nil 时回退到 itemModel.video.vast
///                  （write-side 只把 VAST 回填给"第一个出现的 EndCardSegment"，
///                   后续段 material.vast 是 nil，但仍可通过本 getter 读到广告级 VAST 元数据）
///   - 其他段     → 返回 nil
///
/// 注意：判断"是否消费 VAST companion 视觉主体"必须直读 currentMaterial.vast.companionAds.url，
/// 不能走本 getter，否则会破坏"companion 只展示一次（首段消费）"语义。
@property (nonatomic, strong, readonly, nullable) HSSVastCreativeAdModel *currentSegmentVast;

@end

NS_ASSUME_NONNULL_END
