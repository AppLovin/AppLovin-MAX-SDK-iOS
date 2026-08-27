//
//  HSSEllipseCountDownView.h
//  HSADXSDK
//
//  Created by biyingquan on 2026/2/6.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdComponentProtocol.h>

/// 倒计时控件类型枚举
typedef NS_ENUM(NSInteger, HSSEllipseCountDownType) {
    HSSEllipseCountDownViewSkip = 0,  ///< 点击跳过使用（默认值）
    HSSEllipseCountDownViewClose = 1  ///< 关闭
};

@interface HSSEllipseCountDownView : HSSBaseView <HSSAdComponentProtocol>

/// 倒计时控件类型（默认值为 HSSCircularCountDownTypeSkip）
@property (nonatomic, assign) HSSEllipseCountDownType countDownType;

/// 开始倒计时
/// @param duration 倒计时时长（秒）
- (void)startCountDownWithDuration:(NSInteger)duration adFormat:(HSSAdFormatType)adFormat;


@end
