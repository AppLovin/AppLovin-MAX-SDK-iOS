//
//  HSSActionModel.h
//  HSADXSDK
//
//  Created by admin on 2024/11/27.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdFormat.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSActionModel : NSObject

///广告展示类型
@property (nonatomic, assign) HSSAdFormatType formatType;

/// 控制器
@property (nonatomic, weak) UIViewController *viewController;

/// 参数
@property (nonatomic, strong) NSDictionary *params;

@end

NS_ASSUME_NONNULL_END
