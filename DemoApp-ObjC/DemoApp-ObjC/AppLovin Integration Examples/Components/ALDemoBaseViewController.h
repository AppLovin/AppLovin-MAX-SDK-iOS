//
//  ALDemoBaseViewController.h
//  iOS-SDK-Demo
//
//  Created by Thomas So on 9/23/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALDemoBaseViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *adStatusLabel;

- (void)log:(NSString *)format, ...;

@end
