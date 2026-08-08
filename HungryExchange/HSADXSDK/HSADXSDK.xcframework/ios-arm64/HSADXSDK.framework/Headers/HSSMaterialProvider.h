//
//  HSSMaterialProvider.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>

@class HSSCreativeItemModel;
@class HSSTmplSegment;
@class HSSMaterialItem;

NS_ASSUME_NONNULL_BEGIN

/// 素材查找：按"段类型 + 同类型 ordinal"从 itemModel.adInfo.material 里取对应素材。
/// 单一职责：仅做查找；端侧加工产物（streamLoader / webView）通过 Material 自身字段流转，不再经此中介。
@interface HSSMaterialProvider : NSObject

- (instancetype)initWithItemModel:(HSSCreativeItemModel *)itemModel;

/// 按"段类型 + 同类型 ordinal"查找 adInfo.material 里对应的 HSSMaterialItem
/// 注：segment 和 material 不是一一对应（例：[video, endcard] 2 段 vs [video, video, endcard] 3 个 material），
/// 这里按"段在同类型 segments 中的序号"匹配"同类型 materials 里的序号"。
- (nullable HSSMaterialItem *)materialForSegment:(HSSTmplSegment *)segment
                                           atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
