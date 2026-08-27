//
//  HSSBannerSegmentVC.h
//  HSADXSDK
//
//  Created by 张松
//

#import "HSSSegmentVC.h"

NS_ASSUME_NONNULL_BEGIN

/// 插屏单 Banner 段 VC（H5 物料 + 关闭入口）。
///
/// 与 HSSVideoSegmentVC / HSSPlayableSegmentVC / HSSEndCardSegmentVC 平级，
/// 通过 HSSSegmentVCFactory 在 segment 类型为 HSSBannerSegment 时创建。
///
/// 段内职责：
///   - 装配 HSSBannerMedia（WebView 渲染 + 三入口点击 + mraid 桥）
///   - 装配 close / ad_area / overlay_area 组件（tmpl 未配 ad_area 时 fallback ad_mark_style_1）
///   - 创建 HSSBannerSegmentEventHandlerImpl（承接 banner 段独有的业务副作用）
///   - 单点触发 OMID prepareAndReport（webView ready 后）
///
/// 不在本类内做（已迁到 EventHandler / Reporting / Coordinator / HSSModularAdVC）：
///   - 点击 ActionRouter（EventHandler.handleAdClicked）
///   - dwell / btf_auto_close（EventHandler；dwell 回前台由 HSSModularAdVC 统一上报）
///   - adx_sdk_show_duration / SKAd impression（HSSModularAdVC 广告级）
///   - 白屏检测启动（EventHandler）
///   - 预加载 / HTML 加载（Coordinator + BannerMedia）
@interface HSSBannerSegmentVC : HSSSegmentVC

@end

NS_ASSUME_NONNULL_END
