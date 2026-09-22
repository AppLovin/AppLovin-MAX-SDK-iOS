//
//  HSSDeviceNet.h
//  HSADXSDK
//
//  Created by admin on 2024/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSDeviceNet : NSObject

/**
 *  域名解析ip
 *
 *  @param hostName 域名
 *
 *  @return ip
 */
+ (NSString *)getIPWithHostName:(const NSString *)hostName;

/**
 *  使用getaddrinfo解析ip（支持IPv4/IPv6）
 *
 *  @param hostName 域名
 *
 *  @return ip
 */
+ (NSString *)getIPWithHostNameByAddrInfo:(NSString *)hostName error:(NSError * _Nullable * _Nullable)error;

/**
 *  获取当前设备IP
 *
 *  @return IP，异常情况下返回nil
 */
+ (NSDictionary *)getCurrentDeviceIPS;

@end

NS_ASSUME_NONNULL_END
