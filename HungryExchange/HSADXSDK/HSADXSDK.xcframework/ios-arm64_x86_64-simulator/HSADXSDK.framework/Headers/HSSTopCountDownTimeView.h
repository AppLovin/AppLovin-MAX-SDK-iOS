//
//  HSSTopCountDownTimeView.h
//  HSADXSDK
//
//  Created by biyingquan on 2024/12/11.
//

#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdFormat.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSTopCountDownTimeView : HSSBaseView

@property (nonatomic, assign) HSSAdFormatType adFormat;

@property (nonatomic, assign) NSInteger section;

@property (nonatomic, assign) CGFloat margin;

@property (nonatomic, assign) BOOL enableSkip;

// 仅插屏使用
@property (nonatomic, assign) BOOL showCountDownTip;
@property (nonatomic, assign) NSInteger show_count_tip_style;


/**
 * Assign values to the countDownValue and skipValue  while  starting countdown timer
 *
 * @param countDownValue Total countdown time
 *
 * @param skipValue Time when the skip button appears
 */
- (void)startCountDownValue:(NSInteger)countDownValue skipValue:(NSInteger)skipValue;

- (void)countDownFinished;

@end

NS_ASSUME_NONNULL_END
