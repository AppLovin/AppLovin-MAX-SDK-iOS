//
//  HSSEndCardMedia.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import "HSSMediaProtocol.h"

@class HSSMaterialEndCardBase;
@class HSSRenderContext;

NS_ASSUME_NONNULL_BEGIN

/// EndCard 段的主体媒体层。
/// 和 HSSVideoMedia / HSSWebViewMedia 架构对称，承载 endcard 段的主体展示内容。
///
/// 数据来源（按优先级）：
///   1. VAST companion（HSSMaterialEndCardBase.vast.companionAds：url / resourceType / preloadedWebViewHost）
///   2. 服务端直下 endcard 图片（HSSMaterialEndCardImage.url）
///   3. 文字型无 url —— Media 层按"纯背景"展示，子组件由 SegmentVC 挂
@interface HSSEndCardMedia : NSObject <HSSMediaProtocol>

/// 一步装配（Material 即接口）
- (instancetype)initWithMaterial:(HSSMaterialEndCardBase *)material
                         context:(HSSRenderContext *)context;

@end

NS_ASSUME_NONNULL_END
