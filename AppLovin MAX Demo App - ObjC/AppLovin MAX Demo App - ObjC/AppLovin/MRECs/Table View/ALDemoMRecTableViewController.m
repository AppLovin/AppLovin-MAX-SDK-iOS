//
//  ALDemoMRecTableViewController.m
//  AppLovin MAX Demo App - ObjC
//
//  Created by Alan Cao on 6/30/22.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALDemoMRecTableViewController.h"
#import "ALDemoMRecTableViewCell.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALDemoMRecTableViewController () <UITableViewDelegate, UITableViewDataSource, MAAdViewAdDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *adViews;
@property (nonatomic) NSArray *sampleData;

@end

@implementation ALDemoMRecTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.adViews = [NSMutableArray array];
    self.sampleData = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L"];
    
    // Configure table view
    self.tableView.al_delegate = self;
    self.tableView.al_dataSource = self;
    self.tableView.estimatedRowHeight = 250;
    self.tableView.rowHeight = 250;
    
    [self configureAdViews:3];
}

- (void) configureAdViews:(NSInteger)count
{
    for (int i = 0; i < count; i++)
    {
        MAAdView *adView = [[MAAdView alloc] initWithAdUnitIdentifier:@"YOUR_AD_UNIT_ID" adFormat:MAAdFormat.mrec];
        adView.delegate = self;
        
        // Set this extra parameter to work around SDK bug that ignores calls to stopAutoRefresh()
        [adView setExtraParameterForKey: @"allow_pause_auto_refresh_immediately" value: @"true"];
        [adView stopAutoRefresh];
        
        // Load the ad
        [adView loadAd];
        [self.adViews addObject:adView];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sampleData.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    ALDemoMRecTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ALDemoMRecTableViewCell" forIndexPath:indexPath];
    
    switch (indexPath.section)
    {
        case 0:
            [cell configureWith:self.adViews[0]]; // Configure cell with an ad
            break;
        case 4:
            [cell configureWith:self.adViews[1]]; // Configure cell with different ad
            break;
        case 8:
            [cell configureWith:self.adViews[2]]; // Configure cell with another different ad
            break;
        default:
            cell.textLabel.text = self.sampleData[indexPath.section]; // Configure custom cells
    }

    return cell;
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    [self.tableView al_reloadData];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {}

- (void)didClickAd:(MAAd *)ad {}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {}

#pragma mark - MAAdViewAdDelegate Protocol

- (void)didExpandAd:(MAAd *)ad {}

- (void)didCollapseAd:(MAAd *)ad {}

#pragma mark - Deprecated Callbacks

- (void)didDisplayAd:(MAAd *)ad { /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */ }
- (void)didHideAd:(MAAd *)ad { /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */ }

@end
