//
//  HSSADXWeakProxy.h
//  HSADXSDK
//
//  Created by biyingquan on 2024/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// A weak proxy which forward all the message to the target
@interface HSSADXWeakProxy : NSProxy

@property (nonatomic, weak, readonly, nullable) id target;

- (nonnull instancetype)initWithTarget:(nonnull id)target;
+ (nonnull instancetype)proxyWithTarget:(nonnull id)target;
@end

NS_ASSUME_NONNULL_END
