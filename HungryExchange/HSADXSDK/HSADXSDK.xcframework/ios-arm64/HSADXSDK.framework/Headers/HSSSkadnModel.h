//
//  HSSSkadnModel.h
//  HSADXSDK
//
//  Created by biyingquan on 2024/12/12.
//

#import "HSSBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@class HSSFidelityModel;
@class HSSSkoverlayModel;

/// 对于通过skadn校验的请求，下发skadn物料
@interface HSSSkadnModel : HSSBaseModel

/// 服务端选择的skadn版本，该版本影响signature字段签名的生成和bid.ext.skadn 对象下发的参数
@property (nonatomic, copy) NSString *version;

/// 符合苹果SkAdNetwork规范的Campaign ID，skan 3.0及以下会使用该字段下发
@property (nonatomic, copy) NSString *campaign;

/// Skan 4.0及以上会使用sourceidentifier替代campaign广告服务商定义的四位整数，用于表示广告系列。
/// sourceidentifier可以是1到9999之间的整数。
@property (nonatomic, copy) NSString *sourceIdentifier;

/// 广告App的苹果应用商店ID
@property (nonatomic, copy) NSString *itunesItem;

/// Skadn请求里的媒体应用苹果应用商店ID
@property (nonatomic, copy) NSString *sourceApp;

/// Pangle的SkAdNetwork ID 22mmun2rn5.skadnetwork
@property (nonatomic, copy) NSString *network;

/// inmobi：productpageid
@property (nonatomic, copy) NSString *productPageid;

/// 每个skadn返回体都不同的随机字符串。Skadn 2.2版本迁移至fidelities
@property (nonatomic, copy) NSString *nonce;

/// 用于签名的时间戳，单位为毫秒。Skadn 2.2版本迁移至fidelities
@property (nonatomic, copy) NSString *timeStamp;

/// 符合苹果SkAdNetwork规范的签名。Skadn 2.2版本迁移至fidelities
@property (nonatomic, copy) NSString *signature;

/// Skadn 2.2版本启用的分展示归因、点击归因的签名字段。
/// 对于skadn 2.2请求，服务端会同时下发两个fidelity Signature，分别承载展示归因和点击归因的签名
@property (nonatomic, copy) NSArray<HSSFidelityModel *> *fidelities;

@property (nonatomic, strong) HSSSkoverlayModel *skOverlay;

@end

NS_ASSUME_NONNULL_END
