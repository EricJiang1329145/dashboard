# ContentView组件文档

## 功能说明

ContentView是应用的主视图组件，作为仪表盘的容器，包含时钟显示和设置入口。该组件负责管理仪表盘与设置页面之间的交互，并实现当设置页面显示时为仪表盘背景添加模糊效果的功能（使用.light样式）。

## 文件位置

`/Users/ericjiang/Desktop/pgms/dashboard/dashboard/ContentView.swift`

## 技术实现

1. 使用`@State`管理设置页面的显示状态`isSettingsVisible`
2. 使用`@ObservedObject`观察用户设置变化
3. 使用`@Environment(\.colorScheme)`响应系统颜色模式变化
4. 采用`ZStack`实现分层布局，使设置页面覆盖在仪表盘之上
5. 使用`GeometryReader`获取视图尺寸信息，避免使用已弃用的`UIScreen.main`
6. 实现了精确的组件层级结构：
   - 桌面组件（时钟、设置按钮）位于底层
   - 模糊效果层位于桌面组件之上，设置页面之下
   - 设置页面位于最顶层
7. 实现了条件渲染的背景模糊效果：当设置页面显示时，在桌面组件之上添加`.light`样式的模糊效果
8. 使用`VisualEffectView`封装UIKit的`UIVisualEffectView`，实现SwiftUI中的模糊效果
9. 通过设置`zIndex`确保各组件正确的显示层级关系

## 核心实现代码

```swift
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isSettingsVisible = false
    @ObservedObject private var userSettings = UserSettings.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // 主背景
                colorScheme == .dark ? Color.black : Color.white
                
                // 桌面组件（时钟、设置按钮）
                ClockView(showSeconds: $userSettings.showSeconds, fontSize: $userSettings.fontSize, is24HourFormat: $userSettings.is24HourFormat)
                    .padding()
                
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
                
                // 模糊效果层（位于桌面组件之上，设置页面之下）
                if isSettingsVisible {
                    VisualEffectView(effect: UIBlurEffect(style: .light))
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(1)
                }
                
                // 设置页面（位于最顶层）
                if isSettingsVisible {
                    SettingsView(isVisible: $isSettingsVisible)
                        .transition(.move(edge: .bottom))
                        .zIndex(2)
                        .frame(maxWidth: 850, maxHeight: 700)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
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
```

## 功能特性

1. **桌面组件模糊效果**：当设置页面打开时，模糊效果覆盖所有桌面组件（时钟、设置按钮等），增强视觉层次感和现代感
2. **精确的层级管理**：通过调整组件在ZStack中的顺序和设置zIndex，确保模糊效果正确地覆盖桌面组件而不影响设置页面的显示
3. **响应式设计**：模糊效果随设置页面的显示状态动态添加和移除
4. **全屏覆盖**：模糊效果覆盖整个安全区域，确保视觉一致性
5. **与系统样式兼容**：模糊效果适配系统明亮和暗黑模式
6. **现代化API使用**：使用GeometryReader替代已弃用的UIScreen.main，确保代码的兼容性和未来可维护性