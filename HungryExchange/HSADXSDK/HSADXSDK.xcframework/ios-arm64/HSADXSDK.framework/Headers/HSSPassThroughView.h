//
//  HSSPassThroughView.h
//  HSADXSDK
//
//  Created by 张松
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 点击穿透容器：默认 UIView 在 frame 内即使没命中任何子 view 也会"吞掉"点击；
/// 本类在该情形下返回 nil 让 hitTest 沿 view 树继续下移。
///
/// 通过 `passThroughDirectChild` 适配两类场景：
///
///   【容器型 · 默认】passThroughDirectChild = NO
///     直接子 view 是真正的可交互组件（按钮 / 倒计时 / 标签等），
///     命中子 view 时**必须让其响应**；仅在命中 self（缝隙）时透传。
///     典型：HSSSegmentVC.componentContainer —— 让段空白区域透到下层 mediaContainer。
///
///   【包裹型】passThroughDirectChild = YES
///     直接子 view 是另一个"容器层"（如整卡 self），其内部还嵌套真正的按钮；
///     命中该容器层 self 时（即整卡缝隙）应**视为缝隙**透传到下层。
///     典型：HSSEndCardSegmentVC 整卡外层 wrapper —— 让整卡缝隙透到下层 clickOverlay。
@interface HSSPassThroughView : UIView

/// 命中"直接子 view"时是否透传。默认 NO（容器型）。
/// 设 YES 后，hit 是 self 的直接 subview 时也返回 nil 透传到下层；
/// 嵌套更深的 subview（按钮等）不受影响，正常响应。
@property (nonatomic, assign) BOOL passThroughDirectChild;

@end

NS_ASSUME_NONNULL_END
