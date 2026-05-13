//
//  ShieldOrchestrator.swift
//  BootUp
//
//  Created by Eli on 5/13/26.
//

//  After the boot sequence completes, unlocks the specific app, starts
//  a DeviceActivity interval monitor for re-shielding, and (for apps
//  with a known urlScheme) deep-links into the target app.
//

import Foundation
import UIKit
import ManagedSettings
import FamilyControls
import DeviceActivity

class ShieldOrchestrator {

    static let shared = ShieldOrchestrator()
    private init() {}

    private let data  = SharedDataManager.shared
    private let store = ManagedSettingsStore()

    /// Called from the main app when the boot sequence completes.
    func completeBoot(forBundleID bundleID: String) {
        guard let token = findToken(forBundleID: bundleID) else {
            print("[ShieldOrchestrator] No token for bundleID \(bundleID)")
            return
        }

        let gracePeriodMinutes = effectiveGracePeriod(for: token)

        let profile = ApplicationProfile(applicationToken: token)
        DataBase().addApplicationProfile(profile)
        print("[ShieldOrchestrator] Created profile \(profile.id) for \(bundleID)")

        store.shield.applications?.remove(token)
        print("[ShieldOrchestrator] Removed shield for \(bundleID)")

        startMonitoring(for: profile, gracePeriodMinutes: gracePeriodMinutes)

        // Deep-link into the target app if it has a known urlScheme
        deepLink(forBundleID: bundleID)
    }

    // Find the token for a bundle ID

    private func findToken(forBundleID bundleID: String) -> ApplicationToken? {
        let allBundleIDs = data.bundleIDs
        guard let matchingKey = allBundleIDs.first(
            where: { $0.value == bundleID }
        )?.key else {
            return nil
        }

        return data.activitySelection.applicationTokens.first {
            data.stableKey(for: $0) == matchingKey
        }
    }

    // Effective grace period for the token (override or global)

    private func effectiveGracePeriod(for token: ApplicationToken) -> Int {
        let key = data.stableKey(for: token)
        if let override = data.timerOverrides[key] {
            return override
        }
        return data.gracePeriod
    }

    // DeviceActivity interval monitor

    private func startMonitoring(
        for profile: ApplicationProfile,
        gracePeriodMinutes: Int
    ) {
        let event: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            DeviceActivityEvent.Name(profile.id.uuidString):
                DeviceActivityEvent(
                    applications: Set<ApplicationToken>([profile.applicationToken]),
                    threshold: DateComponents(minute: gracePeriodMinutes)
                )
        ]

        let intervalEnd = Calendar.current.dateComponents(
            [.hour, .minute, .second],
            from: Calendar.current.date(
                byAdding: .minute,
                value: gracePeriodMinutes,
                to: .now
            ) ?? .now
        )

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: intervalEnd,
            repeats: false
        )

        let center = DeviceActivityCenter()
        do {
            try center.startMonitoring(
                DeviceActivityName(profile.id.uuidString),
                during: schedule,
                events: event
            )
            print("[ShieldOrchestrator] Monitoring started for \(gracePeriodMinutes)m")
        } catch {
            print("[ShieldOrchestrator] Monitoring error: \(error)")
        }
    }

    // Deep link into the target app, if a urlScheme is known

    private func deepLink(forBundleID bundleID: String) {
        guard let app = knownApps.first(where: { $0.bundleID == bundleID }),
              let scheme = app.urlScheme,
              let url = URL(string: scheme) else {
            print("[ShieldOrchestrator] No urlScheme for \(bundleID) — manual return")
            return
        }

        // Small delay so the unlock has time to propagate before we try
        // to open the target app. Without this, the OS can still consider
        // the app shielded and route the user back to the BootUp shield.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIApplication.shared.open(url) { success in
                print("[ShieldOrchestrator] Deep link to \(scheme) success=\(success)")
            }
        }
    }
}
