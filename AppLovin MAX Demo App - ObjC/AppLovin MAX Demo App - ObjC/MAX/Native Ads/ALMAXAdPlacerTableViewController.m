//
//  ALMAXAdPlacerTableViewController.m
//  AppLovin MAX Demo App - ObjC
//
//  Created by Ritam Sarmah on 4/1/22.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMAXAdPlacerTableViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXAdPlacerTableViewController()<MAAdPlacerDelegate>

@property (nonatomic, strong) MATableViewAdPlacer *adPlacer;
@property (nonatomic, strong) NSArray<NSString *> *data;

@end

@implementation ALMAXAdPlacerTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = [UIFont.familyNames sortedArrayUsingSelector: @selector(compare:)];
    
    MAAdPlacerSettings *settings = [MAAdPlacerSettings settingsWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID"];
    [settings addFixedPosition: [NSIndexPath indexPathForRow: 2 inSection: 0]];
    [settings addFixedPosition: [NSIndexPath indexPathForRow: 8 inSection: 0]];
    settings.repeatingInterval = 10;
    
    // If using custom views, you must also set the `nativeAdViewNib` and `nativeAdViewBinder` properties on the ad placer
    
    self.adPlacer = [MATableViewAdPlacer placerWithTableView: self.tableView settings: settings];
    self.adPlacer.delegate = self;
    [self.adPlacer loadAds];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView al_dequeueReusableCellWithIdentifier: @"ALMAXAdPlacerTableViewCell" forIndexPath: indexPath];
    cell.textLabel.text = self.data[indexPath.row];
    return cell;
}

#pragma mark - MAAdPlacerDelegate

- (void)didLoadAdAtIndexPath:(NSIndexPath *)indexPath {}
- (void)didRemoveAdsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {}
- (void)didClickAd:(MAAd *)ad {}
- (void)didPayRevenueForAd:(MAAd *)ad {}

@end
