//
//  MAErrorCodes.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/27/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

/**
 * @file MAErrorCodes.h
 */

/**
 * No ads are currently eligible for your device.
 */
#define kMAErrorCodeNoFill 204

/**
 * The system is in unexpected state.
 */
#define kMAErrorCodeUnspecifiedError -1

/**
 * The internal state of the SDK is invalid. There are various ways this can occur.
 */
#define kMAErrorCodeInvalidInternalState -5201

/**
 * The ad failed to load due to no networks being able to fill.
 */
#define kMAErrorCodeMediationAdapterLoadFailed -5001

/**
 * An attempt to show a fullscreen ad (interstitial or rewarded) was made while another fullscreen ad is still showing.
 */
#define kMAErrorCodeFullscreenAdAlreadyShowing -23
