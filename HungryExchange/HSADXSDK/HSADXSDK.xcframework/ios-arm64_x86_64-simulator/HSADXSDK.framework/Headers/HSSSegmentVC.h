//
//  HSSSegmentVC.h
//  HSADXSDK
//
//  Created by 张松
//

#import <UIKit/UIKit.h>
#import "HSSSegmentVCContext.h"
#import "HSSSegmentTransitioning.h"
#import "HSSSegmentEventHandler.h"

@class HSSTmplSegment;
@class HSSControlInfo;
@class HSSClickArea;
@protocol HSSAdComponentProtocol;
@protocol HSSMediaProtocol;

NS_ASSUME_NONNULL_BEGIN

/// 段即 UIViewController 架构的基类。
///
/// 定位：
///   每种段（Video / Playable / EndCard）对应一个 HSSSegmentVC 子类，
///   借鉴 UIKit Child View Controller Containment 模式作为 HSSModularAdVC（容器 VC）的 childViewController。
///
/// 职责：
///   - 提供段级容器视图（mediaContainer / componentContainer）
///   - 提供「通用挂载原语」给子类调用（挂 Media / 挂组件 / 挂点击拦截层）
///   - 段进入：UIKit 原生 viewDidAppear（替代 1.5 的自定义 onSegmentChange 回调）
///   - 段结束：由 Parent VC 在切段 completion / dismiss completion 显式调 -performSegmentTearDown
///     （不绑定 viewWillDisappear / viewDidDisappear，避免 push/present 盖住时误清理）
///   - 响应链事件（hss_xxx）在 SegmentVC 就地处理（子类按段语义重写）
///
/// 子类最小实现：
///   - (void)segmentDidLoadAssemble;  // 调用 self.mountMedia: / mountComponent... 组装段内视图
///   可选：重写 viewDidAppear 做段内专属业务（OMID reset 等）
///   可选：重写 performSegmentTearDown 做段结束业务（如 Playable.stopAndReportSkip），末尾 [super ...]
///   可选：实现 HSSSegmentTransitioning 的 -preferredEntryTransitionStyle 定制入场动画
@interface HSSSegmentVC : UIViewController <HSSSegmentTransitioning>

#pragma mark - 数据（由 configureWithSegment:index:context: 注入，之后只读）

/// 段模板配置（服务端下发的数据模型）
@property (nonatomic, strong, readonly, nullable) HSSTmplSegment *segment;

/// 段索引（tmplInfo.segments 中的位置）
@property (nonatomic, assign, readonly) NSInteger segmentIndex;

/// 段 VC 服务门面（访问 tracker / omidManager / flow 等）
@property (nonatomic, weak, readonly, nullable) id<HSSSegmentVCContext> context;

#pragma mark - 容器视图（基类创建，子类直接使用）

/// Media 容器（承载 HSSVideoMedia.mediaView / HSSWebViewMedia.mediaView 等）
@property (nonatomic, strong, readonly) UIView *mediaContainer;

/// 组件容器（承载所有 HSSAdComponentProtocol 组件 + 点击拦截层）
/// 叠在 mediaContainer 之上，userInteractionEnabled=YES 吃空白区域点击
@property (nonatomic, strong, readonly) UIView *componentContainer;

#pragma mark - 段内资产

/// 当前段的 Media（子类通过 mountMedia: 挂入后可读）
@property (nonatomic, strong, readonly, nullable) id<HSSMediaProtocol> currentMedia;

/// 活跃组件列表（供 OMID friendly obstructions / 遍历分发事件等）
@property (nonatomic, strong, readonly) NSMutableArray<id<HSSAdComponentProtocol>> *activeComponents;

/// 段事件处理器（业务集中地）。子类在 segmentDidLoadAssemble 内创建对应实现。
/// 基类自动 forward 通用事件（close / skip / cta / adClicked / countdown / appStore* / buttonAppear）。
/// 段专有事件（media* / mute / playableProgress 等）由子类自己 forward 给具体协议类型的 handler。
@property (nonatomic, strong, nullable) id<HSSSegmentEventHandler> eventHandler;

#pragma mark - 注入（由 HSSSegmentVCFactory 或 Parent VC 调用）

/// 注入段数据 + 服务门面
/// 约定：viewDidLoad 之前调用；一次性赋值，之后不再变更
- (void)configureWithSegment:(HSSTmplSegment *)segment
                        index:(NSInteger)index
                      context:(id<HSSSegmentVCContext>)context;

#pragma mark - 子类重写点

