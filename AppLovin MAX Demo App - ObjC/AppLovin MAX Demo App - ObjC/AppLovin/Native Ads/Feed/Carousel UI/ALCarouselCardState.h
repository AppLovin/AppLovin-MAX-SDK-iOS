//
//  ALCarouselCardState.h
//  sdk
//
//  Created by Matt Szaro on 4/17/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Tracks the state of a card within an ALCarouselView.
 */
@interface ALCarouselCardState : NSObject

/**
 Retrieve an instance with appropriate default settings for use within a carousel view.
 */
+(instancetype) cardStateForCarousel;

/**
 Retrieve an instance with appropriate default settings for use within a single ALCarouselCardView outside a carousel.
 */
+(instancetype) cardStateForSingleCard;

typedef NS_ENUM(NSUInteger, ALMuteState)
{
    ALMuteStateUnspecified,
    ALMuteStateUnmuted,
    ALMuteStateMuted
};

@property (assign, atomic, getter=wasVideoStarted)           BOOL videoStarted;
@property (assign, atomic, getter=wasVideoCompleted)         BOOL videoCompleted;
@property (assign, atomic, getter=wasVideoStartTracked)      BOOL videoStartTracked;
@property (assign, atomic, getter=isFirstPlayback)           BOOL firstPlayback;
@property (assign, atomic, getter=wasImpressionTracked)      BOOL impressionTracked;
@property (assign, atomic, getter=isCurrentlyActive)         BOOL currentlyActive;
@property (assign, atomic, getter=isReplayOverlayVisible)    BOOL replayOverlayVisible;
@property (assign, atomic, getter=isPrecaching)              BOOL precaching; // To prvent a slot from being redundantly pre-caching

@property (assign, atomic)                                   Float64 lastMediaPlayerPosition;
@property (assign, atomic)                                   ALMuteState muteState;
@property (strong, atomic)                                   UIImage *screenshot;
@property (assign, atomic)                                   CGRect videoRect;

@end

NS_ASSUME_NONNULL_END
