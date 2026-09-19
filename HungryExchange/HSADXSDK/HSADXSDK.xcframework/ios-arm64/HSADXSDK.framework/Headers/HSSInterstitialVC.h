//
//  HSSInterstitialVC.h
//  HSADXSDK
//
//  Created by admin on 2024/11/28.
//

#import <HSADXSDK/HSSVideoPlayerVC.h>
#import <HSADXSDK/HSSAdFormat.h>
#import "HSSInterVCProtocol.h"


@class HSSCreativeItemModel;
NS_ASSUME_NONNULL_BEGIN

@interface HSSInterstitialVC : HSSVideoPlayerVC<HSSInterVCProtocol>

@property (nonatomic, assign) HSSAdFormatType adFormat;

@property (nonatomic, strong) HSSCreativeItemModel *itemModel;

@property (nonatomic, strong) HSSCreativeItemModel *itemModel2;

// 跳转结果事件
@property (nonatomic, copy) adVCDeeplinkCompletionBlock routerResultBlock;

@property (nonatomic, copy) adVCOldDeeplinkCompletionBlock deeplinkBlock;

// 试玩游戏跳过事件
@property (nonatomic, copy) playableAdSkipBlock skipBlock;

@property (nonatomic, copy) adDwellBlock dwellBlock;

@property (nonatomic, copy) adShowTimeBlock adTimeBlock;

// 按钮出现事件（跳过按钮、关闭按钮）
@property (nonatomic, copy) buttonAppearBlock buttonAppear;

@property (nonatomic, assign, readonly) NSInteger adShowTimeValue;

- (void)webviewGameEnd;

@end

NS_ASSUME_NONNULL_END


