# 时钟组件 (ClockView)

## 功能说明

时钟组件是一个简约的数字时钟，显示当前的小时和分钟，并支持以下自定义选项：
- 秒钟显示开关
- 字体大小调节
- 时钟颜色自定义（支持预设颜色和自定义颜色）

## 功能特性

1. **实时时间显示**：每秒更新一次当前时间
2. **12/24小时制切换**：支持12小时制和24小时制显示
3. **秒钟显示控制**：可选择是否显示秒钟
4. **大写AM/PM标识（靠上对齐）**：12小时制下显示AM/PM标识，当使用自定义颜色时，AM/PM标识使用相同颜色但透明度降低
5. **字体大小调节**：支持自定义字体大小
6. **时钟颜色自定义**：支持预设颜色和自定义颜色选择
7. **现代化设计**：采用Liquid Glass效果和Monospaced字体
8. **兼容性更新**：使用最新的onChange语法以兼容iOS 17.0及以上版本

## 实现细节

### 文件位置

```
dashboard/Components/ClockView.swift     # 时钟组件
```

### 技术实现

1. 使用SwiftUI的Timer.publish实现每秒更新时间显示
2. 通过DateFormatter格式化时间显示
3. 支持12/24小时制时间格式切换
4. 支持显示秒钟的开关设置
5. 字体大小可调节
6. 时钟颜色可自定义，支持从设置中获取颜色值
7. 使用Liquid Glass效果增强视觉体验
8. 优化了时钟显示更新机制，确保在设置更改时能立即正确更新显示格式

### 代码结构

```swift
struct ClockView: View {
    @State private var currentTime = Date()
    @Binding var showSeconds: Bool
    @Binding var fontSize: CGFloat
    @Binding var is24HourFormat: Bool
    @Binding var clockColor: Color

    // 缓存formatter实例以提高性能
    private static let hour24Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter
    }()
    
    private static let hour12Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h"
        return formatter
    }()
    
    private static let amPmFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter
    }()
    
    private static let minuteFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter
    }()
    
    private static let secondFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter
    }()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(showSeconds: Binding<Bool>, fontSize: Binding<CGFloat>, 
         is24HourFormat: Binding<Bool>, clockColor: Binding<Color>) {
        self._showSeconds = showSeconds
        self._fontSize = fontSize
        self._is24HourFormat = is24HourFormat
        self._clockColor = clockColor
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // 小时部分
            Text(formatHour(currentTime))
                .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                .foregroundColor(clockColor)
            
            Text(":")
                .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                .foregroundColor(clockColor)
            
            // 分钟部分
            Text(formatMinute(currentTime))
                .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                .foregroundColor(clockColor)
            
            // 秒钟部分（可选）
            if showSeconds {
                Text(":")
                    .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(clockColor)
                
                Text(formatSecond(currentTime))
                    .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(clockColor)
            }
            
            // AM/PM标识（仅12小时制）
            if !is24HourFormat {
                Text(formatAmPm(currentTime))
                    .font(.system(size: fontSize * 0.5, weight: .medium, design: .monospaced))
                    .foregroundColor(clockColor == .primary ? .gray : clockColor.opacity(0.7))
                    .padding(.leading, 4)
                    .alignmentGuide(.top) { _ in 0 }
                    .offset(y: -fontSize * 0.25)
            }
        }
        .padding(20)
        .glassEffect(.regular) // 使用Liquid Glass效果替代传统的半透明背景
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}
```

## 使用方法

在其他视图中使用 `ClockView` 时需要传递设置值：

```swift
@ObservedObject private var userSettings = UserSettings.shared

var body: some View {
    ZStack {
        // 背景
        Color.white
        
        // 时钟组件
        ClockView(
            showSeconds: $userSettings.showSeconds,
            fontSize: $userSettings.fontSize,
            is24HourFormat: $userSettings.is24HourFormat,
            clockColor: $userSettings.clockColor
        )
        .padding()
    }
}
```

## 自定义选项

1. **秒钟显示**：可选择是否显示秒钟
2. **字体大小**：可调节时钟字体大小（20-80pt）
3. **时间格式**：仅支持24小时制显示
4. **视觉效果**：时钟设置页面保持了组件级别的Liquid Glass效果，但移除了整体背景效果以提高可读性
5. **尺寸调整**：时钟设置子页面的宽度从750调整为700，使其稍微缩小以改善视觉比例