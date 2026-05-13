//
//  SettingsView.swift
//  BootUp
//
//  Created by Eli on 5/12/26.
//

import SwiftUI
import FamilyControls

struct SettingsView: View {

    @ObservedObject var viewModel: AppListViewModel
    @State private var localDuration: Int = 30
    @State private var localGracePeriod: Int = 5

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {

                        // Global Timer

                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader("DEFAULT BOOT TIMER")

                            HStack(spacing: 24) {
                                Button {
                                    if localDuration > 5 {
                                        localDuration -= 5
                                        viewModel.saveGlobalDuration(localDuration)
                                    }
                                } label: {
                                    stepperButton("−")
                                }

                                Text("\(localDuration)s")
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundColor(.terminal)
                                    .frame(minWidth: 80, alignment: .center)

                                Button {
                                    if localDuration < 300 {
                                        localDuration += 5
                                        viewModel.saveGlobalDuration(localDuration)
                                    }
                                } label: {
                                    stepperButton("+")
                                }
                            }

                            Text("How long the boot sequence runs before unlocking")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.terminalFaint)
                        }

                        // Grace Period

                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader("GRACE PERIOD")

                            HStack(spacing: 24) {
                                Button {
                                    if localGracePeriod > 1 {
                                        localGracePeriod -= 1
                                        viewModel.saveGracePeriod(localGracePeriod)
                                    }
                                } label: {
                                    stepperButton("−")
                                }

                                Text("\(localGracePeriod)m")
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundColor(.terminal)
                                    .frame(minWidth: 80, alignment: .center)

                                Button {
                                    if localGracePeriod < 60 {
                                        localGracePeriod += 1
                                        viewModel.saveGracePeriod(localGracePeriod)
                                    }
                                } label: {
                                    stepperButton("+")
                                }
                            }

                            Text("Re-locks after \(localGracePeriod) minute\(localGracePeriod == 1 ? "" : "s") of use")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.terminalFaint)
                        }

                        // About

                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader("ABOUT")
                            infoRow(
                                label: "VERSION",
                                value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
                            )
                            infoRow(label: "BUILD",   value: "open source")
                            infoRow(label: "GITHUB",  value: "eliguzz/BootUp")
                        }

                        #if DEBUG
                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader("DEBUG")

                            Button("RESET AUTHORIZATION") {
                                Task {
                                    AuthorizationCenter.shared.revokeAuthorization { result in
                                        switch result {
                                        case .success:
                                            print("authorization revoked")
                                            Task {
                                                do {
                                                    try await AuthorizationCenter.shared
                                                        .requestAuthorization(for: .individual)
                                                    print("re-authorized")
                                                } catch {
                                                    print("re-auth error: \(error)")
                                                }
                                            }
                                        case .failure(let error):
                                            print("revoke error: \(error)")
                                        }
                                    }
                                }
                            }
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.red)
                        }
                        #endif

                        Spacer()
                    }
                    .padding(32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SETTINGS")
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminal)
                }
            }
            .onAppear {
                localDuration    = viewModel.globalDuration
                localGracePeriod = max(viewModel.gracePeriod, 1)
                if localGracePeriod != viewModel.gracePeriod {
                    viewModel.saveGracePeriod(localGracePeriod)
                }
            }
        }
    }

    // Subviews

    private func stepperButton(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 24, weight: .light, design: .monospaced))
            .foregroundColor(.terminal)
            .frame(width: 44, height: 44)
            .background(Color.terminalFaint)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundColor(.terminalFaint)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.terminalDim)
            Spacer()
            Text(value)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.terminal)
        }
    }
}
