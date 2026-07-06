//
//  HSSHotClickAreaView.h
//  HSADXSDK
//
//  Created by admin on 2025/6/25.
//

#import <UIKit/UIKit.h>
#import "HSSBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSHotClickAreaView : HSSBaseView
/// 是否开启可点热区
@property (nonatomic, assign) NSInteger clickable_area_pct;
/// 默认是跳转到广告详情， 此处可以自定义
@property (nonatomic, copy) dispatch_block_t actionBlock;
@end

NS_ASSUME_NONNULL_END
