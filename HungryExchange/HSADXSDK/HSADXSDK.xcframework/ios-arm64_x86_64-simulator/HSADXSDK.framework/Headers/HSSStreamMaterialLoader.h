//
//  HSSStreamMaterialLoader.h
//  HSADXSDK
//
//  Created by HSADXSDK on 2026/01/13.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSStreamStats.h>

@class HSSCreativeItemModel;
@class HSSStreamVideoLoader;

NS_ASSUME_NONNULL_BEGIN

/**
 *  流式素材下载器
 *  负责并行处理：
 *  1. 调用 Model 下载非视频素材（图片等）
 *  2. 使用 HSSStreamVideoLoader 预加载视频
 *  3. 处理 Ready 判定（moov + 进度阈值）
 */
@interface HSSStreamMaterialLoader : NSObject

@property (nonatomic, strong, readonly) HSSStreamStats *stats;
@property (nonatomic, strong, readonly, nullable) HSSStreamVideoLoader *videoPreloader;

/**
 *  加载素材（流式模式）
 *
 *  @param model           素材模型
 *  @param timeout         预加载超时时间（通常设为 13s）
 *  @param readyHandler    广告可播放状态回调（moov + 进度阈值同时满足）
 *                         本类保证：readyHandler 仅在 Ready 条件满足时调用。
 *  @param completionHandler 最终下载结果回调 (success: 全部成功, error: 失败信息)
 *                           注意：即使 readyHandler 已经触发，下载可能还在继续（断点续传），
 *                           completionHandler 会在最终所有任务结束时调用。
 */
- (void)loadMaterialWithModel:(HSSCreativeItemModel *)model
                      timeout:(NSTimeInterval)timeout
                 readyHandler:(void(^)(void))readyHandler
            completionHandler:(void(^)(BOOL success, NSError * _Nullable error))completionHandler
               timeoutHandler:(void(^ _Nullable)(NSDictionary *info))timeoutHandler;

/// 取消加载
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
