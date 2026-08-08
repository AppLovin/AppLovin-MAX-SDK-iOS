//
//  HSSInterVCProtocol.h
//  HSADXSDK
//
//  Created by admin on 2025/5/20.
//

#import <Foundation/Foundation.h>
#import "HSSCreativeItemModel.h"
#import <HSADXSDK/HSSJumpTrackingContext.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^adVCDeeplinkCompletionBlock)(BOOL result, NSString *_Nullable deeplinkUrl, HSSJumpTrackingContext *_Nullable context, HSSCreativeItemModel *itemModel, BOOL is_auto);
/// 兼容旧版本的Router逻辑
typedef void(^adVCOldDeeplinkCompletionBlock)(BOOL result, NSString *_Nullable deeplinkUrl);

typedef void(^playableAdSkipBlock)(NSInteger duration, NSString *endReason);
typedef void(^adDwellBlock)(NSInteger duration);
typedef void(^adShowTimeBlock)(NSInteger duration);
typedef void(^buttonAppearBlock)(NSString *buttonType);

@protocol HSSInterVCProtocol <NSObject>

@property (nonatomic, assign) HSSAdFormatType adFormat;

@property (nonatomic, strong) HSSCreativeItemModel *itemModel;

@property (nonatomic, strong) HSSCreativeItemModel *itemModel2;

// 跳转结果事件
@property (nonatomic, copy) adVCDeeplinkCompletionBlock routerResultBlock;

// 触发Deeplink跳转事件
@property (nonatomic, copy) adVCOldDeeplinkCompletionBlock deeplinkBlock;

// 试玩游戏跳过事件
@property (nonatomic, copy) playableAdSkipBlock skipBlock;

@property (nonatomic, copy) adDwellBlock dwellBlock;

@property (nonatomic, copy) adShowTimeBlock adTimeBlock;

// 按钮出现事件（跳过按钮、关闭按钮）
@property (nonatomic, copy) buttonAppearBlock buttonAppear;

@property (nonatomic, assign, readonly) NSInteger adShowTimeValue;

- (void)webviewGameEnd;
- (void)skipActionFromWebView;
@end

NS_ASSUME_NONNULL_END
