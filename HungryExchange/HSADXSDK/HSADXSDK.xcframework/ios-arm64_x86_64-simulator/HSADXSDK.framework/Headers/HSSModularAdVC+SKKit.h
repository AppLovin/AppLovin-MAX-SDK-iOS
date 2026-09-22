//
//  HSSModularAdVC+SKKit.h
//  HSADXSDK
//
//  Created by 张松
//
//  Apple StoreKit 集成合并：
//    - SKAd     : SKAdNetwork 归因（iOS 14.5+）
//                 viewDidAppear 首次可见时 startImpression；dismiss 时 endImpression
//    - SKOverlay: SKOverlay 推荐弹窗（iOS 14+）
//                 每个视频段独立触发一次，EndCard / Playable 段不触发；dismiss 时主动 dismiss
//

#import "HSSModularAdVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSModularAdVC (SKKit)

#pragma mark - SKAdNetwork（归因）

- (void)startSKAdImpression;
- (void)endSKAdImpression;

#pragma mark - SKOverlay（推广横幅）

/// 指定视频段索引首次可见时调用；重复索引会短路 return
- (void)checkSKOverlayForVideoSegmentIndex:(NSInteger)index;

/// 关闭 overlay（dismiss 流程中调用）
- (void)dismissSKOverlay;

@end

NS_ASSUME_NONNULL_END
