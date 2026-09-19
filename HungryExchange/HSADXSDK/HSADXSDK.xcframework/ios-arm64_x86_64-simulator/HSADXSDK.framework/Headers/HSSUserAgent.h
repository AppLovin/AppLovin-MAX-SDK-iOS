//
//  HSSUserAgent.h
//  HSADXSDK
//
//  Created by admin on 2024/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSUserAgent : NSObject

+ (NSString *)userAgent;

+ (void)getUserAgentFromWebView;

@end

NS_ASSUME_NONNULL_END
