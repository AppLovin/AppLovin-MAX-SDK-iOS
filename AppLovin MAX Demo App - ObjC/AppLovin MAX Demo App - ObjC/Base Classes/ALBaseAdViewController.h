//
//  ALBaseAdViewController.h
//  DemoApp-ObjC
//
//  Created by Harry Arakkal on 10/9/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALBaseAdViewController : UIViewController
@property (nonatomic, weak) IBOutlet UITableView *callbackTableView;
/**
 * Used for logging ad callbacks in the callback table.
 */
- (void)logCallback:(const char *)name;

@end

NS_ASSUME_NONNULL_END
