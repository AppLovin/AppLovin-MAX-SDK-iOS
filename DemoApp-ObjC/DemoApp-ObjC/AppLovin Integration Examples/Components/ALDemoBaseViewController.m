//
//  ALDemoBaseViewController.m
//  iOS-SDK-Demo
//
//  Created by Thomas So on 9/23/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

#import "ALDemoBaseViewController.h"

@implementation ALDemoBaseViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Dynamically support dark mode setting of systemBackgroundColor
    if (@available(iOS 13.0, *))
    {
        if ([UIColor respondsToSelector:NSSelectorFromString(@"systemBackgroundColor")])
        {
            UIColor *backgroundColor = [UIColor performSelector:NSSelectorFromString(@"systemBackgroundColor")];
            [self.view setBackgroundColor: backgroundColor];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self.navigationController setToolbarHidden: self.hidesBottomBarWhenPushed animated: YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden: YES];
    [super viewWillDisappear: animated];
}

#pragma mark - Logging

- (void)log:(NSString *)format, ...
{
    va_list valist;
    va_start(valist, format);
    NSString *message = [[NSString alloc] initWithFormat: format arguments: valist];
    va_end(valist);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ( self.adStatusLabel )
        {
            self.adStatusLabel.text = message;
        }
        ALLog(@"[%@] : %@", NSStringFromClass([self class]), message);
    });
}

@end
