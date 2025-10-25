# 设置页面选项内容和样式规范

## 概述

本文档详细说明仪表盘应用中设置页面的结构、选项内容、样式规范和交互设计，确保设置功能的一致性和良好用户体验。

## 设置页面架构

设置功能采用分层结构：
- **主设置页面**：提供设置分类入口和全局确认机制
- **子设置页面**：提供具体功能类别的详细设置选项

## 主设置页面设计

### 页面布局

```swift
RoundedRectangle(cornerRadius: 20)
    .fill(Color(.systemBackground))
    .frame(width: 850, height: 700)
    .shadow(radius: 10)
```

### 尺寸规范
- 宽度：850pt
- 高度：700pt
- 圆角半径：20pt
- 阴影半径：10pt

### 标题栏设计

标题栏包含以下元素：
- 页面标题（居中）
- 确认按钮（右侧）
- 关闭按钮（最右侧）

```swift
HStack {
    Spacer()
    Text("设置")
        .font(.system(size: 20, weight: .semibold))
    Spacer()
    
    // 确认按钮
    Button(action: {})
    
    // 关闭按钮
    Button(action: {})
}
.padding()
```

### 设置分类项设计

设置分类项使用统一的`SettingItemView`组件：

```swift
SettingItemView(
    title: "时钟设置",
    subtitle: "调整时钟显示格式和外观",
    icon: "clock.fill"
) {
    // 点击操作
}
```

### 当前设置分类项

1. **时钟设置**
   - 图标：`clock.fill`
   - 标题："时钟设置"
   - 副标题："调整时钟显示格式和外观"

2. **位置设置**
   - 图标：`location.fill`
   - 标题："位置设置"
   - 副标题："调整位置信息显示格式和外观"

## 时钟设置子页面设计

### 标题栏设计

```swift
HStack {
    Button(action: {})
    Spacer()
    Text("时钟设置")
        .font(.system(size: 20, weight: .semibold))
    Spacer()
}
.padding()
.background(Color(.systemGray6))
```

### 设置选项内容

#### 1. 时间格式设置部分

包含以下选项：

- **时间格式选择器**
  - 类型：分段选择器（SegmentedPicker）
  - 选项："24小时制"、"12小时制"
  - 默认值："24小时制"

- **显示秒钟开关**
  - 类型：Toggle开关
  - 图标：`stopwatch`
  - 标签："显示秒钟"
  - 默认值：关闭

- **显示日期开关**
  - 类型：Toggle开关
  - 图标：`calendar`
  - 标签："显示日期"
  - 默认值：关闭

#### 2. 字体大小设置部分

包含以下控制元素：

- **当前字号显示**
  - 格式："大小: XX"
  - 字号范围：20-80

- **增减按钮**
  - 减小按钮：`minus.circle.fill`
  - 增大按钮：`plus.circle.fill`
  - 按钮状态：超出范围时禁用

- **滑动调节条**
  - 类型：Slider
  - 范围：20-80
  - 步长：2
  - 颜色：蓝色

#### 3. 时钟颜色设置部分

包含以下选项：

- **预设颜色选择器**
  - 选项：默认、红色、蓝色、绿色、橙色、紫色
  - 显示方式：圆形颜色按钮+文字标签
  - 选中状态：蓝色背景+白色边框

- **自定义颜色选择器**
  - 类型：ColorPicker
  - 支持不透明度：否
  - 标签："选择颜色"

## 位置设置子页面设计

### 标题栏设计

与时钟设置子页面标题栏设计一致。

### 设置选项内容

1. **显示位置开关**
   - 类型：Toggle开关
   - 标签："显示位置"
   - 默认值：关闭

2. **位置颜色选择器**
   - 类型：ColorPicker
   - 标签："位置颜色"
   - 默认值：主颜色（.primary）

## 设置交互规范

### 1. 临时值机制

所有设置更改使用临时值机制：
- 修改设置时，更改保存在临时属性中
- 实时预览设置效果，但不影响实际应用设置
- 只有点击确认按钮后，更改才会应用到实际属性

### 2. 确认机制

- **主设置页面**：提供全局确认按钮
- **子设置页面**：不单独提供确认按钮
- 确认按钮状态：
  - 有未应用更改时：蓝色背景，白色图标，可点击
  - 无未应用更改时：灰色背景，灰色图标，禁用状态

### 3. 未保存提示

当有未保存的设置更改时关闭设置页面，显示提醒对话框：

```swift
.alert("未保存的更改", isPresented: $showUnsavedAlert) {
    Button("取消", role: .cancel) {}
    Button("放弃更改", role: .destructive) {}
    Button("保存更改") {}
} message: {
    Text("您有未保存的设置更改，请选择操作。")
}
```

### 4. 页面导航

- 使用`.sheet`实现子页面的模态显示
- 返回按钮点击时，保留临时值状态
- 主页面监听子页面的返回，自动更新确认按钮状态

## UI设计规范

### 颜色规范

- 设置页面背景：系统背景色（`Color(.systemBackground)`）
- 标题栏背景：浅灰色（`Color(.systemGray6)`）
- 激活状态：蓝色（`Color.blue`）
- 文本颜色：主文本颜色（`.primary`）
- 辅助文本：次要文本颜色（`.secondary`）

### 字体规范

- 页面标题：system 20pt semibold
- 选项标题：system 16pt regular
- 辅助文字：system caption2

### 间距规范

- 组件间距：20pt
- 标题与内容间距：15pt
- 页面内边距：16pt
- 控件间距：12-20pt

### 圆角规范

- 设置页面：20pt
- 按钮：圆形（使用`.clipShape(Circle())`）

## 代码实现规范

### 1. 设置项分组

使用`SectionView`组织相关设置项：

```swift
SectionView(title: "时间格式") {
    // 相关设置控件
}
```

### 2. 开关样式

```swift
Toggle(isOn: $binding) {
    HStack {
        Image(systemName: "icon_name")
            .foregroundColor(.blue)
        Text("标签文本")
            .font(.system(size: 16))
    }
}
```

### 3. 视图大小限制

设置项内容区域限制最大宽度为屏幕的85%，确保在宽屏设备上有良好的布局：

```swift
.frame(maxWidth: .infinity * 0.85, alignment: .leading)
```

## 扩展性指南

### 添加新的设置分类

1. 在`SettingsView`中添加新的`SettingItemView`
2. 创建对应的子设置视图文件
3. 在UserSettings中添加相应的设置属性
4. 实现临时值和持久化逻辑

### 添加新的设置选项

1. 在对应的子设置视图中添加UI控件
2. 在UserSettings中添加对应的属性（实际值和临时值）
3. 更新相关的持久化、同步和比较方法

## 设计最佳实践

1. **一致性**：保持设置页面和主应用的设计风格一致
2. **易用性**：确保每个设置选项的作用明确，提供清晰的标签
3. **即时反馈**：提供实时预览功能，让用户直观看到设置效果
4. **确认机制**：重要设置更改提供确认和回退机制
5. **状态保存**：确保设置更改正确持久化到`UserDefaults`

通过遵循本规范，可以确保设置页面的设计一致性、功能完整性和良好的用户体验。