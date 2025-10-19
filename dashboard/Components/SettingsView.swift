//
//  SettingsView.swift
//  dashboard
//
//  Created by Eric Jiang on 2025/10/12.
//

import SwiftUI

/// 设置页面视图 - 主要用于显示和管理应用的各种设置选项
struct SettingsView: View {
    /// 绑定属性，控制设置页面是否可见
    @Binding var isVisible: Bool
    
    /// 观察UserSettings共享实例，用于管理用户设置
    @ObservedObject private var userSettings = UserSettings.shared
    
    /// 状态变量，控制时钟设置子页面是否显示
    @State private var showClockSettings = false
    
    /// 状态变量，控制位置设置子页面是否显示
    @State private var showLocationSettings = false
    
    /// 状态变量，控制未保存更改提醒对话框是否显示
    @State private var showUnsavedAlert = false
    
    var body: some View {
        ZStack {
            // 设置页面背景，带有圆角效果
            // 使用RoundedRectangle创建圆角矩形背景
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))  // 填充系统背景色
                .frame(width: 850, height: 700)  // 设置固定宽度和高度
                .shadow(radius: 10)  // 添加阴影效果
                
                // 垂直堆栈布局，包含标题栏和内容区域
                VStack(spacing: 0) {
                    // 设置页面标题栏 - 包含标题和操作按钮
                    HStack {
                        Spacer()  // 左侧留空
                        
                        // 设置页面标题文本
                        Text("设置")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Spacer()  // 中间留空
                        
                        // 确认按钮 - 用于保存设置更改
                        Button(action: {
                            // 应用临时设置值到实际设置
                            userSettings.applyTempSettings()
                        }) {
                            Image(systemName: "checkmark")  // 对勾图标
                                .font(.system(size: 18, weight: .medium))
                                // 根据是否有未应用的更改来设置按钮颜色
                                .foregroundColor(userSettings.hasUnappliedChanges() ? .white : .gray)
                                .padding(8)
                                // 根据是否有未应用的更改来设置按钮背景色
                                .background(
                                    (userSettings.hasUnappliedChanges() ? Color.blue : Color(.systemGray6))
                                )
                                .clipShape(Circle())  // 裁剪为圆形
                        }
                        .buttonStyle(PlainButtonStyle())  // 使用平面按钮样式
                        .disabled(!userSettings.hasUnappliedChanges())  // 如果没有未应用的更改则禁用按钮
                        
                        // 关闭按钮 - 用于关闭设置页面
                        Button(action: {
                            // 检查是否有未保存的更改
                            if userSettings.hasUnappliedChanges() {
                                // 显示未保存更改提醒对话框
                                showUnsavedAlert = true
                            } else {
                                // 直接关闭设置页面
                                isVisible = false
                            }
                        }) {
                            Image(systemName: "xmark")  // 叉号图标
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)  // 设置前景色
                                .padding(8)
                                .background(
                                    Color(.systemGray6)  // 设置背景色
                                )
                                .clipShape(Circle())  // 裁剪为圆形
                        }
                        .buttonStyle(PlainButtonStyle())  // 使用平面按钮样式
                    }
                    .padding()  // 添加内边距
                    
                    // 设置内容区域 - 使用滚动视图包含设置项
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // 时钟设置入口 - 点击可进入时钟设置子页面
                            SettingItemView(
                                title: "时钟设置",  // 设置项标题
                                subtitle: "调整时钟显示格式和外观",  // 设置项副标题
                                icon: "clock.fill"  // 设置项图标
                            ) {
                                // 点击时显示时钟设置子页面
                                showClockSettings = true
                            }
                            
                            // 位置设置入口 - 点击可进入位置设置子页面
                            SettingItemView(
                                title: "位置设置",  // 设置项标题
                                subtitle: "调整位置信息显示格式和外观",  // 设置项副标题
                                icon: "location.fill"  // 设置项图标
                            ) {
                                // 点击时显示位置设置子页面
                                showLocationSettings = true
                            }
                            
