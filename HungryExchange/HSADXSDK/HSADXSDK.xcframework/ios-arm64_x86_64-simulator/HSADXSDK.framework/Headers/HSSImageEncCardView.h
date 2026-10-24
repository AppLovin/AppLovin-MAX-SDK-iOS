//
//  HSSImageEncCardView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/3/10.
//

#import <HSADXSDK/HSADXSDK.h>
#import <HSADXSDK/HSSHotClickAreaView.h>

@class HSSPlayUniTmplMaterialModel;
@class HSSControlBtnModel;

NS_ASSUME_NONNULL_BEGIN

// 内推广告专用 dsp不要使用
@interface HSSImageEncCardView : HSSHotClickAreaView

- (void)setBackgroundUrl:(NSString *)url btnUrl:(NSString *)btnUrl;

- (void)startDelayTimerWithValue:(NSInteger)delayValue;

- (void)configUIWithModel:(HSSPlayUniTmplMaterialModel *)uniTmplMaterialModel
        andCountDownValue:(NSInteger)countDownValue;

- (void)configUIWithAdxModel:(HSSControlBtnModel *)controlModel
        andCountDownValue:(NSInteger)countDownValue clickArea:(NSInteger)clickArea;

@property (nonatomic, assign) BOOL isOfflineAd;

@property (nonatomic, assign) BOOL isLocalAd;

//@property (nonatomic, assign) NSInteger clickable_area_pct;

@end

NS_ASSUME_NONNULL_END
