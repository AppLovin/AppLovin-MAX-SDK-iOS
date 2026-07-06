//
//  NSString+Extension.h
//  Pods-Example
//
//  Created by admin on 2024/11/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HSSExtension)

/// 判断是否是空字符串或者非字符串类型
+ (BOOL)isNullString:(NSString *)string;

/// 非空字符串
+ (NSString *)NonNULLString:(NSString *)string;

/// json 转 dictionary
-(NSDictionary *)jsonStringToDicionary;

/// 字符串转 MD5
- (NSString *)stringToMD5;

/**
 @param font 字体
 @param width 限定观看
 @return 字符串高度
 */
- (CGFloat)heightForFont:(UIFont *)font andWidth:(float)width;

/**
 @param fontSize 字体大小
 @param width 限定观看
 @return 字符串高度
 */
- (CGFloat)heightForFontSize:(float)fontSize andWidth:(float)width;

/**
 @param font 字体
 @param height 限定高度
 @return 字符串宽度
 */
- (CGFloat)widthForFont:(UIFont *)font andHeight:(float)height;

/**
 @param fontSize 字体大小
 @param height 限定高度
 @return 字符串宽度
 */
- (CGFloat)widthForFontSize:(float)fontSize andHeight:(float)height;

@end

NS_ASSUME_NONNULL_END
