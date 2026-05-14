//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by Eli on 5/13/26.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import FamilyControls

private let appGroupID = "group.com.eliguzz.bootup"

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private let defaults = UserDefaults(suiteName: appGroupID)

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let appName = application.localizedDisplayName ?? "APP"

        // Cache bundle ID so the action extension can read it later
        if let bundleID = application.bundleIdentifier,
           let token = application.token {
            storeBundleID(bundleID, for: token)
        }

        return ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1.0),
            icon: UIImage(systemName: "power",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 64,
                    weight: .medium
                )
            )?
            .withTintColor(
                UIColor(red: 0.18, green: 1.0, blue: 0.45, alpha: 1.0),
                renderingMode: .alwaysOriginal
            ),
            title: ShieldConfiguration.Label(
                text: "BOOT UP",
                color: UIColor(red: 0.18, green: 1.0, blue: 0.45, alpha: 1.0)
            ),
            subtitle: ShieldConfiguration.Label(
                text: appName.uppercased(),
                color: UIColor(red: 0.18, green: 1.0, blue: 0.45, alpha: 0.6)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "BOOT UP",
                color: UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1.0)
            ),
            primaryButtonBackgroundColor: UIColor(
                red: 0.18, green: 1.0, blue: 0.45, alpha: 1.0
            ),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "STAND DOWN",
                color: UIColor(red: 0.18, green: 1.0, blue: 0.45, alpha: 0.4)
            )
        )
    }

    override func configuration(
        shielding application: Application,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        configuration(shielding: application)
    }

    // Store Bundle ID so the action extension can construct deep links
    private func storeBundleID(_ bundleID: String, for token: ApplicationToken) {
        guard let encoded = try? JSONEncoder().encode(token) else { return }
        let key = encoded.base64EncodedString()

        var bundleIDs: [String: String]
        if let data = defaults?.data(forKey: "bundleIDs"),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            bundleIDs = decoded
        } else {
            bundleIDs = [:]
        }

        // Only write if changed — avoid spurious App Group writes
        guard bundleIDs[key] != bundleID else { return }
        bundleIDs[key] = bundleID

        if let data = try? JSONEncoder().encode(bundleIDs) {
            defaults?.set(data, forKey: "bundleIDs")
        }
    }
}
