//
//  ALCarouselCardView.m
//  sdk
//
//  Created by Thomas So on 4/20/15.
//
//

@import AppLovinSDK;
#import "ALCarouselCardView.h"
#import "ALCarouselCardState.h"
#import "UIView+ALActivityIndicator.h"
#import "ALCarouselViewSettings.h"
#import "ALDebugLog.h"

@interface ALCarouselCardView()

@property (weak,   nonatomic) ALSdk                     *sdk;

@property (strong, nonatomic) ALCarouselCardState       *cardState;
@property (strong, nonatomic) ALNativeAd                *ad;

@property (strong, nonatomic) UITapGestureRecognizer    *cardTapGesture;
@property (strong, nonatomic) UIView                    *contentView;
@property (strong, nonatomic) UIView                    *topBarContainer;
@property (strong, nonatomic) UIImageView               *appIcon;
@property (strong, nonatomic) UILabel                   *titleLabel;
@property (strong, nonatomic) UIImageView               *ratingImageView;
@property (strong, nonatomic) UILabel                   *descriptionLabel;
@property (strong, nonatomic) UIButton                  *ctaButton;

@end

@implementation ALCarouselCardView
static NSString *const TAG = @"ALCarouselCardView";

#pragma mark - Initialization

- (instancetype)initWithSdk:(ALSdk *)sdk
{
    self = [super init];
    if ( self )
    {
        [self baseInitWithSdk: sdk];
    }
    return self;
}

- (instancetype)initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];
    if ( self )
    {
        [self baseInitWithSdk: [ALSdk shared]];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if ( self )
    {
        [self baseInitWithSdk: [ALSdk shared]];
    }
    return self;
}

- (void)baseInitWithSdk:(ALSdk*) sdk
{
    self.sdk = sdk;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.cardTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didTapCard:)];
    self.cardTapGesture.enabled = kConfigEntireCardClickable;
    [self addGestureRecognizer: self.cardTapGesture];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = kCardBackgroundColor;
    [self addSubview: self.contentView];
    
    self.topBarContainer = [[UIView alloc] init];
    [self.contentView addSubview: self.topBarContainer];
    
    self.appIcon                        = [[UIImageView alloc] init];
    self.appIcon.userInteractionEnabled = YES;
    [self.contentView addSubview: self.appIcon];
    
    UITapGestureRecognizer *appIconTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didTapAppIcon:)];
    [self.appIcon addGestureRecognizer: appIconTapGesture];
    
    self.titleLabel                     = [[UILabel alloc] init];
    self.titleLabel.textColor           = kTextColor;
    [self.topBarContainer addSubview: self.titleLabel];
    
    self.ratingImageView                = [[UIImageView alloc] init];
    self.ratingImageView.contentMode    = UIViewContentModeScaleAspectFit;
    [self.topBarContainer addSubview: self.ratingImageView];
    
    self.descriptionLabel               = [[UILabel alloc] init];
    self.descriptionLabel.textColor     = kTextColor;
    self.descriptionLabel.numberOfLines = kDescriptionMaxLines;
    [self.contentView addSubview: self.descriptionLabel];
    
    self.mediaView                      = [[ALCarouselMediaView alloc] initWithSdk: self.sdk parentView: self];
    [self.contentView addSubview: self.mediaView];
    
    self.ctaButton                      = [[UIButton alloc] init];
    self.ctaButton.layer.masksToBounds  = YES;
    self.ctaButton.layer.cornerRadius   = kCtaCornerRadius;
    self.ctaButton.backgroundColor      = kCardButtonColor;
    [self.ctaButton setTitleColor: kTextColor forState: UIControlStateNormal];
    [self.ctaButton addTarget: self action: @selector(didTapCTAButton:) forControlEvents: UIControlEventTouchUpInside];
    [self.contentView addSubview: self.ctaButton];
    
    // Determine label fonts
    if ( [[UIFont familyNames] containsObject: kFontFamily] )
    {
        self.titleLabel.font            = [UIFont fontWithName: kFontFamily size: kFontSizeTitle];
        self.descriptionLabel.font      = [UIFont fontWithName: kFontFamily size: kFontSizeDescription];
        self.ctaButton.titleLabel.font  = [UIFont fontWithName: kFontFamily size: kFontSizeButton];
    }
    else
    {
        self.titleLabel.font            = [UIFont systemFontOfSize: kFontSizeTitle];
        self.descriptionLabel.font      = [UIFont systemFontOfSize: kFontSizeDescription];
        self.ctaButton.titleLabel.font  = [UIFont systemFontOfSize: kFontSizeButton];
    }
}

