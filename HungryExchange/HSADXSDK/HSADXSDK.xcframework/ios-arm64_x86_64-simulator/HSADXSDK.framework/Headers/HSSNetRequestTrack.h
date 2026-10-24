//
//  HSSNetRequestTrack.h
//  HSADXSDK
//
//  Created by biyingquan on 2024/12/18.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSNetRequestTrack : NSObject
// 网络请求结果上报事件接口 事件上报时机：任意网络结果请求上报事件
+ (void)netRequestTrack:(NSURLResponse *_Nullable)response responseObject:(id _Nullable)responseObject error:(HSSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END

