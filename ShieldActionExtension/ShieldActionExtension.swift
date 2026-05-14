import ManagedSettings
import FamilyControls
import UIKit
import UserNotifications
import Foundation

private let appGroupID = "group.com.eliguzz.bootup"

class ShieldActionExtension: ShieldActionDelegate {

    private let defaults = UserDefaults(suiteName: appGroupID)

    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            fireBootUpNotification(for: application)
            // Defer keeps the shield up — we'll unlock from the main app
            completionHandler(.defer)

        case .secondaryButtonPressed:
            completionHandler(.close)

        default:
            completionHandler(.defer)
        }
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(.close)
    }

    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(.close)
    }

    // Fire the notification as fast as possible.
    // Body is hardcoded; name lookup is deferred to the main app.

    private func fireBootUpNotification(for token: ApplicationToken) {
        let key      = stableKey(for: token)
        let bundleID = loadBundleID(for: key)
        let duration = loadBootDuration(for: key)

        let urlString = "bootup://launch?bundle=\(bundleID)&duration=\(duration)&key=\(key)"

        let content = UNMutableNotificationContent()
        content.title             = "BOOT UP ENGINE"
        content.body              = "SELECT TO START BOOT UP"
        content.sound             = .default
        content.interruptionLevel = .timeSensitive
        content.userInfo          = ["bootupURL": urlString]

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(
            withIdentifiers: ["bootup.shield.active"]
        )

        let request = UNNotificationRequest(
            identifier: "bootup.shield.active",
            content: content,
            trigger: nil   // deliver immediately
        )

        center.add(request) { _ in }
    }

    // Helpers — must produce same output as SharedDataManager.stableKey

    private func stableKey(for token: ApplicationToken) -> String {
        guard let encoded = try? JSONEncoder().encode(token) else {
            return "\(token.hashValue)"
        }
        return encoded.base64EncodedString()
    }

    private func loadBootDuration(for key: String) -> Int {
        let global = defaults?.integer(forKey: "cooldownDuration") ?? 0
        return global == 0 ? 30 : global
    }

    private func loadBundleID(for key: String) -> String {
        guard let data = defaults?.data(forKey: "bundleIDs"),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data)
        else { return "" }
        return decoded[key] ?? ""
    }
}
