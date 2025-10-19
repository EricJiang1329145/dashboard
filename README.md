# Dashboard 应用

这是一个现代化的仪表板应用程序，具有时钟显示、位置信息等功能。

## 更新日志

### 最近更新
- 改进了ClockView组件的默认初始化方法，使其接受默认参数，方便预览和使用
- 更新了clock-component.md文档，反映了初始化方法的变更
- 确保ClockView组件的所有绑定参数与UserSettings保持一致
- 添加位置信息显示功能：新增位置组件，可显示当前位置的经纬度信息，用户可以在设置中控制是否显示位置信息及自定义颜色
- 修复日期颜色显示：调整日期颜色逻辑，使其与AM/PM标识颜色保持一致（默认状态为灰色，自定义颜色时降低透明度）
- 修复ClockView组件：添加showDate参数支持，确保日期显示功能正常工作
- 添加日期显示功能：时钟组件现在支持显示日期，用户可以在设置中控制是否显示日期
- 设置页面UI优化：将液态玻璃效果从设置内容区域移除，应用到设置标题上，解决排版问题
- 时钟颜色自定义功能：支持多种预设颜色和自定义颜色选择器，用户可以个性化时钟显示效果
- 设置确认机制重构：统一了设置确认流程，防止用户误操作丢失设置
- 修复了设置状态保持问题：返回上级页面时保留临时设置值，提升用户体验
- 移除了SettingsView中的NavigationView：修复了在ContentView中调用SettingsView时出现的方框底层问题，现在设置界面在两种预览模式下都能正确显示圆角效果，不会有额外的方框遮挡下方组件
- 使用GeometryReader替代UIScreen.main：修复了iOS 26.0中UIScreen.main API弃用警告，提高了代码的未来兼容性
- 将设置页的所有参数设置为存储在应用数据内，调整开关后对勾变成可用状态，只有打勾才能应用修改，否则不应用修改
- 统一确认流程：移除子页面确认按钮，仅在总设置页面提供确认功能，避免重复确认
- 优化了内部元素宽度：将时间格式和字体大小设置项的宽度调整为85%，避免占据整行，让液态玻璃效果更好地包围内容
- 修复了时间格式栏目的液态玻璃效果：优化了按钮背景透明度和布局约束，确保液态玻璃效果完全包住内部元素
- 改进了状态管理：移除了不必要的onChange处理，简化了状态更新逻辑
- 更新了onChange语法以兼容iOS 17.0及以上版本
- 修复了24小时制切换后时钟显示问题：确保时钟显示格式正确
- 完善了数据持久化功能：所有设置项都会保存在本地存储中，不会随软件关闭而重置
- 修复了设置页面覆盖问题：调整了设置页面的显示方式，使其不会覆盖整个屏幕，仅在指定区域内显示

- 优化了设置页面圆角显示效果：移除了标题栏的背景色，使设置页面的圆角更加明显
- 进一步优化了设置页面的圆角效果：使用RoundedRectangle重新设计了设置页面的背景，确保圆角效果更加明显和美观

## 功能特性

### 时钟功能
- 🕐 实时数字时钟显示（支持24小时制）
- 📅 日期显示（可选）
- 🎨 自定义时钟颜色（支持多种预设颜色和自定义颜色选择）
- ⚙️ 设置面板（可通过右上角齿轮图标访问）

### 位置功能
- 📍 实时显示当前位置的经纬度信息
- 🏙️ 显示当前位置所在城市
- 🖌️ 可自定义字体大小和颜色
- 🎛️ 可通过设置面板控制显示/隐藏
- 🔄 支持点击组件重新加载位置信息

### 通用特性
- ✨ Liquid Glass 设计风格
- 📱 响应式设计，适配不同屏幕尺寸
- 💾 设置持久化存储（设置项会在应用重启后保留）
- 🧩 与现有设置机制无缝集成
- 📚 完整的文档说明

## 组件说明

### 主要组件

1. **ContentView** - 主视图，包含时钟组件和设置按钮
2. **ClockView** - 数字时钟组件，显示当前时间
3. **LocationView** - 位置信息组件，显示当前位置的经纬度
4. **SettingsView** - 设置面板组件，提供各种自定义选项
5. **ClockSettingsView** - 时钟设置子页面，用于配置时钟相关参数
6. **LocationSettingsView** - 位置设置子页面，用于配置位置信息相关参数
7. **UserSettings** - 用户设置管理器，负责设置的加载、保存和持久化

### 组件交互关系

```
ContentView (主视图)
├── ClockView (时钟组件)
├── LocationView (位置信息组件)
└── SettingsView (设置面板)
    ├── ClockSettingsView (时钟设置子页面)
    └── LocationSettingsView (位置设置子页面)

UserSettings (共享设置管理器)
├── showSeconds (实际应用的秒数显示设置)
├── fontSize (实际应用的字体大小设置)
├── tempShowSeconds (临时秒数显示设置)
├── tempFontSize (临时字体大小设置)
└── 设置应用/重置方法
```

##### 技术实现

- 使用 SwiftUI 构建用户界面
- 使用 @Binding 实现组件间数据传递
- 使用 @ObservedObject 和 UserDefaults 实现数据持久化
- 使用 Liquid Glass 效果增强视觉体验
- 使用 MVVM 架构模式组织代码结构
- 使用 CoreLocation 获取设备位置信息
- 在 Info.plist 中配置位置权限说明，确保应用能正确获取位置信息

## 使用方法

1. 点击屏幕右上角的设置按钮打开设置面板
2. 在设置面板中可以调整时钟和位置相关参数
3. 修改设置后点击确认按钮保存更改
4. 点击关闭按钮或在设置面板外点击可关闭设置面板

## 开发说明

### 项目结构

```
Dashboard/
├── Components/
│   ├── ContentView.swift
│   ├── ClockView.swift
│   ├── LocationView.swift
│   ├── SettingsView.swift
│   ├── ClockSettingsView.swift
│   └── LocationSettingsView.swift
├── Managers/
│   └── UserSettings.swift
├── Resources/
│   └── Info.plist
├── Assets.xcassets/
└── Preview Content/
    └── Preview Assets.xcassets/
```

### 代码规范

- 使用SwiftUI框架进行开发
- 遵循MVVM架构模式
- 使用ObservableObject管理状态
- 使用UserDefaults进行数据持久化
- 遵循Swift命名规范

## 详细文档

- [位置组件详细说明](docs/location-component.md)
- [位置设置组件详细说明](docs/location-settings.md)

## 文档

详细的技术文档请参阅 [docs](./docs) 目录：

- [组件设计说明](./docs/component-design.md)
- [时钟组件](./docs/clock-component.md)
- [时钟设置组件](./docs/clock-settings-component.md)
- [设置组件](./docs/settings-component.md)