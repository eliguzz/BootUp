import SwiftUI
import FamilyControls

@main
struct BootUpApp: App {

    let center = AuthorizationCenter.shared
    
    init() {
        applyGlobalAppearance()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .task {
                    do {
                        try await center.requestAuthorization(for: .individual)
                    } catch {
                        print("Failed to get authorization: \(error)")
                    }
                }
        }
    }
}

private func applyGlobalAppearance() {
    let attrs: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(Color.terminal),
        .font: UIFont.monospacedSystemFont(ofSize: 13, weight: .medium)
    ]

    let navAppearance = UINavigationBarAppearance()
    navAppearance.configureWithOpaqueBackground()
    navAppearance.backgroundColor          = UIColor(Color.appBackground)
    navAppearance.titleTextAttributes      = attrs
    navAppearance.largeTitleTextAttributes = attrs

    UINavigationBar.appearance().standardAppearance   = navAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    UINavigationBar.appearance().compactAppearance    = navAppearance
    UINavigationBar.appearance().tintColor            = UIColor(Color.terminal)

    let tabAppearance = UITabBarAppearance()
    tabAppearance.configureWithOpaqueBackground()
    tabAppearance.backgroundColor = UIColor(Color.appBackground)
    UITabBar.appearance().standardAppearance   = tabAppearance
    UITabBar.appearance().scrollEdgeAppearance = tabAppearance
}

