//
//  HSSTmplInfo.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import "HSSBaseModel.h"

@class HSSTmplSegment;

NS_ASSUME_NONNULL_BEGIN

@interface HSSTmplInfo : HSSBaseModel

/// 模板 ID
@property (nonatomic, copy) NSString *tmplId;

/// 模板段列表
@property (nonatomic, strong) NSArray<HSSTmplSegment *> *segments;

@end

NS_ASSUME_NONNULL_END
