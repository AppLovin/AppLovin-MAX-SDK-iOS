//
//  HSSSKAdnEventTracker.h
//  HSADXSDK
//
//  Created by admin on 2024/12/13.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface HSSSKAdnEventTracker : NSObject
+(void)startImpression:(SKAdImpression *)impression API_AVAILABLE(ios(14.5));
+(void)endImpression:(SKAdImpression *)impression API_AVAILABLE(ios(14.5));
@end

NS_ASSUME_NONNULL_END
