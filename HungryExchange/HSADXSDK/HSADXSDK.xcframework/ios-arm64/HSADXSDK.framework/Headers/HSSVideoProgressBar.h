//
//  HSSVideoProgressBar.h
//  HSADXSDK
//
//  Created by admin on 2025/1/7.
//
//  视频广告底部进度条控件
//

#import <UIKit/UIKit.h>
#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSVideoProgressBar : HSSBaseView <HSSAdComponentProtocol>

/// 初始化方法
/// @param countdownDuration 倒计时时间（秒）
/// @param viewMoreText View More 按钮文案
- (instancetype)initWithCountdownDuration:(NSInteger)countdownDuration
                             viewMoreText:(NSString *)viewMoreText;

/// 开始倒计时
- (void)startCountdown;

/// 暂停倒计时
- (void)pauseCountdown;

/// 恢复倒计时
- (void)resumeCountdown;

/// 停止倒计时
- (void)stopCountdown;

/// 更新 View More 按钮文案
- (void)updateViewMoreText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END

