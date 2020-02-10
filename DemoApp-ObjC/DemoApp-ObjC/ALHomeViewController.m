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
@property (nonatomic, weak) IBOutlet UITableViewCell *mediationDebuggerCell;
@end

@implementation ALHomeViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if ( [tableView cellForRowAtIndexPath: indexPath] == self.mediationDebuggerCell )
    {
        [[ALSdk shared] showMediationDebugger];
    }
}

@end
