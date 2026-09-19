//
//  HSSImageTextView.h
//  HSADXSDK
//
//  Created by admin on 2024/12/10.
//

#import "HSSBaseView.h"
#import <HSADXSDK/HSSHotClickAreaView.h>

@class HSSItemImageModel;

NS_ASSUME_NONNULL_BEGIN

@interface HSSImageTextView : HSSHotClickAreaView<HSSViewImageTextProtocol>

@property (nonatomic, strong) HSSItemImageModel *imageModel;

@property (nonatomic, strong) HSSCreativeExtModel *extra;
@end

NS_ASSUME_NONNULL_END
