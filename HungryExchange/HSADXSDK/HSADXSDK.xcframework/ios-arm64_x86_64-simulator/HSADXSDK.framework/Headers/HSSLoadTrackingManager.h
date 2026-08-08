//
//  HSSLoadTrackingManager.h
//  HSADXSDK
//
//  Created by 张松 on 2025/11/17.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdFormat.h>

@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN
/**
 * 加载失败原因（reason）
 */
typedef NS_ENUM(NSInteger, HSSLoadErrorType) {
    HSSLoadErrorTypeDownloadFailed = 1,     // 1-素材下载失败
    HSSLoadErrorTypeVastParseFailed = 2,    // 2-VAST解析失败
    HSSLoadErrorTypeHTMLLoadFailed = 3      // 3-HTML加载失败
};

/**
 * 广告素材加载追踪管理器
 * 用于统一管理广告素材加载过程的状态追踪和埋点上报
 */
@interface HSSLoadTrackingManager : NSObject

#pragma mark - 属性

/// 日志前缀（用于区分不同广告类型的日志）
@property (nonatomic, copy, readonly) NSString *logPrefix;

/// 加载开始时间戳（秒）
@property (nonatomic, assign, readonly) NSTimeInterval loadStartTime;

/// 素材类型
@property (nonatomic, assign, readonly) HSSAdMaterialType materialType;

/// 加载结果（YES-成功，NO-失败）
@property (nonatomic, assign, readonly) BOOL loadResult;

/// 错误类型
@property (nonatomic, assign, readonly) HSSLoadErrorType errorType;

/// 文件大小（字节）
@property (nonatomic, assign, readonly) unsigned long long fileSize;

#pragma mark - 初始化

/**
 * 初始化加载追踪管理器
 * @param logPrefix 日志前缀（如 "InterstitialAd"、"RewardedAd"、"BannerView"）
 * @return 管理器实例
 */
- (instancetype)initWithLogPrefix:(NSString *)logPrefix;

/**
 * 禁用默认的 init 方法
 */
- (instancetype)init NS_UNAVAILABLE;

#pragma mark - 加载状态管理

/**
 * 开始加载素材
 * @param materialType 素材类型（HSSAdMaterialType）
 *
 * @discussion 调用此方法会重置之前的加载状态，并开始新的计时
 */
- (void)startLoadingWithMaterialType:(HSSAdMaterialType)materialType;

/**
 * 记录加载成功
 * 
 * @discussion 调用此方法会：
 * 1. 停止计时
 * 2. 设置 loadResult = YES
 * 3. 清除错误信息
 */
- (void)recordLoadSuccess;

/**
 * 记录加载失败
 * @param errorType 错误类型
 * @param errorCode 错误码
 * @param errorMsg 错误信息（可选）
 * 
 * @discussion 调用此方法会：
 * 1. 停止计时
 * 2. 设置 loadResult = NO
 * 3. 记录错误信息
 */
- (void)recordLoadFailure:(HSSLoadErrorType)errorType
                errorCode:(NSInteger)errorCode
                 errorMsg:(nullable NSString *)errorMsg;

/**
 * 重置加载追踪状态
 * 
 * @discussion 清除所有状态，回到初始状态
 */
- (void)resetLoadTracking;

/**
 * 记录文件大小
 * @param fileSize 文件大小（字节）
 *
 * @discussion 在素材下载成功后调用，用于记录文件大小
 */
- (void)recordFileSize:(unsigned long long)fileSize;

/**
 * 从文件路径获取并记录文件大小
 * @param filePath 文件路径
 *
 * @discussion 通过文件路径自动获取文件大小并记录
 * @return YES-成功获取，NO-获取失败
 */
- (BOOL)recordFileSizeFromPath:(NSString *)filePath;

#pragma mark - 埋点上报

/**
 * 上报 adx_sdk_load 埋点
 * @param creative 素材模型（可选，用于获取素材相关信息）
 * @param commonParams 广告公共参数（通过 adsRelatedStat 获取）
 * 
 * @discussion 上报的参数包括：
 * - material_type: 素材类型（1-图文, 2-原生视频, 3-VAST, 5-Banner, 6-ADX统一模板等）
 * - cost_time: 下载素材消耗时间（毫秒）
 * - result: 1-成功，0-失败
 * - reason: 失败原因（仅失败时）：1-素材下载失败，2-VAST解析失败，3-HTML加载失败
 * - isStreamLoad：是否是流式加载
 * - 其他广告公共参数（placement、ad_id、crid等）
 * 
 * @warning 上报完成后会自动调用 resetLoadTracking 重置所有状态，防止重复上报
 */
- (void)reportLoadStatWithCreative:(nullable HSSCreativeItemModel *)creative
                      commonParams:(nullable NSDictionary *)commonParams
                      isStreamLoad:(NSInteger)isStreamLoad;

#pragma mark - 辅助方法

/**
 * 计算加载耗时（毫秒）
 * @return 从开始加载到当前的时间间隔（ms）
 * 
 * @discussion 如果未开始加载（loadStartTime == 0），返回 0
 */
- (NSInteger)calculateLoadDuration;

@end

NS_ASSUME_NONNULL_END
