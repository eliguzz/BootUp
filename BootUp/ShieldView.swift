import SwiftUI
import FamilyControls

struct ShieldView: View {

    @StateObject private var manager = ShieldManager()
    @State private var showActivityPicker = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {

                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("BOOTUP ENGINE")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminalDim)

                    Text("v0.1.0")
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundColor(.terminalFaint)
                }

                Spacer()

                // Actions
                VStack(alignment: .leading, spacing: 16) {

                    Button {
                        showActivityPicker = true
                    } label: {
                        terminalButton(label: "CONFIGURE ACTIVITIES")
                    }

                    Button {
                        manager.shieldActivities()
                    } label: {
                        terminalButton(label: "APPLY SHIELDING", filled: true)
                    }
                }

                Spacer()

                // Footer info
                Text("Select apps to shield. Tap apply to engage.")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.terminalFaint)
            }
            .padding(32)
        }
        .familyActivityPicker(
            isPresented: $showActivityPicker,
            selection: $manager.discouragedSelections
        )
    }

    // Reusable button style
    private func terminalButton(label: String, filled: Bool = false) -> some View {
        Text(label)
            .font(.system(size: 15, weight: .bold, design: .monospaced))
            .foregroundColor(filled ? .appBackground : .terminal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(filled ? Color.terminal : Color.terminalFaint)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