#pragma mark - Action Methods

- (void)didTapCTAButton:(UIButton *)sender
{
    ALLog(@"Redirecting from cta button click");
    [self handleClickForAd: self.ad];
}

- (void)didTapAppIcon:(UITapGestureRecognizer *)tapGesture
{
    ALLog(@"Redirecting from app icon click");
    [self handleClickForAd: self.ad];
}

- (void)didTapCard:(UITapGestureRecognizer *)tapGesture
{
    ALLog(@"Redirecting from card click");
    [self handleClickForAd: self.ad];
}

#pragma mark - View Management

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Layout content view
    CGRect contentFrame      = CGRectZero;
    contentFrame.origin.x    = kCardMargin;
    contentFrame.size.width  = CGRectGetWidth(self.bounds) - (2*kCardMargin);
    contentFrame.size.height = CGRectGetHeight(self.bounds);
    self.contentView.frame   = contentFrame;
    
    // Layout app icon
    self.appIcon.frame = CGRectMake(kCardPadding, kTopMargin, kAppIconSize, kAppIconSize);
    
    // Layout title
    CGRect titleFrame      = CGRectZero;
    titleFrame.size.width  = (CGRectGetWidth(self.contentView.frame) - CGRectGetMaxX(self.appIcon.frame)) - (2*kCardPadding);
    titleFrame.size.height = [self.titleLabel sizeThatFits: CGSizeMake(CGRectGetWidth(titleFrame), CGFLOAT_MAX)].height;
    self.titleLabel.frame  = titleFrame;
    
    // Layout star rating
    const CGFloat ratingWidth = kMaxStarRatingHeight*kStarWidthToHeightMultiplier;
    self.ratingImageView.frame = CGRectMake(CGRectGetMinX(titleFrame), CGRectGetMaxY(titleFrame) + kStarRatingTopPadding, ratingWidth, kRatingHeight);
    
    // Layout top bar
    CGRect topBarFrame          = CGRectZero;
    topBarFrame.origin.x        = CGRectGetMaxX(self.appIcon.frame) + kCardPadding;
    topBarFrame.size.width      = CGRectGetWidth(self.contentView.frame) - (3*kCardPadding) - kAppIconSize;
    topBarFrame.size.height     = CGRectGetHeight(self.titleLabel.frame) + kRatingHeight;
    self.topBarContainer.frame  = topBarFrame;
    self.topBarContainer.center = CGPointMake(self.topBarContainer.center.x, self.appIcon.center.y);
    
    // Layout description
    CGRect descriptionFrame      = CGRectZero;
    descriptionFrame.origin.x    = kCardPadding;
    descriptionFrame.origin.y    = CGRectGetMaxY(self.topBarContainer.frame) + kDescriptionVerticalMargin;
    descriptionFrame.size.width  = CGRectGetWidth(self.contentView.frame) - (2*kCardPadding);
    descriptionFrame.size.height = [self.descriptionLabel sizeThatFits: CGSizeMake(CGRectGetWidth(descriptionFrame), CGFLOAT_MAX)].height;
    self.descriptionLabel.frame  = descriptionFrame;
    
    // Layout media view
    const CGFloat maxHeightPossible = (CGRectGetMaxY(self.frame) - kCardPadding) - (CGRectGetMaxY(self.descriptionLabel.frame) + kCardPadding);
    const CGFloat fittedHeight      = (CGRectGetWidth(self.frame)) * kVideoAspectRatio;
    
    CGRect mediaFrame      = CGRectZero;
    mediaFrame.origin.y    = CGRectGetMaxY(self.topBarContainer.frame) + (2*kDescriptionVerticalMargin) + kDescriptionTextHeight;
    mediaFrame.size.width  = CGRectGetWidth(self.contentView.frame);
    mediaFrame.size.height = MIN(maxHeightPossible, fittedHeight);
    self.mediaView.frame   = mediaFrame;
    
    // Layout CTA button (center it between bottom of video and bottom of card)
    const CGFloat ctaOriginY = CGRectGetMaxY(self.mediaView.frame) + (CGRectGetMaxY(self.contentView.frame) - CGRectGetMaxY(self.mediaView.frame))/2 - kCtaMaxHeight/2;
    
    // If button will overflow bottom, hide it
    BOOL willOverflow = (ctaOriginY + kCtaMaxHeight) > CGRectGetMaxY(self.contentView.frame);
    if ( willOverflow )
    {
        self.ctaButton.frame  = CGRectZero;
        self.ctaButton.hidden = YES;
    }
    else
    {
        CGRect ctaFrame      = CGRectZero;
        ctaFrame.origin.y    = ctaOriginY;
        ctaFrame.size.height = kCtaMaxHeight;
        ctaFrame.size.width  = (2*kCardPadding) + [self.ctaButton sizeThatFits: CGSizeMake(CGFLOAT_MAX, 0.0f)].width;
        ctaFrame.origin.x    = CGRectGetWidth(self.contentView.frame) - kCardPadding - CGRectGetWidth(ctaFrame);
        
        self.ctaButton.frame  = ctaFrame;
    }
    
    // Activity Views from category
    self.activityIndicatorOverlay.frame = self.bounds;
    self.activityIndicator.center       = self.activityIndicatorOverlay.center;
}

