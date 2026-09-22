//
//  HSSBlsMessageHandler.h
//  HSADXSDK
//
//  Created by biyingquan on 2026/3/5.
//
//
//  BLS 问卷消息事件统一处理
//

#import <Foundation/Foundation.h>

@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN

/// BLS 消息处理所需上下文（插屏/激励视频 Ad 实现此协议）
@protocol HSSBlsMessageContext <NSObject>
- (NSDictionary *)adsRelatedStat:(HSSCreativeItemModel *)creativeModel;
- (NSInteger)blsInterVcTotalValue;
- (NSInteger)blsSelfTotalValue;
- (void)setBlsSelfTotalValue:(NSInteger)value;
- (void)blsSkipActionFromWebView;
@end

@interface HSSBlsMessageHandler : NSObject

/// 统一处理 BLS message 事件
+ (void)handleMessageEvent:(NSDictionary *)payload
            creativeModel:(HSSCreativeItemModel *)creativeModel
                 context:(id<HSSBlsMessageContext>)context;

@end

NS_ASSUME_NONNULL_END
