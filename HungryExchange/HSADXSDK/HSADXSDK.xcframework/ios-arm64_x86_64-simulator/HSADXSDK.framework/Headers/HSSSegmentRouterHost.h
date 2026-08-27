//
//  HSSSegmentRouterHost.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 段路由器的宿主协议。
///
/// 定位：
///   HSSFlowCoordinator 只做「路由决策」（下一段是谁、何时 dismiss），
///   实际的 UIKit 容器操作（addChildViewController / removeFromSuperview / dismissVC）由 host 执行。
///   两者通过协议解耦：Flow 不依赖 UIKit，纯算法可单测；Host 不关心段状态机。
///
/// 典型实现：HSSModularAdVC（作为 UIKit 容器 VC）
@protocol HSSSegmentRouterHost <NSObject>

/// Flow 请求切到指定索引的段
/// 典型实现：
///   1. 通过 HSSSegmentVCFactory 按段类型创建新的 HSSSegmentVC 子类
///   2. 使用 UIKit Containment API（addChildViewController + transitionFromViewController:toViewController:）完成切换
///   3. 更新共享 HSSRenderContext 的 currentSegment / currentSegmentIndex / currentMaterial / currentMedia
- (void)routerRequestsTransitionToSegmentAtIndex:(NSInteger)index;

/// Flow 请求结束整个广告
/// 典型实现：关闭 SKAd Impression / dismiss SKOverlay / destroy AdShowTimer + dismissViewControllerAnimated
/// @param params 透传参数（可包含 close_position 等）
- (void)routerRequestsDismissWithParams:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
