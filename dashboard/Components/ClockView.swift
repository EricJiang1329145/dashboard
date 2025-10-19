//
//  ClockView.swift
//  dashboard
//
//  Created by Eric Jiang on 2025/10/12.
//

import SwiftUI
import Combine

/// 简约数字时钟视图
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
    
    init(showSeconds: Binding<Bool>, fontSize: Binding<CGFloat>, is24HourFormat: Binding<Bool>, clockColor: Binding<Color>) {
        self._showSeconds = showSeconds
        self._fontSize = fontSize
        self._is24HourFormat = is24HourFormat
        self._clockColor = clockColor
    }
    
    // 默认初始化方法，用于预览
    init() {
        self._showSeconds = Binding.constant(false)
        self._fontSize = Binding.constant(48)
        self._is24HourFormat = Binding.constant(true)
        self._clockColor = Binding.constant(.primary)
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
                    .foregroundColor(clockColor == .primary ? .gray : clockColor.opacity(0.7)) // 自定义颜色时降低透明度
                    .padding(.leading, 4)
                    .alignmentGuide(.top) { _ in 0 } // 与时间顶部对齐
                    .offset(y: -fontSize * 0.25) // 向上偏移，靠上对齐
            }
        }
        .padding(20)
        .glassEffect(.regular) // 使用Liquid Glass效果替代传统的半透明背景
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    /// 格式化小时显示
    private func formatHour(_ date: Date) -> String {
        if is24HourFormat {
            return Self.hour24Formatter.string(from: date)
        } else {
            return Self.hour12Formatter.string(from: date)
        }
    }
    
    /// 格式化分钟显示
    private func formatMinute(_ date: Date) -> String {
        return Self.minuteFormatter.string(from: date)
    }
    
    /// 格式化秒钟显示
    private func formatSecond(_ date: Date) -> String {
        return Self.secondFormatter.string(from: date)
    }
    
    /// 格式化AM/PM显示
    private func formatAmPm(_ date: Date) -> String {
        return Self.amPmFormatter.string(from: date).uppercased()
    }
}

#Preview {
    ClockView()
}