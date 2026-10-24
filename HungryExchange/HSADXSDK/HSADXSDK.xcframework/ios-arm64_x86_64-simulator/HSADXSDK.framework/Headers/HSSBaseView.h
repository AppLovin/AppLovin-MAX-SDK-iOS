//
//  HSSInterstitialBaseView.h
//  HSADXSDK
//
//  Created by admin on 2024/11/22.
//

#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSViewActionDelegate.h>
NS_ASSUME_NONNULL_BEGIN

@interface HSSBaseView : UIView

@property (nonatomic, weak) id<HSSViewActionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
