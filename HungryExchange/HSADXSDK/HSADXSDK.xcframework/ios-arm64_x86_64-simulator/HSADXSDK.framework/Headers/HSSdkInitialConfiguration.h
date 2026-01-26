//
//  HSSdkInitialConfiguration.h
//  HSADXSDK
//
//  Created by admin on 2024/11/22.
//

#import <Foundation/Foundation.h>

@class HSSdkConfigurationBuilder;
@class HSSdkSettings;
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const HSAdxSdkAdWayNumKey;

typedef void(^HSSdkConfigurationBuilderBlock)(HSSdkConfigurationBuilder *builder);

@interface HSSdkInitialConfiguration : NSObject

@property(nonatomic, copy,readonly) NSString *sdkKey;

@property (nonatomic, strong, readonly) HSSdkSettings *settings;

+(instancetype)configurationWithSdkKey:(NSString *)key builderBlock:(HSSdkConfigurationBuilderBlock)builderBlock;

- (HSSdkConfigurationBuilder *)configurationBuilder;

@end

NS_ASSUME_NONNULL_END
