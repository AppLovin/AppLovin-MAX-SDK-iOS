//
//  ALMAXManualNativeLateBindingAdViewController.m
//  AppLovin MAX Demo App - ObjC
//
//  Created by Billy Hu on 3/8/22.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMAXManualNativeLateBindingAdViewController.h"
#import <Adjust/Adjust.h>
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXManualNativeLateBindingAdViewController()<MANativeAdDelegate, MAAdRevenueDelegate>

@property (nonatomic, weak) IBOutlet UIView *nativeAdContainerView;
@property (nonatomic, weak) IBOutlet UIButton *showAdButton;

@property (nonatomic, strong) MANativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) MANativeAdView *nativeAdView;
@property (nonatomic, strong, nullable) MAAd *nativeAd;

@end

@implementation ALMAXManualNativeLateBindingAdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nativeAdLoader = [[MANativeAdLoader alloc] initWithAdUnitIdentifier: @"YOUR_AD_UNIT"];
    self.nativeAdLoader.nativeAdDelegate = self;
    self.nativeAdLoader.revenueDelegate = self;
}

- (void)dealloc
{
    [self cleanUpAdIfNeeded];
    
    self.nativeAdLoader.nativeAdDelegate = nil;
    self.nativeAdLoader.revenueDelegate = nil;
}

- (void)cleanUpAdIfNeeded
{
    // Clean up any pre-existing native ad to prevent memory leaks
    if ( self.nativeAd )
    {
        [self.nativeAdLoader destroyAd: self.nativeAd];
    }
    
    if ( self.nativeAdView )
    {
        [self.nativeAdView removeFromSuperview];
    }
}

- (MANativeAdView *)createNativeAdView
{
    UINib *nativeAdViewNib = [UINib nibWithNibName: @"NativeManualAdView" bundle: NSBundle.mainBundle];
    MANativeAdView *nativeAdView = [nativeAdViewNib instantiateWithOwner: nil options: nil].firstObject;
    
    MANativeAdViewBinder *binder = [[MANativeAdViewBinder alloc] initWithBuilderBlock:^(MANativeAdViewBinderBuilder *builder) {
        builder.titleLabelTag = 1001;
        builder.advertiserLabelTag = 1002;
        builder.bodyLabelTag = 1003;
        builder.iconImageViewTag = 1004;
        builder.optionsContentViewTag = 1005;
        builder.mediaContentViewTag = 1006;
        builder.callToActionButtonTag = 1007;
    }];
    [nativeAdView bindViewsWithAdViewBinder: binder];
    
    return nativeAdView;
}

#pragma mark - IB Actions

- (IBAction)loadAd
{
    [self cleanUpAdIfNeeded];
    
    [self.nativeAdLoader loadAd];
}

- (IBAction)showAd
{
    self.nativeAdView = [self createNativeAdView];
    [self.nativeAdLoader renderNativeAdView: self.nativeAdView withAd: self.nativeAd];
    [self.nativeAdContainerView addSubview: self.nativeAdView];
    
    [self.showAdButton setEnabled: NO];
}

#pragma mark - NativeAdDelegate Protocol

- (void)didLoadNativeAd:(MANativeAdView *)nativeAdView forAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
    
    // Save ad to be rendered later
    self.nativeAd = ad;
    
    [self.showAdButton setEnabled: YES];
    
    // Set to false if modifying constraints after adding the ad view to your layout
    self.nativeAdContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Set ad view to span width and height of container and center the ad
    [self.nativeAdContainerView.widthAnchor constraintEqualToAnchor: nativeAdView.widthAnchor].active = YES;
    [self.nativeAdContainerView.heightAnchor constraintEqualToAnchor: nativeAdView.heightAnchor].active = YES;
    [self.nativeAdContainerView.centerXAnchor constraintEqualToAnchor: nativeAdView.centerXAnchor].active = YES;
    [self.nativeAdContainerView.centerYAnchor constraintEqualToAnchor: nativeAdView.centerYAnchor].active = YES;
}

- (void)didFailToLoadNativeAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error
{
    [self logCallback: __PRETTY_FUNCTION__];
}

- (void)didClickNativeAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
}

#pragma mark - MAAdRevenueDelegate Protocol

- (void)didPayRevenueForAd:(MAAd *)ad
{
    [self logCallback: __PRETTY_FUNCTION__];
    
    ADJAdRevenue *adjustAdRevenue = [[ADJAdRevenue alloc] initWithSource: ADJAdRevenueSourceAppLovinMAX];
    [adjustAdRevenue setRevenue: ad.revenue currency: @"USD"];
    [adjustAdRevenue setAdRevenueNetwork: ad.networkName];
    [adjustAdRevenue setAdRevenueUnit: ad.adUnitIdentifier];
    [adjustAdRevenue setAdRevenuePlacement: ad.placement];
    
    [Adjust trackAdRevenue: adjustAdRevenue];
}

@end
