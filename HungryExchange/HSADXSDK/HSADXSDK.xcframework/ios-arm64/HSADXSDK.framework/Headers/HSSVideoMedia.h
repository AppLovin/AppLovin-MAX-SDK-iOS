//
//  HSSVideoMedia.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import "HSSMediaProtocol.h"

@class HSSMaterialVideo;
@class HSSRenderContext;

NS_ASSUME_NONNULL_BEGIN

@interface HSSVideoMedia : NSObject <HSSMediaProtocol>

/// 一步装配（Material 即接口）
/// @param material     视频素材（含 url / vast / preloadedStreamLoader 等所有播放所需字段）
/// @param initialMuted 段配置 audioArea.isMuted + 全局 mute 开关合并值（user mute 在内部从 context.muteUserStatus 取，优先级更高）
/// @param context      渲染上下文（读 muteUserStatus 等跨段状态）
- (instancetype)initWithMaterial:(HSSMaterialVideo *)material
                    initialMuted:(BOOL)initialMuted
                         context:(HSSRenderContext *)context;

/// 截取当前视频帧
- (nullable UIImage *)captureCurrentFrame;

/// 截取视频最后一帧
- (nullable UIImage *)captureLastFrame;

@end

NS_ASSUME_NONNULL_END
