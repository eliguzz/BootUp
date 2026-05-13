//
//  LockedAppsView.swift
//  BootUp
//
//  Created by Eli on 5/12/26.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct LockedAppsView: View {

    @ObservedObject var viewModel: AppListViewModel
    @State private var isPickerPresented = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if viewModel.selection.applicationTokens.isEmpty {
                    emptyState
                } else {
                    appList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("LOCKED APPS")
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminal)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPickerPresented = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.terminal)
                    }
                }
            }
            .familyActivityPicker(
                isPresented: $isPickerPresented,
                selection: Binding(
                    get: { viewModel.selection },
                    set: { newSelection in
                        viewModel.save(newSelection: newSelection)
                    }
                )
            )
        }
    }

    // Empty state

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.open")
                .font(.system(size: 48))
                .foregroundColor(.terminalFaint)
            Text("NO APPS LOCKED")
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(.terminalDim)
            Text("Tap + to add an app")
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(.terminalFaint)
        }
    }

    // App list (minimal version — rows are placeholders for now)

    private var appList: some View {
        List {
            ForEach(Array(viewModel.selection.applicationTokens)) { token in
                HStack(spacing: 16) {
                    Label(token)
                        .labelStyle(.iconOnly)
                        .frame(width: 36, height: 36)

                    Text("APP")
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminal)

                    Spacer()
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.appBackground)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            .onDelete { offsets in
                var tokens = Array(viewModel.selection.applicationTokens)
                tokens.remove(atOffsets: offsets)
                var newSelection = viewModel.selection
                newSelection.applicationTokens = Set(tokens)
                viewModel.save(newSelection: newSelection)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
    }
}
