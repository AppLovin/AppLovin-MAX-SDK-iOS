//
//  HSSPlayableCDTimeView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/3/8.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseView.h"

NS_ASSUME_NONNULL_BEGIN
// 试玩游戏的倒计时view
@interface HSSPlayableCDTimeView : HSSBaseView

// 倒计时背景图
@property (nonatomic, copy) NSString *bgUrl;

// 开启倒计时定时器
- (void)startCountDownWtihValue:(NSInteger)countDownValue;

// 销毁定时器
- (void)destroyTimer;

@end

NS_ASSUME_NONNULL_END
