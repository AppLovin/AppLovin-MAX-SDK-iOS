//
//  ALCCommunicator.h
//  AppLovinSDK
//
//  Created by Thomas So on 7/4/19.
//

#import <Foundation/Foundation.h>
#import "ALCSubscriber.h"
#import "ALCMessage.h"
#import "ALCMessagingService.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This communicator SDK acts as a hub for all SDK pub/sub communication.
 */
@interface ALCCommunicator : NSObject

/**
 * Add the provided subscriber to the set of subscribers for a given topic.
 */
- (void)subscribe:(id<ALCSubscriber>)subscriber forTopic:(NSString *)topic;

/**
 * Add the provided subscriber to the set of subscribers for the given topics.
 */
- (void)subscribe:(id<ALCSubscriber>)subscriber forTopics:(NSArray<NSString *> *)topics;

/**
 * Remove the provided subscriber from the set of subscribers for a given topic.
 */
- (void)unsubscribe:(id<ALCSubscriber>)subscriber forTopic:(NSString *)topic;

/**
 * Remove the provided subscriber from the set of subscribers for the given topics.
 */
- (void)unsubscribe:(id<ALCSubscriber>)subscriber forTopics:(NSArray<NSString *> *)topics;

/**
 * The messaging service for the communicator SDK responsible for relaying messages within the system.
 */
@property (nonatomic, strong, readonly) ALCMessagingService *messagingService;

/**
 * Returns the default communicator instance.
 */
@property (class, strong, readonly) ALCCommunicator *defaultCommunicator;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
