//
//  HSSInterstitialVideoCountdownHost.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/04/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSViewActionDelegate.h>
#import "HSSVideoSkipTemplateHandler.h"

@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN

/// 插屏/激励视频「新倒计时模板」：子视图创建与布局，并实现 `HSSVideoSkipTemplatePerforming`；`viewActionDelegate` 通常为 VC。
@interface HSSInterstitialVideoCountdownHost : NSObject <HSSVideoSkipTemplatePerforming>

@property (nonatomic, weak, nullable) HSSCreativeItemModel *itemModel;

- (instancetype)initWithContainerView:(UIView *)containerView
                 viewActionDelegate:(id<HSSViewActionDelegate>)viewActionDelegate;

- (void)teardownAllCountdownViews;

@end

NS_ASSUME_NONNULL_END
