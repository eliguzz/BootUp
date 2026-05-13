import SwiftUI
import FamilyControls
import ManagedSettings

class ShieldManager: ObservableObject {
    @Published var discouragedSelections = FamilyActivitySelection()

    private let store = ManagedSettingsStore()

    func shieldActivities() {
        // Clear to reset previous settings
        store.clearAllSettings()

        let applications = discouragedSelections.applicationTokens
        let categories = discouragedSelections.categoryTokens

        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy.specific(categories)
        store.shield.webDomainCategories = categories.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy.specific(categories)
    }
}
