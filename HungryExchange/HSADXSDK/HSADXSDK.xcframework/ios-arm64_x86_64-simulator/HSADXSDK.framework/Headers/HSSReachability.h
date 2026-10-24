//
//  HSSReachability.h
//  Pods-Example
//
//  Created by admin on 2024/11/19.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSNetworking.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const kHSSReachabilityChangedNotification;

typedef enum : NSUInteger {
    HSSNetStatusTypeUnknown = 0,
    HSSNetStatusTypeEthernet,
    HSSNetStatusTypeWifi,
    HSSNetStatusTypeUnWWAN,
    HSSNetStatusType2G,
    HSSNetStatusType3G,
    HSSNetStatusType4G,
    HSSNetStatusType5G,
} HSSNetStatusType;

@interface HSSReachability : NSObject


+ (HSSNetworkReachabilityManager *_Nullable)reachability;

/**
 网络是否可用

 @return YES or NO
 */
+ (BOOL)reachable;


/**
 是否是蜂窝网络

 @return YES or NO
 */
+ (BOOL)reachableViaWWAN;


/**
 判断是否是WIFT

 @return YES or NO
 */
+ (BOOL)reachableViaWiFi;


/**
 返回当前网络字符串

 @return 值包括：Wifi、2G、3G、4G、Unknown
 */
+ (NSString *_Nonnull)networkStatus;


/**
 @return 网络状态类型
 */
+(HSSNetStatusType)netType;

/**
 启动网络监控
 */
+ (void)startMonitoring;


/**
 停止网络监控
 */
+ (void)stopMonitoring;



@end

NS_ASSUME_NONNULL_END
