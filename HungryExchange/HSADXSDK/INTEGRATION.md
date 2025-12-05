# HSADXSDK 二进制集成指南

## 📦 产物说明

本二进制分发包包含以下内容：

```
HSADXSDK-Binary/
├── HSADXSDK.xcframework          # 预编译的二进制Framework（已包含OMSDK）
├── HSADX.bundle                  # 资源文件
└── VERSION.txt                   # 版本信息
```

### ✨ 特性

- ✅ **已包含 OMSDK**：无需单独集成 OMSDK 静态库
- ✅ **支持真机和模拟器**：arm64（真机）+ arm64/x86_64（模拟器）
- ✅ **依赖分离**：第三方依赖通过 CocoaPods 管理，避免符号冲突
- ✅ **快速编译**：使用预编译二进制，大幅减少项目编译时间

---

## 🚀 快速集成（推荐）

### 方式一：CocoaPods 本地集成

> ⚠️ **重要提示**
> 
> **正确做法**：
> - ✅ 将 `HSADXSDK-Binary` 文件夹放置在项目目录下（文件系统层面）
> - ✅ 在 `Podfile` 中引用该路径
> - ✅ 执行 `pod install`，让 CocoaPods 自动管理
> 
> **常见错误**：
> - ❌ **切勿将 `HSADX.bundle` 拖入 Xcode 项目导航器**
> - ❌ **切勿将 `HSADXSDK-Binary` 文件夹拖入 Xcode 项目导航器**
> - ❌ **切勿手动添加 bundle 到 Build Phases → Copy Bundle Resources**
> 
> 💡 **原因**：手动添加会导致 `Multiple commands produce` 编译错误，因为 CocoaPods 已经通过 podspec 自动管理资源文件。

#### Step 1: 放置二进制文件

将整个 `HSADXSDK-Binary` 目录复制到你的项目根目录（**仅在文件系统中，不要拖入 Xcode**）：

```bash
YourProject/
├── HSADXSDK-Binary/
│   ├── HSADXSDK.xcframework
│   ├── HSADX.bundle
│   └── VERSION.txt
├── YourApp/
├── Podfile
└── ...
```

#### Step 2: 配置 Podfile

在项目的 `Podfile` 中添加：

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  # HSADXSDK 二进制版本（本地路径）
  pod 'HSADXSDK', :path => './HSADXSDK-Binary'
  
  # HSADXSDK 的依赖（必须）
  pod 'lottie-ios', :git => 'https://github.com/airbnb/lottie-ios'
  pod 'MMKV'
  pod 'YYModel', :git => 'https://github.com/ibireme/YYModel.git'
  pod 'SDWebImage'
