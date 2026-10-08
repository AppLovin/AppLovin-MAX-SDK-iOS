//
//  HSSCircularCountDownView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/01/19.
//

#import <UIKit/UIKit.h>
#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@class HSSCircularCountDownView;

/// 倒计时控件类型枚举
typedef NS_ENUM(NSInteger, HSSCircularCountDownType) {
    HSSCircularCountDownTypeSkip = 0,  ///< 点击跳过使用（默认值）
    HSSCircularCountDownTypeClose = 1  ///< 关闭
};

/// 圆形倒计时控件
/// 圆角正方形，带边框进度动画
/// 同时承担模板 2.0 新架构的 countdown 组件职责（type=countdown, key=default）
@interface HSSCircularCountDownView : HSSBaseView <HSSAdComponentProtocol>

/// 倒计时控件类型（默认值为 HSSCircularCountDownTypeSkip）
@property (nonatomic, assign) HSSCircularCountDownType countDownType;

/// 开始倒计时
/// @param duration 倒计时时长（秒）
- (void)startCountDownWithDuration:(NSInteger)duration;

/// 停止倒计时
- (void)stopCountDown;

/// 重置控件
- (void)reset;

@end

NS_ASSUME_NONNULL_END
