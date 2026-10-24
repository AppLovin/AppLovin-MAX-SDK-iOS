//
//  HSSOMIDDataManager.h
//  HSADXSDK
//
//  Created by admin on 2025/4/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OMIDHungrystudioPartner;

@interface HSSOMIDDataManager : NSObject
@property (nonatomic, strong, readonly) OMIDHungrystudioPartner *partner;
@property (nonatomic, copy, readonly) NSString *omidScript;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
