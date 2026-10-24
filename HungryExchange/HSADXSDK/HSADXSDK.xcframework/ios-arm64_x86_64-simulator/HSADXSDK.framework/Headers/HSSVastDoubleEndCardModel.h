//
//  HSSVastDoubleEndCardModel.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/7/16.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseModel.h"
#import "HSSAdxUniTmplModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSVastDoubleEndCardModel : HSSBaseModel

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *btn_txt;

@property (nonatomic, assign) NSInteger interval;

@property (nonatomic, strong) HSSAdxMatTmplCfgECModel *cfgECModel;

@property (nonatomic, assign) BOOL isAdxMaterialModel;

@property (nonatomic, strong) HSSControlBtnModel *controlBtn;

@property (nonatomic, assign) CGFloat closeSize;
@property (nonatomic, assign) CGFloat closeMargin;

@end

NS_ASSUME_NONNULL_END
