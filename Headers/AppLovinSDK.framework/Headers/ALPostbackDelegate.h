//
//  ALPostbackDelegate
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@class ALPostbackService;

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
 * @param errorCode       The HTTP status code received, if any; otherwise a negative constant.
 */
// [PLP] does the particular "negative constant" have any meaning; e.g. might different negative constants refer to different reasons a connection could not be established?
- (void)postbackService:(ALPostbackService *)postbackService didFailToExecutePostback:(nullable NSURL *)postbackURL errorCode:(NSInteger)errorCode;

@end

NS_ASSUME_NONNULL_END
