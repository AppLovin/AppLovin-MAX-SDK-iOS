//
//  ALUserSegment.h
//  AppLovinSDK
//
//  Created by Thomas So on 10/30/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * User segments allow AppLovin to serve ads by using custom-defined rules that are based on which segment the user is in. User segments are custom strings of
 * 32 alphanumeric characters or less.
 */
 // [PLP] {@see} to upcoming docs page on segmentation?
@interface ALUserSegment : NSObject

/**
 * A custom user segment name with 32 alphanumeric characters or less, as defined in your AppLovin dashboard.
 */
 // [PLP] {@see} to the page in the AppLovin dashboard where the developer can define these?
@property (nonatomic, copy, nullable) NSString *name;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
