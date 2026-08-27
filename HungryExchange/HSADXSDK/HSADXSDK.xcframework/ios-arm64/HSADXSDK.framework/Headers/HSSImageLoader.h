//
//  HSSImageLoader.h
//  HSADXSDK
//
//  Created by 张松 on 2025/12/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSImageLoader : NSObject
+ (void)loadAdImageForImageView:(UIImageView *)imageView
                            url:(NSURL *)url
               placeholderImage:(nullable UIImage *)placeholderImage
                      completed:(nullable void(^)(UIImage * _Nullable image, NSURL * _Nullable imageUrl, NSError * _Nullable error))completedBlock;
@end

NS_ASSUME_NONNULL_END
