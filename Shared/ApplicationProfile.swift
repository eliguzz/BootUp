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
