//
//  HSSReadyAdInfo.h
//  HSADXSDK
//
//  Created by admin on 2026/3/3.
//

#import <Foundation/Foundation.h>

@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN

@interface HSSReadyAdInfoManager : NSObject
+ (void)addReadyAdInfoFromCreative:(HSSCreativeItemModel *)creative
                      commonParams:(NSDictionary *)commonParams;

+ (void)removeReadyAdInfoWithAdUnitId:(NSString *)maxAdUnitId;

+ (void)recordBidCountForAdUnitId:(NSString *)AdUnitId ecpm:(double)ecpm networkName:(NSString *)networkName;

@end

NS_ASSUME_NONNULL_END
