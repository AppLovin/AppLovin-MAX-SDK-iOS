Pod::Spec.new do |s|

s.authors =
{
	'AppLovin Corporation' => 'devsupport@applovin.com'
}
s.name = 'AppLovinMediationSmaatoAdapter'
s.version = '21.7.0.0'
s.platform = :ios, '9.0'
s.summary = 'Smaato adapter used for mediation with the AppLovin MAX SDK'
s.homepage = 'https://github.com/CocoaPods/Specs/search?o=desc&q=AppLovinMediationSmaatoAdapter&s=indexed'
s.license = 
{ 
  :type => 'Commercial License',
  :text => <<-LICENSE

Copyright 2022 AppLovin Corp. All rights reserved.

The AppLovin MAX SDK is available under a commercial license (https://www.applovin.com/eula).

LICENSE
}

s.source = 
{
  :http => 'https://artifacts.applovin.com/ios/com/applovin/mediation/smaato-adapter/AppLovinMediationSmaatoAdapter-21.7.0.0.zip',
  :type => 'zip'
}

s.vendored_frameworks = 'AppLovinMediationSmaatoAdapter-21.7.0.0/AppLovinMediationSmaatoAdapter.framework'

s.dependency 'smaato-ios-sdk', '= 21.7.0'
s.dependency 'smaato-ios-sdk/InApp', '= 21.7.0'
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
