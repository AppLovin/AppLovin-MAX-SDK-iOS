//
//  ALHomeViewController.m
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALHomeViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALHomeViewController()

@end

@implementation ALHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)showMediationDebugger:(UIBarButtonItem *)sender
{
    [[ALSdk shared] showMediationDebugger];
}

@end
