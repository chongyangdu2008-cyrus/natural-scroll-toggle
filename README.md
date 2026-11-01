# Natural Scroll Toggle

A small native macOS app that toggles the system's **Natural scrolling** setting with one click. Pin it to the Dock, click when needed, and the app exits after showing a brief result.

[English](#english) · [简体中文](#简体中文)

## English

### Features

- One app switches Natural scrolling both on and off.
- The setting applies to both the mouse and trackpad.
- A rounded status message appears for about 1.2 seconds, then the app exits.
- Both the default and dark app icons use blue arrows on black, so the Dock keeps the dark icon even when macOS selects the default icon style. The legacy icon also uses the same black background.
- No background watcher, login item, Bluetooth monitoring, network requests, analytics, or account requirement.

The current app interface uses Traditional Chinese. The application name is **自然捲動切換**.

### Build

Requirements:

- macOS and Xcode with Swift, `actool`, and support for Icon Composer `.icon` resources.
- Python 3, available as `python3`. No additional Python packages are needed.

Clone or download this repository, open a terminal in its directory, and run:

```zsh
./build.sh
```

The resulting app is:

```text
work/build/自然捲動切換.app
```

The build uses an ad-hoc local signature. An Apple Developer account is not required for this local build. The repository does not provide an Apple-notarized installer.

### Install and use

1. Move the built app to an Applications folder of your choice.
2. Drag the app to the Dock.
3. Click its Dock icon to switch Natural scrolling. Click again to switch back.

The process exists briefly while handling a click and displaying the result. It does not stay running between uses. macOS continues to manage the Dock icon normally.

To read the current setting without changing it:

```zsh
defaults read -g com.apple.swipescrolldirection
```

`1` means enabled; `0` means disabled.

### Implementation and compatibility

The app reads and writes the global `com.apple.swipescrolldirection` preference. To apply the change immediately, it calls `setSwipeScrollDirection` from macOS's built-in `PreferencePanesSupport` framework.

This is a **private system API** and can change in a future macOS release. If the framework or symbol is missing, the app shows an error before writing a new setting. The build declares macOS 13 as its deployment target; this is not a claim that every macOS version has been tested. Adaptive icon rendering also depends on the macOS version and icon appearance settings.

### Source layout

```text
src/ScrollToggle.swift        Application and rounded status message
src/MakeIcon.swift            Legacy icon generation
assets/ScrollToggle.icon/    Native default and dark icon artwork
build.sh                     Local build and ad-hoc signing
```

Generated apps, build output, logs, local configuration, and credentials are excluded from version control.

## 简体中文

这是一个原生 macOS 小工具，用来一键切换系统的**自然滚动**。将“自然捲動切換”固定到 Dock 后，点击一次切换开关；提示显示约 1.2 秒后，程序自行退出。

### 功能

- 一个程序即可切换开启和关闭，同时影响鼠标与触控板。
- 使用圆角状态提示框。
- 默认图标和深色图标均为黑底蓝箭头，即使 macOS 使用默认图标样式，Dock 也能显示黑底图标；传统图标同样采用黑色背景。
- 没有后台监测、登录自启、蓝牙监控、网络请求、数据统计或账号要求。
- 当前程序界面使用繁体中文，README 提供英文和简体中文说明。

### 构建与使用

需要支持 Icon Composer `.icon` 资源的 Xcode 构建工具，以及命令为 `python3` 的 Python 3，无需额外 Python 包。在仓库目录运行：

```zsh
./build.sh
```

生成的程序位于 `work/build/自然捲動切換.app`。将它移动到应用程序文件夹，再拖入 Dock 即可使用。程序只在点击时短暂运行，两次使用之间不会常驻。

本机构建采用临时本地签名，不需要 Apple 开发者账号；本仓库不提供经过 Apple 公证的安装包。

### 兼容性

程序通过修改系统全局自然滚动偏好，并调用 macOS 内置 `PreferencePanesSupport` 框架的私有接口立即应用设置。系统更新可能改变该接口；如果接口不存在，程序会在写入前报错。

构建中声明的最低系统版本为 macOS 13，但这不代表所有系统版本都已验证。图标最终显示效果也取决于系统版本和图标外观设置。程序不会分别控制鼠标和触控板的滚动方向。
