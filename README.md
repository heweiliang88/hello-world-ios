# Hello World iOS

一个用 SwiftUI 写的极简 iOS 应用，**由 GitHub Actions 在云端 macOS runner 上自动编译成 IPA**。

整个仓库不需要 Mac、不需要 Apple 开发者账号（$99）、不需要配置任何 Secret。

## 这个项目演示了什么

| 环节 | 做法 |
|---|---|
| 本地开发环境 | 任意系统（本项目就是在 Linux 上编写的） |
| 编译 | GitHub Actions 的 `macos-15` runner（真实 Apple Silicon Mac） |
| 签名 | **完全不签名**（`CODE_SIGNING_ALLOWED=NO`） |
| 产物 | 未签名 IPA，发布到 Releases 页面 |

## 项目结构

```
.
├── HelloWorld/
│   ├── HelloWorldApp.swift        # @main 入口
│   └── ContentView.swift          # 界面：图标 + 文字 + 计数器按钮
├── HelloWorld.xcodeproj/
│   └── project.pbxproj            # 手写的 Xcode 工程文件
├── .github/workflows/build-ipa.yml  # CI：编译 → 打包 IPA → 发布 Release
└── scripts/make-ipa.sh            # 把 .app 打成 .ipa
```

## 怎么拿到 IPA

1. 打开仓库的 **Actions** 标签页
2. 等 `Build iOS IPA` 跑完（首次约 2–4 分钟）
3. 到 **Releases** 页面下载 `HelloWorld-unsigned.ipa`
4. 或者在 Actions 运行详情页底部下载 Artifacts

## 怎么把 IPA 装到 iPhone 上

⚠️ **这是未签名的 IPA，不能直接安装**，必须先自行签名。

**未越狱设备**（推荐）

1. 电脑上装 Sideloadly（[sideloadly.io](https://sideloadly.io)）或 AltStore
2. USB 连接 iPhone，把 IPA 拖进工具，填入自己的 Apple ID
3. 首次安装后：`设置 → 通用 → VPN与设备管理` → 信任你的开发者证书
4. iOS 16+ 还需：`设置 → 隐私与安全性 → 开发者模式` → 开启并重启

> 免费 Apple ID 签的有效期只有 **7 天**，到期后 App 会打不开，需要重签一次。
> AltStore 可以自动完成这个续签。

**已越狱设备**

装 AppSync Unified 后可直接安装未签名 IPA，永久有效。

## 技术要点

**1. 为什么不签名也能编译**

代码签名发生在 `xcodebuild` 的最后一步。设置 `CODE_SIGNING_ALLOWED=NO`
后 Xcode 只做编译和链接，产出一个没有签名的 `.app`。因为跳过了签名，
所以不需要证书、不需要描述文件，也不需要付费开发者账号。

**2. 为什么用 `-target` 而不是 `-scheme`**

`-scheme` 需要 `.xcodeproj/xcshareddata/xcschemes/` 下有 scheme 文件，
而 scheme 通常由 Xcode 图形界面生成。用 `-target` 可以完全绕过这个依赖，
纯文本就能维护整个工程。

**3. 为什么不用 Flutter**

Flutter 编译 iOS 需要 `flutter build ipa`，而该命令依赖完整的 Flutter 工具链。
原生 SwiftUI 只需要 Xcode，runner 上自带，构建更快、依赖更少。

**4. IPA 的打包原理**

IPA 就是一个 zip：

```
Payload/
└── HelloWorld.app/
    ├── HelloWorld       (Mach-O 可执行文件)
    └── Info.plist
```

压缩时用 `zip -y` 保留符号链接是必须的 —— App 内部大量依赖 symlink，
被解引用会导致安装后无法启动。

## 本地构建（需要 macOS）

```bash
xcodebuild \
  -project HelloWorld.xcodeproj \
  -target HelloWorld \
  -configuration Release \
  -sdk iphoneos \
  CONFIGURATION_BUILD_DIR="$PWD/build/Release-iphoneos" \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
  build

bash scripts/make-ipa.sh build/Release-iphoneos/HelloWorld.app build/ipa/HelloWorld-unsigned.ipa
```

## 许可

仅用于学习和个人测试。
