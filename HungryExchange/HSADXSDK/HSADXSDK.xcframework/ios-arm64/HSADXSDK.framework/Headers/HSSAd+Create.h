//
//  HSSAd+Create.h
//  HSADXSDK
//
//  Created by admin on 2024/12/20.
//

#import "HSSAd.h"

@class HSSCreativeItemModel;
@class HSSAdsModel;
NS_ASSUME_NONNULL_BEGIN

@interface HSSAd (Create)

+(instancetype)create;

- (void)configure:(NSString *)placementId rid:(NSString *)rid adFormat:(HSSAdFormatType)format itemModel:(HSSAdsModel *)adsModel;

- (void)configure:(NSString *)placementId rid:(NSString *)rid isLocal:(BOOL)isLocal adFormat:(HSSAdFormatType)format creativeItemModel:(HSSCreativeItemModel *)creativeItemModel;

@end

NS_ASSUME_NONNULL_END
