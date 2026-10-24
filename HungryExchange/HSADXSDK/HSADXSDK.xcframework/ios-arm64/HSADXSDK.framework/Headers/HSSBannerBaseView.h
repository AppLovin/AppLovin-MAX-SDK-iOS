//
//  HSSBannerBaseView.h
//  HSADXSDK
//
//  Created by admin on 2024/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSBannerBaseView : UIView

#pragma mark - 回调

/// 屏幕点击追踪回调（用于 adx_sdk_s_click 上报）
@property (nonatomic, copy, nullable) void (^screenClickTrackingCompletion)(CGPoint clickPoint, NSString *_Nullable element);

@end

NS_ASSUME_NONNULL_END
