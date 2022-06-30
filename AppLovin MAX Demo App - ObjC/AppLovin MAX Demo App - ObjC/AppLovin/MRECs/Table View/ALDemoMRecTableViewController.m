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

@property (nonatomic) NSMutableArray *adViewQueue;
@property (nonatomic) NSArray *sampleData;

@end

@implementation ALDemoMRecTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.adViewQueue = [NSMutableArray array];
    self.sampleData = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L"];
    
    // Configure table view
    self.tableView.al_delegate = self;
    self.tableView.al_dataSource = self;
    self.tableView.estimatedRowHeight = 250;
    self.tableView.rowHeight = 250;
    
    [self configureAdViews: 5];
}

- (void)configureAdViews:(NSInteger)count
{
    for (int i = 0; i < count; i++)
    {
        MAAdView *adView = [[MAAdView alloc] initWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID" adFormat: MAAdFormat.mrec];
        adView.delegate = self;
        
        // Set this extra parameter to work around SDK bug that ignores calls to stopAutoRefresh()
        [adView setExtraParameterForKey: @"allow_pause_auto_refresh_immediately" value: @"true"];
        [adView stopAutoRefresh];
        
        // Load the ad
        [adView loadAd];
        [self.adViewQueue addObject: adView];
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
    ALDemoMRecTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ALDemoMRecTableViewCell" forIndexPath: indexPath];
    
    if (indexPath.section % 4 == 0 && self.adViewQueue.count)
    {
        MAAdView *adView = [self.adViewQueue objectAtIndex: 0];
        [adView startAutoRefresh];
        [self.adViewQueue removeObjectAtIndex: 0];
        
        cell.adView = adView;
        [cell configure];
        
        [self.adViewQueue addObject: adView];
    }
    else
    {
        cell.textLabel.text = self.sampleData[indexPath.section]; // Configure custom cells
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALDemoMRecTableViewCell *adViewCell = (ALDemoMRecTableViewCell *) cell;
    
    if (adViewCell.adView != nil)
    {
        // Set this extra parameter to work around SDK bug that ignores calls to stopAutoRefresh()
        [adViewCell.adView setExtraParameterForKey: @"allow_pause_auto_refresh_immediately" value: @"true"];
        [adViewCell.adView stopAutoRefresh];
    }
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
