//
//  ALCarouselReplayOverlayView.m
//  sdk
//
//  Created by Thomas So on 4/22/15.
//
//

#import "ALCarouselReplayOverlayView.h"
#import "ALCarouselViewSettings.h"

@interface ALCarouselReplayOverlayView()
@property (weak, nonatomic) ALCarouselMediaView *mediaView;
@end

@implementation ALCarouselReplayOverlayView

#pragma mark - Initialization

- (instancetype)initWithParentView:(ALCarouselMediaView *)parentView
{
    self = [super init];
    if ( self )
    {
        self.mediaView = parentView;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.overlay = [[UIView alloc] init];
        
        self.overlay.backgroundColor = kReplayOverlayBackgroundColor;
        self.overlay.alpha           = kConfigReplayOverlayAlpha;
        [self addSubview: self.overlay];
        
        self.replayIconButton = [[UIButton alloc] init];
        [self addSubview: self.replayIconButton];
        
        self.replayButton = [[UIButton alloc] init];
        [self addSubview: self.replayButton];
        
        self.learnMoreIconButton = [[UIButton alloc] init];
        [self addSubview: self.learnMoreIconButton];
        
        self.learnMoreButton = [[UIButton alloc] init];
        [self addSubview: self.learnMoreButton];
        
        [self.replayIconButton    setTintColor:  kButtonHighlightTint];
        [self.replayButton        setTitleColor: kReplayTextColor             forState: UIControlStateNormal];
        [self.replayButton        setTitleColor: kButtonHighlightTint         forState: UIControlStateHighlighted];
        [self.learnMoreButton     setTitleColor: kReplayTextColor             forState: UIControlStateNormal];
        [self.learnMoreButton     setTitleColor: kButtonHighlightTint         forState: UIControlStateHighlighted];
        [self.learnMoreIconButton setTintColor:  kButtonHighlightTint];
        
        [self.replayIconButton    setImage: [UIImage imageNamed: @"applovin_card_replay"] forState: UIControlStateNormal];
        [self.learnMoreIconButton setImage: [UIImage imageNamed: @"applovin_card_learn_more"] forState: UIControlStateNormal];
        
        [self.replayButton    setTitle: kTextReplayVideo forState: UIControlStateNormal];
        [self.learnMoreButton setTitle: kTextLearnMore   forState: UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.overlay.frame = self.bounds;
    
    const CGFloat replayButtonWidth = [self.replayButton sizeThatFits: CGSizeMake(CGFLOAT_MAX, 0.0f)].width;
    const CGFloat totalReplayWidth  = kPlayReplayWidth + kPadding + replayButtonWidth;
    
    const CGFloat learnMoreButtonWidth = [self.learnMoreButton sizeThatFits: CGSizeMake(CGFLOAT_MAX, 0.0f)].width;
    const CGFloat totalLearnMoreWidth  = kPlayReplayWidth + kPadding + learnMoreButtonWidth;
    
    const CGFloat totalContentHeight = (2*kPlayReplayHeight) + kPadding;
    
    // We will center and align depending on which button has the longer total width
    const CGFloat longerWidth = totalReplayWidth >= totalLearnMoreWidth ? totalReplayWidth : totalLearnMoreWidth;
    
    self.replayIconButton.frame = CGRectMake(CGRectGetMidX(self.frame) - longerWidth/2.0f,
                                             CGRectGetMidY(self.frame) - totalContentHeight/2.0f,
                                             kPlayReplayWidth,
                                             kPlayReplayHeight);
    self.replayButton.frame = CGRectMake(CGRectGetMaxX(self.replayIconButton.frame) + kPadding,
                                         CGRectGetMinY(self.replayIconButton.frame),
                                         replayButtonWidth,
                                         kPlayReplayHeight);
    
    self.learnMoreIconButton.frame = CGRectMake(CGRectGetMidX(self.frame) - longerWidth/2.0f,
                                                CGRectGetMaxY(self.replayIconButton.frame) + kPadding,
                                                kPlayReplayWidth,
                                                kPlayReplayHeight);
    self.learnMoreButton.frame  = CGRectMake(CGRectGetMaxX(self.learnMoreIconButton.frame) + kPadding,
                                             CGRectGetMaxY(self.replayIconButton.frame) + kPadding,
                                             learnMoreButtonWidth,
                                             kPlayReplayHeight);
}

@end
