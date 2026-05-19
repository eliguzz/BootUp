//
//  ShieldOrchestrator.swift
//  BootUp
//
//  Created by Eli on 5/13/26.
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

    // Result the caller uses to decide overlay dismissal timing
    enum BootCompletion {
        case deepLinking       // a deep link is being attempted; caller should wait
        case manualReturn      // no urlScheme; caller can dismiss overlay normally
        case failed            // setup failed; caller should dismiss to recover
    }

    // Called from the main app when the boot sequence completes.
    // Callback fires when the orchestrator finishes its work — either
    // immediately (manual return, failure) or after the deep link returns.
    func completeBoot(
        forBundleID bundleID: String,
        completion: @escaping (BootCompletion) -> Void
    ) {
        guard let token = findToken(forBundleID: bundleID) else {
            print("[ShieldOrchestrator] No token for bundleID \(bundleID)")
            completion(.failed)
            return
        }

        let gracePeriodMinutes = effectiveGracePeriod(for: token)

        let profile = ApplicationProfile(applicationToken: token)
        DataBase().addApplicationProfile(profile)
        print("[ShieldOrchestrator] Created profile \(profile.id) for \(bundleID)")

        store.shield.applications?.remove(token)
        print("[ShieldOrchestrator] Removed shield for \(bundleID)")

        startMonitoring(for: profile, gracePeriodMinutes: gracePeriodMinutes)

        let url: URL? = {
            // actual url scheme priority
            if let app = knownApps.first(where: { $0.bundleID == bundleID }),
               let scheme = app.urlScheme,
               let nativeURL = URL(string: scheme) {
                return nativeURL
            }

            // added user shortcut link option
            let key = data.stableKey(for: token)
            if let shortcutName = data.shortcutNames[key],
               !shortcutName.isEmpty {
                var components = URLComponents()
                components.scheme = "shortcuts"
                components.host   = "run-shortcut"
                components.queryItems = [URLQueryItem(name: "name", value: shortcutName)]
                return components.url
            }

            return nil
        }()

        guard let url else {
            print("[ShieldOrchestrator] No deep-link path for \(bundleID) — manual return")
            completion(.manualReturn)
            return
        }

        let scheme = url.scheme ?? "unknown"

        // Signal that we're about to deep-link, then attempt it
        completion(.deepLinking)

        // launch pass so automation lets this launch through silently
        data.grantLaunchPass(
            forBundleID: bundleID,
            validForMinutes: gracePeriodMinutes
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIApplication.shared.open(url) { success in
                print("[ShieldOrchestrator] Deep link to \(scheme) success=\(success)")
            }
        }
    }


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

    private func effectiveGracePeriod(for token: ApplicationToken) -> Int {
        let key = data.stableKey(for: token)
        if let override = data.gracePeriodOverrides[key] {
            return override
        }
        return data.gracePeriod
    }

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
}
