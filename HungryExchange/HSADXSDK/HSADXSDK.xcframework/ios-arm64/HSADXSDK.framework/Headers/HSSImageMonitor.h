//
//  HSSImageMonitor.h
//  HSADXSDK
//
//  Created by 张松 on 2025/12/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    CGSize pixelSize; /// 像素尺寸
    NSUInteger expectedBytes; /// 预计占用内存
    BOOL isValid; /// 是否有效
} HSSImageMonitorInfo;

/**
 * 图片监控工具类
 * 统一处理图片校验、监控上报、降采样等逻辑
 */
@interface HSSImageMonitor : NSObject

#pragma mark - 图片信息读取

/**
 * 从 NSData 读取图片属性（不解码）
 * @param data 图片数据
 * @return 图片监控信息
 */
+ (HSSImageMonitorInfo)imageInfoFromData:(NSData *)data;

/**
 * 从 UIImage 获取图片监控信息
 * @param image UIImage 对象
 * @return 图片监控信息
 */
+ (HSSImageMonitorInfo)imageInfoFromImage:(UIImage *)image;

#pragma mark - 监控上报

/**
 * 上报图片监控事件
 * @param imageInfo 图片监控信息
 * @param imageURL 图片 URL（可选）
 */
+ (void)reportImageEventWithInfo:(HSSImageMonitorInfo)imageInfo
                        imageURL:(nullable NSString *)imageURL;

/**
 * 检查图片是否需要监控（超过阈值）
 * @param imageInfo 图片监控信息
 * @return 是否需要监控
 */
+ (BOOL)shouldMonitorImageWithInfo:(HSSImageMonitorInfo)imageInfo;

/**
 * 便捷方法：从 NSData 读取并上报（如果超过阈值）
 * @param data 图片数据
 * @param imageURL 图片 URL
 */
+ (void)monitorAndReportImageData:(NSData *)data
                          imageURL:(nullable NSString *)imageURL;

/**
 * 便捷方法：从 image 读取并上报（如果超过阈值）
 * @param image 图片数据
 * @param imageURL 图片 URL，如果有就传，方便回溯问题
 */
+ (void)monitorAndReportImage:(UIImage *)image
                     imageURL:(nullable NSString *)imageURL;

/**
 * 上报超大图片文件事件（文件大小超过阈值）
 * @param imageURL 图片 URL
 * @param fileSize 文件大小（字节）
 */
+ (void)reportLargeImageFileWithURL:(NSString *)imageURL
                           fileSize:(NSUInteger)fileSize;

/**
 * 上报超大文件事件（本地文件路径）
 * @param filePath 文件路径
 * @param fileSize 文件大小（字节）
 * @param maxSize 最大允许大小（字节）
 */
+ (void)reportLargeFileWithPath:(NSString *)filePath
                       fileSize:(NSUInteger)fileSize
                        maxSize:(NSUInteger)maxSize;

#pragma mark - 降采样

/**
 * 从 NSData 安全解码图片，如果超过阈值则自动降采样
 * @param data 图片数据
 * @param imageURL 图片 URL（可选，用于监控上报）
 * @return 解码后的 UIImage，如果解码失败返回 nil
 */
+ (nullable UIImage *)safeDecodeImageWithData:(NSData *)data
                                     imageURL:(nullable NSString *)imageURL;

/**
 * 从 NSData 解码图片，如果超过阈值则降采样到指定尺寸
 * @param data 图片数据
 * @param maxPixelSize 最大像素尺寸（最长边），0 表示不降采样
 * @param imageURL 图片 URL（可选，用于监控上报）
 * @return 解码后的 UIImage，如果解码失败返回 nil
 */
+ (nullable UIImage *)safeDecodeImageWithData:(NSData *)data
                                  maxPixelSize:(NSUInteger)maxPixelSize
                                     imageURL:(nullable NSString *)imageURL;

/**
 * 对图片进行降采样
 * @param data 图片数据
 * @param maxPixelSize 最大像素尺寸（最长边）
 * @return 降采样后的 UIImage，如果降采样失败返回 nil
 */
+ (nullable UIImage *)downsampleImageWithData:(NSData *)data
                                  maxPixelSize:(NSUInteger)maxPixelSize;

/**
 * 检查图片是否需要降采样
 * @param imageInfo 图片监控信息
 * @return 是否需要降采样
 */
+ (BOOL)shouldDownsampleImageWithInfo:(HSSImageMonitorInfo)imageInfo;

/**
 * 获取降采样目标尺寸（从配置读取）
 * @return 最大像素尺寸（最长边），0 表示不降采样
 */
+ (NSUInteger)downsamplingMaxPixelSize;

@end

NS_ASSUME_NONNULL_END
