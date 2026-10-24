//
//  HSSBannerTextCloseComponent.h
//  HSADXSDK
//
//  Created by 张松
//

#import "HSSBaseComponentView.h"

NS_ASSUME_NONNULL_BEGIN

/// 插屏 banner「倒计时文案 + 关闭」组件（对齐 1.0 HSSInterstitialBannerVC tmpl_1 / tmpl_4）。
///
/// 视觉：右上角半透明深色圆角胶囊，内含倒计时文案 +关闭 ✕。
///   - 倒计时阶段：灰色文案「Ns to Close」+ 灰色 ✕（不可点）
///   - 倒计时结束：白色文案「Close」+ 白色 ✕（可点）
///
/// 两个 key 的差异（按 PM 规约 key 硬编码，不读 fc_close_mode）：
///   - instl_banner_tmpl_1：仅 ✕ 可关闭，文案不可点
///   - instl_banner_tmpl_4：✕ 与文案均可关闭，且结束时执行一次放大动效
///
/// 倒计时由组件自管 NSTimer 驱动（mediaDidStart 起计 controlInfo.countDown 秒），
/// 与其它 2.0 倒计时组件（HSSSectorCountDownView 等）同范式；段时钟仅负责露出时机。
@interface HSSBannerTextCloseComponent : HSSBaseComponentView

@end

NS_ASSUME_NONNULL_END
