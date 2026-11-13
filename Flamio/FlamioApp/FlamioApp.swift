import SwiftUI

@main struct FlamioApp: App {
    @StateObject private var store = AppStore()
    var body: some Scene { WindowGroup { RootView().environmentObject(store) } }
}

struct RootView: View {
    @EnvironmentObject var store: AppStore
    @State private var tab: AppTab = .weather
    var body: some View {
        ZStack { AnimatedBackground(accent: store.settings.accent); VStack(spacing: 0) { Group { switch tab { case .weather: WeatherView(); case .shifts: ShiftsView(); case .pet: PetView(); case .finance: FinanceView() } }.transition(.opacity.combined(with: .move(edge: .trailing))); FloatingTabBar(selected: $tab) } }
        .preferredColorScheme(store.settings.theme == .dark ? .dark : store.settings.theme == .light ? .light : nil)
        .overlay(alignment: .top) { if let notice = store.notice { Text(notice).font(.subheadline.weight(.semibold)).padding(.horizontal, 18).padding(.vertical, 12).background(.ultraThinMaterial, in: Capsule()).padding(.top, 8).transition(.move(edge: .top).combined(with: .opacity)).onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { store.notice = nil } } } } }
        .animation(store.settings.reduceMotion ? nil : .easeInOut(duration: 0.28), value: tab)
    }
}

struct AnimatedBackground: View { let accent: AccentTheme; @State private var drift = false; var body: some View { ZStack { Color(hex: "070313").ignoresSafeArea(); LinearGradient(colors: [.clear, accent.colors[0].opacity(0.16), .clear], startPoint: drift ? .topLeading : .bottomTrailing, endPoint: drift ? .bottomTrailing : .topLeading).ignoresSafeArea(); ForEach(0..<28, id: \.self) { i in Circle().fill(i % 5 == 0 ? Color.orange : accent.colors[0]).frame(width: CGFloat(i % 3 + 1), height: CGFloat(i % 3 + 1)).position(x: CGFloat((i * 73) % 410), y: CGFloat((i * 131) % 820)).opacity(0.55).blur(radius: i % 3 == 0 ? 0.6 : 0).offset(x: drift ? 5 : -5, y: drift ? -8 : 8) } }.onAppear { withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) { drift.toggle() } } } }

struct FloatingTabBar: View { @Binding var selected: AppTab; var body: some View { HStack(spacing: 6) { ForEach(AppTab.allCases, id: \.self) { tab in Button { selected = tab } label: { VStack(spacing: 4) { Image(systemName: tab.icon).font(.system(size: 21, weight: .semibold)); Text(tab.title).font(.caption.weight(.semibold)) }.frame(maxWidth: .infinity).padding(.vertical, 13).background(selected == tab ? LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [.clear, .clear], startPoint: .top, endPoint: .bottom), in: Capsule()).foregroundStyle(selected == tab ? .white : .white.opacity(0.72)) } } }.padding(7).background(.ultraThinMaterial, in: Capsule()).overlay(Capsule().stroke(.white.opacity(0.14))).padding(.horizontal, 22).padding(.bottom, 6) } }

extension Color { init(hex: String) { let v = UInt64(hex, radix: 16) ?? 0; self.init(red: Double((v >> 16) & 255) / 255, green: Double((v >> 8) & 255) / 255, blue: Double(v & 255) / 255) } }
