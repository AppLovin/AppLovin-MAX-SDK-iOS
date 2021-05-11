//
//  ALCSubscriber.h
//  AppLovinSDK
//
//  Created by Thomas So on 7/4/19.
//

#import <Foundation/Foundation.h>
#import "ALCMessage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol that subscribers in the AppLovin pub-sub system should conform to in order to receive messages from subscribed topics.
 */
@protocol ALCSubscriber <ALCEntity>

/**
 * Called when a message of a topic the subscriber is interested in has been received.
 */
- (void)didReceiveMessage:(ALCMessage *)message;

@end

NS_ASSUME_NONNULL_END
