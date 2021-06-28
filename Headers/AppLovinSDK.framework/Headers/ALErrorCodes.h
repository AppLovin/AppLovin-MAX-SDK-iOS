//
//  ALErrorCodes.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

// Loading & Displaying Ads

/**
 * @file ALErrorCodes.h
 */

/**
 * The SDK is currently disabled.
 */
#define kALErrorCodeSdkDisabled -22

/**
 * No ads are currently eligible for your device & location.
 */
#define kALErrorCodeNoFill 204

/**
 * A fetch ad request timed out (usually due to poor connectivity).
 */
#define kALErrorCodeAdRequestNetworkTimeout -1001

/**
 * The device is not connected to internet (for instance if user is in Airplane mode). This returns the same code as NSURLErrorNotConnectedToInternet.
 */
#define kALErrorCodeNotConnectedToInternet -1009

/**
 * An unspecified network issue occurred.
 */
#define kALErrorCodeAdRequestUnspecifiedError -1

/**
 * There has been a failure to render an ad on screen.
 */
#define kALErrorCodeUnableToRenderAd -6

/**
 * The zone provided is invalid; the zone needs to be added to your AppLovin account or may still be propagating to our servers.
 */
#define kALErrorCodeInvalidZone -7

/**
 * The provided ad token is invalid; ad token must be returned from AppLovin S2S integration.
 */
#define kALErrorCodeInvalidAdToken -8

/**
 * An attempt to cache a resource to the filesystem failed; the device may be out of space.
 */
#define kALErrorCodeUnableToPrecacheResources -200

/**
 * An attempt to cache an image resource to the filesystem failed; the device may be out of space.
 */
#define kALErrorCodeUnableToPrecacheImageResources -201

/**
 * An attempt to cache a video resource to the filesystem failed; the device may be out of space.
 */
#define kALErrorCodeUnableToPrecacheVideoResources -202

/**
 * AppLovin servers have returned an invalid response.
 */
#define kALErrorCodeInvalidResponse -800

//
// Rewarded Videos
//

/**
 * The developer called for a rewarded video before one was available.
 */
#define kALErrorCodeIncentiviziedAdNotPreloaded -300

/**
 * An unknown server-side error occurred.
 */
#define kALErrorCodeIncentivizedUnknownServerError -400

/**
 * A reward validation requested timed out (usually due to poor connectivity).
 */
#define kALErrorCodeIncentivizedValidationNetworkTimeout -500

/**
 * The user exited out of the rewarded ad early. You may or may not wish to grant a reward depending on your preference.
 */
#define kALErrorCodeIncentivizedUserClosedVideo -600

/**
 * A postback URL you attempted to dispatch was empty or nil.
 */
#define kALErrorCodeInvalidURL -900
