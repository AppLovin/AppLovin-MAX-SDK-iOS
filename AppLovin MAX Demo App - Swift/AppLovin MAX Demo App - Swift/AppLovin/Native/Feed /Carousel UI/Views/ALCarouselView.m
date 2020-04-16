//
//  ALCarouselView.m
//
//  Created by Thomas So on 3/30/15.
//  Copyright (c) 2015, AppLovin Corporation. All rights reserved.
//

@import AppLovinSDK;
#import "ALCarouselView.h"
#import "ALCarouselView+Internal.h"
#import "UIView+ALActivityIndicator.h"
#import "ALCarouselCardView.h"
#import "ALCarouselCardState.h"
#import "ALCarouselViewModel.h"
#import "ALCarouselViewSettings.h"
#import "ALDebugLog.h"

@class ALCarouselView;

/**
 *  This class acts as an intermediary between pre-cache events of slots and which card to notify.
 */
@interface ALCarouselPrecacheRouter : NSObject<ALNativeAdPrecacheDelegate>

@property (copy, nonatomic) NSString *tag;
@property (weak, nonatomic) ALCarouselView *carouselView;

- (instancetype)initWithCarouselView:(ALCarouselView *)carouselView;

@end

@interface ALCarouselView()<ALNativeAdLoadDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) ALSdk *sdk;
@property (weak,   nonatomic) ALPostbackService *postbackService;

@property (weak,      atomic) NSArray<ALNativeAd *> *previousNativeAdsRendered;
@property (strong, nonatomic) ALCarouselViewModel *carouselModel;
@property (assign, nonatomic) NSInteger            currentAdIndex;

@property (strong, nonatomic) ALCarouselPrecacheRouter *precacheRouter;

// This array has 5 card objets that are used to render the ad
@property (strong, nonatomic) NSArray<ALCarouselCardView *> *cardViews;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

@end

#pragma mark ALCarouselView

@implementation ALCarouselView
static NSString * const TAG = @"ALCarouselView";

// Card constants
static NSInteger const kNumSideCards = 2;
static NSInteger const kNumCards     = 5;
static NSInteger const kMidCardIndex = 2;

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if ( self )
    {
        [self baseInitWithSdk: [ALSdk shared]];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.sdk = [ALSdk shared];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame: frame sdk: [ALSdk shared]];
}

- (instancetype)initWithFrame:(CGRect)frame sdk:(ALSdk *)sdk
{
    return [self initWithFrame: frame sdk: sdk nativeAds: @[]];
}

- (instancetype)initWithFrame:(CGRect)frame sdk:(ALSdk *)sdk nativeAds:(NSArray<ALNativeAd *> *)nativeAds
{
    self = [super initWithFrame: frame];
    if ( self )
    {
        [self baseInitWithSdk: sdk];
        self.nativeAds = nativeAds;
    }
    return self;
}

- (void)baseInitWithSdk:(ALSdk *)sdk
{
    self.sdk = sdk;
    self.postbackService = sdk.postbackService;
    
    self.currentAdIndex = 0;
    
    self.precacheRouter = [[ALCarouselPrecacheRouter alloc] initWithCarouselView: self];
    
    // Setup View
    self.userInteractionEnabled = YES;
    self.clipsToBounds          = YES;
    self.autoresizingMask       = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor        = kCarouselBackgroundColor;

    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panGesture.delegate           = self;
    self.panGesture.delaysTouchesBegan = NO;
    self.panGesture.delaysTouchesEnded = NO;
    [self addGestureRecognizer: self.panGesture];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = kCarouselBackgroundColor;
    [self addSubview: self.contentView];
    
    NSMutableArray* tempCards = [NSMutableArray arrayWithCapacity: kNumCards];
    for ( NSInteger i = 0; i < kNumCards; ++i )
    {
        ALCarouselCardView *cardView = [[ALCarouselCardView alloc] initWithSdk: sdk];
        cardView.backgroundColor     = [UIColor clearColor];
        cardView.hidden              = YES;
        
        
        [self.contentView addSubview: cardView];
        
        [tempCards addObject: cardView];
    }
    
    self.cardViews = [NSArray arrayWithArray: tempCards];
}

