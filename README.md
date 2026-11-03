# Natural Scroll Toggle

A small native macOS app that toggles the system's **Natural scrolling** setting with one click. Pin it to the Dock, click when needed, and the app exits after showing a brief result.

[English](#english) · [简体中文](#简体中文)

## English

### Features

- One app switches Natural scrolling both on and off.
- The setting applies to both the mouse and trackpad.
- A rounded status message appears for about 1.2 seconds, then the app exits.
- The native icon provides blue arrows on white for light appearance and Apple's **System Dark** background gradient for dark appearance. The dark background uses the system-provided preset rather than pure black or a hard-coded gray. macOS selects the icon variant even while the app is not running.
- No background watcher, login item, Bluetooth monitoring, network requests, analytics, or account requirement.

The current app interface uses Traditional Chinese. The application name is **自然捲動切換**.

The dark background follows Apple's native System Dark preset. Apple recommends its system gradients over pure black or white icon backgrounds in the [app icon design session](https://developer.apple.com/videos/play/wwdc2025/220/).

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

### Sync the Dock icon with system appearance

On macOS versions with an **Icon & widget style** setting, open **System Settings → Appearance**, choose **Dark** under **Icon & widget style**, then select **Auto**. This lets macOS select the light or dark icon according to system appearance without a resident app process.

This is a **system-wide** setting: other compatible app icons and widgets will also follow system appearance. The separate **Default** icon style can keep using the white/default icon even when windows and menus are dark. The app does not silently change this preference.

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
src/ScrollToggle.swift              Application and rounded status message
src/MakeIcon.swift                  Legacy icon generation
assets/ScrollToggleAppearance.icon/  Native light and dark icon artwork
build.sh                            Local build and ad-hoc signing
```

Generated apps, build output, logs, local configuration, and credentials are excluded from version control.

## 简体中文

这是一个原生 macOS 小工具，用来一键切换系统的**自然滚动**。将“自然捲動切換”固定到 Dock 后，点击一次切换开关；提示显示约 1.2 秒后，程序自行退出。

### 功能

- 一个程序即可切换开启和关闭，同时影响鼠标与触控板。
- 使用圆角状态提示框。
- 原生图标提供浅色白底蓝箭头，以及采用 Apple **System Dark** 系统渐变背景的深色版本。深色背景使用系统预设，不使用纯黑或固定的灰色值；即使程序退出，也可以由 macOS 选择对应版本。
- 没有后台监测、登录自启、蓝牙监控、网络请求、数据统计或账号要求。
- 当前程序界面使用繁体中文，README 提供英文和简体中文说明。

### 构建与使用

需要支持 Icon Composer `.icon` 资源的 Xcode 构建工具，以及命令为 `python3` 的 Python 3，无需额外 Python 包。在仓库目录运行：

```zsh
./build.sh
```

生成的程序位于 `work/build/自然捲動切換.app`。将它移动到应用程序文件夹，再拖入 Dock 即可使用。程序只在点击时短暂运行，两次使用之间不会常驻。

本机构建采用临时本地签名，不需要 Apple 开发者账号；本仓库不提供经过 Apple 公证的安装包。

### 让 Dock 图标跟随系统

在提供“图标与小组件样式”设置的 macOS 上，打开“系统设置 → 外观”，将图标与小组件样式选择为“深色”，再选择“自动”。macOS 就会根据系统外观切换浅色或深色图标，不需要程序常驻。

这是一个**系统全局设置**，其他支持的应用图标与小组件也会随系统切换。“默认”图标样式与窗口、菜单的深浅色外观是独立的，可能在深色外观下继续显示白底默认图标。程序不会擅自修改这个系统设置。

### 兼容性

程序通过修改系统全局自然滚动偏好，并调用 macOS 内置 `PreferencePanesSupport` 框架的私有接口立即应用设置。系统更新可能改变该接口；如果接口不存在，程序会在写入前报错。

构建中声明的最低系统版本为 macOS 13，但这不代表所有系统版本都已验证。图标最终显示效果也取决于系统版本和图标外观设置。程序不会分别控制鼠标和触控板的滚动方向。
