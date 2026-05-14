//
//  ApplicationProfile.swift
//  Shared
//
//  Created by Eli on 5/13/26.
//
import Foundation
import ManagedSettings

struct ApplicationProfile: Codable, Hashable {
    let id: UUID
    let applicationToken: ApplicationToken

    init(id: UUID = UUID(), applicationToken: ApplicationToken) {
        self.id = id
        self.applicationToken = applicationToken
    }
}
