//
//  HSSdkConfiguration+Create.h
//  HSADXSDK
//
//  Created by admin on 2024/12/24.
//

#import "HSSdkConfiguration.h"

@class HSSConfigureModel;
NS_ASSUME_NONNULL_BEGIN

@interface HSSdkConfiguration (Create)

+(instancetype)create;

-(void)configure:(HSSConfigureModel *)configureModel;
@end

NS_ASSUME_NONNULL_END