-(void) didMoveToSuperview
{
    [super didMoveToSuperview];
    
    // If there are attached from initialization
    if ( self.nativeAds.count > 0 )
    {
        // All of the objects in the array are checked to be of proper type in setter. Render.
        [self renderAdsIfNeeded];
    }
    // If there isn't currently any native ad(s) attached, load one.
    else
    {
        [self al_showActivityIndicator];
        
        // AppLovin SDK has deprecated loading of multiple native ads
        [self.sdk.nativeAdService loadNextAdAndNotify: self];
        //[self.sdk.nativeAdService loadNativeAdGroupOfCount: kNativeAdsToLoadCount andNotify: self];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat cardWidth    = (CGRectGetWidth(self.bounds) * kCardWidthPercentage) - (2 * kCardMargin);
    const CGFloat contentWidth = kNumCards * cardWidth;
    
    CGRect contentFrame      = CGRectZero;
    contentFrame.origin.x    = CGRectGetMidX(self.bounds) - (contentWidth/2);
    contentFrame.size.width  = contentWidth;
    contentFrame.size.height = CGRectGetHeight(self.bounds);
    self.contentView.frame       = contentFrame;
    
    CGFloat currentX = 0.0f;
    for ( ALCarouselCardView *cardView in self.cardViews )
    {
        cardView.frame = CGRectMake(currentX, 0.0f, cardWidth, CGRectGetHeight(self.bounds));
        currentX += cardWidth;
    }
    
    // Activity Views from category
    self.activityIndicatorOverlay.frame = self.bounds;
    self.activityIndicator.center       = self.activityIndicatorOverlay.center;
}

#pragma mark - Native Ad Load Delegate

- (void)nativeAdService:(ALNativeAdService *)service didLoadAds:(NSArray *)ads
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        self.nativeAds = ads;
        [self renderAdsIfNeeded];
        
        @try
        {
            if ( [(id)self.loadDelegate respondsToSelector: @selector(nativeAdService:didLoadAds:)] )
            {
                [self.loadDelegate nativeAdService: service didLoadAds: ads];
            }
        }
        @catch (NSException *exception)
        {
            ALLog(@"Unable to notify native ad load delegate because of exception: %@", exception);
        }
    }];
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToLoadAdsWithError:(NSInteger)code
{
    ALLog(@"Native ad service did fail to load native ad with error: %ld", code);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        @try
        {
            if ( [(id)self.loadDelegate respondsToSelector: @selector(nativeAdService:didFailToLoadAdsWithError:)] )
            {
                [self.loadDelegate nativeAdService: service didFailToLoadAdsWithError: code];
            }
        }
        @catch (NSException *exception)
        {
            ALLog(@"Unable to notify native ad load delegate about failing to load because of exception: %@", exception);
        }
    }];
}

#pragma mark - View Rendering

- (void)renderAdsIfNeeded
{
    if ( [self.nativeAds isEqual: self.previousNativeAdsRendered] )
    {
        ALLog(@"Attempting to re-render native ad(s)");
    }
    else
    {
        // Keep track of native ad(s) rendered to prevent re-rendering
        self.previousNativeAdsRendered = self.nativeAds;
        
        self.carouselModel = [[ALCarouselViewModel alloc] initWithNativeAds: self.nativeAds];
        
        self.panGesture.enabled = self.nativeAds.count > 1;     // Don't allow swiping if only one card
        
        self.currentAdIndex = 0;
        
        [self refreshView];
    }
}

