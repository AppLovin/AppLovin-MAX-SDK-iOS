//
//  HSSBottomDesView.h
//  HSADXSDK
//
//  Created by admin on 2024/12/7.
//

#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/// 底部"AD" + 描述文案条（合规广告标识）。
///
/// 1.0 路径：HSSInterstitialVC 直接 alloc + addSubview 到 VC.view，跨段持续显示
/// 2.0 路径（模板 2.0）：实现 HSSAdComponentProtocol，按服务端下发的 ad_area.key 挂载，pos 决定位置
///   服务端约定 key："ad_label_style_key"
@interface HSSBottomDesView : HSSBaseView <HSSAdComponentProtocol>

/// 描述文案（1.0 通过 setter 直设；2.0 在 configureWithControlInfo:context: 中从 itemModel.ext.ext_info 自动注入）
@property (nonatomic, copy) NSString *des;

@end

NS_ASSUME_NONNULL_END
