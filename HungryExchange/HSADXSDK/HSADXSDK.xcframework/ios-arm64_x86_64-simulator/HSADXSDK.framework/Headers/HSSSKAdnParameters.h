//
//  HSSSKAdnParameters.h
//  HSADXSDK
//
//  Created by admin on 2024/12/13.
//

#import <Foundation/Foundation.h>

@class HSSSkadnModel;
@class SKAdImpression;
NS_ASSUME_NONNULL_BEGIN

@interface HSSSKAdnParameters : NSObject

+(SKAdImpression *)getSkadnImpression:(HSSSkadnModel *)skadnInfo;

+(NSDictionary *)getSkadnProductParameters:(HSSSkadnModel *)skadnInfo;

@end

NS_ASSUME_NONNULL_END
