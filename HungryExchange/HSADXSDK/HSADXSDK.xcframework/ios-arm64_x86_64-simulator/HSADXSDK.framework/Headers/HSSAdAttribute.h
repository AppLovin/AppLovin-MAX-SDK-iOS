//
//  HSSAdAttribute.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/2/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 此类用于给AppsFlyer提供归因数据
@interface HSSAdAttribute : NSObject

/// 推广活动名
@property (nonatomic, copy, readonly) NSString *campaignId;

/// 交叉推广归因所需参数
@property (nonatomic, strong, readonly) NSDictionary *crossParams;

/// appid
@property (nonatomic, copy, readonly) NSString *appId;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
