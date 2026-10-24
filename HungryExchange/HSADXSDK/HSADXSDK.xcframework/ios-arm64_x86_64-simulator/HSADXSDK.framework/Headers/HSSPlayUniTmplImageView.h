//
//  HSSPlayUniTmplImageView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/5/12.
//

#import <HSADXSDK/HSADXSDK.h>
#import <HSADXSDK/HSSHotClickAreaView.h>

@class HSSPlayUniTmplMaterialModel;
@class HSSControlBtnModel;

NS_ASSUME_NONNULL_BEGIN

@interface HSSPlayUniTmplImageView : HSSHotClickAreaView

- (void)setBackgroundUrl:(NSString *)url;

- (void)configUIWithData:(HSSPlayUniTmplMaterialModel *)uniTmplMaterialModel
       andCountDownValue:(NSInteger)countDownValue;

- (void)configAdxUIWithData:(HSSControlBtnModel *)controlBtn
      clickableAreaPct:(NSInteger)clickableAreaPct
      andCountDownValue:(NSInteger)countDownValue;

@property (nonatomic, assign) BOOL isOfflineAd;

@property (nonatomic, assign) BOOL isLocalAd;

@end

NS_ASSUME_NONNULL_END