                            Spacer()  // 底部留空
                        }
                        .padding()  // 添加内边距
                    }
                    
                    Spacer()  // 底部留空
                }
                .frame(width: 850, height: 700)  // 设置固定宽度和高度，与背景保持一致
            }
            // 时钟设置子页面 - 以模态页面形式显示
            .sheet(isPresented: $showClockSettings) {
                ClockSettingsView()  // 显示时钟设置视图
            }
            
            // 位置设置子页面 - 以模态页面形式显示
            .sheet(isPresented: $showLocationSettings) {
                LocationSettingsView()  // 显示位置设置视图
            }
            // 监听时钟设置页面的返回
            .onChange(of: showClockSettings) {
                if !showClockSettings {
                    // 时钟设置页面关闭时，SettingsView的确认按钮状态会自动更新
                    // 因为UserSettings.shared的hasUnappliedChanges()会反映最新的临时值状态
                }
            }
            
            // 监听位置设置页面的返回
            .onChange(of: showLocationSettings) {
                if !showLocationSettings {
                    // 位置设置页面关闭时，SettingsView的确认按钮状态会自动更新
                    // 因为UserSettings.shared的hasUnappliedChanges()会反映最新的临时值状态
                }
            }
        .onAppear {
            // 当视图出现时，同步临时值到当前值
            // 这确保了设置页面显示的是最新的设置值
            userSettings.syncTempToCurrent()
        }
        .onDisappear {
            // 当视图消失时，检查是否有关闭时未应用的更改
            if userSettings.hasUnappliedChanges() {
                // 重置临时值到当前值，放弃未保存的更改
                userSettings.resetTempToCurrent()
            }
        }
        // 未保存更改提醒对话框
        .alert("未保存的更改", isPresented: $showUnsavedAlert) {
            // 取消按钮 - 不执行任何操作，保持设置页面打开
            Button("取消", role: .cancel) {
                // 不关闭设置页面
            }
            // 放弃更改按钮 - 重置临时值并关闭设置页面
            Button("放弃更改", role: .destructive) {
                // 重置临时值并关闭设置页面
                userSettings.resetTempToCurrent()
                isVisible = false
            }
            // 保存更改按钮 - 应用更改并关闭设置页面
            Button("保存更改") {
                // 应用更改并关闭设置页面
                userSettings.applyTempSettings()
                isVisible = false
            }
        } message: {
            // 对话框消息内容
            Text("您有未保存的设置更改，请选择操作。")
        }
    }
}

/// 设置项视图 - 用于显示单个设置项的通用组件
struct SettingItemView: View {
    /// 设置项标题
    let title: String
    
    /// 设置项副标题（描述）
    let subtitle: String
    
    /// 设置项图标名称
    let icon: String
    
    /// 设置项点击操作回调
    let action: () -> Void
    
    var body: some View {
        // 按钮包装器，处理点击事件
        Button(action: action) {
            // 水平堆栈布局，包含图标、文本和指示箭头
            HStack(spacing: 15) {
                // 设置项图标
                Image(systemName: icon)
                    .font(.system(size: 24))  // 设置图标大小
                    .foregroundColor(.blue)    // 设置图标颜色
                    .frame(width: 30)          // 设置图标宽度
                
                // 垂直堆栈布局，包含标题和副标题
                VStack(alignment: .leading, spacing: 4) {
                    // 设置项标题
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))  // 设置字体样式
                        .foregroundColor(.primary)                   // 设置文字颜色
                
                    // 设置项副标题
                    Text(subtitle)
                        .font(.system(size: 14))       // 设置字体样式
                        .foregroundColor(.secondary)   // 设置文字颜色
                }
                
                Spacer()  // 中间留空
                
                // 指示箭头图标 - 表示该项可点击进入子页面
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))  // 设置图标大小
                    .foregroundColor(.secondary)               // 设置图标颜色
            }
            .padding()  // 添加内边距
            // 设置项背景 - 使用半透明灰色背景
            .background(
                Color(.systemGray6)
                    .opacity(0.5)
            )
            .cornerRadius(12)  // 设置圆角
        }
        .buttonStyle(PlainButtonStyle())  // 使用平面按钮样式
    }
}

#Preview {
    SettingsView(isVisible: .constant(true))
}