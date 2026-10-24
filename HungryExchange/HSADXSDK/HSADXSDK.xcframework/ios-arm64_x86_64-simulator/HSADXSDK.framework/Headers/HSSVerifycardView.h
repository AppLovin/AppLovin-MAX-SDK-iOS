//
//  HSSVerifycardView.h
//  HSADXSDK
//  Created by biyingquan on 2026/4/9.
//

#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/// 右侧固定图资源：`hss_cta_verifycard_g` / `hss_cta_verifycard_b`。
typedef NS_ENUM(NSInteger, HSSVerifycardCTAIconVariant) {
    /// 默认，`hss_cta_verifycard_g`
    HSSVerifycardCTAIconVariantG = 0,
    /// `hss_cta_verifycard_b`
    HSSVerifycardCTAIconVariantB = 1,
};

/// 圆角核验卡：200pt 宽，有描述时三行区（每行 40 + 2pt 分隔线），无描述时两行总高 80；模板 2.0 实现 `HSSAdComponentProtocol`（`video_cta_lottie_verifycard_g` / `video_cta_lottie_verifycard_b`）
@interface HSSVerifycardView : HSSBaseView <HSSAdComponentProtocol>

/// 点击时回传给 `actionMore:params:` 的附加参数，可选。
@property (nonatomic, nullable) id actionParams;
/// 右侧固定图样式，默认 `HSSVerifycardCTAIconVariantG`。
@property (nonatomic, assign) HSSVerifycardCTAIconVariant ctaIconVariant;

/// 配置展示内容：`description` 为空或长度为 0 时自动切换为两行紧凑布局（高 80）。
- (void)configureWithIconURL:(nullable NSString *)iconURLString
                    domain:(NSString *)domain
               description:(NSString *)description
               buttonTitle:(NSString *)buttonTitle;

/// 将卡添加到全屏父视图；初始在屏幕右侧外，1.5s 内自右向左滑入并停在右下角（留 safeArea 与 16pt 边距）；`UIButton` 盖在卡上，点击走 delegate。
- (void)show:(UIView *)parentView;

@end

NS_ASSUME_NONNULL_END
