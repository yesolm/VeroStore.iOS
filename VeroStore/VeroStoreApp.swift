//
//  VeroStoreApp.swift
//  VeroStore
//
//  Created by Yesehake Berhe on 11/21/25.
//

import SwiftUI

@main
struct VeroStoreApp: App {
    init() {
        // Force light mode globally
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        
        // Customize navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        // Remove back button text, show only icon
        appearance.setBackIndicatorImage(UIImage(systemName: "arrow.left"), transitionMaskImage: UIImage(systemName: "arrow.left"))
        appearance.backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -1000, vertical: 0)
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .preferredColorScheme(.light)
                .environmentObject(LocalizationHelper.shared)
                .onAppear {
                    // Ensure light mode on appear
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
                }
        }
    }
}
