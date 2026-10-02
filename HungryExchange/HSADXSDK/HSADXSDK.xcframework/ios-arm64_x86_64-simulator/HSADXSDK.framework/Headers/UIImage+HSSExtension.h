//
//  UIImage+HSSExtension.h
//  HSADXSDK
//
//  Created by biyingquan on 2024/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (HSSExtension)

// 一个方法用于缩放图片到指定尺寸
- (UIImage *)resizeImage:(CGSize)size;

// 改变图片的背景色
- (UIImage *)imageWithBackgroundColor:(UIColor *)backgroundColor;

/// 图片圆角处理
- (UIImage *)imageWithRoundedCornerRadius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END
