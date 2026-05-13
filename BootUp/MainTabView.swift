//
//  MainTabView.swift
//  BootUp
//
//  Created by Eli on 5/12/26.
//

import SwiftUI

struct MainTabView: View {

    @StateObject private var viewModel = AppListViewModel()

    var body: some View {
        TabView {
            LockedAppsView(viewModel: viewModel)
                .tabItem {
                    Label("Apps", systemImage: "lock.app.dashed")
                }

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
        }
        .preferredColorScheme(.dark)
        .tint(.terminal)
    }
}
