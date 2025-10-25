# 设置组件 (SettingsView)

## 功能说明

设置组件提供了一个用户界面，允许用户自定义应用程序的各种设置。目前支持时钟相关的设置选项。

## 实现细节

### 文件位置

```
dashboard/Components/SettingsView.swift     # 主设置页面
dashboard/Components/ClockSettingsView.swift # 时钟设置子页面
dashboard/Components/LocationSettingsView.swift # 位置设置子页面
dashboard/Components/UserSettings.swift     # 用户设置管理器
```

### 技术实现

1. 使用 `@ObservedObject` 和 `UserSettings.shared` 管理全局设置状态
2. 使用 `Sheet` 实现页面导航
3. 使用标准的系统背景色和圆角设计
4. 使用 `UserDefaults` 实现数据持久化
5. 使用临时值机制实现设置预览和确认应用功能
6. 仅支持24小时制时间显示
7. 实现了统一的确认机制：仅在总设置页面提供确认功能（蓝色背景）
8. 移除了子页面的确认按钮，避免重复确认设计
9. 添加了未保存退出提醒功能，提供取消、放弃更改、保存更改选项
10. 优化了页面显示方式，确保设置页面仅在指定区域内显示，不会覆盖整个屏幕
11. 移除了标题栏背景色，使设置页面的圆角效果更加明显
12. 进一步优化了设置页面的圆角效果：使用RoundedRectangle重新设计了设置页面的背景，确保圆角效果更加明显和美观
13. 添加日期显示设置：支持在时钟中显示或隐藏日期信息

### 代码结构

```swift
struct SettingsView: View {
    @Binding var isVisible: Bool
    @ObservedObject private var userSettings = UserSettings.shared
    @State private var showClockSettings = false
    @State private var showLocationSettings = false
    @State private var showUnsavedAlert = false
    
    var body: some View {
        ZStack {
            // 设置页面背景，带有圆角效果
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .frame(width: 850, height: 700)
                .shadow(radius: 10)
                
            VStack {
                // 标题栏
                HStack {
                    Spacer()
                    Text("设置")
                        .font(.system(size: 20, weight: .semibold))
                    Spacer()
                    
                    // 确认按钮
                    Button(action: {
                        userSettings.applyTempSettings()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(userSettings.hasUnappliedChanges() ? .white : .gray)
                            .padding(8)
                            .background(
                                (userSettings.hasUnappliedChanges() ? Color.blue : Color(.systemGray6))
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!userSettings.hasUnappliedChanges())
                    
                    // 关闭按钮
                    Button(action: {
                        if userSettings.hasUnappliedChanges() {
                            showUnsavedAlert = true
                        } else {
                            isVisible = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                
                // 设置内容
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        SettingItemView(
                            title: "时钟设置",
                            subtitle: "调整时钟显示格式和外观",
                            icon: "clock.fill"
                        ) {
                            showClockSettings = true
                        }
                        
                        SettingItemView(
                            title: "位置设置",
                            subtitle: "管理位置相关设置",
                            icon: "location.fill"
                        ) {
                            showLocationSettings = true
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                
                Spacer()
            }
            .frame(width: 850, height: 700)
            
            // 时钟设置子页面
            .sheet(isPresented: $showClockSettings) {
                ClockSettingsView()
            }
            
            // 位置设置子页面
            .sheet(isPresented: $showLocationSettings) {
                LocationSettingsView()
            }
        }
        .onAppear {
            userSettings.syncTempToCurrent()
        }
        .onDisappear {
            if userSettings.hasUnappliedChanges() {
                userSettings.resetTempToCurrent()
            }
        }
        // 未保存更改提醒对话框
        .alert("未保存的更改", isPresented: $showUnsavedAlert) {
            Button("取消", role: .cancel) {}
            Button("放弃更改", role: .destructive) {
                userSettings.resetTempToCurrent()
                isVisible = false
            }
            Button("保存更改") {
                userSettings.applyTempSettings()
                isVisible = false
            }
        } message: {
            Text("您有未保存的设置更改，请选择操作。")
        }
    }
}
```

