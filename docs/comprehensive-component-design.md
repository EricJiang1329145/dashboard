# 仪表盘应用组件设计规范

## 概述

本文档是仪表盘应用的综合设计规范，涵盖所有UI组件的设计原则、样式指南、交互规范和实现建议。遵循本规范可确保应用界面的一致性、美观性和良好的用户体验。

## 目录

- [1. 基础设计系统](#1-基础设计系统)
  - [1.1 颜色系统](#11-颜色系统)
  - [1.2 字体系统](#12-字体系统)
  - [1.3 间距系统](#13-间距系统)
  - [1.4 组件开发指南](#14-组件开发指南)

- [2. 液态玻璃效果](#2-液态玻璃效果)
  - [2.1 实现方式](#21-实现方式)
  - [2.2 应用场景规范](#22-应用场景规范)
  - [2.3 设计参数规范](#23-设计参数规范)
  - [2.4 性能优化](#24-性能优化)

- [3. 设置页面设计](#3-设置页面设计)
  - [3.1 页面架构](#31-页面架构)
  - [3.2 主设置页面](#32-主设置页面)
  - [3.3 时钟设置子页面](#33-时钟设置子页面)
  - [3.4 位置设置子页面](#34-位置设置子页面)
  - [3.5 交互规范](#35-交互规范)

- [4. 组件实现指南](#4-组件实现指南)
  - [4.1 组件结构模板](#41-组件结构模板)
  - [4.2 设置管理](#42-设置管理)
  - [4.3 响应式设计](#43-响应式设计)
  - [4.4 深色模式支持](#44-深色模式支持)

## 1. 基础设计系统

### 1.1 颜色系统

- **主色调**：使用系统默认的 accentColor
- **背景色**：根据系统主题自动切换（浅色模式为白色，深色模式为黑色）
- **文字颜色**：根据系统主题自动切换
  - 主要文本：`.primary`
  - 次要文本：`.secondary`
  - 禁用状态：`.gray`
- **功能色**：
  - 确认/成功：`Color.blue`
  - 警告/错误：`Color.red`
  - 按钮背景：`Color(.systemGray6)`

### 1.2 字体系统

- **时钟数字**：使用 monospaced 字体，size 24，weight medium
- **标题文字**：使用 system 字体，size 18，weight bold
- **正文文字**：使用 system 字体，size 16，weight regular
- **设置标题**：使用 system 字体，size 20，weight semibold
- **设置关闭按钮**：使用 system 字体，size 18，weight medium
- **辅助文字**：使用 system 字体，caption2 size

### 1.3 间距系统

- **组件内边距**：使用 16pt 标准间距
- **组件间距离**：使用 8pt 小间距
- **组件与屏幕边缘距离**：使用 16pt 标准间距
- **设置项间距**：20pt
- **分组间距**：15pt

### 1.4 组件开发指南

1. 每个组件应独立存在于自己的文件中
2. 组件文件应放在 Components 目录下
3. 组件应支持深色/浅色模式自动切换
4. 组件应具有良好的可重用性
5. 组件应包含预览代码以便于调试
6. **即时反馈** - 设置更改能立即反映在UI上，提供即时反馈
7. **简化设计** - 移除了12小时制切换功能，时钟仅支持24小时制显示
8. **可选显示** - 对于可选的显示元素，应提供开关设置让用户选择是否显示

## 2. 液态玻璃效果

### 2.1 实现方式

#### 2.1.1 使用系统原生修饰符（iOS 15+）

```swift
.glassEffect(.regular)  // 标准玻璃效果
```

**适用场景**：
- 小型UI元素，如按钮、小部件
- 需要简单玻璃效果的组件

**示例**：
```swift
Button(action: {}) {
    Image(systemName: "gear")
        .font(.system(size: 24, weight: .medium))
        .foregroundColor(.primary)
        .padding(12)
}
.glassEffect(.regular)
.clipShape(Circle())
```

#### 2.1.2 使用自定义VisualEffectView（全平台兼容）

```swift
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}
```

**使用方式**：
```swift
VisualEffectView(effect: UIBlurEffect(style: .light))
    .edgesIgnoringSafeArea(.all)
```

### 2.2 应用场景规范

- **设置页面背景虚化**：当设置页面显示时，整个应用背景应应用虚化效果
- **组件背景**：小型功能性组件应使用玻璃效果作为背景
- **浮动按钮**：浮动操作按钮应使用玻璃效果，使其在各种背景上都清晰可见

### 2.3 设计参数规范

- **模糊程度**：使用`.light`或`.regular`模糊样式
- **圆角和形状**：
  - 圆形按钮：配合`.clipShape(Circle())`使用
  - 矩形组件：使用12-20pt圆角
- **阴影效果**：可选择性添加轻微阴影（`.shadow(radius: 10)`）

### 2.4 性能优化

1. 避免过度使用玻璃效果
2. 仅在必要的UI元素上应用
3. 使用`zIndex`确保层级正确

## 3. 设置页面设计

### 3.1 页面架构

设置功能采用分层结构：
- **主设置页面**：提供设置分类入口和全局确认机制
- **子设置页面**：提供具体功能类别的详细设置选项

### 3.2 主设置页面

#### 3.2.1 页面布局

```swift
RoundedRectangle(cornerRadius: 20)
    .fill(Color(.systemBackground))
    .frame(width: 850, height: 700)
    .shadow(radius: 10)
```

#### 3.2.2 尺寸规范
- 宽度：850pt
- 高度：700pt
- 圆角半径：20pt
- 阴影半径：10pt

#### 3.2.3 标题栏设计

包含页面标题（居中）、确认按钮（右侧）和关闭按钮（最右侧）。

#### 3.2.4 设置分类项

1. **时钟设置**
   - 图标：`clock.fill`
   - 标题："时钟设置"
   - 副标题："调整时钟显示格式和外观"

2. **位置设置**
   - 图标：`location.fill`
   - 标题："位置设置"
   - 副标题："调整位置信息显示格式和外观"

### 3.3 时钟设置子页面

#### 3.3.1 标题栏设计

包含返回按钮（左侧）、页面标题（居中）。

#### 3.3.2 设置选项

1. **时间格式设置**
   - 时间格式选择器（24/12小时制）
   - 显示秒钟开关
   - 显示日期开关

2. **字体大小设置**
   - 当前字号显示
   - 增减按钮
   - 滑动调节条（范围：20-80，步长：2）

3. **时钟颜色设置**
   - 预设颜色选择器（默认、红色、蓝色、绿色、橙色、紫色）
   - 自定义颜色选择器

### 3.4 位置设置子页面

#### 3.4.1 设置选项

1. **显示位置开关**
2. **位置颜色选择器**

### 3.5 交互规范

#### 3.5.1 临时值机制

所有设置更改使用临时值机制：
- 修改设置时，更改保存在临时属性中
- 实时预览设置效果，但不影响实际应用设置
- 只有点击确认按钮后，更改才会应用到实际属性

#### 3.5.2 确认机制

- 主设置页面提供全局确认按钮
- 子设置页面不单独提供确认按钮
- 确认按钮根据是否有未应用更改自动启用/禁用

#### 3.5.3 未保存提示

当有未保存的设置更改时关闭设置页面，显示提醒对话框。

## 4. 组件实现指南

### 4.1 组件结构模板

```swift
import SwiftUI

struct ComponentName: View {
    // 组件属性和状态
    
    var body: some View {
        // 组件内容
    }
}

#Preview {
    ComponentName()
        .preferredColorScheme(.dark) // 同时预览深色模式
}
```

### 4.2 设置管理

使用`UserSettings`类管理全局设置状态：

```swift
class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    // 实际设置值
    @Published var settingName: Type = defaultValue
    
    // 临时设置值
    @Published var tempSettingName: Type = defaultValue
    
    // 同步、应用、重置方法
    func syncTempToCurrent() { ... }
    func applyTempSettings() { ... }
    func resetTempToCurrent() { ... }
    func hasUnappliedChanges() -> Bool { ... }
    
    // 持久化方法
    private func loadSettings() { ... }
}
```

### 4.3 响应式设计

- 使用`GeometryReader`获取屏幕尺寸
- 使用相对尺寸而非固定尺寸
- 限制最大宽度（如`maxWidth: .infinity * 0.85`）确保在宽屏设备上的良好布局

### 4.4 深色模式支持

- 使用系统颜色（如`.primary`、`.secondary`、`Color(.systemBackground)`）
- 在预览中使用`.preferredColorScheme(.dark)`测试深色模式
- 避免使用硬编码的颜色值
- 为玻璃效果选择合适的模糊样式

## 5. 设计最佳实践

1. **一致性**：保持整个应用的设计风格一致
2. **易用性**：确保设置选项的作用明确，提供清晰的标签
3. **即时反馈**：提供实时预览功能，让用户直观看到设置效果
4. **确认机制**：重要设置更改提供确认和回退机制
5. **状态保存**：确保设置更改正确持久化
6. **性能优化**：避免过度使用复杂效果，确保流畅运行
7. **可访问性**：确保文本对比度符合标准，控件尺寸易于点击

## 6. 未来扩展

### 6.1 新增设置分类

当需要添加新的设置分类时：
1. 在`SettingsView`中添加新的`SettingItemView`
2. 创建对应的子设置视图文件
3. 在UserSettings中添加相应的设置属性

### 6.2 新增组件

创建新组件时应遵循：
1. 组件文件放在Components目录下
2. 提供详细的文档说明
3. 包含预览代码
4. 支持深色模式
5. 考虑可重用性和性能

---

本设计规范将随着应用的发展不断更新和完善。所有开发人员应严格遵循本规范，确保应用的设计质量和用户体验。