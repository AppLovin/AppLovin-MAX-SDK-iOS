//
//  HSSEndCardView.h
//  HSADXSDK
//
//  Created by admin on 2024/12/9.
//

#import <HSADXSDK/HSSHotClickAreaView.h>

@class HSSContentModel;
NS_ASSUME_NONNULL_BEGIN

@interface HSSEndCardView : HSSHotClickAreaView<HSSViewEndCardProtocol>

@property (nonatomic, strong) HSSContentModel *model;

@property (nonatomic, assign) BOOL hasDoubleEC;

@end

NS_ASSUME_NONNULL_END
