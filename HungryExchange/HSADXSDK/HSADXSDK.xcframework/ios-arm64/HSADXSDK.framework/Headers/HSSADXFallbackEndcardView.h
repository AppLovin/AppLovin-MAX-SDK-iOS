//
//  HSSADXFallbackEndcardView.h
//  HSADXSDK
//
//  Created by biyingquan
//
//  模板 2.0 整卡 EndCard 组件 —— ADX 经典样式（垂直居中 ICON + Title + Desc + CTA）。
//
//  对应：
//    - HSSEndCardSegment.styleKey == "ec_fallback_tmpl_0"
//    - 与 HSSCreativeItemModel.video.ec_fallback_tmpl == 0（默认）等价
//
//  渲染语义：
//    复用 1.0 HSSEndCardView.m 中 self.model.isAdxMaterialModel == YES 的视觉与交互逻辑
//    （updateAdxMoreBtn / cfgECModel.cta / clickable_area_pct / icon_clickable / Lottie variant 等）。
//
//  数据来源（2.0 方式）：
//    所有字段从 HSSRenderContext 拼装（itemModel / currentSegment / currentMaterial / currentSegmentVast），
//    不读 1.0 旧的 itemModel.adxUniTmplModel 路径。
//
//  与 HSSTVShowEndcardView（ec_fallback_tmpl_1，TV-Show 视频截图样式）平级；
//  二者共同覆盖 EndCard 段的 styleKey 路由分发。
//

#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSAdComponentProtocol.h>

@class HSSContentModel;

NS_ASSUME_NONNULL_BEGIN

@interface HSSADXFallbackEndcardView : UIView <HSSAdComponentProtocol>

@property (nonatomic, strong) HSSContentModel *model;

@end

NS_ASSUME_NONNULL_END
