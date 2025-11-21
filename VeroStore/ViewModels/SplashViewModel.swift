//
//  SplashViewModel.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation

@MainActor
class SplashViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var shouldShowOnboarding = false
    @Published var shouldShowMain = false

    private let apiService = APIService.shared
    private let dbManager = DatabaseManager.shared
    private let userDefaults = UserDefaults.standard

    func loadInitialData() async {
        do {
            // Fetch stores from API
            let stores = try await apiService.fetchStores()

            // Save to database
            dbManager.saveStores(stores)

            // Set default store (first one or the one marked as default)
            if let defaultStore = stores.first(where: { $0.isDefault == true }) {
                dbManager.saveDefaultStoreId(defaultStore.id)
            } else if let firstStore = stores.first {
                dbManager.saveDefaultStoreId(firstStore.id)
            }

            // Check if onboarding has been completed
            let hasCompletedOnboarding = userDefaults.bool(forKey: "has_completed_onboarding")

            await MainActor.run {
                isLoading = false
                if hasCompletedOnboarding {
                    shouldShowMain = true
                } else {
                    shouldShowOnboarding = true
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func retry() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        await loadInitialData()
    }
}
