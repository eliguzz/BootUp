//
//  AppIdentifierView.swift
//  BootUp
//
//  Created by Eli on 5/12/26.
//


import SwiftUI
import FamilyControls
import ManagedSettings

struct AppIdentifierView: View {

    let token: ApplicationToken?
    var onConfirm: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery: String = ""
    @State private var selectedApp: KnownApp? = nil
    @State private var customName: String = ""
    @State private var showingManual: Bool = false

    private var searchResults: [KnownApp] {
        searchApps(searchQuery)
    }

    private var groupedResults: [(category: String, apps: [KnownApp])] {
        var seen: Set<String> = []
        var order: [String] = []
        for app in searchResults {
            if seen.insert(app.category).inserted {
                order.append(app.category)
            }
        }
        return order.map { cat in
            (category: cat, apps: searchResults.filter { $0.category == cat })
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // Header

                VStack(alignment: .leading, spacing: 8) {
                    Text("IDENTIFY APP")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminalFaint)

                    HStack(spacing: 12) {
                        if let token {
                            Label(token)
                                .labelStyle(.iconOnly)
                                .frame(width: 36, height: 36)
                        }
                        Text("Which app did you select?")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.terminal)
                    }
                }
                .padding(24)

                // Search Bar

                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.terminalFaint)

                    TextField("Search apps...", text: $searchQuery)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.terminal)
                        .tint(.terminal)
                        .autocorrectionDisabled()
                }
                .padding(12)
                .background(Color.terminalFaint)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

                // Selection Preview

                if let selected = selectedApp {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.terminal)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(selected.name)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.terminal)
                            Text(selected.bundleID)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.terminalFaint)
                        }

                        Spacer()

                        Button("CLEAR") { selectedApp = nil }
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.terminalFaint)
                    }
                    .padding(12)
                    .background(Color.terminal.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                }

                // App List

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {

                        ForEach(groupedResults, id: \.category) { group in
                            Text(group.category.uppercased())
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.terminalFaint)
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                                .padding(.bottom, 4)

                            ForEach(group.apps, id: \.bundleID) { app in
                                appRow(app)
                            }
                        }

                        // Manual entry

                        Button(action: { showingManual = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.terminalFaint)
                                Text("Enter manually")
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.terminalFaint)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        }

                        Spacer().frame(height: 100)
                    }
                }

                // Confirm Button

                VStack {
                    Button(action: confirm) {
                        Text("CONFIRM")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.appBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canConfirm ? Color.terminal : Color.terminalFaint)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .disabled(!canConfirm)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                .background(Color.appBackground)
            }
        }
        .sheet(isPresented: $showingManual) {
            manualEntrySheet
        }
    }

    // App Row

    private func appRow(_ app: KnownApp) -> some View {
        Button(action: { selectedApp = app }) {
            HStack(spacing: 16) {
                Image(
                    systemName: selectedApp?.bundleID == app.bundleID
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .foregroundColor(
                    selectedApp?.bundleID == app.bundleID ? .terminal : .terminalFaint
                )
                .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminal)

                    Text(app.bundleID)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.terminalFaint)
                        .lineLimit(1)

                    // Option A: flag apps without urlScheme
                    if app.urlScheme == nil {
                        Text("manual launch only")
                            .font(.system(size: 9, weight: .regular, design: .monospaced))
                            .foregroundColor(.terminalFaint)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(
                selectedApp?.bundleID == app.bundleID
                    ? Color.terminal.opacity(0.08)
                    : Color.clear
            )
        }
        .buttonStyle(.plain)
    }

    // Manual Entry Sheet

    private var manualEntrySheet: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("MANUAL ENTRY")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.terminal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("APP NAME")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.terminalFaint)
                    TextField("e.g. TikTok", text: $customName)
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(.terminal)
                        .tint(.terminal)
                        .padding(12)
                        .background(Color.terminalFaint)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .autocorrectionDisabled()
                }

                Spacer()

                Button {
                    let trimmedName = customName.trimmingCharacters(in: .whitespaces)
                    guard !trimmedName.isEmpty else { return }
                    selectedApp = KnownApp(
                        name: trimmedName,
                        bundleID: "custom.\(UUID().uuidString)",
                        category: "Custom"
                    )
                    showingManual = false
                } label: {
                    Text("CONFIRM")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.appBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            !customName.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.terminal : Color.terminalFaint
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(32)
        }
        .presentationDetents([.medium])
        .presentationBackground(Color.appBackground)
    }

    // Helpers

    private var canConfirm: Bool { selectedApp != nil }

    private func confirm() {
        guard let app = selectedApp else { return }
        onConfirm(app.name, app.bundleID)
    }
}
