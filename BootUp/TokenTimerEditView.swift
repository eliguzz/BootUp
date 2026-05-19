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

    // Automation instructions
    @State private var showInstructions: Bool = false
    @State private var showAutomationGuide: Bool = false

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

                    Spacer().frame(height: 8)

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

                    Divider().background(Color.terminalFaint)

                    // add shortcuts automation instructions
                    automationInstructionsSection
                }
                .padding(32)
            }
        }
        .sheet(isPresented: $showAutomationGuide) {
            OnboardingView(slides: automationSlides, finishButtonLabel: "DONE")
        }
        .presentationDetents([.large])
        .presentationBackground(Color.appBackground)
    }

    // Automation Instructions

    private var automationInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showInstructions.toggle()
                }
            } label: {
                HStack {
                    Text("SHORTCUTS AUTOMATION (HIGHLY RECOMMENDED)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminalDim)
                    Spacer()
                    Image(systemName: showInstructions ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11))
                        .foregroundColor(.terminalDim)
                }
            }
            .buttonStyle(.plain)

            if showInstructions {
                VStack(alignment: .leading, spacing: 12) {

                    Text("Faster launch via the Shortcuts app. Set this up once per locked app.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.terminalFaint)

                    VStack(alignment: .leading, spacing: 6) {
                        instructionLine("01", "Open the Shortcuts app")
                        instructionLine("02", "Tap the Automation tab")
                        instructionLine("03", "Tap + or New Automation")
                        instructionLine("04", "Search for or select \"App\"")
                        instructionLine("05", "Select choose and search for your app: \(viewModel.appName(for: token))")
                        instructionLine("06", "Select check mark in top right to confirm")
                        instructionLine("07", "Toggle \"Is Opened\" on")
                        instructionLine("08", "Toggle \"Run Immediately\" on")
                        instructionLine("09", "Toggle \"Notify When Run\" off")
                        instructionLine("10", "Tap Next")
                        instructionLine("11", "Select \"Create New Shortcut\" under \"Get Started\"")
                        instructionLine("12", "Search \"Launch with Boot Up\" and select it")
                        instructionLine("13", "Set Target App to your app: \(viewModel.appName(for: token))")
                        instructionLine("14", "Tap the check mark to complete the automation setup")
                    }

                    Button {
                        showAutomationGuide = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.rectangle")
                                .font(.system(size: 10))
                            Text("watch automation guide")
                                .font(.system(size: 11, design: .monospaced))
                        }
                        .foregroundColor(.terminalDim)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private func instructionLine(_ number: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.terminalFaint)
                .frame(width: 20, alignment: .leading)
            Text(text)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.terminal)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
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
