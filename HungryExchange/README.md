# HungryExchange Adapter - Build Instructions

## Overview

HungryExchange Adapter for AppLovin MAX SDK mediation.

**Supported Ad Formats:**
- Interstitial
- Rewarded Video  
- Banner (320x50, 728x90, 300x250)

**Version:** 1.0.0.0  
**Certified with:** HSADXSDK 1.0.57  
**Minimum iOS:** 13.0

## Important Notes

### HSADXSDK Binary Inclusion

The `HSADXSDK/` directory contains the pre-compiled SDK binary required for building this adapter:

```
HSADXSDK/
├── HSADXSDK.xcframework     # Framework binary
├── HSADX.bundle             # Resource bundle
└── HSADXSDK.podspec         # Local podspec
```

**Why included in repository?**
- HSADXSDK is **not publicly available** (private SDK)
- Required for compilation to resolve headers and symbols
- Provided by HungryExchange specifically for MAX integration

**Important:** The final adapter framework will **NOT include** HSADXSDK implementation - only symbol references.

## Build Instructions

### Step 1: Install Dependencies

```bash
cd HungryExchange/
pod install
```

This will:
- Install HSADXSDK from local path (`./HSADXSDK`)
- Install AppLovinSDK from CocoaPods
- Install dependencies: lottie-ios, MMKV, YYModel, SDWebImage
- Generate `HungryExchangeAdapter.xcworkspace`

### Step 2: Build the Adapter

#### Using Xcode:

1. Open `HungryExchangeAdapter.xcworkspace` (not .xcodeproj)
2. Select scheme: `HungryExchangeAdapter`
3. Select target: `Any iOS Device`
4. Build: `Cmd + B`

#### Using Command Line:

```bash
xcodebuild -workspace HungryExchangeAdapter.xcworkspace \
           -scheme HungryExchangeAdapter \
           -configuration Release \
           -sdk iphoneos \
           build
```

### Step 3: Create XCFramework

```bash
# Clean previous builds
rm -rf build/

# Archive for device (arm64)
xcodebuild archive \
  -workspace HungryExchangeAdapter.xcworkspace \
  -scheme HungryExchangeAdapter \
  -archivePath ./build/ios.xcarchive \
  -sdk iphoneos \
  -configuration Release \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Archive for simulator (arm64 + x86_64)
xcodebuild archive \
  -workspace HungryExchangeAdapter.xcworkspace \
  -scheme HungryExchangeAdapter \
  -archivePath ./build/ios-simulator.xcarchive \
  -sdk iphonesimulator \
  -configuration Release \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create XCFramework
xcodebuild -create-xcframework \
  -framework ./build/ios.xcarchive/Products/Library/Frameworks/AppLovinMediationHungryExchangeAdapter.framework \
  -framework ./build/ios-simulator.xcarchive/Products/Library/Frameworks/AppLovinMediationHungryExchangeAdapter.framework \
  -output ./AppLovinMediationHungryExchangeAdapter.xcframework
```

## Verification (Critical!)

### Verify HSADXSDK is NOT Bundled

**This is the most important verification step.**

```bash
# Set framework path
FRAMEWORK="Build/Products/Release-iphoneos/AppLovinMediationHungryExchangeAdapter.framework/AppLovinMediationHungryExchangeAdapter"

# Check symbols - all HSADXSDK symbols should be "U" (undefined)
nm -g "$FRAMEWORK" | grep "HSS"
```

**Expected Output (Correct):**
```
                 U _OBJC_CLASS_$_HSSADXBannerView
                 U _OBJC_CLASS_$_HSSInterstitialAd
                 U _OBJC_CLASS_$_HSSMaxBiddingManager
                 U _OBJC_CLASS_$_HSSRewardedAd
                 U _OBJC_CLASS_$_HSSdk
                 U _OBJC_CLASS_$_HSSdkInitialConfiguration
```

- ✅ **"U" (Undefined)** = Symbols are references only, implementation NOT included
- ❌ **"T" or "S" with address** = Implementation included (incorrect)

**Check Framework Size:**

```bash
ls -lh "$FRAMEWORK"
# Expected: ~130KB (if much larger, HSADXSDK may be bundled)
```

**Check Dependencies:**

```bash
otool -L "$FRAMEWORK"
# Should show: @rpath/HSADXSDK.framework/HSADXSDK
```

## Why This Architecture?

### Compilation Flow:

```
1. Podfile references HSADXSDK (:path => './HSADXSDK')
   └─> Compiler can find HSADXSDK headers and symbols
   
2. Adapter code compiles successfully
   └─> References HSADXSDK classes (but doesn't embed them)
   
3. Final framework contains only symbol references
   └─> HSADXSDK implementation is NOT bundled
```

### End User Integration:

```
User's App
├── HSADXSDK.framework (manually added by user)
└── AppLovinMediationHungryExchangeAdapter.framework (via CocoaPods)
    └─> Links to user's HSADXSDK at runtime
```

**Result:** No symbol conflicts - both use the same HSADXSDK instance.

## Podspec Configuration

The published podspec (`AppLovinMediationHungryExchangeAdapter.podspec`) does NOT include HSADXSDK dependency:

```ruby
# AppLovinMediationHungryExchangeAdapter.podspec
s.dependency 'AppLovinSDK', '>= 13.0.0'
s.dependency 'lottie-ios'
s.dependency 'MMKV'
s.dependency 'YYModel'
s.dependency 'SDWebImage'

# Note: HSADXSDK is NOT listed - users must manually integrate it
```

This ensures:
- Users manage their own HSADXSDK version
- No automatic download attempt (HSADXSDK is not public)
- No symbol conflicts with existing HSADXSDK in user's app

## Troubleshooting

### Build Error: "HSADXSDK/HSADXSDK.h file not found"

**Solution:** Ensure `HSADXSDK/` directory exists and contains:
- `HSADXSDK.xcframework/`
- `HSADXSDK.podspec`

### Build Error: "SDK does not contain 'libarclite'"

**Solution:** Update Podfile with post_install script to set minimum deployment target:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 13.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
```

Then run `pod install` again.

### Verification Failed: Found "T" symbols for HSADXSDK

**This means HSADXSDK was statically linked (incorrect).**

**Solution:**
- Ensure `use_frameworks!` is set in Podfile (dynamic frameworks)
- Verify HSADXSDK.podspec has correct configuration
- Check that adapter's podspec does NOT include `s.dependency 'HSADXSDK'`

## End User Requirements

**Note for MAX Documentation:**

End users who integrate this adapter must:
1. Install adapter via CocoaPods: `pod 'AppLovinMediationHungryExchangeAdapter'`
2. Manually integrate HSADXSDK.xcframework into their Xcode project
3. Contact HungryExchange for HSADXSDK access (not publicly available)

Without manual HSADXSDK integration, the adapter will fail at runtime with missing symbol errors.

## Contact

**HungryExchange:**  
Email: zhangsong@hungrystudio.com

**For MAX Team Internal Use Only**

