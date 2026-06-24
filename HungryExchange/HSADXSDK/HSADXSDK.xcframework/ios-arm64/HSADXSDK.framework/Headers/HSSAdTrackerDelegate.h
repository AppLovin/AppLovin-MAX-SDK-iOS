//
//  HSSTrackerDelegate.h
//  HSADXSDK
//
//  Created by admin on 2024/11/29.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HSSAdTrackerDelegate <NSObject>

-(void)hss_adTracker:(NSString *)eventName  params:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
