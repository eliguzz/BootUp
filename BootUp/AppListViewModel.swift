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
    @Published var timerOverrides: [String: Int] = [:]

    private let data = SharedDataManager.shared
    private let store = ManagedSettingsStore()

    init() {
        selection      = data.activitySelection
        globalDuration = data.cooldownDuration
        gracePeriod    = data.gracePeriod
        appNames       = data.appNames
        timerOverrides = data.timerOverrides
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

    // Timer Overrides

    func setTimerOverride(for token: ApplicationToken, duration: Int?) {
        let key = data.stableKey(for: token)
        if let duration {
            timerOverrides[key] = duration
        } else {
            timerOverrides.removeValue(forKey: key)
        }
        data.timerOverrides = timerOverrides
    }

    func effectiveGracePeriod(for token: ApplicationToken) -> Int {
        let key = data.stableKey(for: token)
        return timerOverrides[key] ?? gracePeriod
    }

    func hasOverride(for token: ApplicationToken) -> Bool {
        let key = data.stableKey(for: token)
        return timerOverrides[key] != nil
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
