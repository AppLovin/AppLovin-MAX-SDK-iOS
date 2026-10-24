//
//  HSSAdMaterial+Create.h
//  HSADXSDK
//
//  Created by admin on 2024/12/21.
//

#import "HSSAdMaterial.h"

@class HSSCreativeItemModel;
NS_ASSUME_NONNULL_BEGIN

@interface HSSAdMaterial (Create)

+(instancetype)create;

- (void)configure:(HSSCreativeItemModel *)itemModel;
@end

NS_ASSUME_NONNULL_END
