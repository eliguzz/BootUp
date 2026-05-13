//
//  ApplicationToken+Identifiable.swift
//  BootUp
//
//  Created by Eli on 5/12/26.
//

import SwiftUI
import FamilyControls
import ManagedSettings

extension ApplicationToken: @retroactive Identifiable {
    public var id: String {
        SharedDataManager.shared.stableKey(for: self)
    }
}
