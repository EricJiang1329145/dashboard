# 设置组件 (SettingsView)

## 功能说明

设置组件提供了一个用户界面，允许用户自定义应用程序的各种设置。目前支持时钟相关的设置选项。

## 实现细节

### 文件位置

```
dashboard/Components/SettingsView.swift     # 主设置页面
dashboard/Components/ClockSettingsView.swift # 时钟设置子页面
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

### 代码结构

```swift
struct SettingsView: View {
    @Binding var isVisible: Bool
    @ObservedObject private var userSettings = UserSettings.shared
    @State private var showClockSettings = false
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

## 使用方法

设置组件通过 `ContentView` 调用，使用共享的UserSettings实例：

```swift
@ObservedObject private var userSettings = UserSettings.shared

SettingsView(isVisible: $isSettingsVisible)
```

设置确认机制：
- 所有设置修改都存储在临时值中（tempShowSeconds, tempFontSize）
- 只有点击确认按钮才会将临时值应用到实际设置
- 如果直接关闭设置页面而未点击确认，修改将不会被应用

## 功能特性

1. **统一设置管理**：通过UserSettings.shared单例管理所有设置
2. **子页面导航**：提供时钟设置等子页面的入口
3. **临时值机制**：使用临时属性存储用户修改，支持预览效果
4. **统一确认机制**：仅在总设置页面提供确认功能（蓝色背景），移除子页面确认按钮
5. **智能状态跟踪**：自动检测是否有未应用的更改
6. **未保存退出提醒**：提供取消、放弃更改、保存更改三个选项
7. **取消保护**：未点击确认直接关闭不会应用修改
8. **生命周期同步**：视图出现时同步临时值，确保一致性
9. **数据持久化**：设置项保存在UserDefaults中，不随应用关闭而重置
10. **24小时制显示**：仅支持24小时制时间显示
11. **无背景覆盖层**：删除了设置页面的半透明黑色背景覆盖层，使设置页面更加简洁
12. **详细注释**：为SettingsView添加了详细的中文注释，便于理解和维护
116| ```