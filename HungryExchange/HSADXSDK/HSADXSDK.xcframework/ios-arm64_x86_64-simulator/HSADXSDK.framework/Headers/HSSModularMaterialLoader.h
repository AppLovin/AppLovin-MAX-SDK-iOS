//
//  HSSModularMaterialLoader.h
//  HSADXSDK
//
//  Created by 张松
//
//  原子级素材能力提供者（2.0 模板架构基础设施层）。
//
//  设计原则（严格遵守，违反即重构）：
//    1. 只提供"加工 / IO 能力"，不感知业务流程
//       （不知道 VAST 解析后要回填 EndCard 这种业务串联）
//    2. 零埋点：adx_sdk_load_start / vast_parse / load 等所有埋点
//       全部由 Coordinator 在调用前后做
//    3. 不感知 itemModel / segment / material 全貌；
//       只接收 url / xml / 枚举 等原子参数
//    4. 不写 Material 字段：写字段由 Coordinator 编排时做
//
//  与 Coordinator 的协作：
//    Coordinator → 调 Loader.parseVastXml: → 拿到 vast 对象 → 自己写 material.vast
//    Coordinator → 调 Loader.downloadVideoURL: → 拿到 streamLoader → 自己写 material.preloadedStreamLoader
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <HSADXSDK/HSSVastCreativeCompanionAdsModel.h>   // HSSVastCompanionResourceType

@class HSSVastCreativeAdModel;
@class HSSStreamVideoLoader;
@class HSSEndCardWebViewHost;

NS_ASSUME_NONNULL_BEGIN

/// 全静态工具类：纯能力提供，零运行时状态。
/// 调用方直接 [HSSModularMaterialLoader xxx]，无需实例化、无需管理生命周期。
@interface HSSModularMaterialLoader : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

#pragma mark - VAST 解析

/// 解析 VAST XML（无埋点）。
/// @param xml         VAST XML 字符串
/// @param completion  vast：解析后的 VAST 模型（失败时 nil）
///                    vastType："Inline" / "Wrapper" / ""（基于 XML 前缀识别，埋点用）
///                    error：解析错误（成功时 nil）
+ (void)parseVastXml:(NSString *)xml
          completion:(void (^)(HSSVastCreativeAdModel * _Nullable vast,
                               NSString *vastType,
                               NSError * _Nullable error))completion;

#pragma mark - 视频流式下载

/// 启动视频流式下载（无埋点）。
/// @return loader 同步返回，调用方自管 readyHandler / 生命周期；同 url 已有 loader 时返回 nil（去重由 caller 在调用前查 material.preloadedStreamLoader 自管）
/// @param completion ready=YES 表示可播放（下载仍可能继续）；失败时 ready=NO + error
+ (nullable HSSStreamVideoLoader *)downloadVideoURL:(NSString *)url
                                       preferredMime:(nullable NSString *)mime
                                          completion:(void (^)(BOOL ready, NSError * _Nullable error))completion;

#pragma mark - Playable 文件下载

/// 下载 Playable HTML 文件到本地（无埋点）。
/// @param completion success=YES 时 localPath 为本地文件路径
+ (void)downloadPlayableURL:(NSString *)url
                 completion:(void (^)(NSString * _Nullable localPath, BOOL success, NSError * _Nullable error))completion;

#pragma mark - EndCard WebView 预加载（HTML / IFrame）

/// 创建带 MRAID JS + window.open override 的 WKWebView 并发起加载（无埋点）。
/// fire-and-forget 异步：内部切主线程创建 HSSEndCardWebViewHost（含 WKWebView） + 发起加载，完成后回调。
/// Host 从创建起即作为 webview 的 navigationDelegate / UIDelegate / ScriptMessageHandler，
/// 全生命周期不换 delegate（与 1.0 HSSVastImageEndCardView 同构），避免预加载后 delegate 交接丢状态。
/// @param urlOrHtml HTML 模式：HTML 片段；IFrame 模式：URL 字符串
/// @param type      仅支持 Html / IFrame；其他 type completion 回调 nil
/// @param completion 主线程回调；Host 已发起加载（HTML 仍可能在加载中），caller 持有
+ (void)preloadEndCardWebViewWithURLOrHTML:(NSString *)urlOrHtml
                              resourceType:(HSSVastCompanionResourceType)type
                                completion:(void (^)(HSSEndCardWebViewHost * _Nullable host))completion;

#pragma mark - 图片

/// 阻塞下载图片（无埋点）。
+ (void)downloadImageURL:(NSString *)url
              completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

/// 异步预下载图片到 SDWebImage 缓存，fire-and-forget（无埋点）。
+ (void)prefetchImages:(NSArray<NSString *> *)urls;

#pragma mark - 工具

/// Playable URL 对应的本地存储路径（{md5}.{pathExtension}）。
/// 2.0 只支持在线广告，路径固定在 Library 目录。
+ (NSString *)localFilePathForPlayableURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
