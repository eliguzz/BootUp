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

    private let data = SharedDataManager.shared
    private let store = ManagedSettingsStore()

    init() {
        selection      = data.activitySelection
        globalDuration = data.cooldownDuration
        gracePeriod    = data.gracePeriod
    }

    // Selection changes — save and apply shields

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
