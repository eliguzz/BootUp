//
//  BootUpApp.swift
//  BootUp
//

import SwiftUI
import FamilyControls
import UserNotifications

@main
struct BootUpApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let center = AuthorizationCenter.shared

    @State private var isShowingShield = false
    @State private var targetBundleID: String = ""
    @State private var targetAppName: String = ""
    @State private var shieldDuration: Double = 30

    init() {
        applyGlobalAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()

                if isShowingShield {
                    ShieldLoadingView(
                        appName: targetAppName,
                        bundleID: targetBundleID,
                        totalDuration: shieldDuration,
                        onComplete: handleTimerComplete
                    )
                    .zIndex(1)
                }
            }
            .preferredColorScheme(.dark)
            .animation(nil, value: isShowingShield)
            .task {
                do {
                    try await center.requestAuthorization(for: .individual)
                } catch {
                    print("Failed to get authorization: \(error)")
                }
                await requestNotificationPermission()
            }
            .onOpenURL { url in
                handleIncomingURL(url)
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .bootupLaunchURL)
            ) { notification in
                if let url = notification.userInfo?["url"] as? URL {
                    handleIncomingURL(url)
                }
            }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "bootup", url.host == "launch" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let params     = components?.queryItems

        let bundle = params?.first(where: { $0.name == "bundle" })?.value ?? ""
        let key    = params?.first(where: { $0.name == "key" })?.value ?? ""
        let duration = Double(
            params?.first(where: { $0.name == "duration" })?.value ?? "30"
        ) ?? Double(SharedDataManager.shared.cooldownDuration)

        // Look up the display name in the main app — the extension skipped this
        // work to fire the notification faster.
        let name = SharedDataManager.shared.appNames[key] ?? "APP"

        targetBundleID = bundle
        targetAppName  = name
        shieldDuration = duration

        withAnimation {
            isShowingShield = true
        }
    }

    private func handleTimerComplete() {
        ShieldOrchestrator.shared.completeBoot(forBundleID: targetBundleID) { result in
            switch result {
            case .deepLinking:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingShield = false
                    }
                }

            case .manualReturn, .failed:
                withAnimation(.easeInOut(duration: 0.6)) {
                    isShowingShield = false
                }
            }
        }
    }

    private func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        guard settings.authorizationStatus == .notDetermined else {
            return
        }

        do {
            _ = try await center.requestAuthorization(
                options: [.alert, .sound])
        } catch {
            print("Notification authorization error: \(error)")
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
}
