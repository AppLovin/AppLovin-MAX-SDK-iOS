//
//  HSSStreamResourceLoader.h
//  HSADXSDK
//
//  Created by 张松 on 2026/01/14.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HSSStreamCacheManager;

@interface HSSStreamResourceLoader : NSObject

@property (nonatomic, copy) void (^onRequest)(AVAssetResourceLoadingRequest *req);
@property (nonatomic, assign, readonly) long long expectedContentLength;

+ (dispatch_queue_t)streamQueue;

- (instancetype)initWithCache:(HSSStreamCacheManager *)cache;

- (AVPlayerItem *)buildPlayerItemWithURL:(NSURL *)url preferredMime:(NSString * _Nullable)mime;

- (void)updateContentLength:(long long)expected mimeType:(NSString * _Nullable)mime;
- (void)updatePreferredMimeType:(NSString * _Nullable)mime;
- (void)updateReceivedLength:(long long)received;
- (void)setDownloadFinished:(BOOL)finished;
- (void)setTailData:(NSData * _Nullable)data offset:(long long)offset;

- (void)notifyDataAvailable;

@end

NS_ASSUME_NONNULL_END
