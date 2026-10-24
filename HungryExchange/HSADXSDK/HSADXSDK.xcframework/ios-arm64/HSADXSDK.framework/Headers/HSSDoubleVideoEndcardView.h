//
//  HSSDoubleVideoEndcardView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/11/6.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseView.h"

@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN

@interface HSSDoubleVideoEndcardView : HSSBaseView

/// 设置上部分的素材模型
@property (nonatomic, strong) HSSCreativeItemModel *topModel;

/// 设置下部分的素材模型
@property (nonatomic, strong) HSSCreativeItemModel *bottomModel;

/// 关闭按钮延迟时间
@property (nonatomic, assign) NSInteger closeDelay;

@end

NS_ASSUME_NONNULL_END
