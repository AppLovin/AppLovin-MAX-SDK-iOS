//
//  HSSGradientView.h
//  HSADXSDK
//
//  Created by admin on 2024/12/19.
//

#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSAdComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/// 底部渐变遮罩视图（透明 → 半透明黑）。
///
/// 1.0 路径：HSSInterstitialVC / HSSImageTextView 直接 alloc + addSubview，frame 调用方手动控制
///
/// 2.0 路径：实现 HSSAdComponentProtocol，由 SegmentVC 通过
///   `mountComponentWithKey:@"bottom_gradient_style_key"` 挂载，frame 由 frameInContainer: 自算。
///   - key 全局唯一：bottom_gradient_style_key
///   - OMID purpose 自声明：NotVisible（不可见装饰）
@interface HSSGradientView : UIView <HSSAdComponentProtocol>

@end

NS_ASSUME_NONNULL_END
