//
//  HSSFloatingCapsuleView.h
//  HSADXSDK
//  Created by biyingquan on 2026/4/2.
//

#import <UIKit/UIKit.h>
#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/// 胶囊形浮动提示条：自屏幕底部弹出，周期性轻微上浮提醒；模板 2.0 实现 `HSSAdComponentProtocol`（overlay `video_cta_lottie_floating_b` / `video_cta_lottie_floating_r`）
@interface HSSFloatingCapsuleView : HSSBaseView <HSSAdComponentProtocol>

/// 配置文案、文字颜色（如 #000000）、控件背景色（如 #FFFFFF）。请在 `show` 前调用。
- (void)configureWithText:(NSString *)text
             textColorHex:(NSString *)textColorHex
      backgroundColorHex:(NSString *)backgroundColorHex;

/// 将控件添加到 `parentView`：以父视图 bounds 为参照，宽 60%、高宽比 4:1；自父视图底边外滑入至距底约 15% 父视图高度处，动画 1s；结束后每 2s 提醒动效（前后台会暂停/恢复定时器）。
- (void)showInParentView:(UIView *)parentView;

/// 移除并停止定时器与动画（可选，不调用则需在适当时机自行 removeFromSuperview）。
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