- (void)refreshView
{
    ALLog(@"Begin refreshing carousel view for number of native ads: %lu", self.nativeAds.count);

    // Update/save states before refreshing each card
    for ( ALCarouselCardView *cardView in self.cardViews )
    {
        [cardView.mediaView setInactive];
    }
    
    for ( NSInteger cardIndex = 0; cardIndex < kNumCards ; ++cardIndex )
    {
        ALLog(@"Begin refreshing for card at index %ld", cardIndex);
        
        ALCarouselCardView *cardView = self.cardViews[cardIndex];
        
        // Determine what slot should be displaying in the card with index 'cardIndex' now
        // Please Note: Will return an out-of-bounds if we're not supposed to render ad for card at this index
        NSInteger adIndex = [self adIndexForCardIndex: cardIndex];
        
        // If ad exists for this card view, render
        if ( (adIndex >= 0) && (adIndex < self.nativeAds.count) )
        {
            ALLog(@"Refreshing card view at index: %ld with slot at index: %ld", cardIndex, adIndex);
            ALNativeAd *ad = self.nativeAds[adIndex];

            ALCarouselCardState *cardState = [self.carouselModel cardStateAtNativeAdIndex: adIndex];
            cardState.currentlyActive = (cardIndex == kMidCardIndex);
            
            if ( [ad isImagePrecached] )
            {
                ALLog(@"Card at index: %ld currently has its images pre-cached", cardIndex);
                
                [cardView renderViewForNativeAd: ad cardState: cardState];
                
                // Only middle (active) card can be clicked on
                cardView.userInteractionEnabled = cardState.currentlyActive;
                cardView.hidden = NO;
                
                if ( cardState.currentlyActive )
                {
                    // Handle events when middle card is displayed
                    [cardView trackImpression];
                }
            }
            // If images are not pre-cached, then videos are not pre-cached as well
            else
            {
                ALLog(@"Card at index: %ld is not pre-cached", cardIndex);
                
                [cardView clearView];
                [cardView al_showActivityIndicator];
                cardView.hidden = NO;
                
                if ( cardState.precaching )
                {
                    ALLog(@"Card at index: %ld is already currently pre-caching", cardIndex);
                }
                else
                {
                    cardState.precaching = YES;
                    
                    ALLog(@"Begin pre-caching for card at index: %ld", cardIndex);
                    [self.sdk.nativeAdService precacheResourcesForNativeAd: ad andNotify: self.precacheRouter];
                }
            }
        }
        // Slot does not exist for this card view, hide
        else
        {
            ALLog(@"Hiding card at card index: %ld", cardIndex);
            
            [cardView clearView];
            cardView.hidden = YES;
            
            if ( cardIndex == kMidCardIndex )
            {
                ALLog(@"Hiding middle card because of nil ad.");
            }
        }
    }
    
    [self al_hideActivityIndicatorAnimated: YES];
    
    ALLog(@"Finish refreshing carousel view");
}

- (void)clearView
{
    for ( ALCarouselCardView *cardView in self.cardViews )
    {
        [cardView clearView];
    }
    [self.carouselModel removeAllObjects];
}

#pragma mark - Overridden Getters/Setters

- (void)setNativeAds:(NSArray * __nullable)nativeAds
{
    if ( self.nativeAds.count > 0 )
    {
        // Check if array contains objects of the proper ad type
        for ( id obj in self.nativeAds )
        {
            if ( ![obj isKindOfClass: [ALNativeAd class]] )
            {
                // Found an object of invalid type
                ALLog(@"Found an object of invalid type (%@) in nativeAds", NSStringFromClass([obj class]));
                
                return;
            }
        }
    }
    else
    {
        // We clear the view if native ads is set to an empty array
        ALLog(@"Setting native ads of count 0. Clearing view...");
        [self clearView];
    }
    
    _nativeAds = nativeAds;
}

- (void)setCurrentAdIndex:(NSInteger)currentAdIndex
{
    if ( currentAdIndex < self.nativeAds.count )
    {
        if ( self.currentAdIndex == currentAdIndex )
        {
            ALLog(@"Setting same current ad index of %ld", currentAdIndex);
        }
        else
        {
            ALLog(@"Setting new current ad index of %ld", currentAdIndex);
            
            _currentAdIndex = currentAdIndex;
            
            [self refreshView];
        }
    }
    else
    {
        ALLog(@"Setting out-of-bounds index of %ld", currentAdIndex);
    }
}

#pragma mark - Utility

