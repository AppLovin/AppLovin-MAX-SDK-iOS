//
//  HSSSNetworkingConfig.h
//  Pods-Example
//
//  Created by admin on 2024/11/19.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSNetworkConstant.h>
NS_ASSUME_NONNULL_BEGIN

@interface HSSNetworkingConfig : NSObject

@property (nonatomic, assign) NSInteger timeout;

+ (instancetype)shareInstance;

// 通用基本参数
-(NSDictionary *)baseParams;

// 公共header信息
- (NSMutableDictionary *)header;

// 转换请求方式
- (NSString *)covertRequestMode:(HSSRequestMode)mode;

- (HSSRequestMode)requestModeWithMethod:(NSString *)method;

@end

NS_ASSUME_NONNULL_END
