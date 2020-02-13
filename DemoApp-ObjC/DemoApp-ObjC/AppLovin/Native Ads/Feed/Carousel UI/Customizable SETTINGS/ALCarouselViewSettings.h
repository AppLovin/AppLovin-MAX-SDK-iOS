//
//  ALCarouselViewSettings.h
//  iOS Test App NG
//
//  Created by Thomas So on 5/27/15.
//  Copyright (c) 2015 AppLovin. All rights reserved.
//

/**
 * This file contains advanced UI configuration for ALCarouselView.
 * Sizing and colors can be easily tweaked to your liking here.
 */

#ifndef iOS_Test_App_NG_ALCarouselViewSettings_h
#define iOS_Test_App_NG_ALCarouselViewSettings_h

#define kTextColor                            [UIColor darkTextColor]
#define kReplayTextColor                      [UIColor whiteColor]
#define kCarouselBackgroundColor              [UIColor whiteColor]
#define kCardBackgroundColor                  [UIColor whiteColor]
#define kCardButtonColor                      [UIColor colorWithWhite: 0.84f alpha: 1.0f]
#define kVideoViewBackgroundColor             [UIColor blackColor]
#define kVideoViewBackgroundWhilePlayingColor [UIColor blackColor]
#define kReplayOverlayBackgroundColor         [UIColor blackColor]
#define kButtonHighlightTint                  [UIColor colorWithWhite: 0.87f alpha: 1.0f]

// Media controls
static BOOL const kIsAutoplay                        = YES;
static BOOL const kVideoClicksThrough                = YES;
static BOOL const kConfigIsMuted                     = YES;
static BOOL const kRenderVideoScreenshotAsFallbackImage     = YES;

// Replay overlay controls
static NSString *const kTextReplayVideo               = @"Replay Video";
static NSString *const kTextLearnMore                 = @"Learn More";
static CGFloat const kConfigReplayOverlayAlpha        = 0.75f;



// Carousel constants
static NSUInteger const kNativeAdsToLoadCount = 3;
static NSString *const kFontFamily = @"";

// Carousel layout constants
static CGFloat const kCardWidthPercentage = 0.90f;  // As percentage of width of screen
static CGFloat const kCardMargin          = 5.0f;   // The margin on the side of each card. So a margin of 5px would result in a total of 10px separation card-to-card

// Spring animation constants
static CGFloat const kSpringDuration                = 0.3f;
static CGFloat const kDelay                         = 0.0f;
static CGFloat const kSpringDampeningGoNextCard     = 0.9f;
static CGFloat const kSpringDampeningReturnSameCard = 0.7f;
static CGFloat const kInitialSpringVelocity         = 0.0f;
static CGFloat const kConfigSwipeThreshold          = 40.0f; // The number of pixels that will trigger a swipe event

// Card layout constants
static CGFloat const kCardPadding                    = 10.0f;
static CGFloat const kTopMargin                      = 5.0f;
static CGFloat const kAppIconSize                    = 40.0f;
static CGFloat const kRatingHeight                   = 15.0f;
static CGFloat const kStarRatingTopPadding           = 0.0f;
static CGFloat const kMaxStarRatingHeight            = 15.0f;
static NSUInteger const kStarWidthToHeightMultiplier = 5;
static CGFloat const kDescriptionVerticalMargin      = 16.0f;
static CGFloat const kVideoAspectRatio               = 1.0f/1.78f;
static CGFloat const kDescriptionTextHeight          = 36.0f;
static CGFloat const kCtaMaxHeight                   = 40.0f;
static CGFloat const kCtaCornerRadius                = 3.0f;

// Card configurations
static BOOL const kConfigEntireCardClickable         = YES;
static CGFloat const kFontSizeTitle                  = 14.0f;
static CGFloat const kFontSizeDescription            = 14.0f;
static CGFloat const kFontSizeButton                 = 18.0f;
static NSUInteger const kDescriptionMaxLines         = 2;

// Media layout constants
static CGFloat const kPadding                        = 10.0f;
static CGFloat const kMuteButtonPadding              = 12.0f;
static CGFloat const kMuteWidth                      = 20.0f;
static CGFloat const kMuteHeight                     = 20.0f;
static CGFloat const kMuteButtonMargin               = 8.0f;
static CGFloat const kPlayReplayWidth                = 40.0f;
static CGFloat const kPlayReplayHeight               = 40.0f;

#endif