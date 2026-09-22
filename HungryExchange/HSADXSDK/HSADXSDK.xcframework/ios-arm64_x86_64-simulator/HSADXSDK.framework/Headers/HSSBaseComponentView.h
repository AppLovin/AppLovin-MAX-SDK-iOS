//
//  HSSBaseComponentView.h
//  HSADXSDK
//
//  Created by 张松
//

#import <UIKit/UIKit.h>
#import "HSSAdComponentProtocol.h"

@class HSSControlInfo;
@class HSSRenderContext;

NS_ASSUME_NONNULL_BEGIN

/// 所有广告组件的基类
/// 子类只需要：
///   1. 实现 +componentKey（自注册用；全局唯一）
///   2. 实现 configureWithControlInfo:context:（配置 UI）
///   3. 实现 frameInContainer:（布局）
@interface HSSBaseComponentView : UIView <HSSAdComponentProtocol>

/// 当前组件的配置信息
@property (nonatomic, strong, nullable) HSSControlInfo *controlInfo;

/// 渲染上下文
@property (nonatomic, weak, nullable) HSSRenderContext *context;

/// 组件注册
+ (void)registerComponents;

#pragma mark - 组件查找（由 RenderEngine 调用）

/// 根据 key 精确匹配并创建组件实例
/// @param key 服务端下发的 ControlInfo.key 或客户端约定的 key
/// @return 组件实例，找不到返回 nil（不挂组件）
+ (nullable id<HSSAdComponentProtocol>)componentForKey:(NSString *)key;

/// 仅查询 key 是否注册（不创建实例）。供"挂载前预检 + fallback"场景使用。
+ (BOOL)isComponentRegisteredForKey:(NSString *)key;

#pragma mark - 基类提供的默认实现（供子类调用 [super xxx]）
// 注：这些已不再是 HSSAdComponentProtocol 的必需方法，仅作为本基类的便捷 API 保留，
// 供继承 HSSBaseComponentView 的子类需要自定义挂载/卸载时复用默认行为

- (void)mountToContainer:(UIView *)container;
- (void)unmount;
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
