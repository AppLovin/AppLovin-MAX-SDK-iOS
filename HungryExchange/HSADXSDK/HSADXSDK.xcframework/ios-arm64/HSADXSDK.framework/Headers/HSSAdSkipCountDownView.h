//
//  HSSAdSkipCountDownView.h
//  HSADXSDK
//
//  Created by admin on 2025/01/19.
//

#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdFormat.h>
#import <HSADXSDK/HSSAdComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/// 倒计时控件类型枚举
typedef NS_ENUM(NSInteger, HSSAdSkipCountDownType) {
    HSSAdSkipCountDownTypeSkip = 0,  ///< 点击跳过使用（默认值）
    HSSAdSkipCountDownTypeClose = 1  ///< 关闭
};

/// 广告跳过倒计时控件
/// 深灰色圆角矩形按钮，显示品牌名称和倒计时
/// 同时承担模板 2.0 新架构的 close 组件职责（矩形样式）
@interface HSSAdSkipCountDownView : HSSBaseView <HSSAdComponentProtocol>

/// 倒计时控件类型（默认值为 HSSAdSkipCountDownTypeSkip）
@property (nonatomic, assign) HSSAdSkipCountDownType countDownType;

/// 是否开启倒计时边框和进度逻辑（默认 YES）
@property (nonatomic, assign) BOOL enableCountDownBorder;

/// 插屏 video 跳过按钮样式模板
@property (nonatomic, assign) NSInteger instl_video_tmpl;

/// 激励 video 跳过按钮样式模板 
@property (nonatomic, assign) NSInteger reward_video_tmpl;

/// 开始倒计时
/// @param duration 倒计时时长（秒）
- (void)startCountDownWithDuration:(NSInteger)duration adFormat:(HSSAdFormatType)adFormat;

/// 停止倒计时
- (void)stopCountDown;

/// 重置控件
- (void)reset;

@end

NS_ASSUME_NONNULL_END
