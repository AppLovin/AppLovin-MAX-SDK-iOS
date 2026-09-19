//
//  HSSStreamCacheManager.h
//  HSADXSDK
//
//  Created by 张松 on 2026/01/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSStreamCacheManager : NSObject

@property (nonatomic, copy, readonly) NSString *filePath;

- (instancetype)initWithURL:(NSURL *)url;

+ (void)clearAllStreamCache;

- (long long)fileSize;

- (NSFileHandle *)readHandle;
/// 写入数据，返回 YES 成功，NO 失败；error 携带失败原因（磁盘满等）
- (BOOL)appendData:(NSData *)data error:(NSError **)outError;

- (void)truncateAndReset;

@end

NS_ASSUME_NONNULL_END
