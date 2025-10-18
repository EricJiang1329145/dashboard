//
//  ContentView.swift
//  dashboard
//
//  Created by Eric Jiang on 2025/10/12.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isSettingsVisible = false
    
    // 时钟设置状态
    @ObservedObject private var userSettings = UserSettings.shared
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 主背景
            colorScheme == .dark ? Color.black : Color.white
            
            // 时钟组件放置在左上角
            ClockView(showSeconds: $userSettings.showSeconds, fontSize: $userSettings.fontSize, is24HourFormat: $userSettings.is24HourFormat)
                .padding()
            
            // 设置按钮放置在右上角
            Button(action: {
                isSettingsVisible = true
            }) {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(12)
                    .glassEffect(.regular)
                    .clipShape(Circle())
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            
            // 设置页面覆盖层（仅覆盖内容区域，不覆盖整个屏幕）
            if isSettingsVisible {
                SettingsView(isVisible: $isSettingsVisible)
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
                    .frame(maxWidth: 850, maxHeight: 700)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSettingsVisible)
    }
}

// 视觉效果视图包装器，用于实现背景虚化
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
