//
//  ALCarouselModel.m
//  sdk
//
//  Created by Matt Szaro on 4/20/15.
//
//

#import "ALCarouselViewModel.h"
#import "ALCarouselCardState.h"
#import "ALDebugLog.h"

@interface ALCarouselViewModel ()

@property (strong, nonatomic) ALSdk* sdk;

@property (strong, nonatomic) NSArray*             nativeAds;
@property (strong, nonatomic) NSMutableDictionary* cardStates;

@end

@implementation ALCarouselViewModel
@dynamic nativeAdsCount;

static void* ALCarouselViewModelKVOContext = &ALCarouselViewModelKVOContext;
static NSString* kKeypathMuteState = @"muteState";

-(instancetype) initWithNativeAds: (NSArray *)ads
{
    self = [super init];
    if ( self )
    {
        self.nativeAds  = ads;
        self.cardStates = [NSMutableDictionary dictionary];
    }
    return self;
}

- (ALCarouselCardState *)cardStateAtNativeAdIndex:(NSUInteger)index
{
    if ( index >= [self nativeAdsCount])
    {
        ALLog(@"Requested card state at native ad index %lu is out-of-bounds", index);
        return nil;
    }
    else
    {
        ALCarouselCardState* cardState = self.cardStates[ @(index) ];
        if ( cardState )
        {
            ALLog(@"Requested card state at native ad index %lu", index);
            return cardState;
        }
        else
        {
            ALLog(@"Requested card state at native ad index %lu does not exist yet. Creating new card state", index);
            
            ALCarouselCardState* newState = [ALCarouselCardState cardStateForCarousel];
            [self beginObservingCardState: newState];
            [self.cardStates setObject: newState forKey: @(index)];
            
            return newState;
        }
    }
}

-(void) beginObservingCardState: (ALCarouselCardState*) cardState
{
    // Observe any properties which need to be synchronized among all card states.
    // E.g., propogate mute settings among cards while within a carousel view.
    // This allows us to add syncronization features on top of the card state without adding complexity for single card integrations.
    
    [cardState addObserver: self
                forKeyPath: kKeypathMuteState
                   options: NSKeyValueObservingOptionNew
                   context: ALCarouselViewModelKVOContext];
}

-(void) endObservingCardState: (ALCarouselCardState*) cardState
{
    // Observe any properties which need to be synchronized among all card states.
    // E.g., propogate mute settings among cards while within a carousel view.
    // This allows us to add syncronization features on top of the card state without adding complexity for single card integrations.
    
    @try {
        [cardState removeObserver: self
                       forKeyPath: kKeypathMuteState
                          context: ALCarouselViewModelKVOContext];
    }
    @catch (NSException* __unused ignore)
    {
    }
}

-(void) observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context
{
    if (context == ALCarouselViewModelKVOContext)
    {
        if ([keyPath isEqual: kKeypathMuteState])
        {
            NSNumber* newValue = change[NSKeyValueChangeNewKey];
            ALMuteState muteState = (ALMuteState) [newValue unsignedIntegerValue];
            
            if (muteState != ALMuteStateUnspecified)
            {
                [self updateMuteStates: muteState];
            }
        }
    }
    else
    {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}

-(void) updateMuteStates: (ALMuteState) newState
{
    [self.cardStates enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ALCarouselCardState* cardState = (ALCarouselCardState*) obj;
        [self endObservingCardState: cardState];
        cardState.muteState = newState;
        [self beginObservingCardState: cardState];
    }];
}

- (ALCarouselCardState *)cardStateForNativeAd:(ALNativeAd *)ad
{
    NSUInteger index = [self.nativeAds indexOfObject: ad];
    if ( index != NSNotFound )
    {
        return [self cardStateAtNativeAdIndex: index];
    }
    else
    {
        return nil;
    }
}

- (ALNativeAd *)nativeAdAtIndex:(NSUInteger)index
{
    if ( index < self.nativeAds.count )
    {
        ALLog(@"Requested native ad index %lu", index);
        return [self.nativeAds objectAtIndex: index];
    }
    else
    {
        ALLog(@"Requested native ad index %lu is out of bounds", index);
        return nil;
    }
}

- (NSUInteger)nativeAdsCount
{
    return self.nativeAds.count;
}

-(void) removeAllObjects;
{
    self.nativeAds = nil;
    
    [self.cardStates enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ALCarouselCardState* cardState = (ALCarouselCardState*) obj;
        [self endObservingCardState: cardState];
    }];
    
    [self.cardStates removeAllObjects];
}

-(void) dealloc
{
    [self removeAllObjects];
}

@end
