//
//  HSSALVideoSkipView.h
//  HSADXSDK
//
//  Created by admin on 2025/5/20.
//

#import "HSSBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSALVideoSkipView : HSSBaseView
// 开启倒计时定时器
- (void)startCountDownWtihValue:(NSInteger)countDownValue;
@end

NS_ASSUME_NONNULL_END
