//
//  HSSALSkipView.h
//  HSADXSDK
//
//  Created by admin on 2025/6/25.
//

#import "HSSBaseView.h"
#import <HSADXSDK/HSSPlayUniTmplModel.h>

@class HSSControlBtnModel;
NS_ASSUME_NONNULL_BEGIN

@interface HSSALSkipView : HSSBaseView
/// 兼容现有逻辑， 跳转按钮来自于（视频/试玩，区分secion）
@property (nonatomic, assign) NSInteger section;
/// 兼容现有逻辑， 跳过按钮来自于大图物料
@property (nonatomic, assign) BOOL fromUniTmpImage;
/// 兼容现有逻辑， 跳过按钮来自于endCard
@property (nonatomic, assign) BOOL fromEndCard;

@property (nonatomic, assign, readonly) BOOL isCloseAction;

// 更新展示样式
- (void)updateWithControlBtnModel:(HSSControlBtnModel *)materialModel;

// 开始倒计时
- (void)startCountDownWtihValue:(NSInteger)countDownValue;

// 强制显示， 兼容现有逻辑（视频或者试玩播放已经结束，但是倒计时时间未到)
- (void)showForce;

@end

NS_ASSUME_NONNULL_END
