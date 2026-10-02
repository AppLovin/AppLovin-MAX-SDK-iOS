//
//  HSSAdInfo.h
//  HSADXSDK
//
//  Created by 张松
//

#import "HSSBaseModel.h"

@class HSSMaterialItem;

NS_ASSUME_NONNULL_BEGIN

@interface HSSAdInfo : HSSBaseModel

/// 素材数组（和 TmplInfo.segments 按索引一一对应）
@property (nonatomic, strong) NSArray<HSSMaterialItem *> *material;

@end

NS_ASSUME_NONNULL_END
