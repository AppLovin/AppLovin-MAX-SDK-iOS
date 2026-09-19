//
//  HSSBannerMedia.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "HSSMediaProtocol.h"

@class HSSMaterialBanner;
@class HSSRenderContext;
@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN

/// Banner 段的主体媒体层（H5 物料 + WebView 渲染）。
///
/// 行为与 1.0 HSSInterstitialBannerView 完全等价，但严格遵守 2.0 分层契约：
///   - 单一职责 = WebView 加载 + HTML/omid.js 注入 + mraid 桥 + 三入口点击 Router
///   - OMID / SKAd / 白屏检测 / NSNotification 不在 Media 内自决，由
///     HSSBannerSegmentVC + HSSBannerSegmentEventHandlerImpl 监听 readyHandler 后触发
///   - 点击 / mraid close 通过响应链 hss_adClicked: / hss_closeTapped 上抛
///
/// 装配范式（Material 即接口）：
///   1) Material 端：HSSMaterialBanner.preloadedWebView 由 Coordinator 在 load 阶段按 not_preload
///      预创建并 loadHTMLString（与 HSSMaterialPlayable.preloadedWebView 同范式）
///   2) Media 端：init 时优先复用 preloadedWebView；缺失则裸创建 + loadHTMLString
@interface HSSBannerMedia : NSObject <HSSMediaProtocol>

/// 一步装配
/// @param material  Banner 素材（含 data/width/height/isTransform / preloadedWebView）
/// @param context   渲染上下文
- (instancetype)initWithMaterial:(HSSMaterialBanner *)material
                         context:(HSSRenderContext *)context;

#pragma mark - Load 阶段预加载（行为对齐 1.0 setupInterstitialBannerView.preLoadWebview）

/// Coordinator load 阶段调用：main thread 创建带 mraid 桥 + omid.js 的 WKWebView 并 loadHTMLString，
/// didFinishNavigation 成功后通过 completion 上报，并把 webView 关联到 material.preloadedWebView。
///
/// 必须在 main thread 调用（与 HSSWebViewMedia.preloadedWebView 同范式）。
/// not_preload=YES 时调用方应跳过本方法（与 1.0 行为完全等价）。
+ (void)preloadWebViewForMaterial:(HSSMaterialBanner *)material
                          itemModel:(nullable HSSCreativeItemModel *)itemModel
                         completion:(void(^)(BOOL success))completion;

#pragma mark - 加载状态（供 SegmentVC 单点触发 OMID/SKAd/PageView/白屏）

/// webView 是否已 didFinishNavigation 完成
@property (nonatomic, assign, readonly) BOOL isReady;

/// webView didFinishNavigation 成功后回调（一次性，已注入到 mediaView 内）
/// 调用方在 init/装配后立即设置；若 isReady 已是 YES（命中预加载场景）应立即触发一次
@property (nonatomic, copy, nullable) void (^readyHandler)(void);

/// webView didFailNavigation / didFailProvisionalNavigation 时回调（一次性）
/// 调用方据此触发段降级（flow.segmentUnavailableAtIndex:）
@property (nonatomic, copy, nullable) void (^failHandler)(NSError *error);

/// OMID friendly obstruction：H5 加载进度条（show_h5_progress 开启时存在）
- (nullable NSArray<UIView *> *)omidExtraObstructionViews;

/// InnerWebVC（落地页）覆盖展示：对齐 1.0 bannerViewWillHiddened —— 覆盖期间「抑制」MRAID hide
/// （不发送 viewable=NO / state hidden，维持 default/viewable=YES），且不 stop OMID session。
/// 已由 BannerMedia 内部订阅 HSSInnerWebVCWillAppearNotification 自动驱动，通常无需外部调用。
- (void)pauseForOverlayPresentation;
/// InnerWebVC 关闭：解除抑制并在广告仍前台可见时重发 MRAID default/viewable=YES。
/// 已由 BannerMedia 内部订阅 HSSInnerWebVCDidDisappearNotification 自动驱动，通常无需外部调用。
- (void)resumeFromOverlayPresentation;

@end

NS_ASSUME_NONNULL_END
