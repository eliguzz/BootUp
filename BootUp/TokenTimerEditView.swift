//
//  TokenTimerEditView.swift
//  BootUp
//
//  Created by Eli on 5/12/26.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct TokenTimerEditView: View {

    let token: ApplicationToken
    @ObservedObject var viewModel: AppListViewModel
    @Environment(\.dismiss) private var dismiss

    // Boot duration state
    @State private var useBootCustom: Bool
    @State private var customBootDuration: Int

    // Grace period state
    @State private var useGraceCustom: Bool
    @State private var customGracePeriod: Int

    init(token: ApplicationToken, viewModel: AppListViewModel) {
        self.token = token
        self.viewModel = viewModel
        _useBootCustom      = State(initialValue: viewModel.hasBootDurationOverride(for: token))
        _customBootDuration = State(initialValue: viewModel.effectiveBootDuration(for: token))
        _useGraceCustom     = State(initialValue: viewModel.hasGracePeriodOverride(for: token))
        _customGracePeriod  = State(initialValue: viewModel.effectiveGracePeriod(for: token))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // Header

                    HStack(spacing: 16) {
                        Label(token)
                            .labelStyle(.iconOnly)
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("CUSTOMIZE TIMERS")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.terminalFaint)
                            Text(viewModel.appName(for: token))
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(.terminal)
                        }
                    }

                    // Boot Duration

                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(isOn: $useBootCustom) {
                            Text("CUSTOM BOOT TIMER")
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundColor(.terminal)
                        }
                        .tint(.terminal)

                        if useBootCustom {
                            HStack(spacing: 24) {
                                Button {
                                    if customBootDuration > 5 { customBootDuration -= 5 }
                                } label: {
                                    stepperLabel("−")
                                }

                                Text("\(customBootDuration)s")
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundColor(.terminal)
                                    .frame(minWidth: 80, alignment: .center)

                                Button {
                                    if customBootDuration < 300 { customBootDuration += 5 }
                                } label: {
                                    stepperLabel("+")
                                }
                            }

                            Text("min 5s  ·  max 300s")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.terminalFaint)
                        } else {
                            Text("Using global default: \(viewModel.globalDuration)s")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.terminalFaint)
                        }
                    }

                    Divider().background(Color.terminalFaint)

                    // Grace Period

                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(isOn: $useGraceCustom) {
                            Text("CUSTOM GRACE PERIOD")
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundColor(.terminal)
                        }
                        .tint(.terminal)

                        if useGraceCustom {
                            HStack(spacing: 24) {
                                Button {
                                    if customGracePeriod > 1 { customGracePeriod -= 1 }
                                } label: {
                                    stepperLabel("−")
                                }

                                Text("\(customGracePeriod)m")
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundColor(.terminal)
                                    .frame(minWidth: 80, alignment: .center)

                                Button {
                                    if customGracePeriod < 60 { customGracePeriod += 1 }
                                } label: {
                                    stepperLabel("+")
                                }
                            }

                            Text("min 1m  ·  max 60m")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.terminalFaint)
                        } else {
                            Text("Using global default: \(viewModel.gracePeriod)m")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.terminalFaint)
                        }
                    }
                    
                    // switch for automation, this honestly does nothing
                    if #available(iOS 26.0, *) {
                        Divider().background(Color.terminalFaint)

                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: Binding(
                                get: { viewModel.isAutomationEnabled(for: token) },
                                set: { viewModel.setAutomationEnabled($0, for: token) }
                            )) {
                                Text("USE SHORTCUTS AUTOMATION")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                    .foregroundColor(.terminal)
                            }
                            .tint(.terminal)

                            Text("Faster launch via the Shortcuts app. Requires per-app setup. Notification path still works as a fallback.")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.terminalFaint)
                        }
                    }

                    Spacer().frame(height: 16)

                    Button {
                        viewModel.setBootDurationOverride(
                            for: token,
                            duration: useBootCustom ? customBootDuration : nil
                        )
                        viewModel.setGracePeriodOverride(
                            for: token,
                            duration: useGraceCustom ? customGracePeriod : nil
                        )
                        dismiss()
                    } label: {
                        Text("SAVE")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.appBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.terminal)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .padding(32)
            }
        }
        .presentationDetents([.large])
        .presentationBackground(Color.appBackground)
    }

    private func stepperLabel(_ symbol: String) -> some View {
        Text(symbol)
            .font(.system(size: 24, weight: .light, design: .monospaced))
            .foregroundColor(.terminal)
            .frame(width: 44, height: 44)
            .background(Color.terminalFaint)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