```swift
import Foundation
import SwiftUI
import Combine

/// 用户设置管理器，用于持久化存储设置
class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    // 实际应用的设置值
    @Published var showSeconds: Bool = false {
        didSet {
            UserDefaults.standard.set(showSeconds, forKey: "showSeconds")
        }
    }
    
    @Published var showDate: Bool = false {
        didSet {
            UserDefaults.standard.set(showDate, forKey: "showDate")
        }
    }
    
    @Published var fontSize: CGFloat = 48 {
        didSet {
            UserDefaults.standard.set(Float(fontSize), forKey: "fontSize")
        }
    }
    
    @Published var is24HourFormat: Bool = true {
        didSet {
            UserDefaults.standard.set(is24HourFormat, forKey: "is24HourFormat")
        }
    }
    
    // 新增：时钟颜色设置
    @Published var clockColor: Color = .primary {
        didSet {
            // 将Color转换为Data进行存储
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(clockColor), requiringSecureCoding: false) {
                UserDefaults.standard.set(colorData, forKey: "clockColor")
            }
        }
    }
    
    // 临时设置值（用于预览更改）
    @Published var tempShowSeconds: Bool = false
    @Published var tempShowDate: Bool = false
    @Published var tempFontSize: CGFloat = 48
    @Published var tempIs24HourFormat: Bool = true
    @Published var tempClockColor: Color = .primary

    private init() {
        loadSettings()
        // 初始化临时值为当前设置值
        syncTempToCurrent()
    }
    
    /// 从UserDefaults加载设置
    private func loadSettings() {
        // 加载showSeconds设置
        showSeconds = UserDefaults.standard.bool(forKey: "showSeconds")
        
        // 加载showDate设置
        showDate = UserDefaults.standard.bool(forKey: "showDate")
        
        // 加载fontSize设置，确保默认值为48
        let savedFontSize = UserDefaults.standard.float(forKey: "fontSize")
        fontSize = CGFloat(savedFontSize) > 0 ? CGFloat(savedFontSize) : 48
        
        // 加载时间格式设置，默认为24小时制
        is24HourFormat = UserDefaults.standard.object(forKey: "is24HourFormat") as? Bool ?? true
        
        // 加载时钟颜色设置，默认为.primary
        if let colorData = UserDefaults.standard.data(forKey: "clockColor"),
           let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            clockColor = Color(uiColor)
        }
    }
    
    /// 重置为默认设置
    func resetToDefaults() {
        showSeconds = false
        showDate = false
        fontSize = 48
        is24HourFormat = true
        clockColor = .primary
        syncTempToCurrent()
    }
    
    /// 同步临时值到当前值
    func syncTempToCurrent() {
        tempShowSeconds = showSeconds
        tempShowDate = showDate
        tempFontSize = fontSize
        tempIs24HourFormat = is24HourFormat
        tempClockColor = clockColor
    }
    
    /// 应用临时设置
    func applyTempSettings() {
        showSeconds = tempShowSeconds
        showDate = tempShowDate
        fontSize = tempFontSize
        is24HourFormat = tempIs24HourFormat
        clockColor = tempClockColor
    }
    
    /// 重置临时值到当前值
    func resetTempToCurrent() {
        tempShowSeconds = showSeconds
        tempShowDate = showDate
        tempFontSize = fontSize
        tempIs24HourFormat = is24HourFormat
        tempClockColor = clockColor
    }
    
    /// 检查是否有未应用的更改
    func hasUnappliedChanges() -> Bool {
        return showSeconds != tempShowSeconds || 
               showDate != tempShowDate ||
               fontSize != tempFontSize || 
               is24HourFormat != tempIs24HourFormat ||
               !isColorEqual(clockColor, tempClockColor)
    }
}
```

## 使用方法

`SettingsView` 使用 `UserSettings.shared` 单例管理设置，无需传递参数：

```swift
struct ParentView: View {
    var body: some View {
        SettingsView()
    }
}
```

设置确认机制：
1. 临时值存储：所有修改先保存到临时属性（tempShowSeconds、tempShowDate、tempFontSize等）
2. 统一确认：确认按钮仅在总设置页面（SettingsView）提供
3. 状态保持：返回总设置页面时保留临时值，用户可在总页面确认或取消
4. 取消修改：直接关闭总设置页面会显示提醒，可选择保存、放弃或取消操作

日期显示设置使用示例：
```swift
// 在视图中使用日期显示设置
if UserSettings.shared.showDate {
    Text("今天是美好的一天")
}
```

## 功能特性

1. **时间格式设置**：支持24小时制时间显示
2. **时钟外观定制**：支持字体大小调节和时钟颜色自定义
3. **设置预览机制**：使用临时值实现实时预览，确认后应用更改
4. **统一确认流程**：仅在主设置页面提供确认按钮，避免重复确认
5. **未保存提醒**：未保存更改直接关闭时提醒用户选择操作
6. **状态同步**：视图出现时同步临时值，确保一致性
7. **日期显示控制**：支持显示或隐藏时钟中的日期信息