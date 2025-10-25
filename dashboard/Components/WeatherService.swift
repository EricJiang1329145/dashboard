//
//  WeatherService.swift
//  dashboard
//
//  Created by Assistant on 2025/10/16.
//

import Foundation
import Combine

/// 天气数据模型
struct WeatherData: Decodable {
    let current: CurrentWeather
}

/// 当前天气数据模型
struct CurrentWeather: Decodable {
    let temp: Double
    let weather: [WeatherCondition]
}

/// 天气条件模型
struct WeatherCondition: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

/// 天气服务错误枚举
enum WeatherError: Error {
    case networkError(Error)
    case decodingError
    case noData
    case invalidURL
    case apiError(String)
}

/// 天气服务类，负责与OpenWeatherMap API交互
class WeatherService: ObservableObject {
    private let apiKey = "a3ef445d2ad583ddeff1f816bc921057"
    private let baseURL = "https://api.openweathermap.org/data/3.0/onecall"
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var temperature: String = "--"
    @Published var weatherDescription: String = "暂无天气信息"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    /// 根据经纬度获取天气数据
    func fetchWeather(latitude: Double, longitude: Double) {
        // 调试日志：开始获取天气数据
        print("WeatherService - fetchWeather called with lat: \(latitude), lon: \(longitude)")
        
        isLoading = true
        errorMessage = nil
        
        // 构建URL
        guard var components = URLComponents(string: baseURL) else {
            self.handleError(WeatherError.invalidURL)
            return
        }
        
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "units", value: "metric"), // 使用摄氏度
            URLQueryItem(name: "lang", value: "zh_cn"),  // 使用中文
            URLQueryItem(name: "exclude", value: "minutely,hourly,daily,alerts"), // 只获取当前天气
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = components.url else {
            self.handleError(WeatherError.invalidURL)
            return
        }
        
        // 调试日志：请求URL
        print("WeatherService - Request URL: \(url.absoluteString)")
        
        // 发起网络请求
        session.dataTaskPublisher(for: url)
            .map { result -> Data in
                // 调试日志：收到响应
                print("WeatherService - Received response")
                return result.data
            }
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .finished:
                    // 调试日志：请求成功完成
                    print("WeatherService - Request succeeded")
                    break
                case .failure(let error):
                    // 调试日志：请求失败
                    print("WeatherService - Request failed with error: \(error)")
                    self?.errorMessage = "获取天气数据失败: \(error.localizedDescription)"
                    self?.temperature = "--"
                    self?.weatherDescription = "无法连接到天气服务"
                }
            }, receiveValue: { [weak self] weatherData in
                // 调试日志：解析到天气数据
                print("WeatherService - Successfully parsed weather data")
                // 解析并更新天气数据
                // 直接在这里处理数据更新
                self?.temperature = "\(Int(weatherData.current.temp))°"
                self?.weatherDescription = weatherData.current.weather.first?.description ?? "未知"
                print("WeatherService - Updated temperature: \(self?.temperature ?? "--")")
                print("WeatherService - Updated description: \(self?.weatherDescription ?? "未知")")
            })
            .store(in: &cancellables)
    }
    
    /// 更新天气数据到发布的属性
    private func updateWeatherData(_ data: WeatherData) {
        // 格式化温度，保留一位小数
        temperature = String(format: "%.1f°", data.current.temp)
        
        // 获取天气描述（使用第一个天气条件）
        if let condition = data.current.weather.first {
            weatherDescription = condition.description
        } else {
            weatherDescription = "暂无天气信息"
        }
    }
    
    /// 处理错误
    private func handleError(_ error: WeatherError) {
        DispatchQueue.main.async {
            self.isLoading = false
            switch error {
            case .networkError(let underlyingError):
                self.errorMessage = "网络错误: \(underlyingError.localizedDescription)"
            case .decodingError:
                self.errorMessage = "数据解析错误"
            case .noData:
                self.errorMessage = "未返回天气数据"
            case .invalidURL:
                self.errorMessage = "无效的请求URL"
            case .apiError(let message):
                self.errorMessage = "API错误: \(message)"
            }
            // 在错误情况下重置显示数据
            self.temperature = "--"
            self.weatherDescription = self.errorMessage ?? "暂无天气信息"
        }
    }
    
    /// 清理订阅
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}