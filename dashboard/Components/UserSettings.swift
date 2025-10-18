//
//  UserSettings.swift
//  dashboard
//
//  Created by Assistant on 2025/10/14.
//

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
    
    // 临时设置值（用于预览更改）
    @Published var tempShowSeconds: Bool = false
    @Published var tempFontSize: CGFloat = 48
    @Published var tempIs24HourFormat: Bool = true
    
    private init() {
        loadSettings()
        // 初始化临时值为当前设置值
        syncTempToCurrent()
    }
    
    /// 从UserDefaults加载设置
    private func loadSettings() {
        // 加载showSeconds设置
        showSeconds = UserDefaults.standard.bool(forKey: "showSeconds")
        
        // 加载fontSize设置，确保默认值为48
        let savedFontSize = UserDefaults.standard.float(forKey: "fontSize")
        fontSize = CGFloat(savedFontSize) > 0 ? CGFloat(savedFontSize) : 48
        
        // 加载时间格式设置，默认为24小时制
        is24HourFormat = UserDefaults.standard.object(forKey: "is24HourFormat") as? Bool ?? true
    }
    
    /// 重置为默认设置
    func resetToDefaults() {
        showSeconds = false
        fontSize = 48
        is24HourFormat = true
        syncTempToCurrent()
    }
    
    /// 同步临时值到当前值
    func syncTempToCurrent() {
        tempShowSeconds = showSeconds
        tempFontSize = fontSize
        tempIs24HourFormat = is24HourFormat
    }
    
    /// 应用临时设置
    func applyTempSettings() {
        showSeconds = tempShowSeconds
        fontSize = tempFontSize
        is24HourFormat = tempIs24HourFormat
    }
    
    /// 重置临时值到当前值
    func resetTempToCurrent() {
        tempShowSeconds = showSeconds
        tempFontSize = fontSize
        tempIs24HourFormat = is24HourFormat
    }
    
    /// 检查是否有未应用的更改
    func hasUnappliedChanges() -> Bool {
        return showSeconds != tempShowSeconds || fontSize != tempFontSize || is24HourFormat != tempIs24HourFormat
    }
}