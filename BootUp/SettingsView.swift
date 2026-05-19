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
    @State private var isShowingOnboarding: Bool = false
    @State private var isShowingAutomationGuide: Bool = false
    

    @Environment(\.openURL) private var openURL

    private let repoURL = URL(string: "https://github.com/eliguzz/BootUp")!

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomLeading) {
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

                        // Help

                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader("HELP")

                            Button {
                                isShowingOnboarding = true
                            } label: {
                                helpRow(icon: "play.rectangle", label: "REPLAY ONBOARDING")
                            }

                            Button {
                                isShowingAutomationGuide = true
                            } label: {
                                helpRow(icon: "wand.and.stars", label: "AUTOMATION SETUP GUIDE")
                            }
                        }

                        Spacer().frame(height: 60)
                    }
                    .padding(32)
                }

                // GitHub repo link

                Button {
                    openURL(repoURL)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.system(size: 11))
                        Text("eliguzz/BootUp")
                            .font(.system(size: 11, design: .monospaced))
                    }
                    .foregroundColor(.terminalFaint)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
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
            .sheet(isPresented: $isShowingOnboarding) {
                OnboardingView()
            }
            .sheet(isPresented: $isShowingAutomationGuide) {
                OnboardingView(slides: automationSlides, finishButtonLabel: "DONE")
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
    
    private func helpRow(icon: String, label: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.terminal)
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(.terminal)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(.terminalFaint)
        }
        .padding(16)
        .background(Color.terminalFaint)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
}
