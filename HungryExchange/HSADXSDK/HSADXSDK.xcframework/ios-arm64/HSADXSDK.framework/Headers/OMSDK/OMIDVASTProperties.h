//
//  OMIDVASTProperties.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/06/2017.
//

#import <UIKit/UIKit.h>

/**
 * List of supported media player positions.
 */
typedef NS_ENUM(NSUInteger, OMIDPosition) {
    /**
     * The ad plays preceding video content.
     */
    OMIDPositionPreroll,
    /**
     * The ad plays in the middle of video content, or between two separate content videos.
     */
    OMIDPositionMidroll,
    /**
     * The ad plays following video content.
     */
    OMIDPositionPostroll,
    /**
     * The ad plays independently of any video content.
     */
    OMIDPositionStandalone
};

/**
 *  This object is used to capture key VAST properties so this can be shared with all registered verification providers.
 */
@interface OMIDHungrystudioVASTProperties : NSObject

@property(nonatomic, readonly, getter = isSkippable) BOOL skippable;
@property(nonatomic, readonly) CGFloat skipOffset;
@property(nonatomic, readonly, getter = isAutoPlay) BOOL autoPlay;
@property(nonatomic, readonly) OMIDPosition position;

/**
 *  This method enables the media player to create a new VAST properties instance for skippable media ad placement.
 *
 * @param skipOffset The number of seconds before the skip button is presented.
 * @param autoPlay Determines whether the media will auto-play content.
 * @param position The position of the media in relation to other content.
 * @return A new instance of VAST properties.
 */
- (nonnull instancetype)initWithSkipOffset:(CGFloat)skipOffset
                                  autoPlay:(BOOL)autoPlay
                                  position:(OMIDPosition)position;

/**
 *  This method enables the media player to create a new VAST properties instance for non-skippable media ad placement.
 *
 * @param autoPlay Determines whether the media will auto-play content.
 * @param position The position of the media in relation to other content.
 * @return A new instance of VAST properties.
 */
- (nonnull instancetype)initWithAutoPlay:(BOOL)autoPlay
                                position:(OMIDPosition)position;

- (null_unspecified instancetype)init NS_UNAVAILABLE;

/**
 * For OM SDK internal use only.
 */
- (NSDictionary *_Nonnull)toJSON;

@end
