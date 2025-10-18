# 时钟设置组件 (ClockSettingsView)

## 功能说明

时钟设置组件允许用户自定义时钟的显示格式和外观，包括秒钟显示和字体大小。

## 实现细节

### 文件位置

```
dashboard/Components/ClockSettingsView.swift
```

### 技术实现

1. 使用 `@ObservedObject` 和 `UserSettings.shared` 管理全局设置状态
2. 使用临时设置值实现预览功能，不影响实际应用设置
3. 移除确认按钮：统一在总设置页面处理确认逻辑，避免重复确认
4. 使用 `Picker` 控件实现12/24小时制分段选择
5. 使用 `Toggle` 控件实现开关选项
6. 使用 `Slider` 控件实现数值调节
7. 智能状态同步：仅在无未应用更改时同步临时值，保持用户在总页面的未保存修改
8. 返回时状态保持：返回SettingsView时保留临时值，让总页面处理确认逻辑
9. 支持12/24小时制切换显示

### 代码结构

```swift
struct ClockSettingsView: View {
    @ObservedObject private var userSettings = UserSettings.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            // 标题栏
            HStack {
                // 返回按钮
                Button(action: {
                    if userSettings.hasUnappliedChanges() {
                        userSettings.resetTempToCurrent()
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text("时钟设置")
                
                Spacer()
                
                // 确认按钮
                Button(action: {
                    userSettings.applyTempSettings()
                }) {
                    Image(systemName: "checkmark")
                }
                .disabled(!userSettings.hasUnappliedChanges())
            }
            
            // 设置内容
            ScrollView {
                // 时间格式设置
                SectionView(title: "时间格式") {
                    Toggle(isOn: $userSettings.tempShowSeconds) {
                        HStack {
                            Image(systemName: "stopwatch")
                            Text("显示秒钟")
                        }
                    }
                }
                
                // 字体大小设置
                SectionView(title: "字体大小") {
                    HStack {
                        Text("大小: \(Int(userSettings.tempFontSize))")
                        
                        Spacer()
                        
                        Button(action: {
                            if userSettings.tempFontSize > 20 {
                                userSettings.tempFontSize -= 2
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                        }
                        .disabled(userSettings.tempFontSize <= 20)
                        
                        Button(action: {
                            if userSettings.tempFontSize < 80 {
                                userSettings.tempFontSize += 2
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(userSettings.tempFontSize >= 80)
                    }
                    
                    Slider(value: $userSettings.tempFontSize, in: 20...80, step: 2)
                }
            }
        }
        .onAppear {
            // 只有在没有未应用的更改时才同步临时值
            // 这样可以保持用户在总设置页面未保存的修改
            if !userSettings.hasUnappliedChanges() {
                userSettings.syncTempToCurrent()
            }
        }
    }
}
```

### 使用方法

`ClockSettingsView` 现在使用 `UserSettings.shared` 单例管理设置，无需传递参数：

```swift
struct ParentView: View {
    var body: some View {
        ClockSettingsView()
    }
}
```

设置确认机制（已更新）：
1. 临时值存储：所有修改先保存到临时属性（tempShowSeconds、tempFontSize）
2. 统一确认：确认按钮仅在总设置页面（SettingsView）提供
3. 状态保持：返回总设置页面时保留临时值，用户可在总页面确认或取消
4. 取消修改：直接关闭总设置页面会显示提醒，可选择保存、放弃或取消操作

## 功能特性

1. **时间格式切换**：支持12/24小时制切换，显示/隐藏秒钟
2. **字体大小调节**：提供滑块和按钮调节字体大小（20-80）
3. **临时值机制**：使用临时属性存储用户修改，支持预览效果
4. **确认应用**：只有点击确认按钮才会应用修改到实际设置
5. **智能状态跟踪**：自动检测是否有未应用的更改
6. **取消保护**：未点击确认直接关闭不会应用修改
7. **单例管理**：通过 UserSettings.shared 统一管理全局设置状态
8. **生命周期同步**：视图出现时同步临时值，确保一致性