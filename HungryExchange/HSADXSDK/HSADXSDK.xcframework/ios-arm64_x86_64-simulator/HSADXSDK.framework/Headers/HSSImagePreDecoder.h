#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

/**
 预检回调 Block
 @param pixelSize 图片的像素尺寸
 @param expectedBytes 预计解码后的内存占用 (字节)
 @param shouldDecode 是否继续解码。在 Block 中将其设为 NO，则解码流程终止，返回 nil。
 */
//typedef void(^SDPreflightCheckBlock)(CGSize pixelSize, NSUInteger expectedBytes, BOOL *shouldDecode);

/**
 自定义预检解码器
 用于在图片真正解码成位图之前，通过元数据预估内存占用，进行监控或拦截。
 仅支持静态图片，动图需单独处理
 */
@interface HSSImagePreDecoder : NSObject <SDImageCoder>

/// 实际执行解码的底层解码器，默认为 SDImageIOCoder.sharedCoder 或 SDImageCodersManager
@property (nonatomic, strong, readonly) id<SDImageCoder> actualCoder;

/**
 初始化方法
 @param actualCoder 实际工作的解码器（传 [SDImageCodersManager sharedManager]）
 @param imageUrl 图片地址
 */
- (instancetype)initWithActualCoder:(id<SDImageCoder>)actualCoder imageUrl:(NSString *)imageUrl;

@end

NS_ASSUME_NONNULL_END
