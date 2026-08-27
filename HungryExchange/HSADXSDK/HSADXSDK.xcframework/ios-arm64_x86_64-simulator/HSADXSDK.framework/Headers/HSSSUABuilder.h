//
//  HSSSUABuilder.h
//  HSADXSDK
//
//  iOS Native 拼装 device.sua（OpenRTB 2.6），source=2
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSSUABuilder : NSObject

/// 构造上报用的 device.sua 字典
+ (NSDictionary *)suaDictionary;

@end

NS_ASSUME_NONNULL_END
