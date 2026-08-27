//
//  HSSContentModel.h
//  HSADXSDK
//
//  Created by admin on 2024/12/11.
//

#import "HSSBaseModel.h"
#import "HSSPlayUniTmplModel.h"
#import "HSSAdxUniTmplModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSContentModel : HSSBaseModel

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *msg;

@property (nonatomic, copy) NSString *extra;

@property (nonatomic, copy) NSString *url;

#pragma mark - PageView source 自描述（与上方数据字段一一对应）
/// 取值严格对齐服务端契约（adx_sdk_page_view 协议）：
///   - urlSource (icon)        : 0=不存在 / 1=native_icon / 2=vast_icon
///   - titleSource             : 0=不存在 / 1=服务器下发 / 2=vast
///   - msgSource (des)         : 0=不存在 / 1=服务器下发 / 2=vast
///   - extraSource (cta_text)  : 1=ext服务端下发 / 2=vast / 3=default(view_more)
/// 由数据装配方（如 HSSADXFallbackEndcardView.hss_buildContentModelFromContext / 1.0 各 setModel:）
/// 在组装 url/title/msg/extra 时同步填好；2.0 路径下 pageViewElements 直接读，不再做来源判断。
/// 1.0 视图（如 HSSEndCardView）不读这些字段（继续用 isAdxVastImg 等老逻辑），行为零变化。
@property (nonatomic, assign) NSInteger urlSource;
@property (nonatomic, assign) NSInteger titleSource;
@property (nonatomic, assign) NSInteger msgSource;
@property (nonatomic, assign) NSInteger extraSource;

@property (nonatomic, assign) NSInteger interval;

@property (nonatomic, strong) HSSPlayUniTmplMaterialModel *uniTmplMaterialModel;

@property (nonatomic, strong) HSSAdxUniTmplMaterialModel *adxUniTmplMaterialModel;

@property (nonatomic, strong) HSSControlBtnModel *controlBtn;

@property (nonatomic, strong) HSSAdxMatTmplCfgECModel *cfgECModel;

@property (nonatomic, strong) HSSAdxMatTmplCfgVastImgModel *vastImage;

@property (nonatomic, assign) BOOL isAdxVastImg;

@property (nonatomic, assign) BOOL hasDoubleEC;

@property (nonatomic, assign) BOOL isOfflineAd;

@property (nonatomic, assign) BOOL isAdxMaterialModel;

@property (nonatomic, assign) NSInteger section;

@property (nonatomic, assign) CGFloat skipSize;
@property (nonatomic, assign) CGFloat closeSize;
@property (nonatomic, assign) CGFloat skipMargin;
@property (nonatomic, assign) CGFloat closeMargin;

@property (nonatomic, assign) NSInteger cta_ec_style;
@property (nonatomic, strong) UIImage *videoFrameImage;

@property (nonatomic, copy) NSString *ec_cta_lottie;

@end

NS_ASSUME_NONNULL_END