/// 段内 UI 组装入口；viewDidLoad 完成 mediaContainer / componentContainer 建立后自动调用。
/// 子类在此调用 mountMedia: / mountComponentWithControlInfo: / mountClickOverlayForClickArea:element:
/// 完成段内所有视图挂载。
///
/// 基类默认空实现；子类不重写则段内无视图（仅作为兜底，不建议）。
- (void)segmentDidLoadAssemble;

#pragma mark - 通用挂载原语（基类实现，子类直接调用）

/// 挂载 Media：把 media.mediaView 加到 mediaContainer。
/// Media 必须已通过 -initWithMaterial:context: 完成装配（出生即完整），本方法只做 UIKit 装配。
/// @param media  已装配完成的 Media 实例
- (void)mountMedia:(id<HSSMediaProtocol>)media;

/// 按 HSSControlInfo 挂组件（key 从 info.key 取）
/// 内部走 HSSBaseComponentView.componentForKey: → configureWithControlInfo:context: → addSubview
- (void)mountComponentWithControlInfo:(HSSControlInfo *)info;

/// 带 fallback 的挂组件：info.key 未注册时把 info.key 替换为 fallbackKey 再挂。
/// 用于"服务端可能配错 key 的关键组件"（如视频段 close）兜底，避免用户被困。
/// @param info        待挂组件 controlInfo
/// @param fallbackKey 兜底 key（如 close 业务可传 HSSInternalDefaultCloseKey）；为空 / 已注册时退化为普通挂载
- (void)mountComponentWithControlInfo:(HSSControlInfo *)info
                          fallbackKey:(nullable NSString *)fallbackKey;

/// 按指定 key 挂组件（供 CTA / EndCard 等服务端不下发 key、由客户端约定 key 的场景使用）
- (void)mountComponentWithKey:(NSString *)key controlInfo:(nullable HSSControlInfo *)info;

/// 带 fallback 的指定 key 挂组件：key 为空或未注册时改用 fallbackKey 挂。
/// 用于"服务端可能配错 key 的关键组件"（如 EndCard 整卡）兜底，避免段内空白。
/// @param key         主 key（可能服务端下发，可能客户端约定）
/// @param info        可空 controlInfo
/// @param fallbackKey 兜底 key（如 EC 整卡可传 `[[seg class] defaultFallbackStyleKey]`）；为空或主 key 已注册时退化为普通挂载
- (void)mountComponentWithKey:(NSString *)key
                  controlInfo:(nullable HSSControlInfo *)info
                  fallbackKey:(nullable NSString *)fallbackKey;

/// 按 clickArea 配置挂点击拦截层（全屏 / 底部热区 / 不挂）
/// 默认挂在 componentContainer 最底层（组件在上，空白区域点击穿透到 overlay）
/// 按 clickArea.strategy / action / value 三字段决定 overlay frame 与 regionMask：
///   - strategy=1：全屏 frame、无 mask
///   - strategy=2 action=1 value=N：底部 N% 高度 frame、无 mask（N<=0 不挂）
///   - strategy=2 action=2 value=mask：全屏 frame + 2×2 网格位掩码（按命中点所在区判断接管）
/// @param element "media" / "endcard" / "playable"，用于响应链事件参数
- (void)mountClickOverlayForClickArea:(nullable HSSClickArea *)clickArea element:(NSString *)element;

#pragma mark - 查询（供基类内部与子类使用）

/// 当前 clickArea 是否「全屏可点」（对齐 1.0 is_full_screen_click 语义）
- (BOOL)isFullScreenClickEnabledForClickArea:(nullable HSSClickArea *)clickArea;

#pragma mark - 段生命周期（Parent VC 显式驱动）

/// 段结束：显式清理段内资源（组件 destroy / Media destroy / Playable Timer stop + 埋点等）
///
/// 调用方：仅 Parent VC（HSSModularAdVC）—— 段切换 completion / dismiss completion 时调用
/// 不由 UIKit view lifecycle（viewWillDisappear / viewDidDisappear）触发，
/// 避免"push/present 新 VC 盖住段"场景下误清理。
///
/// 幂等：多次调用安全（内部标记保证只执行一次）
/// 兜底：dealloc 会再调一次，防止异常路径漏清理
///
/// 子类可重写：先做段结束业务（如 Playable.stopAndReportSkip），再 [super performSegmentTearDown]
- (void)performSegmentTearDown;

#pragma mark - Host → Segment 事件下发

/// Host VC 通知段：SK AppStore 弹窗已关闭。
///
/// 调用链：HSSModularAdVC.productViewControllerDidFinish: → 调本方法。
/// 基类默认实现：沿响应链上抛 hss_appStoreDidDismiss（由基类自动 forward 给 eventHandler）。
/// 子类可重写：先驱动 currentMedia.handleAppStoreDidDismiss（视频段恢复播放），再 [super ...]。
- (void)notifyAppStoreDidDismiss NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