- (NSInteger)adIndexForCardIndex:(NSUInteger)cardIndex
{
    return self.currentAdIndex + cardIndex - kNumSideCards;
}

#pragma mark - Gesture Recognizers

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isEqual: self.panGesture] )
    {
        // Our pan gesture should only recognize horizontal pans
        CGPoint translation = [self.panGesture velocityInView: self];
        return fabs(translation.y) < fabs(translation.x);
    }
    
    return YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    switch ( recognizer.state )
    {
        case UIGestureRecognizerStateChanged:
        {
            CGFloat xOffset = [recognizer translationInView: self].x;
            self.contentView.frame = CGRectOffset(self.contentView.frame, xOffset, 0.0f);
            
            [recognizer setTranslation: CGPointZero inView: self];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            const CGFloat cardWidth           = (CGRectGetWidth(self.bounds) * kCardWidthPercentage) - (2 * kCardMargin);
            const CGFloat contentOffset       = fabs(self.center.x - self.contentView.center.x);
            const CGFloat percentageSwiped    = 1.0f - (contentOffset/CGRectGetWidth(self.bounds));
            const CGFloat springDuration      = percentageSwiped * kSpringDuration;
            
            const BOOL exceedsThreshold       = contentOffset > kConfigSwipeThreshold;
            const BOOL leftToRight            = [recognizer velocityInView: self].x > 0.0f;
            
            // If user is swiping left to right
            if ( leftToRight )
            {
                // If the middle card has a slot to the left of it, then execute the swipe
                if ( self.currentAdIndex >= 1 && exceedsThreshold )
                {
                    [UIView animateWithDuration: springDuration
                                          delay: kDelay
                         usingSpringWithDamping: kSpringDampeningGoNextCard
                          initialSpringVelocity: kInitialSpringVelocity
                                        options: UIViewAnimationOptionCurveEaseInOut
                                     animations: ^{
                                         
                                         self.contentView.center = CGPointMake( (CGRectGetWidth(self.frame)/2.0f) + cardWidth, self.contentView.center.y);
                                     }
                                     completion: ^(BOOL finished) {
                                        
                                         if ( finished )
                                         {
                                             --self.currentAdIndex;
                                             [self setNeedsLayout];
                                         }
                                     }];
                }
                // There are no slots to the left of the middle card anymore, spring back
                else
                {
                    [UIView animateWithDuration: kSpringDuration
                                          delay: kDelay
                         usingSpringWithDamping: kSpringDampeningReturnSameCard
                          initialSpringVelocity: kInitialSpringVelocity
                                        options: UIViewAnimationOptionCurveEaseInOut
                                     animations: ^{
                                         
                                         self.contentView.center = CGPointMake(0.5f * CGRectGetWidth( self.frame ), self.contentView.center.y);
                                     }
                                     completion:nil];
                }
            }
            // We are swiping right to left
            else
            {
                // If there is a slot to the right of the middle card, execute the swipe
                if ( self.currentAdIndex < [self.carouselModel nativeAdsCount]-1 && exceedsThreshold )
                {
                    [UIView animateWithDuration: springDuration
                                          delay: kDelay
                         usingSpringWithDamping: kSpringDampeningGoNextCard
                          initialSpringVelocity: kInitialSpringVelocity
                                        options: UIViewAnimationOptionCurveEaseInOut
                                     animations: ^{
                                         
                                         self.contentView.center = CGPointMake( (CGRectGetWidth(self.frame)/2.0f) - cardWidth, self.contentView.center.y);
                                     }
                                     completion:^(BOOL finished) {
                                         
                                         if ( finished )
                                         {
                                             ++self.currentAdIndex;
                                             [self setNeedsLayout];
                                         }
                                     }];
                }
                // There are no slots to the right of the middle card anymore. Spring back
                else
                {
                    [UIView animateWithDuration: kSpringDuration
                                          delay: kDelay
                         usingSpringWithDamping: kSpringDampeningReturnSameCard
                          initialSpringVelocity: kInitialSpringVelocity
                                        options: UIViewAnimationOptionCurveEaseInOut
                                     animations: ^{
                                         
                                         self.contentView.center = CGPointMake(0.5f * CGRectGetWidth( self.frame ), self.contentView.center.y);
                                     }
                                     completion:nil];
                }
            }
            break;
        }
        default:
        {
            break;
        }
    }
}

