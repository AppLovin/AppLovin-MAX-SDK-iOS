//
//  HSSFullScreenImageEndCardView.h
//  HSADXSDK
//
//  Created by 张松
//

#import "HSSBaseComponentView.h"

NS_ASSUME_NONNULL_BEGIN

/// 全屏大图 EndCard 整卡组件（2.0 模板）。
///
/// 与 ec_fallback_tmpl 字段对齐：
///   ec_fallback_tmpl_2 = 全屏大图 EC【无 button】
///   ec_fallback_tmpl_3 = 全屏大图 EC + button（先以 _2 同行为占位，待 image_btn 字段就绪后扩展）
///
/// 装配契约：与 HSSTVShowEndcardView 完全对称，
///   由 HSSEndCardSegmentVC.segmentDidLoadAssemble 中
///   `[self mountComponentWithKey:seg.styleKey controlInfo:nil]` 经组件注册体系按 styleKey 自动分发。
///
/// 数据来源：HSSRenderContext.currentMaterial 强转 HSSMaterialEndCardImage 取 url，
/// 走"磁盘 cache 优先 + SDAnimatedImage 解码"路径，与 1.0 HSSImageEncCardView 同源。
///
/// 1.0 对照：HSSImageEncCardView（注意拼写：1.0 是历史 typo "Enc"），PlayUniTmpl image type==2 整卡。
@interface HSSFullScreenImageEndCardView : HSSBaseComponentView

@end

NS_ASSUME_NONNULL_END
