//
//  BootUpApp.swift
//  BootUp
//
//  Created by Eli on 5/13/26.
//

import SwiftUI
import FamilyControls
import UserNotifications

@main
struct BootUpApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let center = AuthorizationCenter.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var targetBundleID: String = ""
    @State private var targetAppName: String = ""
    @State private var shieldDuration: Double = 30
    @State private var isAwaitingManualReturn: Bool = false

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var isShowingOnboarding: Bool = false
    
    private enum LaunchState {
        case undetermined    // initial — render nothing
        case main            // normal launch — show MainTabView
        case shield          // launched into a shield — show ShieldLoadingView
    }

    @State private var launchState: LaunchState = .undetermined
    
    init() {
        applyGlobalAppearance()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch launchState {
                case .undetermined:
                    Color.appBackground
                        .ignoresSafeArea()

                case .main:
                    MainTabView()

                case .shield:
                    ShieldLoadingView(
                        appName: targetAppName,
                        bundleID: targetBundleID,
                        totalDuration: shieldDuration,
                        onComplete: handleTimerComplete
                    )
                }
            }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $isShowingOnboarding, onDismiss: {
                hasCompletedOnboarding = true
                Task { await requestAllPermissions() }
            }) {
                OnboardingView()
            }
            .task {
                if launchState == .undetermined {
                    launchState = .main
                }

                if !hasCompletedOnboarding {
                    isShowingOnboarding = true
                    return
                }
                await requestAllPermissions()
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
            .onChange(of: scenePhase) { _, newPhase in
                if isAwaitingManualReturn && newPhase != .active {
                    launchState = .main
                    isAwaitingManualReturn = false
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

        let via = params?.first(where: { $0.name == "via" })?.value ?? "notification"
        print("[BootUp] Launch triggered via: \(via)")

        let name = SharedDataManager.shared.appNames[key] ?? "APP"

        targetBundleID = bundle
        targetAppName  = name
        shieldDuration = duration

        launchState = .shield
    }

    private func handleTimerComplete() {
        ShieldOrchestrator.shared.completeBoot(forBundleID: targetBundleID) { result in
            switch result {
            case .deepLinking:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        launchState = .main
                    }
                }

            case .manualReturn:
                isAwaitingManualReturn = true

            case .failed:
                withAnimation(.easeInOut(duration: 0.6)) {
                    launchState = .main
                }
            }
        }
    }

    private func requestAllPermissions() async {
        do {
            try await center.requestAuthorization(for: .individual)
        } catch {
            print("Failed to get authorization: \(error)")
        }
        await requestNotificationPermission()
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
