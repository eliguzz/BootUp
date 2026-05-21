//
//  LaunchWithBootUpIntent.swift
//  BootUp
//
//  Created by Eli on 5/16/26.
//

import AppIntents
import Foundation
import ManagedSettings
import FamilyControls


// shortcut app intent for user to set up automation
@available(iOS 26.0, *)
struct LaunchWithBootUpIntent: AppIntent {

    static let title: LocalizedStringResource = "Launch with BootUp"
    static let description = IntentDescription(
        "Run the BootUp boot sequence before opening an app."
    )

    static var supportedModes: IntentModes = [.background, .foreground(.dynamic)]

    @Parameter(title: "Target App")
    var targetApp: BootUpAppEntity

    init() {}

    init(targetApp: BootUpAppEntity) {
        self.targetApp = targetApp
    }

    func perform() async throws -> some IntentResult {
        let bundleID = targetApp.bundleID
        let key = targetApp.id
        let data = SharedDataManager.shared

        // If just unlocked, dont run automation
        if data.consumeLaunchPass(forBundleID: bundleID) {
            return .result()
        }

        // otherwise loading screen
        let duration: Int
        if let override = data.bootDurationOverrides[key] {
            duration = override
        } else {
            duration = data.cooldownDuration
        }

        let urlString = "bootup://launch?bundle=\(bundleID)&duration=\(duration)&key=\(key)"

        guard let url = URL(string: urlString) else {
            return .result()
        }

        if systemContext.currentMode.canContinueInForeground {
            do {
                try await continueInForeground(alwaysConfirm: false)
            } catch {
            }
        }

        await MainActor.run {
            NotificationCenter.default.post(
                name: .bootupLaunchURL,
                object: nil,
                userInfo: ["url": url]
            )
        }

        return .result()
    }
}


@available(iOS 26.0, *)
struct BootUpAppEntity: AppEntity {

    let id: String 
    let name: String
    let bundleID: String

    static let typeDisplayRepresentation: TypeDisplayRepresentation =
        TypeDisplayRepresentation(name: "BootUp App")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    static let defaultQuery = BootUpAppQuery()
}

@available(iOS 26.0, *)
struct BootUpAppQuery: EntityQuery {

    func entities(for identifiers: [String]) async throws -> [BootUpAppEntity] {
        let added = SharedDataManager.shared.addedApps()
        return added
            .filter { identifiers.contains($0.stableKey) }
            .map { BootUpAppEntity(id: $0.stableKey, name: $0.name, bundleID: $0.bundleID) }
    }

    func suggestedEntities() async throws -> [BootUpAppEntity] {
        SharedDataManager.shared.addedApps().map {
            BootUpAppEntity(id: $0.stableKey, name: $0.name, bundleID: $0.bundleID)
        }
    }
}
