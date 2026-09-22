//
//  OMIDSDK.h
//  AppVerificationLibrary
//
//  Created by Daria on 05/06/2017.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This application level class will be called by all integration partners to ensure OM SDK has been activated before calling any other API methods.
 * Any attempt to use other API methods prior to activation will result in an error.
 *
 * Note that OM SDK may only be used on the main UI thread.
 * Make sure you are on the main thread when you initialize the SDK, create its
 * objects, and invoke its methods.
 */
@interface OMIDHungrystudioSDK : NSObject

/**
 *  The current semantic version of the integrated OMID library.
 */
+ (NSString *)versionString;

/**
 *  Shared OMIDSDK instance.
 */
@property(class, readonly) OMIDHungrystudioSDK *sharedInstance
NS_SWIFT_NAME(shared);

/**
 *  A Boolean value indicating whether OM SDK has been activated.
 *
 *  @discussion Check that OM SDK is active prior to creating any ad sessions.
 */
@property(atomic, readonly, getter=isActive) BOOL active;

/**
 *  Activate OM SDK before calling other API methods.
 *
 *  @discussion Activation sets up the OM SDK environment. In CTV apps (running tvOS), `activate` should be called on launch in
 *  order to capture a "last activity" timestamp on launch and each time the user foregrounds the app).
 *
 *  @return Boolean indicating success.
 */
- (BOOL)activate;

/**
 *  Update the last activity time
 *  After activating OM SDK in CTV apps, refresh the "last activity" timestamp in response to user input prior to starting an ad session.
 */
- (void)updateLastActivity;

@end

NS_ASSUME_NONNULL_END
