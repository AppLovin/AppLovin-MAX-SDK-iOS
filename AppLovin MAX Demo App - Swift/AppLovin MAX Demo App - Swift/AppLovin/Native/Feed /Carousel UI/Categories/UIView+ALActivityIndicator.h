//
//  UIView+ALActivityIndicator.h
//  sdk
//
//  Created by Thomas So on 5/15/15.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ALActivityIndicator)

/**
 *  Show an activity indicator with a semi-transparent black overlay underneath without fade.
 */
- (void)al_showActivityIndicator;

/**
 *  Show an activity indicator with a semi-transparent black overlay underneath with a fade animation option.
 */
- (void)al_showActivityIndicatorAnimated:(BOOL)animated;

/**
 *  Hides the activity indicator view without fade.
 */
- (void)al_hideActivityIndicator;

/**
 *  Hides the activity indicator view with a fade animation option.
 */
- (void)al_hideActivityIndicatorAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
