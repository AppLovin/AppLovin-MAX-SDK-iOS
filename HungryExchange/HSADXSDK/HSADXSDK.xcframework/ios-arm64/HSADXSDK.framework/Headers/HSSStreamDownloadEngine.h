//
//  HSSStreamDownloadEngine.h
//  HSADXSDK
//
//  Created by 张松 on 2026/01/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HSSStreamCacheManager;

@protocol HSSStreamDownloadEngineObserver <NSObject>
- (void)engineDidReceiveResponse:(NSHTTPURLResponse *)response;
- (void)engineDidReceiveDataWithReceived:(long long)received expected:(long long)expected;
- (void)engineDidReceiveDataBytes:(NSData *)data offset:(long long)offset;
- (void)engineDidCompleteWithError:(NSError * _Nullable)error;
- (void)engineDidReceiveTailData:(NSData * _Nullable)data offset:(long long)offset error:(NSError * _Nullable)error;
@end

@interface HSSStreamDownloadEngine : NSObject

@property (nonatomic, assign, readonly) long long expectedContentLength;
@property (nonatomic, assign, readonly) long long receivedLength;
@property (nonatomic, copy, readonly) NSString *mimeType;
@property (nonatomic, strong, readonly) HSSStreamCacheManager *cacheManager;

- (instancetype)initWithURL:(NSURL *)url cacheManager:(HSSStreamCacheManager *)cache;

- (void)attachObserver:(id<HSSStreamDownloadEngineObserver>)observer;
- (void)detachObserver:(id<HSSStreamDownloadEngineObserver>)observer;
- (void)start;
- (void)cancel;
- (void)disableProbe;
- (void)resetAndRedownload;
@end

NS_ASSUME_NONNULL_END
