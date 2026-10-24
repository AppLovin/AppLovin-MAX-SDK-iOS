//
//  HSSModularCreativeAdapter.h
//  HSADXSDK
//
//  Created by 张松
//
//  2.0 模块化 creative 数据 → 1.0 渲染管线老字段适配器（Adapter 层入口）。
//
//  架构定位：
//    - 1.0 / 2.0 桥接层：服务端下发 2.0 模板字段，1.0 渲染管线（Banner / ImageText）
//      只认老字段（itemModel.banner / images / icon / title / desc / ext.btn）。
//      本类把 2.0 的 itemModel.adInfo.material 拍平到 1.0 老字段，让老渲染管线无感复用。
//    - 项目级共享：Banner / ImageText 多个入口（HSSModularAdSession load / show 等）共用。
//    - 仅处理"单 creative + N material"形态。拼接广告（placement.is_mix == 1）由
//      HSSModularAdCoordinator.shouldUseModular 提前拦截，整条链路走 1.0 老路径，
//      不进入本 Adapter。
//
//  与姐妹类 HSSModularAdReportingAdapter 的关系：
//    - HSSModularAdReportingAdapter ：埋点路径适配（2.0 调用 → 1.0 HSSAdTrackingCenter）
//    - HSSModularCreativeAdapter（本类）：数据字段适配（2.0 adInfo.material → 1.0 itemModel 老字段）
//

#import <Foundation/Foundation.h>

@class HSSCreativeItemModel;
@class HSSPlacementsModel;

NS_ASSUME_NONNULL_BEGIN

@interface HSSModularCreativeAdapter : NSObject

/// 把 itemModel.adInfo.material 里的 2.0 模块化字段，适配为 1.0 渲染管线消费的老字段。
///
/// 数据流：
///   itemModel.adInfo.material（2.0 MaterialItem 数组）
///     ──> itemModel.banner                                                （banner 类型）
///     ──> itemModel.title / desc / images / icon / ext.btn                （image_text 类型）
///
/// 调用时机：
///   - Load 入口：HSSModularAdSession.loadWithItemModel: 进入路由前调用一次
///   - Show 入口：HSSModularAdSession.showWithItemModel: 进入路由前防御性再调一次
///   - 视频路径（material_type=video/playable）不走本方法，原样跳过
///
/// 内部按 itemModel.material_type 自分发到具体归一化策略。
///
/// 参数：
///   @param itemModel  2.0 服务端下发的 creative，会就地修改其老字段
///   @param placement  当前广告所属的 placement；保留参数供未来按 placement 维度的归一化扩展使用
///
/// 线程安全：
///   - 本类无状态，多广告位并发调用各自隔离
///   - caller 须保证 itemModel/placement 在调用期间不被其他线程改写
+ (void)adaptAdInfoToLegacyFieldsForItemModel:(HSSCreativeItemModel *)itemModel
                                       placement:(nullable HSSPlacementsModel *)placement;

@end

NS_ASSUME_NONNULL_END
