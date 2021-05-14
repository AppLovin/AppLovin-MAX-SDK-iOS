//
//  ALPostbackDelegate
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * The postback service dispatches postbacks to a developer-specified URL.
 */
@class ALPostbackService;

/**
 * This protocol allows you to monitor the dispatching of postbacks to a developer-specified URL by the postback service.
 */
@protocol ALPostbackDelegate <NSObject>

/**
 * Indicates that a postback dispatched to a given URL completed successfully.
 *
 * Success means having received a 2<var>xx</var> response code from the remote endpoint.
 *
 * @param postbackService The postback service that made the postback call.
 * @param postbackURL     The URL that was notified.
 */
- (void)postbackService:(ALPostbackService *)postbackService didExecutePostback:(NSURL *)postbackURL;

/**
 * Indicates that a postback dispatched to a given URL has failed.
 *
 * Failure means having received a response code outside the 2<var>xx</var> range, or having been unable to establish a connection.
 *
 * @param postbackService The postback service that attempted the postback call.
 * @param postbackURL     The URL to which the notification attempt was made.
 * @param errorCode       The HTTP status code received, if any; otherwise one of the negative constants defined in ALErrorCodes.h.
 */
- (void)postbackService:(ALPostbackService *)postbackService didFailToExecutePostback:(nullable NSURL *)postbackURL errorCode:(NSInteger)errorCode;

@end

NS_ASSUME_NONNULL_END
