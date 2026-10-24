//
//  HSSFidelityModel.h
//  HSADXSDK
//
//  Created by biyingquan on 2024/12/12.
//

#import "HSSBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSFidelityModel : HSSBaseModel

// 归因方式。0: 展示归因，1: 点击归因
@property (nonatomic, copy) NSString *fidelity;

/// 每个skadn返回体都不同的随机字符串
@property (nonatomic, copy) NSString *nonce;

/// 用于签名的时间戳，单位为毫秒
@property (nonatomic, copy) NSString *timeStamp;

/// 符合苹果SkAdNetwork规范的签名
@property (nonatomic, copy) NSString *signature;

@end

NS_ASSUME_NONNULL_END
