//
//  HSSTrackInFlightGuard.h
//  HSADXSDK
//
//  监测 GET 请求 in-flight 互斥保护（同 key 同时只允许一个请求在飞）。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSTrackInFlightGuard : NSObject

+ (NSString *)keyForEvent:(nullable NSString *)event
                   source:(nullable NSString *)source
                      url:(nullable NSString *)url;

+ (BOOL)tryEnterWithKey:(nullable NSString *)key;

+ (BOOL)tryEnterWithKey:(nullable NSString *)key ttl:(NSTimeInterval)ttl;

+ (void)leaveWithKey:(nullable NSString *)key;

@end

NS_ASSUME_NONNULL_END
