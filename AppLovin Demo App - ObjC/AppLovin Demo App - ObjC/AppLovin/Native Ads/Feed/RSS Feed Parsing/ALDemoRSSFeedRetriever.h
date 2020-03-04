//
//  ALDemoRSSFeedRetriever.h
//  iOS-SDK-Demo
//
//  Created by Thomas So on 11/12/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALDemoArticle.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALDemoRSSFeedRetriever : NSObject

typedef void(^ALDemoRSSFeedRetrieverBlock)(NSError *__nullable error, NSArray<ALDemoArticle *> *articles);

+ (ALDemoRSSFeedRetriever *)sharedRetriever;
- (void)startParsingWithCompletion:(ALDemoRSSFeedRetrieverBlock)completion;

@end

NS_ASSUME_NONNULL_END
