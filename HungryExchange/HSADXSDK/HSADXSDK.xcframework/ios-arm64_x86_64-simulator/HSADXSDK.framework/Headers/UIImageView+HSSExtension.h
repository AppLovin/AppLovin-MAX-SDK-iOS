//
//  UIImageView+HSSExtension.h
//  HSADXSDK
//
//  Created by admin on 2024/12/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (HSSExtension)


- (void)setImageWithURL:(NSString *)url success:(void (^)(NSURLRequest * request, NSHTTPURLResponse * _Nullable response, UIImage *image))success failure:(void (^)(NSURLRequest * request, NSHTTPURLResponse * _Nullable response, NSError * error))failure;


- (void)setImageWithURL:(NSString *)url
              placeholderImage:(UIImage * _Nullable)placeholderImage
                       success:(void (^ _Nullable)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                failure:(void (^ _Nullable)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
