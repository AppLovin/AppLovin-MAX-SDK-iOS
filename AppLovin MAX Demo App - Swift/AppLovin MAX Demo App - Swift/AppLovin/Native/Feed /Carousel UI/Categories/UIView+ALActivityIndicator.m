//
//  UIView+ALActivityIndicator.m
//  sdk
//
//  Created by Thomas So on 5/15/15.
//
//

#import "UIView+ALActivityIndicator.h"
#import "ALCarouselView+Internal.h"
#import "ALDebugLog.h"

@implementation UIView(ALActivityIndicator)
static NSString *const kActivityIndicatorKey        = @"activityIndicator";
static NSString *const kActivityIndicatorOverlayKey = @"activityIndicatorOverlay";

static const CGFloat kTargetOverlayAlpha = 1.0f;
static const CGFloat kAnimationDuration  = 0.35f;

- (void)al_showActivityIndicator
{
    [self al_showActivityIndicatorAnimated: NO];
}

- (void)al_showActivityIndicatorAnimated:(BOOL)animated
{
    UIView *overlay = [self valueForKey: kActivityIndicatorOverlayKey];
    if ( !overlay )
    {
        overlay                 = [[UIView alloc] init];
        overlay.backgroundColor = [UIColor whiteColor];
        overlay.frame           = self.bounds;
        
        ALLog(@"Created overlay with frame: %@", NSStringFromCGRect(overlay.frame));
        
        [self setValue: overlay forKey: kActivityIndicatorOverlayKey];
    }
    
    UIActivityIndicatorView *activityIndicator = [self valueForKey: kActivityIndicatorKey];
    if ( !activityIndicator )
    {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator.center           = self.center;
        
        [overlay addSubview: activityIndicator];
        [overlay bringSubviewToFront: activityIndicator];
        
        [self setValue: activityIndicator forKey: kActivityIndicatorKey];
    }
    
    [activityIndicator startAnimating];
    overlay.alpha = animated ? 0.0f : kTargetOverlayAlpha;
    
    [self addSubview: overlay];
    [self bringSubviewToFront: overlay];
    
    if ( animated )
    {
        [UIView animateWithDuration: kAnimationDuration animations:^{
            overlay.alpha = kTargetOverlayAlpha;
        }];
    }
}

- (void)al_hideActivityIndicator
{
    [self al_hideActivityIndicatorAnimated: NO];
}

- (void)al_hideActivityIndicatorAnimated:(BOOL)animated
{
    UIView *overlay = [self valueForKey: kActivityIndicatorOverlayKey];
    if ( !overlay.superview )
    {
        return;
    }
 
    UIActivityIndicatorView *activityIndicator = [self valueForKey: kActivityIndicatorKey];
    [UIView animateWithDuration: animated ? kAnimationDuration  : 0.0f animations:^{
        overlay.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [activityIndicator stopAnimating];
        [overlay removeFromSuperview];
    }];
}

@end
