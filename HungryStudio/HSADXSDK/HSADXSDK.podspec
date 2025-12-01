Pod::Spec.new do |spec|

  spec.name         = "HSADXSDK"
  spec.version      = "1.0.57"
  spec.summary      = "HSADXSDK Binary Distribution - Ad SDK with OMSDK integration"

  spec.description  = <<-DESC
                    HSADXSDK Binary Distribution
                    - Pre-compiled XCFramework with OMSDK included
                    - Supports Rewarded, Interstitial, and Banner ads
                    - Optimized for fast integration and reduced build time
                    - Dependencies managed separately via CocoaPods
                   DESC

  # 项目主页 - 可以改成你们的官网或产品页面
  spec.homepage     = "https://www.hungrystudio.com"

  spec.license      = {
    :type => 'Proprietary',
    :text => <<-LICENSE
      Copyright (c) HungryStudio. All rights reserved.
      
      This software is proprietary and confidential.
      For licensing inquiries: qinhongwei@hungrystudio.com
    LICENSE
  }

  spec.platform      = :ios, '11.0'
  spec.author        = { "HungryStudio" => "qinhongwei@hungrystudio.com" }
  
  # 二进制分发配置
  # 使用方式: 本地路径集成
  # pod 'HSADXSDK', :podspec => './HSADXSDK-Binary/HSADXSDK-Binary.podspec'
  
  # 注意：二进制版本通过本地 podspec 方式集成，不需要 Git 仓库
  # 使用本地路径，不需要下载
  spec.source = { :path => '.' }
  
  spec.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'AdSupport', 'StoreKit', 'CoreTelephony', 'SystemConfiguration'
  spec.requires_arc  = true
  spec.static_framework = true
  
  # 二进制 XCFramework（已包含OMSDK）
  spec.vendored_frameworks = 'HSADXSDK.xcframework'
  
  # 资源文件
  spec.resources = 'HSADX.bundle'
  
  # 系统库依赖
  spec.libraries = 'xml2', 'z', 'c++'
  
  spec.xcconfig = {
    'HEADER_SEARCH_PATHS'   => '$(SDKROOT)/usr/include/libxml2',
    'OTHER_LDFLAGS'         => '-ObjC',
  }
  
  # 第三方依赖（需要使用方通过CocoaPods安装）
  spec.dependency  'lottie-ios'
  spec.dependency  'MMKV'
  spec.dependency  'YYModel'
  spec.dependency  'SDWebImage'
  
  spec.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_CONFIGURATION_BUILD_DIR}/lottie-ios/Swift Compatibility Header"',
  }

end

