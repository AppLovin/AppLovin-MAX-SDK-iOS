//
//  HSSWhiteScreenDetector.h
//  HSADXSDK
//
//  Created on 2025/12/13.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 白屏检测结果结构体

typedef struct {
    BOOL isWhiteScreen;           /// 是否判定为白屏
    CGFloat whitePixelRatio;      /// 白色像素占比 (0.0 - 1.0)
    CGFloat avgBrightness;        /// 平均亮度值 (0.0 - 1.0)
    NSUInteger totalPixels;       /// 总像素数
    NSUInteger whitePixels;       /// 白色像素数
    BOOL isValid;                 /// 检测结果是否有效
} HSSWhiteScreenDetectResult;

#pragma mark - 白屏检测配置

@interface HSSWhiteScreenDetectConfig : NSObject

/// 白色像素判定阈值 (默认 0.95，即 RGB 都大于 242)
/// 值范围: 0.0 - 1.0，值越大判定标准越严格
@property (nonatomic, assign) CGFloat whiteColorThreshold;

/// 白屏判定阈值 - 白色像素占比 (默认 0.97，即 97% 以上像素为白色)
/// 值范围: 0.0 - 1.0
@property (nonatomic, assign) CGFloat whiteScreenThreshold;

/// 亮度判定阈值 (默认 0.98，辅助判断)
/// 值范围: 0.0 - 1.0
@property (nonatomic, assign) CGFloat brightnessThreshold;

/// 检测延迟时间 (默认 0.5 秒)
/// WKWebView 加载完成后延迟一段时间再检测，确保渲染完成
@property (nonatomic, assign) NSTimeInterval detectDelay;

/// 采样间隔 (默认 2)
/// 为了提高性能，每隔 N 个像素采样一次，1 表示不跳过
@property (nonatomic, assign) NSUInteger samplingInterval;

/// 是否忽略透明像素 (默认 YES)
@property (nonatomic, assign) BOOL ignoreTransparentPixels;

/// 最小有效像素数 (默认 100)
/// 如果有效像素数小于此值，认为检测结果无效
@property (nonatomic, assign) NSUInteger minValidPixels;

/// 边缘忽略比例 (默认 0.02，即忽略边缘 2%)
/// 忽略 WebView 边缘区域，避免边框影响检测结果
@property (nonatomic, assign) CGFloat edgeIgnoreRatio;

/// 获取默认配置
+ (instancetype)defaultConfig;

@end

#pragma mark - 白屏检测回调

/// 白屏检测完成回调
/// @param result 检测结果
/// @param snapshotImage 截图图片（WebView 的截屏），如果截图失败则为 nil
/// @param error 错误信息，nil 表示检测成功
typedef void(^HSSWhiteScreenDetectCompletion)(HSSWhiteScreenDetectResult result, UIImage * _Nullable snapshotImage, NSError * _Nullable error);

#pragma mark - 白屏检测器

/**
 * WKWebView 白屏检测工具类
 * 
 * 功能：
 * 1. 对 WKWebView 进行截图并分析像素
 * 2. 计算白色像素占比，判断是否为白屏
 * 3. 支持自定义检测配置
 * 4. 支持异步检测和回调
 * 5. 提供上报接口
 *
 * 使用示例：
 * @code
 * // 基本使用
 * [HSSWhiteScreenDetector detectWhiteScreenForWebView:webView completion:^(HSSWhiteScreenDetectResult result, NSError *error) {
 *     if (result.isValid && result.isWhiteScreen) {
 *         NSLog(@"检测到白屏，白色像素占比: %.2f%%", result.whitePixelRatio * 100);
 *     }
 * }];
 *
 * // 自定义配置
 * HSSWhiteScreenDetectConfig *config = [HSSWhiteScreenDetectConfig defaultConfig];
 * config.whiteScreenThreshold = 0.90; // 90% 白色像素即判定为白屏
 * [HSSWhiteScreenDetector detectWhiteScreenForWebView:webView config:config completion:^(HSSWhiteScreenDetectResult result, NSError *error) {
 *     // 处理结果
 * }];
 * @endcode
 */
@interface HSSWhiteScreenDetector : NSObject

#pragma mark - 单次检测方法

/**
 * 检测 WKWebView 是否白屏（使用默认配置）
 * @param webView 要检测的 WKWebView
 * @param completion 检测完成回调
 *
 * @discussion 此方法会在主线程截图，在后台线程分析像素，最后在主线程回调
 */
+ (void)detectWhiteScreenForWebView:(WKWebView *)webView
                         completion:(HSSWhiteScreenDetectCompletion)completion;

/**
 * 检测 WKWebView 是否白屏（自定义配置）
 * @param webView 要检测的 WKWebView
 * @param config 检测配置，nil 时使用默认配置
 * @param completion 检测完成回调
 */
