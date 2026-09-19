//
//  NSURL+HSURL.h
//  Pods-Example
//
//  Created by admin on 2024/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (HSSURL)

+ (NSURL *)hss_URLWithString:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
