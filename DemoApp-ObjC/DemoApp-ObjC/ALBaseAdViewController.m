//
//  ALBaseAdViewController.m
//  DemoApp-ObjC
//
//  Created by Harry Arakkal on 10/9/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALBaseAdViewController.h"

@interface ALBaseAdViewController ()<UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *callbackTableView;

@property (nonatomic, strong) NSMutableArray<NSString *> *callbacks;

@end

@implementation ALBaseAdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.callbacks = [[NSMutableArray alloc] init];
    
    self.callbackTableView.dataSource = self;
}

- (void)logCallback:(const char *)name
{
    [self.callbacks addObject: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
    
    NSArray<NSIndexPath *> *lastIndexPath = @[ [NSIndexPath indexPathForRow: self.callbacks.count - 1 inSection: 0] ];
    [self.callbackTableView insertRowsAtIndexPaths: lastIndexPath withRowAnimation: UITableViewRowAnimationAutomatic];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"callbackCell" forIndexPath: indexPath];
    
    cell.textLabel.text = self.callbacks[indexPath.row];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.callbacks.count;
}

@end
