//
//  HSSAdComponentProtocol.h
//  HSADXSDK
//
//  Created by 张松
//

#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSOMIDSessionInteractor.h>

@class HSSControlInfo;
@class HSSRenderContext;
@class HSSComponentAnimation;

NS_ASSUME_NONNULL_BEGIN

/// 所有广告组件的统一协议
///
/// 子类最少只需实现 3 个方法（1 静态 + 2 实例）：
///   +componentKeys / configureWithControlInfo:context: / frameInContainer:
///
/// 设计约定：
///   - 一个组件可以响应多个 key（服务端按场景给同一组件下发不同 key 名）
///   - 所有 key 全局唯一：不同组件的 key 不能重复
///   - 精确匹配：找不到 key 不挂组件（Fail Fast，不做 fallback）
///   - 挂载/卸载由 RenderEngine 统一处理（组件不用管）
///   - destroy 是 @optional：组件有 timer/observer 要清理时才实现
@protocol HSSAdComponentProtocol <NSObject>

@required

#pragma mark - 自注册

/// 组件响应的所有 key 列表（全局唯一；大部分组件数组只有 1 个元素）
///
/// 举例（一个"圆形倒计时"组件 HSSCircularCountDownView 响应单个 key）：
///   @[ @"instl_video_tmpl_5" ]
+ (NSArray<NSString *> *)componentKeys;

#pragma mark - 配置契约（组件持有配置单）

/// 当前 area 的配置信息（key/pos/show/value）
/// 组件在 configureWithControlInfo:context: 里被设值，后续 frame 计算 / 显示时机判断等均读取这份数据
/// 基类 HSSBaseComponentView 已提供存储；老组件通过 class extension 同名 @property 自行合成 ivar
@property (nonatomic, strong, nullable) HSSControlInfo *controlInfo;

/// 渲染上下文（itemModel / tmplInfo / adFormat / currentMedia 等）
/// weak 以避免组件持有整个渲染链路
@property (nonatomic, weak, nullable) HSSRenderContext *context;

/// 使用 ControlInfo + RenderContext 初始化组件
/// 默认实现（基类）会把参数赋给 self.controlInfo / self.context；子类重写时请先 super
/// @param info 当前 area 的配置信息，可能为 nil
/// @param context 渲染上下文（纯数据）
- (void)configureWithControlInfo:(nullable HSSControlInfo *)info
                         context:(HSSRenderContext *)context;

#pragma mark - 布局

/// 组件自己计算 frame
/// @param containerSize 容器尺寸
- (CGRect)frameInContainer:(CGSize)containerSize;

@optional

#pragma mark - 媒体事件钩子

/// 当前段的媒体（video / webview 等）已开始播放时回调，**和组件可见性无关**。
/// 对齐老架构 videoStartPlay: 时机。
///
/// 典型用途：组件内需要"与媒体时间线对齐"的逻辑，例如：
///   - 倒计时 Timer 从媒体开播时刻启动（即使组件当前还是 hidden，计时也已经开始），
///     保证倒计时结束时刻不因 show 策略的延迟显示而漂移
///
/// 注意：本钩子在所有 activeComponents 上触发（无论可见与否），
/// 若只想在组件"变可见"时做动作，请用 componentDidBecomeVisible。
- (void)mediaDidStart;

#pragma mark - 可见性钩子

/// 组件由 hidden 首次变为可见时回调，**和媒体事件无关**。
/// 触发源：框架层（HSSRenderEngine）按 controlInfo.show/value 策略统一调度可见性。
///
/// 当前实现：所有组件挂载时初始 hidden=YES，由框架按 show 策略统一在下列时机翻转：
///   show=1 / 未下发   → 媒体开播时翻转并回调本方法
///   show=2 (AtSeconds)/ 3 (AtPercent) / 4 (BeforeEnd) → 进度到点时翻转并回调本方法
///
/// 典型用途：组件"变可见瞬间"的 UI 动作（如入场自定义动画、重新布局等）。
/// 注意：不要在这里做与媒体时间线对齐的计时逻辑（那应放在 mediaDidStart）。
- (void)componentDidBecomeVisible;

#pragma mark - OMID Friendly Obstruction 自声明

/// 本组件作为 OMID Friendly Obstruction 注册时的 purpose（媒体控件 / 不可见装饰 / 关闭按钮 等）
/// 返回 HSSOMIDFriendlyObstructionOther 表示不注册（默认行为）
/// 框架层（HSSAdEventHandler）在 OMID session 启动后自动遍历活跃组件调用本方法
- (HSSOMIDFriendlyObstructionType)omidFriendlyObstructionPurpose;

/// 作为 OMID Friendly Obstruction 注册时的 detailedReason（合规要求）
/// 未实现则默认使用类名
- (nullable NSString *)omidFriendlyObstructionReason;

#pragma mark - 按钮露出埋点（组件自声明语义）

/// 组件第一次露出（Renderer 翻转 hidden=NO）时上报的埋点语义类型。
/// 框架层（HSSSegmentComponentRenderer）在组件露出瞬间调本方法，
///   返回非空字符串 → 触发响应链事件 hss_buttonDidAppear:type，链路最终走到
///                    closeTrackingManager.recordSkipButtonAppear / recordCloseButtonAppear
///                    （对齐 1.0 HSSButtonDidShowNotification + closeTrackingManager 老埋点）；
///   返回 nil / 空串  → 不触发埋点（默认行为）
///
/// 使用约定：
///   - close / skip 类按钮组件应实现本方法，根据 self.context.currentSegment.nextLink.closeNext
///     决定返回 "close"（关闭语义）或 "skip"（跳过语义，closeNext == "1"）
///   - 其他组件（audio / cta / ad_area / overlay / 渐变遮罩等）不实现本方法
- (nullable NSString *)buttonAppearanceType;

#pragma mark - PageView 埋点（组件自声明本组件贡献的 element 列表）

/// 本组件在 adx_sdk_page_view 上报时贡献的 element 列表。
/// 框架在段主体就绪（段 VC.viewDidAppear）时遍历 activeComponents 收集（respondsToSelector: 守卫）。
/// 每个 element 形如 @{ @"element": @"icon", @"source": @1, @"url": @"..." }；
/// 字段定义严格对齐服务端契约（element 类型 / source 取值）。
/// 返回 nil / 空数组表示本组件不贡献。
- (nullable NSArray<NSDictionary *> *)pageViewElements;

#pragma mark - 销毁

/// 清理组件内部资源（timer、observer 等）
/// 如无需清理可不实现；RenderEngine 会自动做 removeFromSuperview
- (void)destroy;

#pragma mark - 动画

/// 入场前的初始位置（不实现则无位移动画）
- (CGRect)initialFrameInContainer:(CGSize)containerSize;

/// 入场动画参数（不实现则直接出现）
- (nullable HSSComponentAnimation *)mountAnimation;

/// 退场动画参数（不实现则直接移除）
- (nullable HSSComponentAnimation *)unmountAnimation;

@end

NS_ASSUME_NONNULL_END
