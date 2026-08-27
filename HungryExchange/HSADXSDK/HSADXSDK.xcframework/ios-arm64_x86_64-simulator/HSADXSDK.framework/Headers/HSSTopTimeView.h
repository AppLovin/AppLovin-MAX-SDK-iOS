//
//  HSSTopTimeView.h
//  HSADXSDK
//
//  Created by admin on 2024/12/9.
//

#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdFormat.h>

@class HSSPlayUniTmplMaterialModel;
@class HSSControlBtnModel;
@class HSSALSkipView;
NS_ASSUME_NONNULL_BEGIN

@interface HSSTopTimeView : HSSBaseView

@property (nonatomic, assign) HSSAdFormatType adFormat;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) CGFloat margin;
// 仅插屏使用
@property (nonatomic, assign) BOOL showCountDownTip;
@property (nonatomic, assign) NSInteger show_count_tip_style;

@property (nonatomic, copy) NSString *mutiNumAD;
@property (nonatomic, strong, readonly) HSSALSkipView *skipView;

/**
 * Assign values to the countDownValue and skipValue  and topTipText  while  starting countdown timer
 *
 * @param countDownValue Total countdown time
 *
 * @param skipValue Time when the skip button appears
 *
 */
- (void)setCountDownValue:(NSInteger)countDownValue skipValue:(NSInteger)skipValue;

/**
 @param rewardValue 奖励达成时间
 @param countDownValue 总时间
 @param skipValue 跳过时间
 */
- (void)setRewardValue:(NSInteger)rewardValue countDownValue:(NSInteger)countDownValue skipValue:(NSInteger)skipValue isPlayableReward:(BOOL)isPlayableReward;

// 仅提供给adx 三段式首段跳过按钮配置使用 ！！！ 首段比较特殊：需要有提示文字+跳过按钮
- (void)setAdxFirstSectionRewardValue:(NSInteger)rewardValue countDownValue:(NSInteger)countDownValue skipValue:(NSInteger)skipValue;

/**
 设置静音按钮状态
 */
-(void)setMuteStatus:(BOOL)mute;

// 销毁定时器
- (void)destroyTimer;

- (void)hideMuteBtn;

- (void)showMuteBtn;

// 激励用
- (BOOL)rewardDone;

// 插屏用
- (BOOL)countDownDone;

// 激励用
- (void)getReward;

// 插屏用
- (void)finishCountDown;

/// 根据模型更新视图样式
- (void)updateStyleWithMaterialModel:(HSSPlayUniTmplMaterialModel *)materialModel;

- (void)updateStyleWithAdxControlBtnModel:(HSSControlBtnModel *)ctrlBtnModel;

@end

NS_ASSUME_NONNULL_END
