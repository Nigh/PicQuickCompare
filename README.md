<div align="center">
	<img src="logo.png" alt="PicQuickCompare logo"/>
	<br/>
	<img src="https://capsule-render.vercel.app/api?type=transparent&fontColor=dbdbdb&text=PicQuickCompare&height=80&fontSize=48" alt="PicQuickCompare"/>
</div>

Windows 下的快速图片对比工具：拖入两张图，按住 / 松开或快捷键在两者之间切换，默认按高度对齐。

[![release](https://img.shields.io/github/v/release/Nigh/PicQuickCompare)](https://github.com/Nigh/PicQuickCompare/releases/latest)

## 下载

从 [Releases](https://github.com/Nigh/PicQuickCompare/releases/latest) 下载 `PicQuickCompare.zip`，解压后运行 `PicQuickCompare.exe`。

## 用法

拖入图片，鼠标按下与松开切换最后拖入的两张图片。默认自动按高度对齐。界面下方显示文件名、尺寸、大小与 EXIF 信息。

拖放图片至 exe 可以直接打开比较。

| 操作 | 默认 |
|------|------|
| 切换查看另一张 | 点击图片，或 `Space` |
| 交换两张图 | `S` |
| 退出 / 隐藏 | `Esc`，或 `Ctrl+W` |
| 后台模式唤起对比 | `Ctrl+Q`（仅「runs in background」开启时生效） |

右键托盘图标 → **Setup 设置**，可配置：

- 窗口位置：free / left / center / right
- 最大宽度、最大高度
- 是否后台运行
- Swap / Close / Compare 快捷键（可选 Win 修饰键）

设置写入同目录 `setting.ini`。

<div align="center">

https://github.com/Nigh/PicQuickCompare/assets/1407471/9bc7cdb1-932e-4e05-bb01-6feeafd778af

</div>

仓库内另有 `preview.mp4` 演示。

## 从源码运行

需要 [AutoHotkey v2](https://www.autohotkey.com/)。

```bash
git clone --recurse-submodules https://github.com/Nigh/PicQuickCompare.git
cd PicQuickCompare
```

用 AHK v2 运行 `app.ahk`。子模块 `ahk-compile-toolset` 用于发布编译；产物名为 `PicQuickCompare.exe`。
