//
//  LocationSettingsView.swift
//  dashboard
//
//  Created by Assistant on 2025/10/15.
//

import SwiftUI

/// 位置设置视图 - 用于管理和配置位置显示相关的设置
struct LocationSettingsView: View {
    /// 观察UserSettings共享实例，用于管理用户设置
    @ObservedObject private var userSettings = UserSettings.shared
    
    var body: some View {
        NavigationView {
            // 设置内容区域 - 使用滚动视图包含设置项
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 位置显示开关
                    SettingToggleItemView(
                        title: "显示位置信息",
                        isOn: $userSettings.tempShowLocation
                    )
                    
                    // 位置信息颜色选择器
                    SettingColorPickerItemView(
                        title: "位置信息颜色",
                        selectedColor: $userSettings.tempLocationColor
                    )
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("位置设置")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

/// 设置开关项视图 - 用于显示带开关的设置项
struct SettingToggleItemView: View {
    /// 设置项标题
    let title: String
    
    /// 绑定开关状态
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle())
        }
        .padding()
        .background(
            Color(.systemGray6)
                .opacity(0.5)
        )
        .cornerRadius(12)
    }
}

/// 设置颜色选择器项视图 - 用于显示带颜色选择器的设置项
struct SettingColorPickerItemView: View {
    /// 设置项标题
    let title: String
    
    /// 绑定选中的颜色
    @Binding var selectedColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(.primary)
            
            ColorPicker("选择颜色", selection: $selectedColor)
                .labelsHidden()
        }
        .padding()
        .background(
            Color(.systemGray6)
                .opacity(0.5)
        )
        .cornerRadius(12)
    }
}

#Preview {
    LocationSettingsView()
}