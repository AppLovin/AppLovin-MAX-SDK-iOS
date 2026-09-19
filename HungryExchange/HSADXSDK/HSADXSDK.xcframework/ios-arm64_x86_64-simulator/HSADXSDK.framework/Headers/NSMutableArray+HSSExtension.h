//
//  NSMutableArray+HSSExtension.h
//  HSADXSDK
//
//  Created by 张松 on 2025/11/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (HSSExtension)
- (void)hssadx_safeAddObject:(id)object;
@end

NS_ASSUME_NONNULL_END
