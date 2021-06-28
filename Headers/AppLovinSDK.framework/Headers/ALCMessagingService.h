//
//  ALCMessagingService.h
//  AppLovinSDK
//
//  Created by Thomas So on 7/16/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Service class of the Communicator SDK responsible for managing and publishing messages.
 */
@interface ALCMessagingService : NSObject

/**
 * Publish the given message to the pub/sub system.
 */
- (void)publishMessage:(ALCMessage *)message;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
