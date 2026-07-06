//
//  HSSReachabilityManager.h
//  Pods-Example
//
//  Created by admin on 2024/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSReachabilityManager : NSObject

+ (instancetype)shared;

- (BOOL)isReachable;

- (BOOL)isReachableViaWWAN;

- (BOOL)isReachableViaWiFi;

- (NSString *)getNetCarrier;

//获得国家区域编码：un  先取得sim代表的国家代号，取不到，再取系统设置的地区代号
- (NSString *)getCountryCode;

//获得sim对应的mcc&mnc
- (NSString *)getMccMnc;

- (NSString *)getNetWorkStatus;

- (NSInteger)getNetStatusType;

// 启动网络监控
- (void)startMonitoring;

// 停止网络监控
- (void)stopMonitoring;

@end

NS_ASSUME_NONNULL_END
