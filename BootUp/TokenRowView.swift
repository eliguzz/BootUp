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
    
    private var rowSubtitle: String {
        if isUnnamed { return "tap to identify" }

        let hasBoot  = viewModel.hasBootDurationOverride(for: token)
        let hasGrace = viewModel.hasGracePeriodOverride(for: token)

        switch (hasBoot, hasGrace) {
        case (true, true):   return "custom boot · custom grace"
        case (true, false):  return "custom boot"
        case (false, true):  return "custom grace"
        case (false, false): return "default timers"
        }
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

                Text(rowSubtitle)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(isUnnamed ? .terminal : .terminalFaint)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(isUnnamed ? .terminal : .terminalFaint)
            }

            Spacer()

            if isUnnamed {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 16))
                    .foregroundColor(.terminal)
            } else {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(viewModel.effectiveBootDuration(for: token))s")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.terminal)
                    Text("\(viewModel.effectiveGracePeriod(for: token))m")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(.terminalDim)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(.terminalFaint)
        }
        .padding(.vertical, 8)
        .background(Color.appBackground)
    }
}
