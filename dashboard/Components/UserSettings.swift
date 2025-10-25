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
    
    @Published var showDate: Bool = false {
        didSet {
            UserDefaults.standard.set(showDate, forKey: "showDate")
        }
    }
    
    @Published var showLocation: Bool = false {
        didSet {
            UserDefaults.standard.set(showLocation, forKey: "showLocation")
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
    
    // 新增：时钟颜色设置
    @Published var clockColor: Color = .primary {
        didSet {
            // 将Color转换为Data进行存储
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(clockColor), requiringSecureCoding: false) {
                UserDefaults.standard.set(colorData, forKey: "clockColor")
            }
        }
    }
    
    // 新增：位置信息颜色设置
    @Published var locationColor: Color = .primary {
        didSet {
            // 将Color转换为Data进行存储
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(locationColor), requiringSecureCoding: false) {
                UserDefaults.standard.set(colorData, forKey: "locationColor")
            }
        }
    }
    
    // 新增：显示天气设置
    @Published var showWeather: Bool = true {
        didSet {
            UserDefaults.standard.set(showWeather, forKey: "showWeather")
        }
    }
    
    // 新增：天气颜色设置
    @Published var weatherColor: Color = .primary {
        didSet {
            // 将Color转换为Data进行存储
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(weatherColor), requiringSecureCoding: false) {
                UserDefaults.standard.set(colorData, forKey: "weatherColor")
            }
        }
    }
    

    
    // 临时设置值（用于预览更改）
    @Published var tempShowSeconds: Bool = false
    @Published var tempShowDate: Bool = false
    @Published var tempShowLocation: Bool = false
    @Published var tempShowWeather: Bool = false
    @Published var tempFontSize: CGFloat = 48
    @Published var tempIs24HourFormat: Bool = true
    @Published var tempClockColor: Color = .primary
    @Published var tempLocationColor: Color = .primary
    @Published var tempWeatherColor: Color = .primary
    
    private init() {
        loadSettings()
        // 初始化临时值为当前设置值
        syncTempToCurrent()
    }
    
    /// 从UserDefaults加载设置
    private func loadSettings() {
        // 加载showSeconds设置
        showSeconds = UserDefaults.standard.bool(forKey: "showSeconds")
        
        // 加载showDate设置
        showDate = UserDefaults.standard.bool(forKey: "showDate")
        
        // 加载showLocation设置
        showLocation = UserDefaults.standard.bool(forKey: "showLocation")
        
        // 加载fontSize设置，确保默认值为48
        let savedFontSize = UserDefaults.standard.float(forKey: "fontSize")
        fontSize = CGFloat(savedFontSize) > 0 ? CGFloat(savedFontSize) : 48
        
        // 加载时间格式设置，默认为24小时制
        is24HourFormat = UserDefaults.standard.object(forKey: "is24HourFormat") as? Bool ?? true
        
        // 加载时钟颜色设置，默认为.primary
        if let colorData = UserDefaults.standard.data(forKey: "clockColor"),
           let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            clockColor = Color(uiColor)
        }
        
        // 加载位置颜色设置，默认为.primary
        if let colorData = UserDefaults.standard.data(forKey: "locationColor"),
           let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            locationColor = Color(uiColor)
        }
        
        // 加载显示天气设置，如果没有保存值则默认为true
        showWeather = UserDefaults.standard.object(forKey: "showWeather") as? Bool ?? true
        
        // 加载天气颜色设置，默认为.primary
        if let colorData = UserDefaults.standard.data(forKey: "weatherColor"),
           let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            weatherColor = Color(uiColor)
        }
    }
    
    /// 重置为默认设置
    func resetToDefaults() {
        showSeconds = false
        showDate = false
        showLocation = false
        showWeather = false
        fontSize = 48
        is24HourFormat = true
        clockColor = .primary
        locationColor = .primary
        weatherColor = .primary
        syncTempToCurrent()
    }
    
    /// 同步临时值到当前值
    func syncTempToCurrent() {
        tempShowSeconds = showSeconds
        tempShowDate = showDate
        tempShowLocation = showLocation
        tempShowWeather = showWeather
        tempFontSize = fontSize
        tempIs24HourFormat = is24HourFormat
        tempClockColor = clockColor
        tempLocationColor = locationColor
        tempWeatherColor = weatherColor
    }
    
    /// 应用临时设置
    func applyTempSettings() {
        showSeconds = tempShowSeconds
        showDate = tempShowDate
        showLocation = tempShowLocation
        showWeather = tempShowWeather
        fontSize = tempFontSize
        is24HourFormat = tempIs24HourFormat
        clockColor = tempClockColor
        locationColor = tempLocationColor
        weatherColor = tempWeatherColor
    }
    
    /// 重置临时值到当前值
    func resetTempToCurrent() {
        tempShowSeconds = showSeconds
        tempShowDate = showDate
        tempShowLocation = showLocation
        tempShowWeather = showWeather
        tempFontSize = fontSize
        tempIs24HourFormat = is24HourFormat
        tempClockColor = clockColor
        tempLocationColor = locationColor
        tempWeatherColor = weatherColor
    }
    
    /// 检查是否有未应用的更改
    func hasUnappliedChanges() -> Bool {
        return showSeconds != tempShowSeconds || 
               showDate != tempShowDate ||
               showLocation != tempShowLocation ||
               showWeather != tempShowWeather ||
               fontSize != tempFontSize || 
               is24HourFormat != tempIs24HourFormat ||
               !isColorEqual(clockColor, tempClockColor) ||
               !isColorEqual(locationColor, tempLocationColor) ||
               !isColorEqual(weatherColor, tempWeatherColor)
    }
    
    /// 比较两个Color是否相等（Color不直接支持==比较）
    private func isColorEqual(_ color1: Color, _ color2: Color) -> Bool {
        // 转换为UIColor进行比较
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return r1 == r2 && g1 == g2 && b1 == b2 && a1 == a2
    }
}