//
//  ALDemoBaseTableViewController.m
//  iOS-SDK-Demo
//
//  Created by Thomas So on 9/24/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

#import "ALDemoBaseTableViewController.h"

@implementation ALDemoBaseTableViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end
