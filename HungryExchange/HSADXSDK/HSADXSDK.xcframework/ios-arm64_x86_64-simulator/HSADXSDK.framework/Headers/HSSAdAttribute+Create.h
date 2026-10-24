//
//  HSSAdAttribute+Create.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/2/20.
//

#import "HSSAdAttribute.h"

@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN

@interface HSSAdAttribute (Create)

+ (instancetype)create;

- (void)configure:(HSSCreativeItemModel *)itemModel;

@end

NS_ASSUME_NONNULL_END
