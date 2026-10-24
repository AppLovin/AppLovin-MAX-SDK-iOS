//
//  HSSInnerWebVC.h
//  HSADXSDK
//
//  Created by 张松 on 2025/11/6.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseViewController.h"
#import <WebKit/WebKit.h>
#import <HSADXSDK/HSSCreativeItemModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSInnerWebVC : HSSBaseViewController

// 初始化方法
- (instancetype)initWithRequestUrl:(NSString *)requestUrl 
                     creativeModel:(HSSCreativeItemModel *)creativeModel;

@end

NS_ASSUME_NONNULL_END
