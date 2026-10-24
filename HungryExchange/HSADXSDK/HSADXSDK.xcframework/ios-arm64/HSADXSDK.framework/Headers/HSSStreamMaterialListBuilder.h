//
//  HSSStreamMaterialListBuilder.h
//  HSADXSDK
//
//  Created by 张松 on 2026/01/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HSSCreativeItemModel;

@interface HSSStreamMaterialList : NSObject

@property (nonatomic, copy) NSArray<NSString *> *imageUrls;
@property (nonatomic, copy) NSArray<NSString *> *fileUrls;
@property (nonatomic, copy, nullable) NSString *mainVideoUrl;

@end

@interface HSSStreamMaterialListBuilder : NSObject

- (HSSStreamMaterialList *)buildListWithModel:(HSSCreativeItemModel *)model;

@end

NS_ASSUME_NONNULL_END
