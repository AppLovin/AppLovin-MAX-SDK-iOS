//
//  HSSComponentAnimation.h
//  HSADXSDK
//
//  Created by 张松
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSComponentAnimation : NSObject

/// 延迟（秒）
@property (nonatomic, assign) NSTimeInterval delay;

/// 时长（秒）
@property (nonatomic, assign) NSTimeInterval duration;

/// 弹簧阻尼（0~1，1 = 无弹簧效果）
@property (nonatomic, assign) CGFloat springDamping;

/// 弹簧初速度
@property (nonatomic, assign) CGFloat springVelocity;

/// 动画选项
@property (nonatomic, assign) UIViewAnimationOptions options;

+ (instancetype)springWithDelay:(NSTimeInterval)delay
                       duration:(NSTimeInterval)duration
                        damping:(CGFloat)damping
                       velocity:(CGFloat)velocity;

+ (instancetype)fadeWithDelay:(NSTimeInterval)delay
                     duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
