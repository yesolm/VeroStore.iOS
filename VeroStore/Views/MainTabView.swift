//
//  MainTabView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var cartService = CartService.shared
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    @State private var selectedTab = 0
    
    init() {
        // Set tab bar appearance to use app primary color
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        
        // Selected item color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.appPrimary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.appPrimary)]
        
        // Unselected item color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.appTextSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.appTextSecondary)]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(0)
            
            CategoriesView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                }
                .tag(1)
            
            Group {
                if cartService.itemCount > 0 {
                    CartView()
                        .tabItem {
                            Image(systemName: "cart.fill")
                        }
                        .badge(cartService.itemCount)
                        .tag(2)
                } else {
                    CartView()
                        .tabItem {
                            Image(systemName: "cart.fill")
                        }
                        .tag(2)
                }
            }
            
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
                .tag(4)
        }
        .accentColor(Color.appPrimary)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToHomeTab"))) { _ in
            selectedTab = 0
        }
        .id(localizationHelper.currentLanguage) // Force refresh on language change
    }
}

