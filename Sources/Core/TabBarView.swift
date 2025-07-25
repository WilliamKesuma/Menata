//
//  TabBarView.swift
//  Menata
//
//  Created by Muhamad Azis on 16/06/25.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: Int = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
                    
            ScannerView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "viewfinder.circle.fill" : "viewfinder.circle")
                    Text("Scanner")
                }
                .tag(1)
                    
            ProjectView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "folder.fill" : "folder")
                    Text("Projects")
                }
                .tag(2)
        }
        .accentColor(.orange)
        .onAppear {
            setupTabBarAppearance()
        }
    }
        
            
            private func setupTabBarAppearance() {
                // Konfigurasi untuk iOS 15+
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                
                // Background tab bar
                tabBarAppearance.backgroundColor = UIColor.systemBackground
                
                // Shadow/border
                tabBarAppearance.shadowColor = UIColor.systemGray4
                
                // Konfigurasi untuk item normal (tidak dipilih)
                tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
                tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor.systemGray
                ]
                
                // Konfigurasi untuk item yang dipilih
                tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemOrange
                tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor.systemOrange
                ]
                
                // Apply ke semua state
                UITabBar.appearance().standardAppearance = tabBarAppearance
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                
                // Untuk iOS 13-14 compatibility
                UITabBar.appearance().barTintColor = UIColor.systemBackground
                UITabBar.appearance().backgroundColor = UIColor.systemBackground
            }
    }

#Preview {
    TabBarView()
}
