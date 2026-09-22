//
//  HSSStreamVideoLoader.h
//  HSADXSDK
//
//  Created by HSADXSDK on 2026/01/13.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  流式加载协调器
 *  负责下载、缓存、播放代理、决策等模块协同
 */
@interface HSSStreamVideoLoader : NSObject

@property (nonatomic, assign, readonly) BOOL isReused;  // 是否复用
@property (nonatomic, copy, readonly, nullable) NSString *reuseState;  // 复用状态
@property (nonatomic, assign, readonly) BOOL isResume;  // 是否断点续传
@property (nonatomic, assign, readonly) long long resumeOffset;  // 续传起点（字节）
@property (nonatomic, assign, readonly) BOOL isHitCache;

/// 期望的 MIME Type（优先级高于下载响应的 MIMEType）
/// 典型来自 VAST MediaFile.type（如 video/mp4）。用于填充 AVAssetResourceLoader 的 contentType，避免服务端返回 application/octet-stream 导致识别不稳定。
@property (nonatomic, copy, nullable) NSString *preferredMimeType;

/// Ready 回调（moov + 进度达标）
@property (nonatomic, copy, nullable) void (^readyHandler)(void);

/// 超时回调（在超时时刻触发，不依赖 ready）
@property (nonatomic, copy, nullable) void (^timeoutHandler)(NSDictionary *info);

/// 构造好的 PlayerItem，外部直接拿去播放
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;

/// 原始 URL
@property (nonatomic, strong, readonly) NSURL *url;

/// 是否已完全缓存
@property (nonatomic, assign, readonly) BOOL isCached;

/// 下载完成时的本地文件路径，isCached 为 YES 时有效，可直接用 file URL 播放
@property (nonatomic, copy, readonly, nullable) NSString *localFilePath;

/// 下载统计（只读快照）
@property (nonatomic, assign, readonly) long long expectedContentLength;
@property (nonatomic, assign, readonly) long long receivedLength;
@property (nonatomic, assign, readonly) double speedLong;

/**
 *  初始化加载器
 *  @param url 远程视频 URL
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 *  预加载视频（类方法便捷调用）
 *  @param url 视频 URL
 *  @param timeout 超时时间（<=0 表示不限制）
 *  @param completion 完成回调 (success: YES 表示完成或超时截断成功)
 */
+ (HSSStreamVideoLoader *)preloadVideoWithURL:(NSURL *)url timeout:(NSTimeInterval)timeout completion:(void(^)(BOOL success, NSError * _Nullable error))completion;

/**
 *  取消加载（销毁时调用）
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
