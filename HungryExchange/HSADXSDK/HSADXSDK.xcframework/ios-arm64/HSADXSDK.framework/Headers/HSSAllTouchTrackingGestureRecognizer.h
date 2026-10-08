//
//  HSSAllTouchTrackingGestureRecognizer.h
//  HSADXSDK
//
//  Created by 张松 on 2025/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 通知名称：屏幕点击追踪通知
extern NSNotificationName const HSSScreenClickTrackingNotification;

/// UserInfo 的 Key
extern NSString *const HSSScreenClickPointKey;
extern NSString *const HSSScreenClickViewKey;
extern NSString *const HSSScreenClickTimestampKey;  // NSNumber (NSTimeInterval)
extern NSString *const HSSScreenClickTouchedViewKey;

@interface HSSAllTouchTrackingGestureRecognizer : UIGestureRecognizer

/// 是否启用通知模式（默认 YES）
@property (nonatomic, assign) BOOL notificationEnabled;

@end

NS_ASSUME_NONNULL_END

