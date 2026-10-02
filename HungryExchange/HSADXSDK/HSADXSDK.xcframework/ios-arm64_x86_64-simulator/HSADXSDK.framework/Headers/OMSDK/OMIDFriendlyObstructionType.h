//
//  OMIDFriendlyObstructionType.h
//  AppVerificationLibrary
//
//  Created by Andrew Whitcomb on 4/3/19.
//  Copyright © 2019 Integral Ad Science, Inc. All rights reserved.
//

/**
 * List of allowed friendly obstruction purposes.
 */
typedef NS_ENUM(NSUInteger, OMIDFriendlyObstructionType) {
    /**
     * The friendly obstruction relates to interacting with a video (such as play/pause buttons).
     */
    OMIDFriendlyObstructionMediaControls,
    /**
     * The friendly obstruction relates to closing an ad (such as a close button).
     */
    OMIDFriendlyObstructionCloseAd,
    /**
     * The friendly obstruction is not visibly obstructing the ad but may seem so due to technical
     * limitations.
     */
    OMIDFriendlyObstructionNotVisible,
    /**
     * The friendly obstruction is obstructing for any purpose not already described.
     */
    OMIDFriendlyObstructionOther
};
