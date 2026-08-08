//
//  HSSAdxUniTmplModel.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/8/14.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseModel.h"
#import <HSADXSDK/HSSAdFormat.h>

@class HSSSKOverlayAdModel;
@class HSSSKAutoStoreModel;
@class HSSOverlayModel;
@class HSSVastCreativeAdModel;
@class HSSPlayableToolTipModel;
@class HSSPlayUniTmplProgressBarModel;
@class HSSOverlayCtaModel;
@class HSSControlBtnModel;

typedef void(^HSSVastAdsBuilderParseCompletionBlock)(NSString *_Nullable vastXml, NSError *_Nullable error);

typedef void(^HSSNewVastAdsBuilderParseCompletionBlock)(NSString *_Nullable vastXml, NSString *_Nullable vastTypeStr, NSError *_Nullable error);

typedef NS_ENUM(NSInteger, HSAdxUniTmplMaterialType){
    HSAdxUniTmplMaterialType_Video = 1,
    HSAdxUniTmplMaterialType_Game = 2,
    HSAdxUniTmplMaterialType_PicTxt = 3,
    HSAdxUniTmplMaterialType_EndCard = 4,
    HSAdxUniTmplMaterialType_Image = 5,
    HSAdxUniTmplMaterialType_VAST_Image = 6
};

NS_ASSUME_NONNULL_BEGIN

@interface HSSAdxUniTmplVideoModel :HSSBaseModel

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *vast;

@end

@interface HSSAdxUniTmplPicModel :HSSBaseModel

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *btn_txt;

@end

@interface HSSAdxUniTmplPlayModel :HSSBaseModel

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *url;

@end

@interface HSSAdxUniTmplEndCardModel :HSSBaseModel
//1:icon+title+desc 2:image 3:vast
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *image;

@property (nonatomic, copy) NSString *image_btn;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *btn_txt;

@end

@interface HSSAdxUniTmplImageModel :HSSBaseModel

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *url;

@end

@interface HSSAdxUniTmplVastImageModel :HSSBaseModel

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *fallback_ec_url;

@end

@interface HSSAdxUniTmplMaterialModel :HSSBaseModel

@property (nonatomic, assign) HSAdxUniTmplMaterialType type;

@property (nonatomic, strong) HSSAdxUniTmplVideoModel *video;

@property (nonatomic, strong) HSSAdxUniTmplPicModel *img_txt;

@property (nonatomic, strong) HSSAdxUniTmplPlayModel *playable;

@property (nonatomic, strong) HSSAdxUniTmplEndCardModel *endcard;

@property (nonatomic, strong) HSSAdxUniTmplImageModel *image;

@property (nonatomic, strong) HSSAdxUniTmplVastImageModel *vast_img;

@end

//@interface HSSAdxControlBtnModel :HSSBaseModel
///// 按钮样式， NextRecord, TwoArrows, Close
//@property (nonatomic, copy) NSString *style;
///// 按钮大小
//@property (nonatomic, copy) NSString *size;
//
//@end

@interface HSSAdxUniTmplSectionModel :HSSBaseModel

// section 类型 1.首段 2.中间段 3.ec段
@property (nonatomic, assign) NSInteger type;

// 延时跳过时长，秒，仅首段section && 插屏
@property (nonatomic, assign) NSInteger skipDelay;

// 激励时长，秒，仅首段section && 激励
@property (nonatomic, assign) NSInteger rewardTime;

@property (nonatomic, assign) NSInteger closeDelay;

@property (nonatomic, strong) HSSControlBtnModel *controlBtn;

// materials
@property (nonatomic, strong) NSArray <HSSAdxUniTmplMaterialModel *>*materials;

@end

@interface HSSAdxMatTmplCfgVideoModel :HSSBaseModel

// 是否默认静音，0否 1是
@property (nonatomic, assign) NSInteger isMute;

/// 从底部开始可点区域占比; 50：从底部开始50%可以点击
@property (nonatomic, assign) NSInteger clickable_area_pct;

@property (nonatomic, strong) HSSOverlayModel *overlay;

/// 提示框
@property (nonatomic, strong) HSSPlayableToolTipModel *tooltip;

