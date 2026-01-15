//
//  StoreService.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

@MainActor
class StoreService: ObservableObject {
    static let shared = StoreService()
    
    @Published var stores: [Store] = []
    @Published var selectedStore: Store?
    @Published var isChangingStore = false // Loading indicator during store change
    
    private let networkService = NetworkService.shared
    private let userDefaults = UserDefaults.standard
    private let selectedStoreKey = "selected_store_id"
    
    private init() {
        Task {
            await loadStores()
        }
    }
    
    func loadStores() async {
        do {
            stores = try await networkService.request([Store].self, endpoint: "Stores")
            loadSelectedStore()
            if selectedStore == nil, let firstStore = stores.first {
                // Don't trigger change notification for initial selection
                selectedStore = firstStore
                userDefaults.set(firstStore.id, forKey: selectedStoreKey)
            }
        } catch {
            print("Error loading stores: \(error)")
        }
    }
    
    // Like Android's changeStore() in HomeViewModel
    func selectStore(_ store: Store) {
        let previousStoreId = selectedStore?.id
        
        // Only proceed if store actually changed
        guard previousStoreId != store.id else { return }
        
        isChangingStore = true
        print("🏪 Changing store from \(previousStoreId ?? 0) to \(store.id)")
        
        // Clear cart when switching stores (like Android)
        Task {
            await CartService.shared.clearCart()
        }
        
        // Update selected store - this triggers the publisher
        selectedStore = store
        userDefaults.set(store.id, forKey: selectedStoreKey)
        
        isChangingStore = false
    }
    
    private func loadSelectedStore() {
        if let storeId = userDefaults.object(forKey: selectedStoreKey) as? Int,
           let store = stores.first(where: { $0.id == storeId }) {
            selectedStore = store
        }
    }
}
