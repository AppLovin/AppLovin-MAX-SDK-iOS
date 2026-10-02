//
//  HSSWhiteScreenMonitor.h
//  HSADXSDK
//
//  Created on 2025/12/13.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "HSSWhiteScreenDetector.h"

NS_ASSUME_NONNULL_BEGIN

@class HSSWhiteScreenMonitor;

#pragma mark - 代理协议

@protocol HSSWhiteScreenMonitorDelegate <NSObject>

@optional

/**
 * 检测到白屏
 * @param monitor 监控器实例
 * @param webView 检测的 WebView
 * @param result 检测结果
 */
- (void)whiteScreenMonitor:(HSSWhiteScreenMonitor *)monitor
           didDetectWhiteScreen:(WKWebView *)webView
                      result:(HSSWhiteScreenDetectResult)result;

/**
 * 检测完成（无论是否白屏）
 * @param monitor 监控器实例
 * @param webView 检测的 WebView
 * @param result 检测结果
 */
- (void)whiteScreenMonitor:(HSSWhiteScreenMonitor *)monitor
           didFinishDetect:(WKWebView *)webView
                    result:(HSSWhiteScreenDetectResult)result;

/**
 * 检测失败
 * @param monitor 监控器实例
 * @param webView 检测的 WebView
 * @param error 错误信息
 */
- (void)whiteScreenMonitor:(HSSWhiteScreenMonitor *)monitor
              didFailDetect:(WKWebView *)webView
                     error:(NSError *)error;

@end

#pragma mark - 监控器类

/**
 * WKWebView 白屏自动监控器
 *
 * 功能：
 * 1. 自动在 WebView 加载完成后进行白屏检测
 * 2. 支持定时周期性检测
 * 3. 支持重试机制
 * 4. 自动上报白屏事件
 *
 * 使用示例：
 * @code
 * // 创建监控器
 * HSSWhiteScreenMonitor *monitor = [[HSSWhiteScreenMonitor alloc] init];
 * monitor.delegate = self;
 * monitor.autoReport = YES;
 *
 * // 开始监控 WebView
 * [monitor startMonitoringWebView:webView adParams:@{@"ad_id": @"123", @"placement_id": @"456"}];
 *
 * // WebView 加载完成后调用
 * [monitor triggerDetectForWebView:webView];
 *
 * // 停止监控
 * [monitor stopMonitoring];
 * @endcode
 */
@interface HSSWhiteScreenMonitor : NSObject

#pragma mark - 属性

/// 代理
@property (nonatomic, weak, nullable) id<HSSWhiteScreenMonitorDelegate> delegate;

/// 检测配置
@property (nonatomic, strong) HSSWhiteScreenDetectConfig *config;

/// 是否自动上报白屏事件（默认 YES）
@property (nonatomic, assign) BOOL autoReport;

/// 是否允许上传白屏截图（默认 YES）
/// NO 时只检测并上报白屏事件，但不附带截图（snapshot_raw）。
/// 由广告维度开关 ext.ws_screen_upload 控制（1 开 0 关），是截图上传的唯一开关。
@property (nonatomic, assign) BOOL enableSnapshotUpload;

/// 是否正在监控
@property (nonatomic, assign, readonly) BOOL isMonitoring;

/// 最大重试次数（默认 2）
@property (nonatomic, assign) NSUInteger maxRetryCount;

/// 重试间隔（秒，默认 1.0）
@property (nonatomic, assign) NSTimeInterval retryInterval;

/// 周期性检测间隔（秒，默认 0，表示不启用周期检测）
/// 设置大于 0 的值启用周期性检测
@property (nonatomic, assign) NSTimeInterval periodicDetectInterval;

/// 广告参数（用于上报）
@property (nonatomic, copy, nullable) NSDictionary *adParams;

/// 最后一次检测结果
@property (nonatomic, assign, readonly) HSSWhiteScreenDetectResult lastResult;

/// 是否正在进行检测（用于防止重复检测）
@property (nonatomic, assign, readonly) BOOL isDetecting;

#pragma mark - 初始化

/**
 * 初始化监控器
 */
- (instancetype)init;

/**
 * 使用自定义配置初始化
 * @param config 检测配置
 */
- (instancetype)initWithConfig:(nullable HSSWhiteScreenDetectConfig *)config;

#pragma mark - 监控控制

/**
 * 开始监控 WebView
 * @param webView 要监控的 WKWebView
 *
 * @discussion 调用此方法后，监控器会等待 triggerDetect 调用来执行检测
 */
- (void)startMonitoringWebView:(WKWebView *)webView;

/**
 * 开始监控 WebView（带广告参数）
 * @param webView 要监控的 WKWebView
 * @param adParams 广告参数（用于上报）
 */
- (void)startMonitoringWebView:(WKWebView *)webView
                      adParams:(nullable NSDictionary *)adParams;

/**
 * 停止监控
 */
- (void)stopMonitoring;

/**
 * 触发白屏检测
 * 通常在 WebView 加载完成时调用
 */
- (void)triggerDetect;

/**
 * 触发指定 WebView 的白屏检测
 * @param webView 要检测的 WKWebView
 */
- (void)triggerDetectForWebView:(WKWebView *)webView;

/**
 * 延迟触发白屏检测
 * @param delay 延迟时间（秒）
 */
- (void)triggerDetectAfterDelay:(NSTimeInterval)delay;

#pragma mark - 便捷方法

/**
 * 一次性检测（不需要开始/停止监控）
 * @param webView 要检测的 WKWebView
 * @param adParams 广告参数
 * @param completion 完成回调
 */
- (void)detectOnceForWebView:(WKWebView *)webView
                    adParams:(nullable NSDictionary *)adParams
                  completion:(nullable HSSWhiteScreenDetectCompletion)completion;

@end

#pragma mark - 单例便捷接口

@interface HSSWhiteScreenMonitor (Singleton)

/**
 * 获取共享监控器实例
 * 适用于简单场景，复杂场景建议创建独立实例
 */
+ (instancetype)sharedMonitor;

/**
 * 快速检测 WebView 白屏并上报
 * @param webView 要检测的 WKWebView
 * @param adParams 广告参数
 *
 * @discussion 使用共享实例进行检测，检测到白屏时自动上报
 */
+ (void)quickDetectWebView:(WKWebView *)webView
                  adParams:(nullable NSDictionary *)adParams;

/**
 * 快速检测 WebView 白屏（带回调）
 * @param webView 要检测的 WKWebView
 * @param adParams 广告参数
 * @param completion 完成回调
 */
+ (void)quickDetectWebView:(WKWebView *)webView
                  adParams:(nullable NSDictionary *)adParams
                completion:(nullable HSSWhiteScreenDetectCompletion)completion;

@end

NS_ASSUME_NONNULL_END

