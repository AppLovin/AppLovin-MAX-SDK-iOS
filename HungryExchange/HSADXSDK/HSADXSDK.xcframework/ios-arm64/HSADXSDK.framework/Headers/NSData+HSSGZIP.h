//
//  NSData+GZIP.h
//  Example
//
//  Created by admin on 2024/12/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (HSSGZIP)


- (nullable NSData *)gzippedDataWithCompressionLevel:(float)level;
- (nullable NSData *)gzippedData;
- (nullable NSData *)gunzippedData;
- (BOOL)isGzippedData;

@end

NS_ASSUME_NONNULL_END
