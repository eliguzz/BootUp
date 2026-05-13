import SwiftUI
import FamilyControls

@main
struct BootUpApp: App {

    let center = AuthorizationCenter.shared

    var body: some Scene {
        WindowGroup {
            ShieldView()
                .task {
                    do {
                        try await center.requestAuthorization(for: .individual)
                    } catch {
                        print("Failed to get authorization: \(error)")
                    }
                }
        }
    }
}
