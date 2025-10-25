//
//  LocationView.swift
//  dashboard
//
//  Created by Assistant on 2025/10/15.
//

import SwiftUI
import CoreLocation
import Combine

/// 显示当前位置经纬度的视图
struct LocationView: View {
    @State private var locationManager = LocationManager()
    @Binding var showLocation: Bool
    @Binding var fontSize: CGFloat
    @Binding var locationColor: Color
    
    var body: some View {
        if showLocation {
            VStack(spacing: 8) {
                Text("当前位置")
                    .font(.system(size: fontSize * 0.4, weight: .medium, design: .rounded))
                    .foregroundColor(locationColor == .primary ? .gray : locationColor.opacity(0.7))
                
                HStack {
                    Image(systemName: "location.fill")
                        .font(.system(size: fontSize * 0.5))
                        .foregroundColor(locationColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("城市:")
                                .font(.system(size: fontSize * 0.4, weight: .medium, design: .monospaced))
                                .foregroundColor(locationColor)
                            Text(locationManager.city)
                                .font(.system(size: fontSize * 0.4, weight: .medium, design: .monospaced))
                                .foregroundColor(locationColor)
                        }
                        
                        HStack {
                            Text("纬度:")
                                .font(.system(size: fontSize * 0.4, weight: .medium, design: .monospaced))
                                .foregroundColor(locationColor)
                            Text(locationManager.latitudeString)
                                .font(.system(size: fontSize * 0.4, weight: .medium, design: .monospaced))
                                .foregroundColor(locationColor)
                        }
                        
                        HStack {
                            Text("经度:")
                                .font(.system(size: fontSize * 0.4, weight: .medium, design: .monospaced))
                                .foregroundColor(locationColor)
                            Text(locationManager.longitudeString)
                                .font(.system(size: fontSize * 0.4, weight: .medium, design: .monospaced))
                                .foregroundColor(locationColor)
                        }
                    }
                }
            }
            .padding(15)
            .glassEffect(.regular)
            .onTapGesture {
                // 点击位置组件时重新请求位置
                locationManager.requestLocation()
            }
            .onAppear {
                locationManager.requestLocation()
            }
        }
    }
}

/// 位置管理器，负责获取和管理位置信息
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var latitudeString = "--"
    @Published var longitudeString = "--"
    @Published var city = "--"
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// 请求位置权限
    func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            latitudeString = "无权限"
            longitudeString = "无权限"
            city = "无权限"
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            latitudeString = "未知错误"
            longitudeString = "未知错误"
            city = "未知错误"
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        latitudeString = String(format: "%.6f", location.coordinate.latitude)
        longitudeString = String(format: "%.6f", location.coordinate.longitude)
        
        // 使用反向地理编码获取城市信息
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("反向地理编码错误: \(error)")
                    self?.city = "未知城市"
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    self?.city = "未知城市"
                    return
                }
                
                // 尝试获取城市信息，按照优先级尝试不同字段
                if let city = placemark.locality {
                    self?.city = city
                } else if let subAdministrativeArea = placemark.subAdministrativeArea {
                    self?.city = subAdministrativeArea
                } else if let administrativeArea = placemark.administrativeArea {
                    self?.city = administrativeArea
                } else {
                    // 使用推荐的placemark属性替代废弃的addressDictionary
                    var addressInfo = [String]()
                    
                    if let thoroughfare = placemark.thoroughfare {
                        addressInfo.append(thoroughfare)
                    }
                    if let subThoroughfare = placemark.subThoroughfare {
                        addressInfo.append(subThoroughfare)
                    }
                    if let subLocality = placemark.subLocality {
                        addressInfo.append(subLocality)
                    }
                    
                    // 打印地址信息用于调试
                    if !addressInfo.isEmpty {
                        print("地址信息: \(addressInfo.joined(separator: ", "))")
                    }
                    
                    self?.city = "未知城市"
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        latitudeString = "获取失败"
        longitudeString = "获取失败"
        city = "未知城市"
        print("位置获取失败: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            latitudeString = "无权限"
            longitudeString = "无权限"
            city = "未知城市"
        case .notDetermined:
            // 保持默认值，等待用户授权
            break
        @unknown default:
            latitudeString = "未知状态"
            longitudeString = "未知状态"
            city = "未知城市"
        }
    }
}

#Preview {
    LocationView(
        showLocation: .constant(true),
        fontSize: .constant(48),
        locationColor: .constant(.primary)
    )
}