Pod::Spec.new do |s|

s.authors =
{
	'AppLovin Corporation' => 'devsupport@applovin.com'
}
s.name = 'AppLovinMediationMaioAdapter'
s.version = '1.5.8.0'
s.platform = :ios, '9.0'
s.summary = 'Maio adapter used for mediation with the AppLovin MAX SDK'
s.homepage = 'https://github.com/CocoaPods/Specs/search?o=desc&q=AppLovinMediationMaioAdapter&s=indexed'
s.license = 
{
  :type => 'Commercial License',
  :text => <<-LICENSE

Copyright 2022 AppLovin Corp. All rights reserved.

The AppLovin MAX SDK is available under a commercial license (https://www.applovin.com/eula).
 s
LICENSE
}

s.source = 
{ 
  	:http => 'https://artifacts.applovin.com/ios/com/applovin/mediation/maio-adapter/AppLovinMediationMaioAdapter-1.5.8.0.zip',
  	:type => 'zip'
}

s.vendored_frameworks = 'AppLovinMediationMaioAdapter-1.5.8.0/AppLovinMediationMaioAdapter.framework'

s.dependency 'MaioSDK', '= 1.5.8'
s.dependency 'AppLovinSDK'

s.pod_target_xcconfig =
{
  'VALID_ARCHS' => 'arm64 arm64e armv7 armv7s x86_64',
  'VALID_ARCHS[sdk=iphoneos*]' => 'arm64 arm64e armv7 armv7s',
  'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
}

s.description = <<-DESC

AppLovin turns mobile into the medium of choice for advertisers.

OUR MISSION

Enable advertisers to make ROI-based marketing decisions and deliver relevant content on mobile.

Our marketing platform reaches new users and matches them with relevant brands - ensuring you reach the users that are likely to engage.

We deliver relevant content to over a billion mobile consumers every month. With AppLovin, advertisers attain their mobile marketing goals.

DESC

end
