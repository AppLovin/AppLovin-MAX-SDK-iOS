//
//  UIScreen+HSSafeArea.h
//  HSADXSDK
//
//  Created by admin on 2024/12/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScreen (HSSafeArea)

+ (UIEdgeInsets)hssadx_safeArea;

+ (CGFloat)hssadx_safeBottom;

+ (CGFloat)hssadx_safeTop;

+ (UIWindow *)hssadx_anyWindow;

@end

NS_ASSUME_NONNULL_END
