//
//  HSSError.h
//  HSADXSDK
//
//  Created by admin on 2024/12/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSError : NSError
@property(nonatomic, assign)NSInteger status;
@property(nonatomic, copy)NSString * _Nullable name;
@property(nonatomic, copy)NSString * _Nullable type;

@end

NS_ASSUME_NONNULL_END
