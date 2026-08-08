//
//  HSSBaseModel.h
//  HSADXSDK
//
//  Created by admin on 2024/11/21.
//

#import <Foundation/Foundation.h>
#import "HSSADXMacro.h"
NS_ASSUME_NONNULL_BEGIN

@interface HSSBaseModel : NSObject<NSSecureCoding>

-(instancetype)initWithDictionary:(NSDictionary *)dict;

-(instancetype)initWithArray:(NSArray *)array;

-(instancetype)initWithJson:(NSString *)string;

-(BOOL)isKindNSArray:(id)obj;

-(BOOL)isKindNSDictionary:(id)obj;

@end

NS_ASSUME_NONNULL_END
