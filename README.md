# ClipNest

A personal, local-first clipboard history app for macOS, maintained by [Cyprusky](https://github.com/Cyprusky).

ClipNest is an independently maintained **MIT-licensed fork of [Maccy](https://github.com/p0deje/Maccy)**. The original authors' copyright, license and Git history are preserved. It is not an official Maccy release.

## 功能

- 菜单栏剪贴板历史，支持文本、富文本、图片和文件记录。
- 搜索、固定常用记录、预览、编辑及纯文本粘贴。
- 默认 **Option + 空格** 唤出，可在偏好设置中修改。
- HTML 预览先转换为无外部资源的基本排版片段；原始 HTML 保留用于复制和粘贴。

## 个人版的调整

- 应用名称、Bundle ID、数据目录和偏好设置与 Maccy 分离。
- 去掉原版 Sparkle 更新依赖及原版下载通道；通过本仓库手动获取更新。
- 日志不再输出历史记录标题。
- 本地构建无需原作者的 Apple 开发者证书。
- 保留源代码和许可溯源，避免将上游工作标注为个人从零开发。

## 构建与运行

要求：macOS 14+、完整的 Xcode 26+ 和命令行工具。首次构建需要访问 GitHub 下载 Swift Package 依赖。

```bash
git clone https://github.com/Cyprusky/ClipNest.git
cd ClipNest
./scripts/build.sh build
open .build/DerivedData/Build/Products/Debug/ClipNest.app
```

也可用 Xcode 打开 `ClipNest.xcodeproj`，选择 `ClipNest` scheme 运行。

默认是供本机开发的 ad-hoc 签名。外部分发需要使用自己的 Developer ID 签名与 Apple 公证；本项目不提供任何签名凭据，不应通过关闭系统安全设置安装。

```bash
# 本地回归：不运行会写入系统剪贴板的 ClipboardTests
./scripts/build.sh test

# 所有单元测试：仅在独立测试环境中运行，会改写系统剪贴板
./scripts/build.sh test-all

# 合成 HTML + 本机回环 HTTP 服务器，比较旧接口与安全转换的资源请求
python3 scripts/check-html-network.py

# 生成本地 Release 包（未公证）
./scripts/build.sh release
```

可用环境变量 `CLIPNEST_BUILD_DIR` 指定构建产物位置。依赖版本固定于工程内的 `Package.resolved`；CI 构建与测试状态不等于公证、签名或外部分发验证。

## 使用

1. 启动后正常复制内容，点击菜单栏剪贴板图标或按 `⌥空格` 打开历史。
2. 输入关键词搜索，点击或按 Enter 将选中记录复制回剪贴板，再在目标应用按 `⌘V`。
3. `⌥P` 固定，`⌥Delete` 删除；可在偏好设置里修改。
4. 自动粘贴需要在系统设置中允许辅助功能权限。

ClipNest 使用独立身份 `io.github.cyprusky.ClipNest`，不会自动读取或迁移 Maccy 的历史及设置。原有 Maccy 数据保持在其原来的沙盒中。不要同时让多个剪贴板管理器互相重复记录；需要迁移时先备份，再单独设计迁移流程。

## Privacy

**Local-first does not mean risk-free.**

- 历史保存在当前用户沙盒内的 `Library/Application Support/ClipNest/Storage.sqlite`；没有应用层数据库加密。
- 没有配置历史云同步、远程日志后端或自动更新下载服务。
- HTML 预览移除属性、图片、CSS 和活动内容，只向系统渲染器传入安全文本及基本排版标签。常见段落、换行、粗体、列表和表格仍可预览；网页特有样式不会保留。
- 原始富文本粘贴到其他应用后，目标应用如何渲染或联网属于目标应用的行为。
- 密码管理器的机密标记会被过滤；以普通文本复制的密码、Token 和验证码仍可能被保存。请配置忽略应用/内容、限制历史数量，必要时暂停记录。
- 系统通知可能显示选中记录的标题；系统快捷指令可以在用户调用时获取历史内容。系统剪贴板/Handoff、备份、通知和外部快捷指令不属于应用自建上传通道。
- 网络回归只使用合成数据和 `127.0.0.1`，不读取真实剪贴板；测试通过不构成对所有系统组件、输入或未来版本的绝对安全保证。

请勿在 Issue 中提交真实剪贴板、账号密码、Token、完整数据库或未经脱敏的日志。

## 开发结构

- `ClipNest/AppIdentity.swift`：个人版名称、身份、仓库地址和数据目录。
- `ClipNest/Clipboard.swift`：剪贴板监听和复制/粘贴。
- `ClipNest/Models/`、`Storage.swift`：历史数据模型和本地存储。
- `ClipNest/Observables/`、`Views/`：历史、搜索、导航、预览和界面。
- `ClipNest/Extensions/NSAttributedString+ClipboardHTML.swift`：HTML 预览安全边界。
- `ClipNestTests/`、`ClipNestUITests/`：继承的测试与个人版回归。
- `scripts/`：本地构建、发布包与 HTML 网络验证。

## Attribution

See [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). The upstream baseline is Maccy commit `c700182` (2026-10-19). [Original upstream README](docs/UPSTREAM_README.md) is retained as historical reference; its downloads, support and donation information belongs to Maccy, not ClipNest.
