//
//  ClockSettingsView.swift
//  dashboard
//
//  Created by Assistant on 2025/10/13.
//

import SwiftUI

/// 颜色按钮组件，用于选择预设颜色
struct ColorButton: View {
    var color: Color
    var label: String
    @Binding var selectedColor: Color
    
    // 判断颜色是否相等的辅助方法
    private func isSelected() -> Bool {
        // 对于.primary颜色的特殊处理
        if color == .primary && selectedColor == .primary {
            return true
        }
        
        // 转换为UIColor进行比较
        let uiColor1 = UIColor(color)
        let uiColor2 = UIColor(selectedColor)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return r1 == r2 && g1 == g2 && b1 == b2 && a1 == a2
    }
    
    var body: some View {
        VStack {
            Button(action: {
                selectedColor = color
            }) {
                Circle()
                    .fill(color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        isSelected() ? 
                            Circle().stroke(Color.white, lineWidth: 3) // 选中状态边框
                                .shadow(radius: 2)
                            : nil
                    )
                    .padding(4)
                    .background(isSelected() ? Color.blue : Color.clear)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
    }
}

/// 时钟设置子页面
struct ClockSettingsView: View {
    @ObservedObject private var userSettings = UserSettings.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Button(action: {
                    // 返回时不重置临时值，让SettingsView处理确认逻辑
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text("时钟设置")
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                // 移除确认按钮，统一在SettingsView中处理
            }
            .padding()
            .background(Color(.systemGray6))
            
            // 设置内容区域
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 时间格式设置
                    SectionView(title: "时间格式") {
                        VStack(alignment: .leading, spacing: 20) {
                            // 时间格式分段选择器
                            Picker("时间格式", selection: $userSettings.tempIs24HourFormat) {
                                Text("24小时制").tag(true)
                                Text("12小时制").tag(false)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(maxWidth: .infinity * 0.85)
                            
                            // 秒钟显示开关
                            Toggle(isOn: $userSettings.tempShowSeconds) {
                                HStack {
                                    Image(systemName: "stopwatch")
                                        .foregroundColor(.blue)
                                    Text("显示秒钟")
                                        .font(.system(size: 16))
                                }
                            }
                            
                            // 日期显示开关
                            Toggle(isOn: $userSettings.tempShowDate) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                    Text("显示日期")
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity * 0.85, alignment: .leading)  // 限制宽度为85%
                    }
                    
                    // 字体大小设置
                    SectionView(title: "字体大小") {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("大小: \(Int(userSettings.tempFontSize))")
                                    .font(.system(size: 16))
                                
                                Spacer()
                                
                                Button(action: {
                                    if userSettings.tempFontSize > 20 {
                                        userSettings.tempFontSize -= 2
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                }
                                .disabled(userSettings.tempFontSize <= 20)
                                
                                Button(action: {
                                    if userSettings.tempFontSize < 80 {
                                        userSettings.tempFontSize += 2
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                }
                                .disabled(userSettings.tempFontSize >= 80)
                            }
                            
                            Slider(value: $userSettings.tempFontSize, in: 20...80, step: 2)
                                .accentColor(.blue)
                        }
                    }
                    
                    // 新增：时钟颜色设置
                    SectionView(title: "时钟颜色") {
                        VStack(alignment: .leading, spacing: 15) {
                            // 预设颜色选择器
                            Text("预设颜色:")
                                .font(.system(size: 16))
                            
                            HStack(spacing: 12) {
                                // 主要颜色（跟随系统）
                                ColorButton(color: .primary, label: "默认", selectedColor: $userSettings.tempClockColor)
                                
                                // 常用颜色选项
                                ColorButton(color: .red, label: "红色", selectedColor: $userSettings.tempClockColor)
                                ColorButton(color: .blue, label: "蓝色", selectedColor: $userSettings.tempClockColor)
                                ColorButton(color: .green, label: "绿色", selectedColor: $userSettings.tempClockColor)
                                ColorButton(color: .orange, label: "橙色", selectedColor: $userSettings.tempClockColor)
                                ColorButton(color: .purple, label: "紫色", selectedColor: $userSettings.tempClockColor)
                            }
                            .padding(.vertical, 8)
                            
                            // 自定义颜色选择器（iOS 14及以上）
                            Group {
                                Text("自定义颜色:")
                                    .font(.system(size: 16))
                                    .padding(.top, 8)
                                
                                ColorPicker("选择颜色", selection: $userSettings.tempClockColor, supportsOpacity: false)
                                    .padding(.top, 4)
                            }
                        }
                        .frame(maxWidth: .infinity * 0.85, alignment: .leading)  // 限制宽度为85%
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
            Spacer()
        }
        .frame(width: 700, height: 600)  // 稍微缩小宽度
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .onAppear {
            // 只有在没有未应用的更改时才同步临时值
            // 这样可以保持用户在总设置页面未保存的修改
            if !userSettings.hasUnappliedChanges() {
                userSettings.syncTempToCurrent()
            }
        }
    }
}

/// 设置项容器视图
struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .glassEffect(.regular)
                .cornerRadius(8)
            
            content
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Color(.systemGray6)
                        .opacity(0.5)
                )
                .cornerRadius(12)
        }
    }
}

#Preview {
    ClockSettingsView()
}