//
//  HSSLottieEndcardCta.h
//  HSADXSDK
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CompatibleAnimationView;

NS_ASSUME_NONNULL_BEGIN

/// Lottie 构建：EndCard CTA（ec_btn_lottie_*）、右下角 overlay（cta_* drawer / gradient 等，含可选 image_0）。
@interface HSSLottieEndcardCta : NSObject

/// 按最大宽度缩放 Lottie 内文字字号（与 AE 导出字号换算一致）。
+ (CGFloat)scaledFontSizeForLottieText:(NSString *)text
                            aeFontName:(NSString *)aeFontPostScriptName
                          originalSize:(CGFloat)originalSize
                              maxWidth:(CGFloat)maxWidth;

/// 从 HSADX.bundle 加载 JSON：可选替换 `image_0`、替换「View More 3」文案；`tapHandler` 可选。
+ (nullable CompatibleAnimationView *)lottieViewWithFileName:(nullable NSString *)fileName
                                                   iconImage:(nullable UIImage *)iconImage
                                                    moreText:(nullable NSString *)moreText
                                          loopAnimationCount:(CGFloat)loopAnimationCount
                                                textMaxWidth:(CGFloat)textMaxWidth
                                                  tapHandler:(nullable void (^)(UIView *lottieView))tapHandler;

/// EndCard CTA：`iconImage` 为 nil、带点击回调。
+ (nullable CompatibleAnimationView *)endcardCtaLottieViewWithFileName:(nullable NSString *)fileName
                                                              moreText:(nullable NSString *)moreText
                                                    loopAnimationCount:(CGFloat)loopAnimationCount
                                                          textMaxWidth:(CGFloat)textMaxWidth
                                                            tapHandler:(nullable void (^)(UIView *lottieView))tapHandler;

@end

NS_ASSUME_NONNULL_END
