//
//  HSSStreamDownloadHub.h
//  HSADXSDK
//
//  Created by 张松 on 2026/02/25.
//

#import <Foundation/Foundation.h>

@class HSSStreamDownloadEngine;

NS_ASSUME_NONNULL_BEGIN

@interface HSSStreamDownloadHub : NSObject

+ (HSSStreamDownloadEngine *)sharedEngineForURL:(NSURL *)url;
+ (void)removeEngineForURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
