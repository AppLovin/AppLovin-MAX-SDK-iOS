//
//  NSMutableDictionary+HSSExtension.h
//  HSADXSDK
//
//  Created by biyingquan on 2024/12/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (HSSExtension)

- (void)hssadx_safeSetObject:(id)object forKey:(id)key;

@end

NS_ASSUME_NONNULL_END
