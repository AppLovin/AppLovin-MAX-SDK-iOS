//
//  SDAnimatedImageView+HSSAnimatedImageView.h
//  HSADXSDK
//
//  Created by 张松 on 2025/12/8.
//

/**
 HSADXSDK加载动图建议使用这个分类的方法，统一调用入口，自动应用监控和预检
 */

#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDAnimatedImageView (HSSAnimatedImageView)

/**
 直接设置图片
 
 @param image 图片
 @param imageUrl 图片连接
 */
- (void)hss_setImage:(nullable UIImage *)image imageUrl:(nullable NSString *)imageUrl;

- (void)hss_setImage:(nullable UIImage *)image;

/**
 加载网络图片
 
 @param urlString 图片 URL 字符串
 @param placeholderImage 占位图
 @param completedBlock 完成回调
 */
- (void)hss_setImageWithURLString:(NSString *)urlString
                  placeholderImage:(nullable UIImage *)placeholderImage
                         completed:(nullable void(^)(UIImage * _Nullable image, NSURL * _Nullable imageURL, NSError * _Nullable error))completedBlock;
@end

NS_ASSUME_NONNULL_END
