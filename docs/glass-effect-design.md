# 液态玻璃效果设计规范

## 概述

液态玻璃效果（Glassmorphism）是一种半透明、模糊背景的设计风格，为UI元素提供现代感和层次感。本规范详细说明项目中液态玻璃效果的实现方法、应用场景和设计参数。

## 实现方式

项目中使用两种方式实现液态玻璃效果：

### 1. 使用系统原生修饰符（iOS 15+）

对于iOS 15及以上版本，推荐使用系统原生的`.glassEffect`修饰符：

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

### 2. 使用自定义VisualEffectView（全平台兼容）

对于需要更复杂配置或全平台兼容的场景，使用自定义的`VisualEffectView`：

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

**适用场景**：
- 需要覆盖整个屏幕或大面积区域的背景虚化
- 需要自定义模糊样式的场景
- 需要在iOS 15以下版本兼容的情况

## 应用场景规范

### 1. 设置页面背景虚化

当设置页面显示时，整个应用背景应应用虚化效果，增强层次感：

```swift
if isSettingsVisible {
    VisualEffectView(effect: UIBlurEffect(style: .light))
        .edgesIgnoringSafeArea(.all)
        .zIndex(1)
}
```

### 2. 组件背景

小型功能性组件应使用玻璃效果作为背景，增强视觉吸引力：

```swift
VStack {
    // 组件内容
}
.padding(15)
.glassEffect(.regular)
```

### 3. 浮动按钮

浮动操作按钮应使用玻璃效果，使其在各种背景上都清晰可见：

```swift
Button(action: {}) {
    // 按钮内容
}
.glassEffect(.regular)
.clipShape(Circle())
```

## 设计参数规范

### 模糊程度

- **标准模糊**：使用`.light`或`.regular`模糊样式
- **背景虚化**：根据当前主题选择合适的模糊样式
  - 浅色模式：使用`UIBlurEffect(style: .light)`
  - 深色模式：使用`UIBlurEffect(style: .dark)`或`.systemMaterial`

### 圆角和形状

- 圆形按钮：配合`.clipShape(Circle())`使用
- 矩形组件：使用适当的圆角（推荐12-20pt）

### 阴影效果

玻璃效果组件可选择性添加轻微阴影，增强立体感：

```swift
.shadow(radius: 10)
```

## 性能优化

1. **避免过度使用**：不要在同一屏幕上使用过多玻璃效果组件，以免影响性能
2. **适当区域**：仅在必要的UI元素上应用玻璃效果
3. **合理层级**：使用`zIndex`确保玻璃效果组件层级正确

## 兼容性考虑

1. 对于iOS 15以下版本，需要提供替代方案或回退到标准背景色
2. 确保在不同设备尺寸上玻璃效果显示正常

## 示例组件

### 位置组件应用玻璃效果

```swift
struct LocationView: View {
    // 组件属性
    
    var body: some View {
        if showLocation {
            VStack {
                // 位置信息内容
            }
            .padding(15)
            .glassEffect(.regular)
            .onTapGesture {
                // 点击操作
            }
        }
    }
}
```

### 设置按钮应用玻璃效果

```swift
Button(action: {}) {
    Image(systemName: "gear")
        .font(.system(size: 24, weight: .medium))
        .foregroundColor(.primary)
        .padding(12)
        .glassEffect(.regular)
        .clipShape(Circle())
}
```

## 设计建议

1. 玻璃效果与颜色主题搭配要协调，确保文本可读性
2. 适当的内边距（padding）可以增强玻璃效果的视觉表现
3. 考虑在玻璃效果组件周围添加细微的边框，增强边界感
4. 根据应用的整体设计语言，可调整玻璃效果的强度和透明度

通过遵循本规范，可以确保项目中液态玻璃效果的一致性和最佳用户体验。