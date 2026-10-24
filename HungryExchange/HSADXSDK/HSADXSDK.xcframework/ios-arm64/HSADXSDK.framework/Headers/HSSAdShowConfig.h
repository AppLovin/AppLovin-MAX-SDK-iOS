//
//  HSSAdShowConfig.h
//  HSADXSDK
//
//  Created by admin on 2026/5/6.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSBaseModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSAdShowConfig : HSSBaseModel
@property (nonatomic, assign) CGFloat coef;
@property (nonatomic, assign) CGFloat ecpm;
@property (nonatomic, assign) BOOL is_no_show;
@end

NS_ASSUME_NONNULL_END