+ (void)detectWhiteScreenForWebView:(WKWebView *)webView
                             config:(nullable HSSWhiteScreenDetectConfig *)config
                         completion:(HSSWhiteScreenDetectCompletion)completion;

/**
 * 延迟检测 WKWebView 是否白屏
 * @param webView 要检测的 WKWebView
 * @param delay 延迟时间（秒）
 * @param config 检测配置，nil 时使用默认配置
 * @param completion 检测完成回调
 *
 * @discussion 在 WKWebView 加载完成后调用，延迟一定时间确保渲染完成后再检测
 */
+ (void)detectWhiteScreenForWebView:(WKWebView *)webView
                         afterDelay:(NSTimeInterval)delay
                             config:(nullable HSSWhiteScreenDetectConfig *)config
                         completion:(HSSWhiteScreenDetectCompletion)completion;

#pragma mark - 同步检测方法

/**
 * 同步检测 UIImage 是否为白屏图片
 * @param image 要检测的图片
 * @param config 检测配置，nil 时使用默认配置
 * @return 检测结果
 *
 * @warning 此方法会阻塞当前线程，建议在后台线程调用
 */
+ (HSSWhiteScreenDetectResult)detectWhiteScreenForImage:(UIImage *)image
                                                 config:(nullable HSSWhiteScreenDetectConfig *)config;

/**
 * 同步截图并检测 WKWebView 是否白屏
 * @param webView 要检测的 WKWebView
 * @param config 检测配置，nil 时使用默认配置
 * @return 检测结果
 *
 * @warning 此方法必须在主线程调用，会阻塞主线程
 */
+ (HSSWhiteScreenDetectResult)syncDetectWhiteScreenForWebView:(WKWebView *)webView
                                                       config:(nullable HSSWhiteScreenDetectConfig *)config;

#pragma mark - 截图方法

/**
 * 对 WKWebView 进行截图
 * @param webView 要截图的 WKWebView
 * @param completion 截图完成回调
 *
 * @discussion 必须在主线程调用
 */
+ (void)snapshotWebView:(WKWebView *)webView
             completion:(void(^)(UIImage * _Nullable image, NSError * _Nullable error))completion;

#pragma mark - 上报方法

/**
 * 上报白屏检测结果
 * @param result 检测结果
 * @param webView 被检测的 WKWebView（用于获取 URL 信息）
 * @param adParams 广告相关参数（如 ad_id, crid, placement_id 等）
 *
 * @discussion 当检测到白屏时，调用此方法上报埋点
 */
+ (void)reportWhiteScreenResult:(HSSWhiteScreenDetectResult)result
                        webView:(nullable WKWebView *)webView
                       adParams:(nullable NSDictionary *)adParams;

/**
 * 上报白屏检测结果（带截图）
 * @param result 检测结果
 * @param webView 被检测的 WKWebView（用于获取 URL 信息）
 * @param snapshotImage 截图图片（会压缩后转 base64 上传）
 * @param adParams 广告相关参数（如 ad_id, crid, placement_id 等）
 *
 * @discussion 当检测到白屏时，调用此方法上报埋点，截图会被压缩到约 10KB 后转为 base64
 */
+ (void)reportWhiteScreenResult:(HSSWhiteScreenDetectResult)result
                        webView:(nullable WKWebView *)webView
                  snapshotImage:(nullable UIImage *)snapshotImage
                       adParams:(nullable NSDictionary *)adParams;

#pragma mark - 图片压缩与 Base64

/**
 * 压缩图片到指定大小（KB）
 * @param image 原始图片
 * @param maxSizeKB 目标最大大小（KB），默认 10KB
 * @return 压缩后的图片数据
 *
 * @discussion 通过降低 JPEG 质量和缩放尺寸来压缩图片
 */
+ (nullable NSData *)compressImage:(UIImage *)image
                       maxSizeKB:(NSUInteger)maxSizeKB;

/**
 * 将图片压缩并转为 Base64 字符串
 * @param image 原始图片
 * @param maxSizeKB 目标最大大小（KB），默认 10KB
 * @return Base64 编码的字符串
 */
+ (nullable NSString *)compressImageToBase64:(UIImage *)image
                                  maxSizeKB:(NSUInteger)maxSizeKB;

#pragma mark - 辅助方法

/**
 * 创建无效的检测结果
 * @return 无效的检测结果
 */
+ (HSSWhiteScreenDetectResult)invalidResult;

/**
 * 格式化检测结果为字符串（用于日志）
 * @param result 检测结果
 * @return 格式化后的字符串
 */
+ (NSString *)formatResultDescription:(HSSWhiteScreenDetectResult)result;

@end

NS_ASSUME_NONNULL_END

