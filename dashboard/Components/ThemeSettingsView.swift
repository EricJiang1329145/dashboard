//
//  ThemeSettingsView.swift
//  dashboard
//
//  Created by Assistant on 2025/10/16.
//

import SwiftUI

/// 主题设置视图 - 用于配置应用的主题显示选项
struct ThemeSettingsView: View {
    /// 观察UserSettings共享实例，用于管理用户设置
    @ObservedObject private var userSettings = UserSettings.shared
    
    /// 环境变量，用于控制模态视图的显示
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // 标题栏
                Text("主题设置")
                    .font(.system(size: 22, weight: .semibold))
                    .padding(.top)
                
                // 分隔线
                Divider()
                
                // 主题选择器
                SettingSectionView(title: "选择主题") {
                    Picker("主题模式", selection: $userSettings.tempTheme) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.displayName)
                                .tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 8)
                }
                
                // 主题说明
                VStack(alignment: .leading, spacing: 8) {
                    Text("主题说明")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("跟随系统：应用将根据系统设置自动切换深色/浅色模式")
                        .font(.system(size: 14))
                    
                    Text("深色：应用将始终使用深色模式，无论系统设置如何")
                        .font(.system(size: 14))
                    
                    Text("浅色：应用将始终使用浅色模式，无论系统设置如何")
                        .font(.system(size: 14))
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .onAppear {
                // 当视图出现时，同步当前值到临时值
                userSettings.syncTempToCurrent()
            }
            .onDisappear {
                // 当视图消失时，不自动应用更改，而是等待用户在主设置页面确认
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(maxWidth: 600, maxHeight: 500)
    }
}

#Preview {
    ThemeSettingsView()
}