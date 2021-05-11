//
//  ALUserSegment.h
//  AppLovinSDK
//
//  Created by Thomas So on 10/30/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * User segments allow us to serve ads using custom-defined rules based on which segment the user is in. For now, we only support a custom string 32 alphanumeric characters or less as the user segment.
 */
@interface ALUserSegment : NSObject

/**
 * Custom segment name with 32 alphanumeric characters or less defined in your AppLovin dashboard.
 */
@property (nonatomic, copy, nullable) NSString *name;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
