//
//  HSSIconMoreView.h
//  HSADXSDK
//
//  Created by admin on 2024/12/9.
//

#import "HSSBaseView.h"
#import <HSADXSDK/HSSPlayUniTmplModel.h>
#import <HSADXSDK/HSSAdxUniTmplModel.h>
#import <HSADXSDK/HSSAdComponentProtocol.h>

@class HSSOverlayCtaModel;

NS_ASSUME_NONNULL_BEGIN

@interface HSSIconMoreView : HSSBaseView <HSSAdComponentProtocol>
@property (nonatomic, assign) double show_delay_ms;

/**
 * Assign a value to the image and label while calculating the frame that updates the entire view
 *
 * @param iconIvUrl The url for the image.
 *
 * @param moreText  The moreText for the label.
 */
- (void)setIconIvUrl:(NSString *)iconIvUrl moreText:(NSString *)moreText;

- (void)updateWithMaterialModel:(HSSPlayUniTmplMaterialModel *)materialModel;

- (void)updateWitAdxhMaterialModel:(HSSAdxMatTmplCfgVideoModel *)cfgVideoModel vastIcon:(NSString *)vastIcon;

- (void)show;

- (void)createLottieWithVariant:(NSString *)variant vastIcon:(NSString *)vastIcon moreText:(NSString *)moreText;

/// 模板 2.0：与 `createLottieWithVariant:vastIcon:moreText:` 行为一致，CTA 文案/颜色/背景等由 `HSSOverlayCtaModel` 下发
- (void)createLottieWithVariant:(NSString *)variant vastIcon:(NSString *)vastIcon ctaModel:(nullable HSSOverlayCtaModel *)ctaModel;

/**
 * 创建右下按钮 Lottie 动效，支持替换 icon 和文案
 *
 * @param vastIcon         icon 图片的 URL，用于异步下载并替换 Lottie 中的 icon
 * @param moreText         按钮文案，替换 Lottie 中的 "View More" 文本
 * @param fileName         Lottie JSON 文件名（不含 .json 扩展名）
 * @param cornerRadius     icon 圆角半径，用于对下载的 icon 做圆角处理
 * @param loopAnimationCount    lottie循环次数
 * @param completion       布局完成回调。因 icon 需异步下载，无 icon 时立即回调，有 icon 时在下载完成后回调。在此回调中再将 moreView 添加到视图。
 */
- (void)createLottieWithVastIcon:(NSString *)vastIcon moreText:(NSString *)moreText fileName:(NSString *)fileName iconCornerRadius:(CGFloat)cornerRadius loopAnimationCount:(CGFloat)loopAnimationCount completion:(void(^ _Nullable)(void))completion;

/**
 * 创建右下按钮 Lottie 动效（无自定义 icon）
 *
 * @param moreText           按钮文案，替换 Lottie 中的 "View More" 文本
 * @param fileName           Lottie JSON 文件名（不含 .json 扩展名）
 * @param loopAnimationCount Lottie 动画循环次数（-1 表示无限循环）
 */
- (void)createLottieWithMoreText:(NSString *)moreText fileName:(NSString *)fileName loopAnimationCount:(CGFloat)loopAnimationCount;

@end

NS_ASSUME_NONNULL_END
