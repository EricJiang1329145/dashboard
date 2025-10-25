//
//  WeatherView.swift
//  dashboard
//
//  Created by Assistant on 2025/10/16.
//

import SwiftUI
import Combine
import CoreLocation

/// 显示天气信息的视图组件
struct WeatherView: View {
    @State private var weatherService = WeatherService()
    @State private var locationManager = LocationManager()
    @Binding var showWeather: Bool
    @Binding var fontSize: CGFloat
    @Binding var weatherColor: Color
    
    var body: some View {
        if showWeather {
            // 调试日志：显示组件正在渲染
            let _ = print("WeatherView rendering - showWeather: true")
            VStack(spacing: 8) {
                Text("当前天气")
                    .font(.system(size: fontSize * 0.4, weight: .medium, design: .rounded))
                    .foregroundColor(weatherColor == .primary ? .gray : weatherColor.opacity(0.7))
                
                HStack(alignment: .center, spacing: 12) {
                    // 天气图标
                    Image(systemName: weatherIcon())
                        .font(.system(size: fontSize * 0.8))
                        .foregroundColor(weatherColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // 温度显示
                        Text(weatherService.temperature)
                            .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                            .foregroundColor(weatherColor)
                        
                        // 天气描述
                        Text(weatherService.weatherDescription)
                            .font(.system(size: fontSize * 0.4, weight: .medium, design: .monospaced))
                            .foregroundColor(weatherColor == .primary ? .gray : weatherColor.opacity(0.7))
                    }
                }
                
                // 加载指示器或错误提示
                if weatherService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: weatherColor.opacity(0.7)))
                        .scaleEffect(0.8)
                } else if let errorMessage = weatherService.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: fontSize * 0.35, weight: .medium, design: .monospaced))
                        .foregroundColor(.red.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(15)
            .glassEffect(.regular)
            .onTapGesture {
                // 点击天气组件时重新获取天气数据
                requestWeatherData()
            }
            .onAppear {
                // 组件出现时获取天气数据
                requestWeatherData()
            }
            .onReceive(locationManager.$latitudeString) { _ in
                // 当位置更新时，重新获取天气数据
                requestWeatherData()
            }
        }
    }
    
    /// 根据天气描述返回对应的SF Symbols图标
    private func weatherIcon() -> String {
        let description = weatherService.weatherDescription.lowercased()
        
        // 根据天气描述返回对应的图标
        if description.contains("晴") || description.contains("clear") {
            return "sun.max.fill"
        } else if description.contains("云") || description.contains("cloud") {
            if description.contains("小雨") || description.contains("light rain") {
                return "cloud.drizzle.fill"
            } else if description.contains("雨") || description.contains("rain") {
                return "cloud.rain.fill"
            }
            return "cloud.fill"
        } else if description.contains("雨") || description.contains("rain") {
            return "cloud.rain.fill"
        } else if description.contains("雪") || description.contains("snow") {
            return "cloud.snow.fill"
        } else if description.contains("雾") || description.contains("fog") || description.contains("霾") {
            return "cloud.fog.fill"
        } else if description.contains("雷") || description.contains("thunder") {
            return "cloud.bolt.rain.fill"
        }
        
        // 默认图标
        return "cloud.sun.fill"
    }
    
    /// 请求天气数据
    private func requestWeatherData() {
        // 调试日志：请求天气数据
        print("WeatherView - requestWeatherData called")
        print("WeatherView - Location: lat=\(locationManager.latitudeString), lon=\(locationManager.longitudeString)")
        
        // 尝试将经纬度字符串转换为Double
        guard let latitude = Double(locationManager.latitudeString),
              let longitude = Double(locationManager.longitudeString),
              // 确保经纬度在有效范围内
              latitude >= -90 && latitude <= 90,
              longitude >= -180 && longitude <= 180 else {
            // 调试日志：无效的位置信息
                print("WeatherView - Invalid location data")
                weatherService.errorMessage = "无效的位置信息"
                weatherService.temperature = "--"
                weatherService.weatherDescription = "无法获取天气数据"
                return
        }
        
        // 调用天气服务获取数据
        weatherService.fetchWeather(latitude: latitude, longitude: longitude)
    }
}

#Preview {
    WeatherView(
        showWeather: .constant(true),
        fontSize: .constant(48),
        weatherColor: .constant(.primary)
    )
}