@end

#pragma mark ALCarouselPrecacheRouter

@implementation ALCarouselPrecacheRouter

#pragma mark - Initialization

- (instancetype)initWithCarouselView:(ALCarouselView *)carouselView
{
    self = [super init];
    
    if ( self )
    {
        self.tag          = @"ALCarouselPrecacheRouter";
        self.carouselView = carouselView;
    }
    
    return self;
}

#pragma mark - Precache Delegate Methods

- (void)nativeAdService:(ALNativeAdService *)service didPrecacheImagesForAd:(ALNativeAd *)ad
{
    ALLog(@"Finished pre-caching images for slot (%@). Rendering...", ad.adIdNumber);
    
    const NSUInteger index = [self.carouselView.nativeAds indexOfObject: ad];
    
    if ( index != NSNotFound )
    {
        const NSInteger cardIndex = [self cardIndexForAdIndex: index];
        ALCarouselCardView* cardView = self.carouselView.cardViews[cardIndex];
        ALCarouselViewModel* model = self.carouselView.carouselModel;
        ALCarouselCardState* cardState = [model cardStateAtNativeAdIndex: index];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [cardView renderViewForNativeAd: ad cardState: cardState];
            
            if (cardIndex == kMidCardIndex) {
                [cardView trackImpression];
            }
            
            cardView.hidden = NO;
        }];
    }
    else
    {
        ALLog(@"Finished pre-caching images for ad (%@). Card is not on screen, stashing...", ad.adIdNumber);
    }
}

- (void)nativeAdService:(ALNativeAdService *)service didPrecacheVideoForAd:(ALNativeAd *)ad
{
    if ( ad.videoURL )
    {
        const NSUInteger index = [self.carouselView.nativeAds indexOfObject: ad];
        ALCarouselCardState *cardState = [self.carouselView.carouselModel cardStateAtNativeAdIndex: index];
        
        // If video is loaded for a currently active ad, render the slot
        if ( index != NSNotFound && cardState.currentlyActive )
        {
            ALLog(@"Finished pre-caching for slot (%@) with valid video in active card", ad.adIdNumber);
            
            const NSInteger cardIndex = [self cardIndexForAdIndex: index];
            ALCarouselCardView *cardView = self.carouselView.cardViews[cardIndex];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [cardView.mediaView renderViewForNativeAd: ad cardState: cardState];
            }];
        }
        else
        {
            ALLog(@"Finished pre-caching video for ad (%@). Card is not on screen, stashing...", ad.adIdNumber);
        }
    }
    else
    {
        // Finished pre-caching for slot without video
        ALLog(@"Finished pre-caching for ad (%@) without video", ad.adIdNumber);
    }
    
    [self.carouselView.carouselModel cardStateForNativeAd: ad].precaching = NO;
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToPrecacheImagesForAd:(ALNativeAd *)ad withError:(NSInteger)errorCode
{
    // Have activity indicator remain on card
    [self.carouselView.carouselModel cardStateForNativeAd: ad].precaching = YES;
    
    ALLog(@"Failed to precache images for ad (%@) with error code: %ld", ad.adIdNumber, errorCode);
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToPrecacheVideoForAd:(ALNativeAd *)ad withError:(NSInteger)errorCode
{
    // If the slot already has its images pre-cached, it means video failed to pre-cache. Just ignore that
    [self.carouselView.carouselModel cardStateForNativeAd: ad].precaching = NO;
    
    ALLog(@"Failed to precache video for ad (%@) with error code: %ld", ad.adIdNumber, errorCode);
}

#pragma mark - Utility

- (NSUInteger)cardIndexForAdIndex:(NSUInteger)slotIndex
{
    return kMidCardIndex + slotIndex - self.carouselView.currentAdIndex;
}

@end
