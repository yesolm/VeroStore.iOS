//
//  AppDelegate.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//
//  UNCOMMENT THE LINE BELOW IN INIT TO RESET ONBOARDING FOR TESTING

import Foundation

class AppSettings {
    static let shared = AppSettings()

    private let userDefaults = UserDefaults.standard

    func resetOnboarding() {
        userDefaults.removeObject(forKey: "has_completed_onboarding")
        print("✅ Onboarding reset - will show on next launch")
    }

    func resetAll() {
        // Reset onboarding
        userDefaults.removeObject(forKey: "has_completed_onboarding")

        // Clear auth
        AuthManager.shared.currentUser = nil
        AuthManager.shared.isAuthenticated = false
        APIClient.shared.clearTokens()

        // Clear database
        DatabaseManager.shared.clearAll()

        print("✅ All app data reset")
    }
}
