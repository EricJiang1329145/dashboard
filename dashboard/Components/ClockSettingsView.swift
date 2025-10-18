//
//  ClockSettingsView.swift
//  dashboard
//
//  Created by Assistant on 2025/10/13.
//

import SwiftUI

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
            
            content
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Color(.systemGray6)
                        .opacity(0.5)
                        .glassEffect(.regular)
                )
                .cornerRadius(12)
        }
    }
}

#Preview {
    ClockSettingsView()
}