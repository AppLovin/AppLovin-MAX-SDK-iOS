//
//  HSSSegmentVCFactory.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import "HSSSegmentVCContext.h"

@class HSSTmplSegment;
@class HSSSegmentVC;

NS_ASSUME_NONNULL_BEGIN

/// 段 VC 工厂：按 HSSTmplSegment 子类类型创建对应的 HSSSegmentVC 子类。
///
/// 使用方：HSSModularAdVC 在 routerRequestsTransitionToSegmentAtIndex: 中调用。
///
/// 扩展方式：未来加新段类型（如 HSSSurveySegment）只需：
///   1. 新建 HSSSurveySegmentVC : HSSSegmentVC
///   2. 在本工厂加一条 isKindOfClass 分支
///   其他模块无需改动。
@interface HSSSegmentVCFactory : NSObject

/// 为给定段数据创建对应的 SegmentVC 实例
/// @param segment 段模板数据（HSSVideoSegment / HSSPlayableSegment / HSSEndCardSegment 等）
/// @param index   段索引（tmplInfo.segments 中的位置）
/// @param context 段 VC 服务门面
/// @return 对应子类 VC 实例；未知段类型返回 nil（调用方应做兜底处理）
+ (nullable HSSSegmentVC *)vcForSegment:(HSSTmplSegment *)segment
                                 atIndex:(NSInteger)index
                                 context:(id<HSSSegmentVCContext>)context;

@end

NS_ASSUME_NONNULL_END
