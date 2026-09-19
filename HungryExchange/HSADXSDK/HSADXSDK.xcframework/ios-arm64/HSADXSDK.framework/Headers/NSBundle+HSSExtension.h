//
//  NSBundle+HSSExtension.h
//  HSADXSDK
//
//  Created by admin on 2024/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (HSSExtension)

+(instancetype)hssadxBundle;

+ (NSString *)hssadx_localizedStringForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
