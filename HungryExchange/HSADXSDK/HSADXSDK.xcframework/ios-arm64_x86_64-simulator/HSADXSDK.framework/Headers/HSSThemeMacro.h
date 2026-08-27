
#import <HSADXSDK/UIView+HSSUtils.h>
#import <HSADXSDK/UIScreen+HSSafeArea.h>
#import <HSADXSDK/NSBundle+HSSExtension.h>

/**
 * UIColor Functions
 */
#pragma mark - 颜色宏函数

#define mRGBColor(r, g, b) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0]
#define mRGBAColor(r, g, b, a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define kRandomColor [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:1.0]

//rgb颜色转换（16进制->10进制）
#define mRGBToColor(rgb) [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16)) / 255.0 green:((float)((rgb & 0xFF00) >> 8)) / 255.0 blue:((float)(rgb & 0xFF)) / 255.0 alpha:1.0]

#define mRGBToAlpColor(rgb, alp) [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16)) / 255.0 green:((float)((rgb & 0xFF00) >> 8)) / 255.0 blue:((float)(rgb & 0xFF)) / 255.0 alpha:alp]


/**
 * UIView Frame Functions
 */

#define mScreenWidth [UIScreen mainScreen].bounds.size.width
#define mScreenHeight [UIScreen mainScreen].bounds.size.height

#define mScale [UIScreen mainScreen].bounds.size.width / 375.0
#define mFitPt(num) ceil(num * mScale)


/**
 *  HSADX.bundle
 */

#define HSSBundle(name)  [[[NSBundle hssadxBundle] bundlePath] stringByAppendingPathComponent:name]

#define HSSLocalizedString(key) [NSBundle hssadx_localizedStringForKey:key]
