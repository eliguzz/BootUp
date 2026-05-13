//
//  TokenRowView.swift
//  BootUp
//
//  Created by Eli on 5/12/26.
//


import SwiftUI
import FamilyControls
import ManagedSettings

struct TokenRowView: View {

    let token: ApplicationToken
    @ObservedObject var viewModel: AppListViewModel

    private var isUnnamed: Bool {
        viewModel.appNames[SharedDataManager.shared.stableKey(for: token)] == nil
    }

    var body: some View {
        HStack(spacing: 16) {
            Label(token)
                .labelStyle(.iconOnly)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.appName(for: token))
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .foregroundColor(isUnnamed ? .terminalFaint : .terminal)
                    .lineLimit(1)

                Text(
                    isUnnamed
                        ? "tap to identify"
                        : viewModel.hasOverride(for: token)
                            ? "custom grace"
                            : "default grace"
                )
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(isUnnamed ? .terminal : .terminalFaint)
            }

            Spacer()

            if isUnnamed {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 16))
                    .foregroundColor(.terminal)
            } else {
                Text("\(viewModel.effectiveGracePeriod(for: token))m")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.terminal)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(.terminalFaint)
        }
        .padding(.vertical, 8)
        .background(Color.appBackground)
    }
}
