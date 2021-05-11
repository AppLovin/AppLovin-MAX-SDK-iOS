//
//  MAErrorCodes.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/27/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

/**
 * Indicates that no ads are currently eligible for your device.
 */
#define kMAErrorCodeNoFill 204

/**
 * Indicates that the system is in unexpected state.
 */
#define kMAErrorCodeUnspecifiedError -1

/**
 * Internal state of the SDK is invalid. There are various ways this can occur.
 */
#define kMAErrorCodeInvalidInternalState -5201

/**
 * Indicates that the ad failed to load due to no networks being able to fill.
 */
#define kMAErrorCodeMediationAdapterLoadFailed -5001

/**
 * Indicates that an attempt to show a fullscreen ad (interstitial or rewarded) was made while another fullscreen ad is still showing.
 */
#define kMAErrorCodeFullscreenAdAlreadyShowing -23
