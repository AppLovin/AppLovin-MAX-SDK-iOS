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
static const NSInteger kRowIndexToHideForPhone = 3;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if ( [tableView cellForRowAtIndexPath: indexPath] == self.mediationDebuggerCell )
    {
        [[ALSdk shared] showMediationDebugger];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && indexPath.section == 0 && indexPath.row == kRowIndexToHideForPhone )
    {
        cell.hidden = YES;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && indexPath.section == 0 && indexPath.row == kRowIndexToHideForPhone )
    {
        return 0;
    }
    return [super tableView: tableView heightForRowAtIndexPath: indexPath];
}

@end
