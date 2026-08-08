//
//  HSSVastDoubleEndCardView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/7/16.
//

#import <HSADXSDK/HSADXSDK.h>
#import <HSADXSDK/HSSVastDoubleEndCardModel.h>
#import <HSADXSDK/HSSBaseView.h>
#import "HSSHotClickAreaView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSVastDoubleEndCardView :HSSHotClickAreaView

@property (nonatomic, strong) HSSVastDoubleEndCardModel *model;

- (void)preLoadIconUrl:(NSString *)icon;

@end

NS_ASSUME_NONNULL_END
