# 组件设计规范

## 概述

为了确保所有组件的风格统一，我们制定了以下设计规范。

## 颜色系统

- 主色调：使用系统默认的 accentColor
- 背景色：根据系统主题自动切换（浅色模式为白色，深色模式为黑色）
- 文字颜色：根据系统主题自动切换

## 字体系统

- 时钟数字：使用 monospaced 字体，size 24，weight medium
- 标题文字：使用 system 字体，size 18，weight bold
- 正文文字：使用 system 字体，size 16，weight regular
- 设置标题：使用 system 字体，size 20，weight semibold
- 设置关闭按钮：使用 system 字体，size 18，weight medium

## 间距系统

- 组件内边距：使用 16pt 标准间距
- 组件间距离：使用 8pt 小间距
- 组件与屏幕边缘距离：使用 16pt 标准间距

## 组件开发指南

1. 每个组件应独立存在于自己的文件中
2. 组件文件应放在 Components 目录下
3. 组件应支持深色/浅色模式自动切换
4. 组件应具有良好的可重用性
5. 组件应包含预览代码以便于调试
6. **即时反馈** - 设置更改能立即反映在UI上，提供即时反馈
7. **简化设计** - 移除了12小时制切换功能，时钟仅支持24小时制显示

## 示例组件结构

```swift
import SwiftUI

struct ComponentName: View {
    var body: some View {
        // 组件内容
    }
}

#Preview {
    ComponentName()
}
```