//
//  HSSAsync.h
//  HSADXSDK
//
//  Created by admin on 2024/11/22.
//

#ifndef HSSAsync_h
#define HSSAsync_h

#include <CoreFoundation/CoreFoundation.h>
#ifdef __cplusplus
extern "C" {
#endif

CF_EXPORT void goAsync(dispatch_block_t block);

CF_EXPORT void runMain(dispatch_block_t block);

#ifdef __cplusplus
}
#endif
#endif /* HSSAsync_h */
