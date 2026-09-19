//
//  HSSInterstitialBannerView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/5/29.
//

#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSAdDelegate.h>
#import <HSADXSDK/HSSCreativeItemModel.h>
#import <HSADXSDK/HSSAd.h>
#import <HSADXSDK/HSSJumpTrackingContext.h>

typedef void(^adDeeplinkCompletionBlock)(BOOL result, NSString *_Nullable deeplinkUrl, HSSCreativeItemModel * _Nullable creative);

// 跳转结果回调类型（用于 adx_sdk_click_result 埋点）
typedef void(^adClickResultCompletionBlock)(BOOL result, NSString *_Nullable linkUrl, HSSJumpTrackingContext *_Nullable context, HSSCreativeItemModel * _Nullable creative);

NS_ASSUME_NONNULL_BEGIN

@interface HSSInterstitialBannerView : UIView

/// WebView 顶部加载进度条可视高度（单位 pt，默认 2）。
/// - 说明：UIProgressView 需要通过 transform 才能真正变粗。
+ (void)setWebViewProgressBarHeight:(CGFloat)height;
+ (CGFloat)webViewProgressBarHeight;

@property (nonatomic, weak, nullable) id<HSSAdDelegate> delegate;

@property (nonatomic, strong) HSSAd *hssAd;

@property (nonatomic, assign) BOOL bannerViewWillHiddened;

// 触发Deeplink跳转事件
@property (nonatomic, copy) adDeeplinkCompletionBlock deeplinkBlock;

// 跳转结果回调（adx_sdk_click_result 埋点）
@property (nonatomic, copy) adClickResultCompletionBlock clickResultBlock;

/// 保存element元素，用户page_view埋点上报
@property (nonatomic, strong, readonly) NSMutableArray<NSDictionary *> *elementArray;

/// 点击
@property (nonatomic, copy) void (^clickAdCompletion)(_Nullable id);

/// 加载成功
@property (nonatomic, copy) void (^loadAdCompletion)(void);

/// 加载失败
@property (nonatomic, copy) void (^loadAdFailedCompletion)(id);

/// MRAID close/unload 事件触发时的关闭回调（is_mraid_close_open=1 时调用）
@property (nonatomic, copy, nullable) void (^mraidCloseBlock)(void);

- (instancetype)initWithAdSize:(CGSize)adSize;

- (void)preLoadWebview:(HSSCreativeItemModel *)itemModel;

- (void)preCreateWebView;

@end

NS_ASSUME_NONNULL_END
