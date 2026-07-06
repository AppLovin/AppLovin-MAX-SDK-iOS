//
//  HSSVastPreParseModule.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdCacheCompareModule.h>

NS_ASSUME_NONNULL_BEGIN

/// VAST 预解析模块（纯后台，fire-and-forget）
/// 在有 fill 时对非 winner 的 VAST creative 立即发起解析（不下载），
/// 解析成功后将 resolved 数据（ vast素材数据 等）回写到 MMKV。
/// Ad 类无需感知此模块，降级时通过 CacheCompareModule 从 MMKV 取即可。
@interface HSSVastPreParseModule : NSObject

+ (instancetype)shared;

/// 投入 creative dict 数组进行 VAST 预解析
- (void)feedCreativeDicts:(NSArray<NSDictionary *> *)dicts
                   adType:(NSString *)adType
              placementId:(NSString *)placementId
                   bucket:(HSSAdCacheBucketType)bucket;

@end

NS_ASSUME_NONNULL_END
