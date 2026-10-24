//
//  HSSXMLParser.h
//  HSADXSDK
//
//  Created by admin on 2024/11/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum:NSInteger {
    HSSXMLParserOptionsProcessNamespaces           = 1 << 0,
    HSSXMLParserOptionsReportNamespacePrefixes     = 1 << 1,
    HSSXMLParserOptionsResolveExternalEntities     = 1 << 2,
}HSSXMLParserOptions;

@interface HSSXMLParser : NSObject

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string;
+ (NSDictionary *)dictionaryForXMLData:(NSData *)data options:(HSSXMLParserOptions)options;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string options:(HSSXMLParserOptions)options;

@end

NS_ASSUME_NONNULL_END
