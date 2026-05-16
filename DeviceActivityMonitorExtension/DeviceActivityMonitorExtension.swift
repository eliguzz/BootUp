//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created by Eli on 5/13/26.
//

import DeviceActivity
import ManagedSettings
import Foundation

// fails if exceeds 6mb in ram or something
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidEnd(for activity: DeviceActivityName) {

        let database = DataBase()
        guard let activityId = UUID(uuidString: activity.rawValue) else { return }
        guard let application = database.getApplicationProfile(id: activityId) else { return }

        let store = ManagedSettingsStore()
        store.shield.applications?.insert(application.applicationToken)

        // clear launch pass so next launch triggers loading screen again
        let data = SharedDataManager.shared
        let key = data.stableKey(for: application.applicationToken)
        if let bundleID = data.bundleIDs[key] {
            data.clearLaunchPass(forBundleID: bundleID)
        }

        database.removeApplicationProfile(application)
    }
}