end
```

#### Step 3: 安装依赖

```bash
cd YourProject
pod install
```

#### Step 4: 打开工程

```bash
open YourApp.xcworkspace
```

---

## 📋 方式二：手动集成

如果不使用 CocoaPods，可以手动集成：

### Step 1: 添加 XCFramework

1. 将 `HSADXSDK.xcframework` 拖入 Xcode 项目
2. 在 Target -> General -> Frameworks, Libraries, and Embedded Content 中确认：
   - `HSADXSDK.xcframework` 设置为 **Embed & Sign**

### Step 2: 添加资源文件

1. 将 `HSADX.bundle` 拖入项目
2. 确保在 Target -> Build Phases -> Copy Bundle Resources 中包含该 bundle

### Step 3: 手动安装依赖库

必须手动集成以下依赖：

| 依赖库 | 版本要求 | 下载地址 |
|--------|----------|----------|
| lottie-ios | Latest | https://github.com/airbnb/lottie-ios |
| MMKV | Latest | https://github.com/Tencent/MMKV |
| YYModel | Latest | https://github.com/ibireme/YYModel |
| SDWebImage | Latest | https://github.com/SDWebImage/SDWebImage |

### Step 4: 配置 Build Settings

在项目的 Build Settings 中添加：

**Header Search Paths**:
```
$(SDKROOT)/usr/include/libxml2
```

**Other Linker Flags**:
```
-ObjC
-lxml2
-lz
-lc++
```

**Frameworks**:
- Foundation.framework
- UIKit.framework
- AVFoundation.framework
- AdSupport.framework
- StoreKit.framework
- CoreTelephony.framework
- SystemConfiguration.framework

---

## 💻 代码集成

### 1. 导入头文件

```objc
#import <HSADXSDK/HSADXSDK.h>
```

### 2. SDK 初始化

```objc
// AppDelegate.m
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 配置 SDK
    HSSdkSettings *settings = [[HSSdkSettings alloc] init];
    settings.testMode = NO; // 生产环境设置为 NO
    
    HSSdkInitialConfiguration *config = [[HSSdkInitialConfiguration alloc] initWithSdkKey:@"YOUR_SDK_KEY" settings:settings];
    
    // 初始化 SDK
    [[HSSdk shared] initializeWithConfiguration:config completionHandler:^(HSSdkConfiguration *configuration) {
        NSLog(@"HSADXSDK 初始化成功");
    }];
    
    return YES;
}
```

### 3. 激励视频广告

```objc
#import <HSADXSDK/HSSRewardedAd.h>

@interface YourViewController () <HSSRewardedAdDelegate>
@property (nonatomic, strong) HSSRewardedAd *rewardedAd;
@end

@implementation YourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建激励视频实例
    self.rewardedAd = [HSSRewardedAd sharedWithAdPlacement:@"YOUR_PLACEMENT_ID"];
    self.rewardedAd.delegate = self;
    
    // 加载广告
    [self.rewardedAd loadAd];
}

- (void)showRewardedAd {
    if (self.rewardedAd.isReady) {
        [self.rewardedAd showAd];
    } else {
        NSLog(@"广告未准备好");
    }
}

#pragma mark - HSSRewardedAdDelegate

- (void)didLoadAd:(HSSAd *)ad {
    NSLog(@"激励视频加载成功");
}

- (void)didFailToLoadAdForAd:(HSSAd *)ad withError:(HSSError *)error {
    NSLog(@"激励视频加载失败: %@", error);
}

- (void)didDisplayAd:(HSSAd *)ad {
    NSLog(@"激励视频开始展示");
}

- (void)didFailToDisplayAd:(HSSAd *)ad withError:(HSSError *)error {
    NSLog(@"激励视频展示失败: %@", error);
}

- (void)didHideAd:(HSSAd *)ad {
    NSLog(@"激励视频关闭");
    // 预加载下一个广告
    [self.rewardedAd loadAd];
}

- (void)didClickAd:(HSSAd *)ad {
    NSLog(@"激励视频被点击");
}

- (void)didRewardUserForAd:(HSSAd *)ad withReward:(HSSReward *)reward {
    NSLog(@"用户完成观看，发放奖励");
    // 发放奖励逻辑
}

@end
```

### 4. 插屏广告

```objc
#import <HSADXSDK/HSSInterstitialAd.h>

@interface YourViewController () <HSSAdDelegate>
@property (nonatomic, strong) HSSInterstitialAd *interstitialAd;
@end

@implementation YourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建插屏广告实例
    self.interstitialAd = [[HSSInterstitialAd alloc] initWithAdPlacement:@"YOUR_PLACEMENT_ID"];
    self.interstitialAd.delegate = self;
    
    // 加载广告
    [self.interstitialAd loadAd];
}

- (void)showInterstitialAd {
    if (self.interstitialAd.isReady) {
        [self.interstitialAd showAd];
    }
}

#pragma mark - HSSAdDelegate

- (void)didLoadAd:(HSSAd *)ad {
    NSLog(@"插屏广告加载成功");
}

- (void)didFailToLoadAdForAd:(HSSAd *)ad withError:(HSSError *)error {
    NSLog(@"插屏广告加载失败: %@", error);
}

