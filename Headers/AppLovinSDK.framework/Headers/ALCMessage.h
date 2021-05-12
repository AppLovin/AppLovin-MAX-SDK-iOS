//
//  ALCMessage.h
//  AppLovinSDK
//
//  Created by Thomas So on 7/4/19.
//

#import <Foundation/Foundation.h>
#import "ALCPublisher.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Class representing messages passed in the Communicator SDK.
 */
@interface ALCMessage : NSNotification

/**
 * Convenience property for retrieving the raw data of the message. This will also be available via the "data" key of the `userInfo` property.
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, id> *data;

/**
 * Convenience property for retrieving the topic of the message. This will also be available via the "topic" key of the `userInfo` property.
 * A full list of supported topics may be found in ALCTopic.h.
 */
@property (nonatomic, copy, readonly) NSString *topic;

/**
 * Convenience method for retrieving the id of the publisher of the message. This will also be available via the "pub_id" key of the `userInfo` property.
 */
@property (nonatomic, copy, readonly) NSString *publisherIdentifier;

/**
 * Initialize a message with data in a pre-determined format for a given topic.
 */
- (instancetype)initWithData:(NSDictionary<NSString *, id> *)data topic:(NSString *)topic fromPublisher:(id<ALCPublisher>)publisher;
- (instancetype)initWithData:(NSDictionary<NSString *, id> *)data topic:(NSString *)topic fromPublisher:(id<ALCPublisher>)publisher sticky:(BOOL)sticky;
- (instancetype)initWithName:(NSNotificationName)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
