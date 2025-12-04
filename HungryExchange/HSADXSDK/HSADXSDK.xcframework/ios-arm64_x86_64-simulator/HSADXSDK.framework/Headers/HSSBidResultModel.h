//
//  HSSBidResultModel.h
//  HSADXSDK
//
//  Created by admin on 2024/12/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSBidResultModel : NSObject

/**
 @param result 竞价结果  YES 胜出, NO 失败 (必传)
 @param price 竞价胜出价格 (必传)
 @param winNetwork 竞价胜出 net (必传)
 @param platform 聚合平台 eg: Max ADX
 */
- (instancetype)initWithResult:(BOOL)result price:(double)price network:(NSString *)winNetwork platform:(NSString *)platform;

/**
 @param result 竞价结果  YES 胜出, NO 失败 (必传)
 @param price 竞价胜出价格 (必传)
 @param winNetwork 竞价胜出 net (必传)
 */
-(instancetype)initWithResult:(BOOL)result price:(double)price network:(NSString *)winNetwork;

/**
 竞价结果  YES 胜出, NO 失败 (必传)
 */
@property (nonatomic, assign, readonly) BOOL result;

/**
 竞价胜出价格 (必传)
 */
@property (nonatomic, assign, readonly) double price;

/**
竞价胜出 net (必传)
 */
@property (nonatomic, copy, readonly) NSString *winNetwork;

/**
聚合平台 ： MAX  ADX 等
 */
@property (nonatomic, copy, readonly) NSString *platform;

/**
 当前广告自身价格(adx 广告价格)
 */
@property (nonatomic, assign) double selfPrice;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