/// 进度条配置
@property (nonatomic, strong) HSSPlayUniTmplProgressBarModel *progress_bar;


@end

@interface HSSAdxMatTmplCfgImgTxtModel :HSSBaseModel

/// 从底部开始可点区域占比; 50：从底部开始50%可以点击
@property (nonatomic, assign) NSInteger clickable_area_pct;

@end

@interface HSSAdxMatTmplCfgImgModel :HSSBaseModel

/// 从底部开始可点区域占比; 50：从底部开始50%可以点击
@property (nonatomic, assign) NSInteger clickable_area_pct;

@end

@interface HSSAdxMatTmplCfgPlayableModel :HSSBaseModel

// 是否默认静音，0否 1是
@property (nonatomic, assign) NSInteger isMute;

@end

@interface HSSAdxMatTmplCfgVastImgModel :HSSBaseModel

/// 从底部开始可点区域占比; 50：从底部开始50%可以点击
@property (nonatomic, assign) NSInteger clickable_area_pct;

@end

@interface HSSAdxMatTmplCfgECModel :HSSBaseModel

/// icon是否可点击, 0：不可点击; 1：可点击
@property (nonatomic, assign) BOOL icon_clickable;

/// text是否可点击, 0：不可点击; 1：可点击
@property (nonatomic, assign) BOOL text_clickable;

@property (nonatomic, assign) BOOL sub_text_clickable;

/// 按钮样式
@property (nonatomic, copy) NSString *variant;

/// 从底部开始可点区域占比; 50：从底部开始50%可以点击
@property (nonatomic, assign) NSInteger clickable_area_pct;

/// overlay上面的按钮配置
@property (nonatomic, strong) HSSOverlayCtaModel *cta;

@end

@interface HSSAdxMatTmplCfgModel :HSSBaseModel

@property (nonatomic, strong) HSSAdxMatTmplCfgVideoModel *video;
@property (nonatomic, strong) HSSAdxMatTmplCfgImgTxtModel *img_txt;
@property (nonatomic, strong) HSSAdxMatTmplCfgImgModel *image;
@property (nonatomic, strong) HSSAdxMatTmplCfgECModel *ec;
@property (nonatomic, strong) HSSAdxMatTmplCfgVastImgModel *vastImage;
@property (nonatomic, strong) HSSAdxMatTmplCfgPlayableModel *play;

@end

@interface HSSAdxUniTmplModel :HSSBaseModel

// 是否包含试玩，0否 1是
@property (nonatomic, assign) NSInteger isPlayable;

@property (nonatomic, strong) HSSSKOverlayAdModel *skoverlay;

@property (nonatomic, strong) HSSSKAutoStoreModel *autoStore;

@property (nonatomic, strong) HSSAdxMatTmplCfgModel *mat_tmpl_cfg;

// sections
@property (nonatomic, strong) NSArray <HSSAdxUniTmplSectionModel *>*sections;

/// vast 解析结果的回调 （里面可能涉及到重定向）
@property (nonatomic, copy) HSSVastAdsBuilderParseCompletionBlock parseCompletionBlock;

/// vast 解析结果新的回调 （里面可能涉及到重定向）
@property (nonatomic, copy) HSSNewVastAdsBuilderParseCompletionBlock newParseCompletionBlock;

@property (nonatomic, assign) BOOL hasVast;

/// vast xml
@property (nonatomic, strong) HSSVastCreativeAdModel *vast;

/// 记录 vast 解析失败信息,保存原始数据, 成功该属性 nil
@property (nonatomic, copy) NSString *failureVastXml;

/// 记录 vast inlie解析失败error信息, 成功该属性 nil
@property (nonatomic, strong) NSError *error;

/// 记录 vast 解析失败的错误对象
@property (nonatomic, strong) NSError *failureVastError;

/// 以下手动添加
@property (nonatomic, copy) NSArray *vastVideoUrls;

@property (nonatomic, copy) NSString *vastXml;

/// 设置vast_type：Inline or Wrapper
@property (nonatomic, copy) NSString *vastTypeString;

/// 手动开始vast解析
- (void)beginParseVast;
@end

NS_ASSUME_NONNULL_END
