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
        
        let data = SharedDataManager.shared
        
        // Only re-shield if the token is still in the user's selection
        if data.activitySelection.applicationTokens.contains(application.applicationToken) {
            let store = ManagedSettingsStore()
            store.shield.applications?.insert(application.applicationToken)
        }
        
        let key = data.stableKey(for: application.applicationToken)
        if let bundleID = data.bundleIDs[key] {
            data.clearLaunchPass(forBundleID: bundleID)
        }
        
        database.removeApplicationProfile(application)
    }
}
