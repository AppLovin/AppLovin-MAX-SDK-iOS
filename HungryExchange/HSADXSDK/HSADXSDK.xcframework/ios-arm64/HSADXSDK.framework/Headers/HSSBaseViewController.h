//
//  HSSBaseViewController.h
//  HSADXSDK
//
//  Created by admin on 2024/11/28.
//

#import <UIKit/UIKit.h>

@class HSSPlayer;
NS_ASSUME_NONNULL_BEGIN

@interface HSSBaseViewController : UIViewController

/// 是否开启全屏可点 YES 开启, NO 未开启, 默认 NO
@property (nonatomic, assign) BOOL enableFullClick;
@property (nonatomic, assign) BOOL is_full_screen_click;

// 屏幕点击追踪回调（用于 adx_sdk_s_click 上报）
@property (nonatomic, copy) void (^ screenClickTrackingCompletion)(CGPoint clickPoint, NSString *_Nullable element);

/// App即将被杀死的通知
@property (nonatomic, copy) void (^onAppWillTerminateCompletion)(NSDictionary *paramDict);

/// app生命周期切换，当前只监听willResignActive和didEnterBackground
@property (nonatomic, copy) void (^ onAppLifeCycleChangeCompletion)(NSString *lifeCycleName);

// 素材切换回调（用于重置点击计数器）
@property (nonatomic, copy) void (^ materialSwitchCompletion)(void);

/// 重置点击追踪（素材切换时调用）
- (void)resetClickTracking;

- (void)sendClickTrackingWithPoint:(CGPoint)point element:(NSString *)element;

/// 当App即将被用户杀死时调用（子类可重写此方法进行清理）
- (void)onAppWillTerminate;

@end

NS_ASSUME_NONNULL_END
