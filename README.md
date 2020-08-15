# bddisk

一个简陋的百度网盘客户端。可以查看、搜索、下载文件。

## Demo

| 下载页面                                                   | 搜索页面                                                   | 文件页面                                                   | 文件详情                                                   |
| ---------------------------------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------------- |
| ![下载](https://i.loli.net/2020/08/16/L4sT8OXCJcUBoAm.png) | ![搜索](https://i.loli.net/2020/08/10/qzBGlmF6KSEpsPw.png) | ![文件](https://i.loli.net/2020/08/10/tdPDZafu1CGvQwb.png) | ![详情](https://i.loli.net/2020/08/16/ulRUsFhcaZ8DT5m.png) |

## 开发

首先需要安装依赖：

```bash
flutter upgrade
```

## 打包

打包成 apk:

```bash
flutter build apk
```

可以选择对不同平台分开打包，可以降低单个apk的大小:

```bash
flutter build apk --target-platform android-arm64 --split-per-abi
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
