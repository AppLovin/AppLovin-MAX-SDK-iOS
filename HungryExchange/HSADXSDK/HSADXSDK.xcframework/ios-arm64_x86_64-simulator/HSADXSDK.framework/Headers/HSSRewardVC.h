//
//  HSSRewardVC.h
//  HSADXSDK
//
//  Created by admin on 2024/11/28.
//

#import <HSADXSDK/HSSVideoPlayerVC.h>

typedef void(^rewardAdDeeplinkCompletionBlock)(BOOL result, NSString *_Nullable deeplinkUrl);

@class HSSCreativeItemModel;
NS_ASSUME_NONNULL_BEGIN

@interface HSSRewardVC : HSSVideoPlayerVC

@property (nonatomic, strong) HSSCreativeItemModel *itemModel;

// 触发Deeplink跳转事件
@property (nonatomic, copy) rewardAdDeeplinkCompletionBlock deeplinkBlock;

@end

NS_ASSUME_NONNULL_END
