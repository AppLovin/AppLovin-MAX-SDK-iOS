//
//  HSSSegmentClickOverlay.h
//  HSADXSDK
//
//  Created by 张松
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 点击拦截层：捕获段范围内的点击手势并通过响应链抛出 hss_adClicked: 事件。
///
/// 挂载约定：
///   由 HSSSegmentVC 基类在 mountClickOverlayForClickArea:element: 中按 clickArea 配置挂载，
///   挂在 componentContainer 的最底层，保证按钮命中走按钮、空白命中走 overlay。
///
/// frame 与 regionMask 的协作：
///   - strategy=1（全屏）/ strategy=2 action=1（底部高度比例）：overlay frame 已是精确热区，
///     regionMask=0 → 整个 frame 内点击都接管。
///   - strategy=2 action=2（区域选择）：overlay frame 铺满 componentContainer，
///     regionMask 为四区位掩码（1×4 水平条带：bit0=区1 顶部 / bit1=区2 上中 / bit2=区3 下中 / bit3=区4 底部），
///     hitTest 时按命中点所在条带判断当前点是否在选中区域，否则透传到下层。
///
/// 对齐旧架构：
///   语义与 HSSRenderEngine.m 内的同名内部类一致，后续 RenderEngine 删除后由本类承接。
@interface HSSSegmentClickOverlay : UIView

/// 区域位掩码（1×4 水平条带）；0 表示无 mask（整个 frame 都接管）。
/// bit0=区1 顶部 / bit1=区2 上中 / bit2=区3 下中 / bit3=区4 底部；
/// 例：value=12 (1100) → 选中 区3+区4（下半屏）。
@property (nonatomic, assign, readonly) NSInteger regionMask;

/// @param params 透传给响应链 hss_adClicked: 的参数（element / click_source / fromSource 等）
/// @param mask   区域选择位掩码；0 表示无 mask（整个 frame 都接管）
- (instancetype)initWithClickParams:(nullable NSDictionary *)params
                          regionMask:(NSInteger)mask NS_DESIGNATED_INITIALIZER;

/// 兼容入口：等价于 initWithClickParams:params regionMask:0
- (instancetype)initWithClickParams:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
