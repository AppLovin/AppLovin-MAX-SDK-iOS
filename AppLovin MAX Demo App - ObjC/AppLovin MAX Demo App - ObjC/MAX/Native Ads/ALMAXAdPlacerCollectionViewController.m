//
//  ALMAXAdPlacerCollectionViewController.m
//  AppLovin MAX Demo App - ObjC
//
//  Created by Ritam Sarmah on 4/1/22.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMAXAdPlacerCollectionViewController.h"
#import "ALTextCollectionViewCell.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXAdPlacerCollectionViewController()<MAAdPlacerDelegate>

@property (nonatomic, strong) MACollectionViewAdPlacer *adPlacer;
@property (nonatomic, strong) NSArray<NSString *> *data;

@end

@implementation ALMAXAdPlacerCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = [UIFont.familyNames sortedArrayUsingSelector: @selector(compare:)];
    
    MAAdPlacerSettings *settings = [MAAdPlacerSettings settingsWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID"];
    [settings addFixedPosition: [NSIndexPath indexPathForItem: 2 inSection: 0]];
    [settings addFixedPosition: [NSIndexPath indexPathForItem: 8 inSection: 0]];
    settings.repeatingInterval = 5;
    
    // If using custom views, you must also set the `nativeAdViewNib` and `nativeAdViewBinder` properties on the ad placer
    
    self.adPlacer = [MACollectionViewAdPlacer placerWithCollectionView: self.collectionView settings: settings];
    self.adPlacer.delegate = self;
    [self.adPlacer loadAds];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALTextCollectionViewCell *cell = (ALTextCollectionViewCell *)[collectionView al_dequeueReusableCellWithReuseIdentifier: @"ALMAXAdPlacerCollectionViewCell" forIndexPath: indexPath];
    cell.textLabel.text = self.data[indexPath.row];
    return cell;
}

#pragma mark - MAAdPlacerDelegate

- (void)didLoadAdAtIndexPath:(NSIndexPath *)indexPath {}
- (void)didRemoveAdsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {}
- (void)didClickAd:(MAAd *)ad {}
- (void)didPayRevenueForAd:(MAAd *)ad {}

@end
