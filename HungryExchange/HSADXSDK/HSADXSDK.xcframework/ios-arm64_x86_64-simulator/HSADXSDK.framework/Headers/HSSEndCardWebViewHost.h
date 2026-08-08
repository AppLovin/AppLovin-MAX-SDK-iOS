//
//  HSSEndCardWebViewHost.h
//  HSADXSDK
//
//  Created by biyingquan
//
//  EndCard HTML / IFrame WebView 宿主：
//    - WKWebView 创建 + 全生命周期持有（从预加载阶段到展示到销毁，delegate 不换人）
//    - 实现 WKNavigationDelegate / WKScriptMessageHandler / WKUIDelegate / HSSAdWebViewMraidPromptProvider
//    - MRAID 状态机（loading → default → hidden）与 emit
//    - 点击沿 WebView 自身响应链上抛（webView → containerView → segment VC）
//    - HTML 内容 viewport + style 包装
//
//  与 1.0 HSSVastImageEndCardView 同构：webview 创建者 = delegate = ScriptMessageHandler = 同一个对象。
//  定位：HSSEndCardMedia 的私有帮手 —— 只管 WebView 内部事务，不感知段 VC / Coordinator / 埋点业务语义。
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <HSADXSDK/HSSVastCreativeCompanionAdsModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSEndCardWebViewHost : NSObject

#pragma mark - 创建

/// 创建 WebView 并发起加载（预加载 + 现场创建统一入口）
/// Host 从创建起即作为 webview 的 navigationDelegate / UIDelegate / ScriptMessageHandler
- (instancetype)initWithURLOrHTML:(NSString *)urlOrHtml
                     resourceType:(HSSVastCompanionResourceType)resourceType;

+ (instancetype)new  NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

#pragma mark - 视图

/// 内部 WKWebView（供外部 addSubview 到容器）；destroy 后置 nil
@property (nonatomic, strong, readonly, nullable) WKWebView *webView;

#pragma mark - MRAID 状态切换

/// 切到 default（play 时触发）：emit stateChange(default) + ready + viewable(YES) + exposure(100)
- (void)transitionToDefaultState;

/// 切到 hidden（destroy 前触发）：emit stateChange(hidden) + viewable(NO) + exposure(0)
- (void)transitionToHiddenState;

#pragma mark - 销毁

/// 完整销毁：若未 hidden 先自动 hidden → stopLoading → 解绑 delegate / handler → removeFromSuperview
/// 幂等
- (void)destroy;

#pragma mark - HTML 包装（供 Coordinator 预加载路径复用）

/// viewport + 自适应 style 包装（对齐 HSSVastImageEndCardView.loadWebview:）
/// Coordinator 预加载路径 + 本类现场创建路径使用同一包装，保证两处行为一致
+ (NSString *)wrapHTMLSnippet:(NSString *)htmlSnippet;

@end

NS_ASSUME_NONNULL_END
