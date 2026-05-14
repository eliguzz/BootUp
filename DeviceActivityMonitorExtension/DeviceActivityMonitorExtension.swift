import DeviceActivity
import ManagedSettings
import Foundation

// Replaces the auto-generated file inside your Device Activity Monitor Extension target.
// Class name must match NSExtensionPrincipalClass in the extension's Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        let database = DataBase()
        guard let activityId = UUID(uuidString: activity.rawValue) else { return }
        guard let application = database.getApplicationProfile(id: activityId) else { return }

        let store = ManagedSettingsStore()
        store.shield.applications?.insert(application.applicationToken)

        database.removeApplicationProfile(application)
    }
}
