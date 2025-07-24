Pod::Spec.new do |s|

s.authors = 'AppLovin Corporation'
s.name = 'AppLovinMediationYandexAdapter'
s.version = '7.15.0.0'
s.platform = :ios, '13.0'
s.summary = 'Yandex adapter used for mediation with the AppLovin MAX SDK'
s.homepage = "https://github.com/CocoaPods/Specs/search?o=desc&q=#{s.name}&s=indexed"
s.license = 
{ 
  :type => 'Commercial License',
  :text => <<-LICENSE

Copyright 2025 AppLovin Corp. All rights reserved.

The AppLovin MAX SDK is available under a commercial license (https://www.applovin.com/eula).

LICENSE
}

s.source = 
{ 
  :http => "https://artifacts.applovin.com/ios/com/applovin/mediation/yandex-adapter/#{s.name}-#{s.version}.zip",
  :type => 'zip',
}

s.vendored_frameworks = "#{s.name}-#{s.version}/#{s.name}.xcframework"

s.dependency 'YandexMobileAds', '= {ADAPTER_SDK_VERSION}'
s.dependency 'AppLovinSDK', '>= 11.4.0'
s.swift_version = '5.9.0'

s.description = <<-DESC

AppLovin makes technologies that help businesses of every size connect to their ideal customers. The company provides end-to-end software and AI solutions for businesses to reach, monetize, and grow their global audiences. For more information about AppLovin, visit: www.applovin.com.

DESC

end
