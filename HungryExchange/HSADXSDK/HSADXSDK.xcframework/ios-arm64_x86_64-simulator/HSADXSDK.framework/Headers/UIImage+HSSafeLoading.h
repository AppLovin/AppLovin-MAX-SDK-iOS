//
//  UIImage+HSSafeLoading.h
//  HSADXSDK
//
//  Created by 张松 on 2025/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (HSSafeLoading)
+ (nullable UIImage *)hss_safeImageWithContentsOfFile:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
