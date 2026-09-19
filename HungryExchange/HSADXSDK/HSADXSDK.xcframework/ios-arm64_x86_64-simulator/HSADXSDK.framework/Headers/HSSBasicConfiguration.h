//
//  HSSBasicConfiguration.h
//  HSADXSDK
//
//  Created by admin on 2024/11/30.
//

#import <Foundation/Foundation.h>
@class HSSdkConfiguration;
NS_ASSUME_NONNULL_BEGIN

typedef void(^HSSdkInitialCompletionHander)(HSSdkConfiguration *configuration);

@interface HSSBasicConfiguration : NSObject

@property(class, nonatomic) HSSdkConfiguration *sdkConfiguration;

+ (void)loadBasicConfiguration:(NSString *)token completionHandler:(HSSdkInitialCompletionHander)completionHandler;

@end

NS_ASSUME_NONNULL_END
