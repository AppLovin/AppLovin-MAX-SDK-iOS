//
//  SDAnimatedImage+HSSExtension.h
//  HSADXSDK
//
//  Created by 张松 on 2025/12/8.
//

#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDAnimatedImage (HSSExtension)
+ (instancetype)hss_safeInitWithData:(NSData *)data imageUrl:(NSString *)imageUrl;
@end

NS_ASSUME_NONNULL_END
