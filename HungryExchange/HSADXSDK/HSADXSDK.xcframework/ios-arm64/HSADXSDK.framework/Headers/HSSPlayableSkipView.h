//
//  HSSPlayableSkipView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/3/8.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseView.h"

NS_ASSUME_NONNULL_BEGIN
// 试玩游戏的跳过按钮view
@interface HSSPlayableSkipView : HSSBaseView

// 跳过按钮背景图
@property (nonatomic, copy) NSString *bgUrl;

// 开启倒计时定时器
- (void)startCountDownWtihValue:(NSInteger)countDownValue;

@end

NS_ASSUME_NONNULL_END
