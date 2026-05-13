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

    @State private var useCustom: Bool
    @State private var customDuration: Int

    init(token: ApplicationToken, viewModel: AppListViewModel) {
        self.token = token
        self.viewModel = viewModel
        _useCustom = State(initialValue: viewModel.hasOverride(for: token))
        _customDuration = State(initialValue: viewModel.effectiveGracePeriod(for: token))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {

                // Header

                HStack(spacing: 16) {
                    Label(token)
                        .labelStyle(.iconOnly)
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("GRACE PERIOD")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.terminalFaint)
                        Text(viewModel.appName(for: token))
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.terminal)
                    }
                }

                // Custom toggle

                Toggle(isOn: $useCustom) {
                    Text("CUSTOM GRACE PERIOD")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminal)
                }
                .tint(.terminal)

                if !useCustom {
                    Text("Using global default: \(viewModel.gracePeriod)m")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.terminalFaint)
                }

                // Duration stepper

                if useCustom {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MINUTES")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.terminalFaint)

                        HStack(spacing: 24) {
                            Button {
                                if customDuration > 1 { customDuration -= 1 }
                            } label: {
                                stepperLabel("−")
                            }

                            Text("\(customDuration)m")
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(.terminal)
                                .frame(minWidth: 80, alignment: .center)

                            Button {
                                if customDuration < 60 { customDuration += 1 }
                            } label: {
                                stepperLabel("+")
                            }
                        }

                        Text("min 1m  ·  max 60m")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.terminalFaint)
                    }
                }

                Spacer()

                Button {
                    viewModel.setTimerOverride(
                        for: token,
                        duration: useCustom ? customDuration : nil
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
        .presentationDetents([.medium])
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
