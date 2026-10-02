//
//  HSSDefaultCloseComponent.h
//  HSADXSDK
//
//  Created by 张松
//

#import "HSSBaseComponentView.h"

NS_ASSUME_NONNULL_BEGIN

/// 框架兜底关闭按钮（客户端内部专用，服务端不感知）。
///
/// 角色定位：仅作为"服务端漏配 controlArea.close 时的兜底渲染"使用，
/// 不参与协议层 key 派发 —— 服务端下发的 close（如 instl_video_tmpl_3 / instl_video_tmpl_5 等
/// 1.0 兼容 key）由对应的具体倒计时组件（HSSCircularCountDownView / HSSAdSkipCountDownView 等）
/// 渲染，本组件不抢占。
///
/// 通过 HSSInternalDefaultCloseKey 注册，该 key 仅由 HSSControlInfo.defaultFallbackClose
/// 等框架兜底场景使用，服务端不会下发。
///
/// 视觉：30×30 半透明黑底圆角 + ✕ 文字；点击区扩大 8pt；按 nextLink.closeNext 切 skip/close 类型；
/// 内部复用 HSSTimeButton 倒计时能力（KVO 已禁用，避免向 1.0 VC 串台）。
@interface HSSDefaultCloseComponent : HSSBaseComponentView

@end

/// 框架内部专用 key（服务端不会下发）。
/// 用于 HSSControlInfo.defaultFallbackClose 等兜底工厂方法构造默认 ControlInfo。
extern NSString * const HSSInternalDefaultCloseKey;

NS_ASSUME_NONNULL_END
