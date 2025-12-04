//
//  OMIDAdEvents.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 22/06/2017.
//

#import <Foundation/Foundation.h>
#import "OMIDAdSession.h"
#import "OMIDVASTProperties.h"

/**
 *  Ad event API enabling the integration partner to signal to all verification providers when key events have occurred.
 * Only one ad events implementation can be associated with the ad session and any attempt to create multiple instances will result in an error.
 */
@interface OMIDHungrystudioAdEvents : NSObject

/**
 *  Initializes ad events instance associated with the supplied ad session.
 *
 * @param session The ad session associated with the ad events.
 * @return A new ad events instance associated with the supplied ad session. Returns nil if the supplied ad session is nil or if an ad events instance has already been registered with the ad session.
 */
- (nullable instancetype)initWithAdSession:(nonnull OMIDHungrystudioAdSession *)session error:(NSError * _Nullable * _Nullable)error;

/**
 *  Notifies the ad session that an impression event has occurred.
 *
 *  When triggered all registered verification providers will be notified of this event.
 *
 * NOTE: the ad session will be automatically started if this method has been called first.
 */
- (BOOL)impressionOccurredWithError:(NSError *_Nullable *_Nullable)error;

/**
 *  Notifies the ad session that display loaded event has occurred.
 *
 *  When triggered all registered verification providers will be notified of this event.
 */
- (BOOL)loadedWithError:(NSError *_Nullable *_Nullable)error;

/**
 *  Notifies the ad session that video/audio loaded event has occurred.
 *
 *  When triggered all registered verification providers will be notified of this event.
 * @param vastProperties contains static information about the video/audio placement.
 */
- (BOOL)loadedWithVastProperties:(OMIDHungrystudioVASTProperties *_Nonnull)vastProperties
                           error:(NSError *_Nullable *_Nullable)error;
@end
