//
//  HSSInterstitialBannerVC.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/5/29.
//

#import <HSADXSDK/HSADXSDK.h>
#import <HSADXSDK/HSSCreativeItemModel.h>
#import <HSADXSDK/HSSBaseViewController.h>
#import <HSADXSDK/HSSInterstitialBannerView.h>
#import "HSSInterDoubleBannerView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^adBannerDwellBlock)(NSInteger duration);
typedef void(^adBannerShowTimeBlock)(NSInteger duration);
typedef void(^buttonAppearBlock)(NSString *buttonType);

@interface HSSInterstitialBannerVC : HSSBaseViewController

@property (nonatomic, strong) HSSCreativeItemModel *itemModel;

@property (nonatomic, strong) HSSInterstitialBannerView *bannerView;

@property (nonatomic, strong) HSSInterDoubleBannerView *doubleBannerView;

/// 消失
@property (nonatomic, copy) void (^dismissCompletion)(void);

@property (nonatomic, copy) adBannerDwellBlock dwellBlock;

@property (nonatomic, copy) adBannerShowTimeBlock adShowBlock;

/// 按钮出现事件（跳过按钮、关闭按钮）
@property (nonatomic, copy) buttonAppearBlock buttonAppear;

@property (nonatomic, assign) BOOL isMix;

@end

NS_ASSUME_NONNULL_END
