//
//  ALMAXMRecTableViewController.m
//  AppLovin MAX Demo App - ObjC
//
//  Created by Alan Cao on 6/30/22.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMAXMRecTableViewController.h"
#import "ALMAXMRecTableViewCell.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXMRecTableViewController () <UITableViewDelegate, UITableViewDataSource, MAAdViewAdDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<MAAdView *> *adViews;
@property (nonatomic, strong) NSMutableArray<NSString *> *sampleData;
@property (nonatomic, assign) NSInteger adViewIndex;

@end

@implementation ALMAXMRecTableViewController
static const NSInteger kAdViewCount = 5;
static const NSInteger kAdInterval = 10;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.adViews = [NSMutableArray array];
    self.sampleData = [NSMutableArray arrayWithArray: [UIFont familyNames]];
    self.adViewIndex = 0;
    
    // Configure table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self configureAdViews: kAdViewCount];
}

- (void)configureAdViews:(NSInteger)count
{
    [self.tableView beginUpdates];
    
    for ( int i = 0; i < self.sampleData.count; i += kAdInterval )
    {
        [self.sampleData insertObject: @"" atIndex: i]; // TODO: Unsure if this is the best way to insert rows
        [self.tableView insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: i inSection: 0]] withRowAnimation: UITableViewRowAnimationAutomatic];
    }
    
    [self.tableView endUpdates];
    
    for ( int i = 0; i < count; i++ )
    {
        MAAdView *adView = [[MAAdView alloc] initWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID" adFormat: MAAdFormat.mrec];
        adView.delegate = self;
        
        // Set this extra parameter to work around SDK bug that ignores calls to stopAutoRefresh()
        [adView setExtraParameterForKey: @"allow_pause_auto_refresh_immediately" value: @"true"];
        [adView stopAutoRefresh];
        
        // Load the ad
        [adView loadAd];
        [self.adViews addObject: adView];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sampleData.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if ( indexPath.row % kAdInterval == 0 )
    {
        ALMAXMRecTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ALMAXMRecTableViewCell" forIndexPath: indexPath];
        
        // Select an ad view to display
        MAAdView *adView = [self.adViews objectAtIndex: self.adViewIndex % kAdViewCount];
        self.adViewIndex = (self.adViewIndex + 1) % kAdViewCount; // TODO: Unsure if this is the best way to access adViews
        
        // Configure cell with an ad
        [cell configureWith: adView];
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"customCell"];
        cell.textLabel.text = self.sampleData[indexPath.row];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass: ALMAXMRecTableViewCell.class])
    {
        [(ALMAXMRecTableViewCell *) cell stopAutoRefresh];
    }
}

#pragma mark - MAAdViewAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad {}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {}

- (void)didClickAd:(MAAd *)ad {}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {}

- (void)didExpandAd:(MAAd *)ad {}

- (void)didCollapseAd:(MAAd *)ad {}

#pragma mark - Deprecated Callbacks

- (void)didDisplayAd:(MAAd *)ad { /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */ }
- (void)didHideAd:(MAAd *)ad { /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */ }

@end
