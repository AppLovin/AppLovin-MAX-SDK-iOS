//
//  HSSAdFormat.h
//  HSADXSDK
//
//  Created by admin on 2024/11/26.
//

#ifndef HSSAdFormat_h
#define HSSAdFormat_h

typedef enum : NSUInteger {
    HSSAdFormatTypeInter = 1,
    HSSAdFormatTypeReward = 2,
    HSSAdFormatTypeBanner320_50 = 3,
    HSSAdFormatTypeBanner300_50 = 4,
} HSSAdFormatType;

typedef enum : NSUInteger {
    HSSAdMaterialTypeImageText = 1, // 图文
    HSSAdMaterialTypeNativeVideo = 2, // 原生视频
    HSSAdMaterialTypeVast = 3, // vast
    HSSAdMaterialTypePlayable = 4, // 试玩
    HSSAdMaterialTypeHtml = 5, // html
    HSSAdMaterialTypeBanner = 6, // Banner
    HSSAdMaterialTypeUniTmpl = 7, // 试玩统一模版
    HSSAdMaterialTypeAdxUniTmpl = 8, // adx统一模版
    HSSAdMaterialTypeNativeBanner = 9, // Native Banner
    HSSAdMaterialTypeVideoBanner = 10, // Video Banner
} HSSAdMaterialType;

typedef enum :NSUInteger {
    HSSPlayableAdPromptTypeVideo = 1, // 视频
    HSSPlayableAdPromptTypeImage = 2, // 图片
    HSSPlayableAdPromptTypeGIF = 3, // GIF
} HSSPlayableAdPromptType;

typedef enum :NSUInteger {
    HSSPlayableAdCtaTypeBtn = 1, // cta-btn 预留，目前仅支持1
} HSSPlayableAdCtaType;

typedef enum :NSUInteger {
    HSSPlayableAdGameTypeH5 = 1, //1:H5，预留，目前仅支持1
} HSSPlayableAdGameType;

typedef enum :NSUInteger {
    HSSPlayableAdEndcardTypeNormal = 1, // 1:线上的Endcard样式
    HSSPlayableAdEndcardTypeImage = 2, // 2:新增大图的Endcard样式
} HSSPlayableAdEndcardType;

// 试玩模板
typedef enum :NSUInteger {
    HSSPlayableAdTmplTypeVPE = 1, // 1:视频+试玩+EndCard
    HSSPlayableAdTmplTypePE = 2, // 2:试玩+EndCard
    HSSPlayableAdTmplTypeVP = 3, // 3:视频+试玩
    HSSPlayableAdTmplTypeP = 4, // 4:试玩
} HSSPlayableAdTmplType;

typedef enum :NSUInteger {
    HSSAdBannerTypeHtml = 1, // 1:html代码片段，预留，目前仅支持1
} HSSAdBannerType;

#endif /* HSSAdFormat_h */
