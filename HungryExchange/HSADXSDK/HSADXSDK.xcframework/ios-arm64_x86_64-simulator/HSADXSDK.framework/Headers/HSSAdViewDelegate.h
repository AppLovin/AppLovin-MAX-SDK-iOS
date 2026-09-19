//
//  HSSAdViewDelegate.h
//  HSADXSDK
//
//  Created by admin on 2024/12/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HSSAdViewDelegate <NSObject>

-(void)didClickClose;

-(void)didClickSkip;

-(void)didGetRewarded;

-(void)didDisplayAd;

-(void)didFailToDisplayAd;


@end

NS_ASSUME_NONNULL_END
