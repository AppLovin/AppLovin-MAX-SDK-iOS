Pod::Spec.new do |s|

s.authors = 'AppLovin Corporation'
s.name = 'AppLovinMediationHungryExchangeAdapter'
s.version = '1.0.0.0'
s.platform = :ios, '13.0'
s.summary = 'HungryExchange adapter used for mediation with the AppLovin MAX SDK'
s.homepage = "https://github.com/CocoaPods/Specs/search?o=desc&q=#{s.name}&s=indexed"
s.license = 
{ 
  :type => 'Commercial License',
  :text => <<-LICENSE

Copyright 2025 AppLovin Corp. All rights reserved.

The AppLovin MAX SDK is available under a commercial license (https://www.applovin.com/eula).

LICENSE
}

# 本地源码集成（Adapter 源码与 podspec 同目录的 HungryExchangeAdapter/ 下）
s.source       = { :path => '.' }
s.source_files = 'HungryExchangeAdapter/*.{h,m}'

# HSADXSDK 是 static_framework，本 pod 必须同样声明为 static_framework
s.static_framework = true

s.dependency 'AppLovinSDK', '>= 13.0.0'
s.dependency 'HSADXSDK'

s.description = <<-DESC

AppLovin makes technologies that help businesses of every size connect to their ideal customers. The company provides end-to-end software and AI solutions for businesses to reach, monetize, and grow their global audiences. For more information about AppLovin, visit: www.applovin.com.

DESC

end
