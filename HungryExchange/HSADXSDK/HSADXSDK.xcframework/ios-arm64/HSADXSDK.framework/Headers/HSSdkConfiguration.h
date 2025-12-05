//
//  HSSdkConfiguration.h
//  HSADXSDK
//
//  Created by admin on 2024/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSdkConfiguration : NSObject

///上报地址
@property (nonatomic, copy, readonly) NSString *reportHost;

///当前国家
@property (nonatomic, copy, readonly) NSString *country;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
