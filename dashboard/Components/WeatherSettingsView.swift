//
//  WeatherSettingsView.swift
//  dashboard
//
//  Created by Assistant on 2025/10/16.
//

import SwiftUI

/// 天气设置视图 - 用于配置天气组件的显示选项
struct WeatherSettingsView: View {
    /// 观察UserSettings共享实例，用于管理用户设置
    @ObservedObject private var userSettings = UserSettings.shared
    
    /// 环境变量，用于控制模态视图的显示
    @Environment(\.presentationMode) var presentationMode
    
    /// 状态变量，用于临时存储颜色选择器的颜色
    @State private var colorPickerColor: Color = .primary
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // 标题栏
                Text("天气设置")
                    .font(.system(size: 22, weight: .semibold))
                    .padding(.top)
                
                // 分隔线
                Divider()
                
                // 显示天气选项
                Toggle(isOn: $userSettings.tempShowWeather) {
                    Text("显示天气")
                        .font(.system(size: 16))
                }
                .padding(.vertical, 8)
                
                // 天气颜色设置
                SettingSectionView(title: "天气颜色") {
                    ColorPicker(
                        "选择颜色", 
                        selection: $colorPickerColor,
                        supportsOpacity: true
                    )
                    .padding(.vertical, 8)
                    .onChange(of: colorPickerColor) {
                        // 更新临时颜色设置
                        userSettings.tempWeatherColor = colorPickerColor
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .onAppear {
                // 当视图出现时，同步当前值到临时值
                userSettings.syncTempToCurrent()
                // 设置颜色选择器的初始颜色
                colorPickerColor = userSettings.tempWeatherColor
            }
            .onDisappear {
                // 当视图消失时，不自动应用更改，而是等待用户在主设置页面确认
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(maxWidth: 600, maxHeight: 500)
    }
}

/// 设置部分视图 - 用于显示设置项的分组
struct SettingSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            content
        }
    }
}

#Preview {
    WeatherSettingsView()
}