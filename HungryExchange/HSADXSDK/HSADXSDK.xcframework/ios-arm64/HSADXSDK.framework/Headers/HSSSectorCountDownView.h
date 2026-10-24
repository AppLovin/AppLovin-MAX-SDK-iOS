//
//  HSSSectorCountDownView.h
//  HSADXSDK
//
//  左侧提示文案 + 右侧白色扇形倒计时
//  插屏：Resuming to game -> Back to game
//  激励：Loading Reward -> Rewarded
//

#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdFormat.h>
#import <HSADXSDK/HSSAdComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HSSSectorCountDownType) {
    HSSSectorCountDownTypeSkip = 0,  ///< 点击跳过使用（默认值）
    HSSSectorCountDownTypeClose = 1  ///< 关闭
};

/// 扇形倒计时控件
/// 左侧文案 + 右侧白色扇形进度条（#ffffff 80% 不透明度）
@interface HSSSectorCountDownView : HSSBaseView <HSSAdComponentProtocol>

/// 倒计时控件类型（默认值为 HSSSectorCountDownTypeSkip）
@property (nonatomic, assign) HSSSectorCountDownType countDownType;
/// 开始倒计时
/// @param duration 倒计时时长（秒）
/// @param adFormat 广告类型（插屏/激励），决定提示文案
- (void)startCountDownWithDuration:(NSInteger)duration adFormat:(HSSAdFormatType)adFormat;

/// 停止倒计时
- (void)stopCountDown;

/// 重置控件
- (void)reset;

@end

NS_ASSUME_NONNULL_END
