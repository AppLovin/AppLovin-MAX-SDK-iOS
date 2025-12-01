Pod::Spec.new do |s|

s.authors = 'AppLovin Corporation'
s.name = 'AppLovinMediationHungryStudioAdapter'
s.version = '1.0.0.0'
s.platform = :ios, '13.0'
s.summary = 'HungryStudio adapter used for mediation with the AppLovin MAX SDK'
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
  	:http => "https://artifacts.applovin.com/ios/com/applovin/mediation/hungrystudio-adapter/#{s.name}-#{s.version}.zip",
  	:type => 'zip'
}

s.vendored_frameworks = "#{s.name}-#{s.version}/#{s.name}.xcframework"

s.dependency 'AppLovinSDK', '>= 13.0.0'

s.dependency 'lottie-ios'
s.dependency 'MMKV'
s.dependency 'YYModel'
s.dependency 'SDWebImage'

s.description = <<-DESC

IMPORTANT: This adapter requires HSADXSDK to be manually integrated.

The adapter requires the following dependencies (automatically installed):
- lottie-ios (for animations)
- MMKV (for storage)
- YYModel (for data modeling)
- SDWebImage (for image loading)

AppLovin makes technologies that help businesses of every size connect to their ideal customers. The company provides end-to-end software and AI solutions for businesses to reach, monetize, and grow their global audiences. For more information about AppLovin, visit: www.applovin.com.

DESC

end

