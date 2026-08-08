//
//  HSSVastImageECModel.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/6/20.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSVastImageECModel : HSSBaseModel

@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, copy)  NSString *iconUrl;
@property (nonatomic, assign) NSInteger interval;
@property (nonatomic, assign) BOOL hasDoubleEC;
@property (nonatomic, assign) NSInteger clickable_area_pct;
@property (nonatomic, assign) BOOL isAdxModel;
@property (nonatomic, assign) BOOL isDemotion;
@property (nonatomic, assign) BOOL isHtml;

@property (nonatomic, assign) CGFloat skipSize;
@property (nonatomic, assign) CGFloat closeSize;
@property (nonatomic, assign) CGFloat skipMargin;
@property (nonatomic, assign) CGFloat closeMargin;

@end

NS_ASSUME_NONNULL_END
