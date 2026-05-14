//
//  SharedDataManager.swift
//  BootUp
//
//  Created by Eli on 5/12/26.
//

import Foundation
import FamilyControls
import ManagedSettings

let APP_GROUP_ID = "group.com.eliguzz.bootup"

enum SharedKey {
    static let cooldownDuration   = "cooldownDuration"
    static let gracePeriod        = "gracePeriod"
    static let appNames           = "appNames"
    static let bundleIDs          = "bundleIDs"
    static let gracePeriodOverrides   = "gracePeriodOverrides"
    static let bootDurationOverrides  = "bootDurationOverrides"
    static let activitySelection  = "activitySelection"
}

class SharedDataManager {

    static let shared = SharedDataManager()

    let defaults: UserDefaults

    private init() {
        guard let defaults = UserDefaults(suiteName: APP_GROUP_ID) else {
            fatalError("App Group '\(APP_GROUP_ID)' not found. Check Signing & Capabilities.")
        }
        self.defaults = defaults
    }

    // App Display Names

    var appNames: [String: String] {
        get {
            guard let data = defaults.data(forKey: SharedKey.appNames),
                  let decoded = try? JSONDecoder().decode([String: String].self, from: data)
            else { return [:] }
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            defaults.set(encoded, forKey: SharedKey.appNames)
        }
    }

    // Bundle IDs

    var bundleIDs: [String: String] {
        get {
            guard let data = defaults.data(forKey: SharedKey.bundleIDs),
                  let decoded = try? JSONDecoder().decode([String: String].self, from: data)
            else { return [:] }
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            defaults.set(encoded, forKey: SharedKey.bundleIDs)
        }
    }

    // FamilyActivitySelection (which apps the user wants shielded)

    var activitySelection: FamilyActivitySelection {
        get {
            guard let data = defaults.data(forKey: SharedKey.activitySelection),
                  let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
            else { return FamilyActivitySelection() }
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            defaults.set(encoded, forKey: SharedKey.activitySelection)
        }
    }

    // Settings

    var cooldownDuration: Int {
        get {
            let stored = defaults.integer(forKey: SharedKey.cooldownDuration)
            return stored == 0 ? 30 : stored
        }
        set { defaults.set(newValue, forKey: SharedKey.cooldownDuration) }
    }

    var gracePeriod: Int {
        get {
            let stored = defaults.integer(forKey: SharedKey.gracePeriod)
            return stored == 0 ? 5 : stored
        }
        set { defaults.set(newValue, forKey: SharedKey.gracePeriod) }
    }

    // Grace Period Overrides (per-app, in minutes)

    var gracePeriodOverrides: [String: Int] {
        get {
            guard let data = defaults.data(forKey: SharedKey.gracePeriodOverrides),
                  let decoded = try? JSONDecoder().decode([String: Int].self, from: data)
            else { return [:] }
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            defaults.set(encoded, forKey: SharedKey.gracePeriodOverrides)
        }
    }

    // Boot Duration Overrides (per-app, in seconds)

    var bootDurationOverrides: [String: Int] {
        get {
            guard let data = defaults.data(forKey: SharedKey.bootDurationOverrides),
                  let decoded = try? JSONDecoder().decode([String: Int].self, from: data)
            else { return [:] }
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            defaults.set(encoded, forKey: SharedKey.bootDurationOverrides)
        }
    }

    // Stable Token Key

    func stableKey(for token: ApplicationToken) -> String {
        guard let encoded = try? JSONEncoder().encode(token) else {
            return "\(token.hashValue)"
        }
        return encoded.base64EncodedString()
    }

    func storeBundleID(_ bundleID: String, for token: ApplicationToken) {
        let key = stableKey(for: token)
        var current = bundleIDs
        current[key] = bundleID
        bundleIDs = current
    }
}
