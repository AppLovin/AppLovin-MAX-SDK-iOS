//
//  HSSWebViewMedia.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import "HSSMediaProtocol.h"

@class HSSMaterialPlayable;
@class HSSRenderContext;

NS_ASSUME_NONNULL_BEGIN

@interface HSSWebViewMedia : NSObject <HSSMediaProtocol>

/// 一步装配（Material 即接口）
/// @param material  Playable 素材（含 url / preloadedWebView / localFilePath）
/// @param context   渲染上下文
- (instancetype)initWithMaterial:(HSSMaterialPlayable *)material
                         context:(HSSRenderContext *)context;

@end

NS_ASSUME_NONNULL_END
