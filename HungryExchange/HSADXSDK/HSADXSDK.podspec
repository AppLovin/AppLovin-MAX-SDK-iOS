Pod::Spec.new do |spec|
  spec.name         = "HSADXSDK"
  spec.version      = "1.0.61"
  spec.summary      = "HSADXSDK Binary Distribution - Ad SDK with OMSDK integration"
  
  spec.description  = <<-DESC
                      HSADXSDK Binary Distribution
                      - Pre-compiled XCFramework with OMSDK included
                      - Supports Rewarded, Interstitial, and Banner ads
                      - Optimized for fast integration and reduced build time
                      - Dependencies managed separately via CocoaPods
                     DESC
  
  spec.homepage     = "https://www.hungrystudio.com"
  
  spec.license      = {
    :type => 'Proprietary',
    :text => <<-LICENSE
      Copyright (c) HungryStudio. All rights reserved.
      
      This software is proprietary and confidential.
      For licensing inquiries: zhangsong@hungrystudio.com
    LICENSE
  }
  
  spec.platform      = :ios, '13.0'
  spec.author        = { "HungryStudio" => "zhangsong@hungrystudio.com" }
  
  # 本地路径集成
  spec.source = { :path => '.' }
  
  # 必需的系统框架
  spec.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'AdSupport', 'StoreKit', 'CoreTelephony', 'SystemConfiguration'
  
  spec.requires_arc  = true
  spec.static_framework = true
  
  # 预编译的 XCFramework（包含 OMSDK）
  spec.vendored_frameworks = 'HSADXSDK.xcframework'
  
  # 资源文件（与 XCFramework 分离）
  spec.resources = 'HSADX.bundle'
  
  # 系统库
  spec.libraries = 'xml2', 'z', 'c++'
  
  # 编译配置
  spec.xcconfig = {
    'HEADER_SEARCH_PATHS'   => '$(SDKROOT)/usr/include/libxml2',
    'OTHER_LDFLAGS'         => '-ObjC',
  }
  
  # 第三方依赖（需要单独安装）
  spec.dependency  'lottie-ios'
  spec.dependency  'MMKV'
  spec.dependency  'YYModel'
  spec.dependency  'SDWebImage'
  
  # Pod target 特定配置
  spec.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_CONFIGURATION_BUILD_DIR}/lottie-ios/Swift Compatibility Header"',
  }
end

