//
//  HSSPayDelegate.h
//  HSADXSDK
//
//  Created by admin on 2024/12/19.
//

#import <Foundation/Foundation.h>

@class HSSAd;
NS_ASSUME_NONNULL_BEGIN

@protocol HSSPayDelegate <NSObject>

/**
 * The SDK invokes this callback when it detects a pay event for an ad.
 *
 * The SDK invokes this callback on the UI thread.
 *
 * @param ad The ad for which the pay event was detected.
 */
- (void)didPayEcpmForAd:(HSSAd *)ad;

@end

NS_ASSUME_NONNULL_END
