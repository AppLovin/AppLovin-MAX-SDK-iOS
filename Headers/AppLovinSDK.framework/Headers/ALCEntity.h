//
//  ALCEntity.h
//  AppLovinSDK
//
//  Created by Thomas So on 7/21/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ALCEntity <NSObject>

/**
 * Unique identifier representing the entity (publisher or subscriber) in the AppLovin pub/sub system.
 * Currently used for debugging purposes only - so please provide an easily distinguishable identifier (e.g. "safedk").
 */
- (NSString *)communicatorIdentifier;

@end

NS_ASSUME_NONNULL_END