#pragma mark - View Rendering

- (void)renderViewForNativeAd:(ALNativeAd *)ad cardState:(ALCarouselCardState *)cardState
{
    if ( ad )
    {
        self.ad        = ad;
        self.cardState = cardState;
        
        [self refresh];
    }
    else
    {
        [self clearView];
    }
}

- (void)refresh
{
    ALLog(@"----------Begin refreshing carousel card view----------");
    
    ALNativeAd *ad = self.ad;
    
    // If there is ad, render
    if ( ad )
    {
        ALLog(@"Refreshing ad (%@) for card view", ad.adIdNumber);
        
        self.titleLabel.text       = ad.title;
        self.descriptionLabel.text = ad.descriptionText;
        self.mediaView.hidden      = NO;
        self.ctaButton.hidden      = NO;
        [self.ctaButton setTitle: ad.ctaText forState: UIControlStateNormal];
        [self populateStarRating: ad];
        
        // If the images are pre-cached, just render them
        if ( [ad isImagePrecached] )
        {
            ALLog(@"Native ad (%@) is pre-cached. Refreshing image resources", ad.adIdNumber);
            
#pragma mark - Populate with appropriate stars asset depending on starRating
            self.appIcon.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: ad.iconURL]]; // Local URL
            
            [self.mediaView renderViewForNativeAd: self.ad cardState: self.cardState];
            
            [self al_hideActivityIndicatorAnimated: YES];
            [self setNeedsLayout];
        }
        else
        {
            [self clearView];
            [self al_showActivityIndicator];
        }
    }
    // There is no slot to render, so clear view
    else
    {
        ALLog(@"Refreshing nil native ad for card view. Clearing view...");
        
        [self clearView];
        [self al_hideActivityIndicatorAnimated: YES];
    }
    
    ALLog(@"----------Finish refreshing carousel card view----------");
}

#pragma mark - Utility

- (void)handleClickForAd:(ALNativeAd *)ad
{
    if ( ad )
    {
        [ad launchClickTarget];
    }
    else
    {
        // Something is wrong, trying to redirect when card view does not have a native ad (like when ad is still loading)
        ALLog(@"Attempting to open CTA URL with a nil native ad");
    }
}

- (void)trackImpression
{
    if ( self.ad && self.cardState )
    {
        ALLog(@"Handling displaying of native ad (%@)", self.ad.adIdNumber);
        
        if ( !self.cardState.impressionTracked )
        {
            self.cardState.impressionTracked = YES;
            ALLog(@"Tracking impression for ad (%@)", self.ad.adIdNumber);
            [self.ad trackImpression];
        }
    }
    else
    {
        ALLog(@"Attempting to handle a nil slot or nil card state being displayed");
    }
}

- (void)populateStarRating:(ALNativeAd*) ad
{
    NSString* filename = [NSString stringWithFormat: @"Star_Sprite_%@", ad.starRating.stringValue];
    UIImage* starRating = [UIImage imageNamed: filename];
    self.ratingImageView.image = starRating;
}

- (void)clearView
{
    self.titleLabel.text       = @"";
    self.descriptionLabel.text = @"";
    self.ratingImageView.image = nil;
    self.appIcon.image         = nil;
    
    self.ctaButton.hidden      = YES;
    [self.ctaButton setTitle: @"" forState: UIControlStateNormal];
    
    self.mediaView.hidden      = YES;
    
    // Reset State
    self.cardState             = nil;
    self.ad                    = nil;
}

@end
