//
//  HSSAdCompareStrategy.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 默认比价策略：按 bid_price/ecpm 取最高
@interface HSSAdCompareStrategy : NSObject

/// 从 server dicts + cache dicts 中选出最高价（纯 dict 比价，用于 responseObject 流程）
- (NSDictionary * _Nullable)selectHighestPricedFromServerDicts:(NSArray<NSDictionary *> *)serverDicts
                                                   cacheDicts:(NSArray<NSDictionary *> *)cacheDicts;

@end

NS_ASSUME_NONNULL_END
