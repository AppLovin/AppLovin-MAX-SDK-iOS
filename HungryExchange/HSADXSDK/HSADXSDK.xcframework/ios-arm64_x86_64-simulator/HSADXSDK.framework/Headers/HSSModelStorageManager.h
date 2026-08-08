//
//  HSSModelStorageManager.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSModelStorageManager : NSObject

+ (instancetype)sharedInstance;

- (void)saveAdModels:(NSArray *)models forKey:(NSString *)key;

- (NSArray *)getModelsWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
