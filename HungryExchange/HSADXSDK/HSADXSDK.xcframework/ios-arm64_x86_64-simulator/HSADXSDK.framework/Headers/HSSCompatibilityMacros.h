// HSSCompatibilityMacros.h
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#ifndef HSSCompatibilityMacros_h
#define HSSCompatibilityMacros_h

#ifdef API_AVAILABLE
    #define HSS_API_AVAILABLE(...) API_AVAILABLE(__VA_ARGS__)
#else
    #define HSS_API_AVAILABLE(...)
#endif // API_AVAILABLE

#ifdef API_UNAVAILABLE
    #define HSS_API_UNAVAILABLE(...) API_UNAVAILABLE(__VA_ARGS__)
#else
    #define HSS_API_UNAVAILABLE(...)
#endif // API_UNAVAILABLE

#if __has_warning("-Wunguarded-availability-new")
    #define HSS_CAN_USE_AT_AVAILABLE 1
#else
    #define HSS_CAN_USE_AT_AVAILABLE 0
#endif

#if ((__IPHONE_OS_VERSION_MAX_ALLOWED && __IPHONE_OS_VERSION_MAX_ALLOWED < 100000) || (__MAC_OS_VERSION_MAX_ALLOWED && __MAC_OS_VERSION_MAX_ALLOWED < 101200) ||(__WATCH_OS_MAX_VERSION_ALLOWED && __WATCH_OS_MAX_VERSION_ALLOWED < 30000) ||(__TV_OS_MAX_VERSION_ALLOWED && __TV_OS_MAX_VERSION_ALLOWED < 100000))
    #define HSS_CAN_INCLUDE_SESSION_TASK_METRICS 0
#else
    #define HSS_CAN_INCLUDE_SESSION_TASK_METRICS 1
#endif

#endif /* HSSCompatibilityMacros_h */