- (void)didDisplayAd:(HSSAd *)ad {
    NSLog(@"插屏广告开始展示");
}

- (void)didFailToDisplayAd:(HSSAd *)ad withError:(HSSError *)error {
    NSLog(@"插屏广告展示失败: %@", error);
}

- (void)didHideAd:(HSSAd *)ad {
    NSLog(@"插屏广告关闭");
    [self.interstitialAd loadAd];
}

- (void)didClickAd:(HSSAd *)ad {
    NSLog(@"插屏广告被点击");
}

@end
```

### 5. Banner 广告

```objc
#import <HSADXSDK/HSSADXBannerView.h>

@interface YourViewController () <HSSBannerAdDelegate>
@property (nonatomic, strong) HSSADXBannerView *bannerView;
@end

@implementation YourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建 Banner 广告
    self.bannerView = [[HSSADXBannerView alloc] initWithPlacementId:@"YOUR_PLACEMENT_ID" 
                                                              adSize:CGSizeMake(320, 50)];
    self.bannerView.delegate = self;
    self.bannerView.frame = CGRectMake(0, self.view.bounds.size.height - 50, 320, 50);
    self.bannerView.center = CGPointMake(self.view.center.x, self.bannerView.center.y);
    
    [self.view addSubview:self.bannerView];
    
    // 加载广告
    [self.bannerView loadAd];
}

#pragma mark - HSSBannerAdDelegate

- (void)didLoadBannerAd:(HSSADXBannerView *)ad {
    NSLog(@"Banner 广告加载成功");
}

- (void)didFailToLoadBannerAdForAd:(HSSADXBannerView *)ad withError:(HSSError *)error {
    NSLog(@"Banner 广告加载失败: %@", error);
}

- (void)didClickBannerAd:(HSSADXBannerView *)ad {
    NSLog(@"Banner 广告被点击");
}

@end
```

## 🔧 常见问题

### Q1: 编译时报错 "Multiple commands produce HSADX.bundle"

**原因**:
- 在 Xcode 项目中手动添加了 `HSADX.bundle`
- 导致 CocoaPods 自动复制和手动复制产生冲突

**解决方案**:
1. 在 Xcode 项目导航器中，找到 `HSADX.bundle`（如果有）
2. 右键点击 → Delete → **Remove Reference**（只移除引用，不删除文件）
3. 选择项目 Target → Build Phases → Copy Bundle Resources
4. 删除所有 `HSADX.bundle` 条目（点击 `-` 号）
5. 重新执行 `pod install` 和编译

**预防**:
- 只通过 Podfile 集成，不要手动拖入任何资源文件
- CocoaPods 会自动处理所有依赖和资源

### Q2: 编译时报错 "Framework not found HSADXSDK"

**解决方案**:
- 确认 `HSADXSDK.xcframework` 已正确添加到项目
- 检查 Build Settings -> Framework Search Paths 是否包含 XCFramework 路径
- 使用 CocoaPods 时，确保执行了 `pod install`

### Q3: 运行时报错 "dyld: Library not loaded"

**解决方案**:
- 检查所有依赖库（lottie-ios、HSMMKV、YYModel、SDWebImage）是否已安装
- 确认依赖库的 Embed 设置正确

### Q4: 找不到 OMSDK 相关符号

**解决方案**:
- 本二进制版本已内置 OMSDK，无需单独集成
- 如果项目中已有其他版本的 OMSDK，可能产生冲突，需要移除

### Q5: 符号冲突问题

**解决方案**:
本二进制方案的设计目的就是避免符号冲突：
- HSADXSDK 和 OMSDK 打包在一起，不会产生外部符号冲突
- 其他依赖通过 CocoaPods 管理，使用方可以控制版本

## 📄 许可证

Copyright © HungryStudio. All rights reserved.

本SDK为商业软件，使用前请联系 HungryStudio 获取授权。

