//
//  HSSSegmentTransitioning.h
//  HSADXSDK
//
//  Created by 张松
//
//  段间切换的过渡样式抽象。
//
//  两级分层：
//    Level 1（简单）：HSSSegmentTransitionStyle 描述常用 UIKit 内置转场（crossDissolve / flip / curl 等），
//                     段 VC 通过 -preferredEntryTransitionStyle 返回预设即可（~1 行）
//    Level 2（高级）：通过 -preferredEntryTransitionAnimator 提供 UIKit 标准
//                     id<UIViewControllerAnimatedTransitioning>，支持粒子 / 3D / 交互式自定义转场
//                     （当前仅预留接口，未来需要再连线）
//
//  默认行为：
//    段 VC 不实现任何方法 → 瞬切（duration=0），和当前行为一致
//    段 VC 实现 Style     → 按样式做 UIKit 内置动画
//    段 VC 实现 Animator   → 优先使用自定义 animator（Level 2 预留）
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HSSSegmentTransitionStyle

/// 段间过渡样式：轻量描述对象。
/// 建议通过工厂方法创建（`+none` / `+crossDissolveWithDuration:` 等），不鼓励直接修改字段。
@interface HSSSegmentTransitionStyle : NSObject

/// 动画时长（秒）；0 表示瞬切
@property (nonatomic, assign, readonly) NSTimeInterval duration;

/// 动画 options（通常为 UIViewAnimationOptionTransitionXxx 之一）
@property (nonatomic, assign, readonly) UIViewAnimationOptions options;

#pragma mark - 工厂（常用预设）

/// 瞬切（duration=0），不做任何动画
+ (instancetype)none;

/// 淡入淡出（最常用）
/// @param duration 建议 0.2 ~ 0.4 秒
+ (instancetype)crossDissolveWithDuration:(NSTimeInterval)duration;

/// 从左翻转
+ (instancetype)flipFromLeftWithDuration:(NSTimeInterval)duration;

/// 从右翻转
+ (instancetype)flipFromRightWithDuration:(NSTimeInterval)duration;

/// 从上卷起
+ (instancetype)curlUpWithDuration:(NSTimeInterval)duration;

/// 向下翻页
+ (instancetype)curlDownWithDuration:(NSTimeInterval)duration;

/// 完全自定义样式（工厂未覆盖的场景使用）
+ (instancetype)styleWithDuration:(NSTimeInterval)duration
                          options:(UIViewAnimationOptions)options;

@end

#pragma mark - HSSSegmentTransitioning

@protocol HSSSegmentTransitioning <NSObject>

@optional

/// Level 1：进入本段时期望的过渡样式。
/// 未实现或返回 nil → 使用基类默认（瞬切）
/// 典型用法（段 VC 内）：
///   - (HSSSegmentTransitionStyle *)preferredEntryTransitionStyle {
///       return [HSSSegmentTransitionStyle crossDissolveWithDuration:0.25];
///   }
- (nullable HSSSegmentTransitionStyle *)preferredEntryTransitionStyle;

/// Level 2：完全自定义的 UIKit animator（当前预留扩展点）。
/// 优先级高于 preferredEntryTransitionStyle；二者都实现时使用 animator。
/// 当前版本 Parent VC 暂未连线 animator 路径，未来如需粒子 / 3D / 交互式转场再补齐。
- (nullable id<UIViewControllerAnimatedTransitioning>)preferredEntryTransitionAnimator;

@end

NS_ASSUME_NONNULL_END
