//
//  AppListViewModel.swift
//  BootUp
//
//  Created by Eli on 5/12/26.
//

import SwiftUI
import FamilyControls
import ManagedSettings

class AppListViewModel: ObservableObject {

    @Published var selection: FamilyActivitySelection
    @Published var globalDuration: Int
    @Published var gracePeriod: Int
    @Published var appNames: [String: String] = [:]
    @Published var gracePeriodOverrides: [String: Int] = [:]
    @Published var bootDurationOverrides: [String: Int] = [:]
    @Published var shortcutNames: [String: String] = [:]
    
    private let data = SharedDataManager.shared
    private let store = ManagedSettingsStore()

    init() {
        selection             = data.activitySelection
        globalDuration        = data.cooldownDuration
        gracePeriod           = data.gracePeriod
        appNames              = data.appNames
        gracePeriodOverrides  = data.gracePeriodOverrides
        bootDurationOverrides = data.bootDurationOverrides
        shortcutNames         = data.shortcutNames
    }

    // App Names

    func appName(for token: ApplicationToken) -> String {
        let key = data.stableKey(for: token)
        return appNames[key] ?? "UNKNOWN APP"
    }

    func setAppName(_ name: String, for token: ApplicationToken) {
        let key = data.stableKey(for: token)
        appNames[key] = name.uppercased()
        data.appNames = appNames
    }

    // Bundle IDs

    func storeBundleID(_ bundleID: String, for token: ApplicationToken) {
        data.storeBundleID(bundleID, for: token)
    }

    // Grace Period Overrides

    func setGracePeriodOverride(for token: ApplicationToken, duration: Int?) {
        let key = data.stableKey(for: token)
        if let duration {
            gracePeriodOverrides[key] = duration
        } else {
            gracePeriodOverrides.removeValue(forKey: key)
        }
        data.gracePeriodOverrides = gracePeriodOverrides
    }

    func effectiveGracePeriod(for token: ApplicationToken) -> Int {
        let key = data.stableKey(for: token)
        return gracePeriodOverrides[key] ?? gracePeriod
    }

    func hasGracePeriodOverride(for token: ApplicationToken) -> Bool {
        let key = data.stableKey(for: token)
        return gracePeriodOverrides[key] != nil
    }

    // Boot Duration Overrides

    func setBootDurationOverride(for token: ApplicationToken, duration: Int?) {
        let key = data.stableKey(for: token)
        if let duration {
            bootDurationOverrides[key] = duration
        } else {
            bootDurationOverrides.removeValue(forKey: key)
        }
        data.bootDurationOverrides = bootDurationOverrides
    }

    func effectiveBootDuration(for token: ApplicationToken) -> Int {
        let key = data.stableKey(for: token)
        return bootDurationOverrides[key] ?? globalDuration
    }

    func hasBootDurationOverride(for token: ApplicationToken) -> Bool {
        let key = data.stableKey(for: token)
        return bootDurationOverrides[key] != nil
    }
    
    // Shortcut Names

    func setShortcutName(_ name: String?, for token: ApplicationToken) {
        let key = data.stableKey(for: token)
        if let name, !name.isEmpty {
            shortcutNames[key] = name
        } else {
            shortcutNames.removeValue(forKey: key)
        }
        data.shortcutNames = shortcutNames
    }

    func shortcutName(for token: ApplicationToken) -> String? {
        let key = data.stableKey(for: token)
        return shortcutNames[key]
    }

    func hasShortcutName(for token: ApplicationToken) -> Bool {
        shortcutName(for: token) != nil
    }
    
    

    // Selection — save and apply shields

    func save(newSelection: FamilyActivitySelection) {
        selection = newSelection
        data.activitySelection = newSelection
        applyShields()
    }

    // Settings

    func saveGlobalDuration(_ value: Int) {
        globalDuration = value
        data.cooldownDuration = value
    }

    func saveGracePeriod(_ value: Int) {
        gracePeriod = value
        data.gracePeriod = value
    }

    // Apply shields to current selection

    func applyShields() {
        let tokens = selection.applicationTokens
        store.shield.applications = tokens.isEmpty ? nil : tokens
    }
}
