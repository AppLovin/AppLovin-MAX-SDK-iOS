//
//  HSSAdTipCircularCountDownView.h
//  HSADXSDK
//
//  Created by biyingquan on 2026/3/10.
//
//  左侧文案 + 右侧圆形倒计时控件，圆形内数字递减（5s 4s...），带顺时针进度条
//

#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdFormat.h>
#import <HSADXSDK/HSSAdComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/// 倒计时控件类型枚举
typedef NS_ENUM(NSInteger, HSSAdTipCircularCountDownType) {
    HSSAdTipCircularCountDownTypeSkip = 0,  ///< 点击跳过使用（默认值）
    HSSAdTipCircularCountDownTypeClose = 1  ///< 关闭
};

/// 右侧倒计时展示类型
typedef NS_ENUM(NSInteger, HSSAdTipCircularCountDownDisplayType) {
    HSSAdTipCircularCountDownDisplayTypeCustomCircle = 0,  ///< 自定义 circleContainer（渐变圆+进度条）
    HSSAdTipCircularCountDownDisplayTypeStandard = 1       ///< HSSCircularCountDownView（圆角方框+进度条）
};

/// 广告圆形倒计时控件
/// 左侧文案提示，右侧圆形倒计时（含进度条、数字递减）
@interface HSSAdTipCircularCountDownView : HSSBaseView <HSSAdComponentProtocol>

/// 右侧倒计时展示类型（默认 CustomCircle）
@property (nonatomic, assign) HSSAdTipCircularCountDownDisplayType displayType;

/// 倒计时控件类型（默认值为 HSSAdTipCircularCountDownTypeSkip）
@property (nonatomic, assign) HSSAdTipCircularCountDownType countDownType;

/// 是否开启圆形进度条（默认 YES，仅 CustomCircle 生效）
@property (nonatomic, assign) BOOL enableProgressRing;

/// 开始倒计时
/// @param duration 倒计时时长（秒）
/// @param adFormat 广告类型（插屏/激励）
- (void)startCountDownWithDuration:(NSInteger)duration adFormat:(HSSAdFormatType)adFormat;

/// 停止倒计时
- (void)stopCountDown;

/// 重置控件
- (void)reset;

@end

NS_ASSUME_NONNULL_END
