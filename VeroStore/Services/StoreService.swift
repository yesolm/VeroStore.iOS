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
                selectStore(firstStore)
            }
        } catch {
            print("Error loading stores: \(error)")
        }
    }
    
    func selectStore(_ store: Store) {
        let previousStoreId = selectedStore?.id
        selectedStore = store
        userDefaults.set(store.id, forKey: selectedStoreKey)
        
        if let previousStoreId = previousStoreId, previousStoreId != store.id {
            Task {
                await CartService.shared.clearCart()
            }
        }
    }
    
    private func loadSelectedStore() {
        if let storeId = userDefaults.object(forKey: selectedStoreKey) as? Int,
           let store = stores.first(where: { $0.id == storeId }) {
            selectedStore = store
        }
    }
}
