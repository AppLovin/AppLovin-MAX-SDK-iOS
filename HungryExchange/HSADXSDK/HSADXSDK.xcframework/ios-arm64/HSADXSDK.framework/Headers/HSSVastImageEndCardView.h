//
//  HSSVastImageEndCardView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/6/20.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseView.h"
#import "HSSVastImageECModel.h"
#import <HSADXSDK/HSSHotClickAreaView.h>

@class HSSControlBtnModel;

NS_ASSUME_NONNULL_BEGIN

@interface HSSVastImageEndCardView : HSSHotClickAreaView

@property (nonatomic, strong) HSSVastImageECModel *model;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, copy)  NSString *htmlSnippet;

- (void)configUIWithAdxModel:(HSSControlBtnModel *)controlModel
           andCountDownValue:(NSInteger)countDownValue;
// only for vast html use
- (void)updateWebMraid;

@end

NS_ASSUME_NONNULL_END
