//
//  HSSTmpDoubleEndcardView.h
//  HSADXSDK
//
//  Created by biyingquan on 2026/2/2.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseView.h"
#import <HSADXSDK/HSSVastDoubleEndCardModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSTmpDoubleEndcardView : HSSBaseView

@property (nonatomic, strong) HSSVastDoubleEndCardModel *model;

- (void)preLoadIconUrl:(NSString *)icon;

@end

NS_ASSUME_NONNULL_END
