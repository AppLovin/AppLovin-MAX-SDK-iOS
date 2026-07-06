//
//  HSSALInterstitialVC.h
//  HSADXSDK
//
//  Created by admin on 2025/5/20.
//

#import <HSADXSDK/HSSVideoPlayerVC.h>
#import <HSADXSDK/HSSAdFormat.h>
#import "HSSInterVCProtocol.h"

@class HSSCreativeItemModel;
NS_ASSUME_NONNULL_BEGIN

@interface HSSALInterstitialVC : HSSVideoPlayerVC<HSSInterVCProtocol>

@property (nonatomic, assign) HSSAdFormatType adFormat;

@property (nonatomic, strong) HSSCreativeItemModel *itemModel;

// 触发Deeplink跳转事件
@property (nonatomic, copy) adVCDeeplinkCompletionBlock deeplinkBlock;

// 试玩游戏跳过事件
@property (nonatomic, copy) playableAdSkipBlock skipBlock;

- (void)webviewGameEnd;

@end

NS_ASSUME_NONNULL_END
