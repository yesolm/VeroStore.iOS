//
//  HomeViewModel.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var banners: [Banner] = []
    @Published var trendingProducts: [Product] = []
    @Published var newArrivals: [Product] = []
    @Published var bestSellers: [Product] = []
    @Published var deals: [Product] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let productService = ProductService.shared
    private let categoryService = CategoryService.shared
    private let bannerService = BannerService.shared
    private let storeService = StoreService.shared
    
    private var cancellables = Set<AnyCancellable>()
    private var currentStoreId: Int?
    
    init() {
        // Observe store changes (like Android's preferencesManager.selectedStoreId.collect)
        storeService.$selectedStore
            .dropFirst() // Skip initial value
            .sink { [weak self] newStore in
                guard let self = self else { return }
                if let newStore = newStore, newStore.id != self.currentStoreId {
                    print("🏪 Store changed to: \(newStore.name) (id: \(newStore.id))")
                    self.currentStoreId = newStore.id
                    Task {
                        await self.loadData(forceRefresh: true)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func loadData(forceRefresh: Bool = false) async {
        // Show loading only on first load
        let isFirstLoad = banners.isEmpty && categories.isEmpty && trendingProducts.isEmpty
        
        if isFirstLoad {
            isLoading = true
        }
        error = nil
        
        // Wait for stores to load if not already loaded
        if storeService.stores.isEmpty {
            await storeService.loadStores()
        }
        
        // Wait a bit for store to be selected
        var attempts = 0
        while storeService.selectedStore == nil && attempts < 10 {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            attempts += 1
        }
        
        guard let storeId = storeService.selectedStore?.id else {
            error = "Please select a store"
            isLoading = false
            return
        }
        
        // Track current store
        currentStoreId = storeId
        
        do {
            // Load all data in parallel (like Android)
            async let categoriesTask = loadCategories(storeId: storeId)
            async let bannersTask = loadBanners(storeId: storeId)
            async let productsTask = loadProducts(storeId: storeId)
            
            // Use try? to allow partial success
            _ = try? await categoriesTask
            _ = try? await bannersTask
            _ = try? await productsTask
        } catch let error as NetworkError {
            switch error {
            case .unauthorized:
                // Not an error for home page - user can browse without login
                break
            case .serverError(let code):
                self.error = "Server error: \(code)"
            default:
                self.error = error.localizedDescription
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func loadCategories(storeId: Int) async throws {
        if storeId > 0 {
            categories = try await categoryService.getCategories(storeId: storeId)
        }
    }
    
    private func loadBanners(storeId: Int?) async throws {
        do {
            let newBanners = try await bannerService.getActiveBanners(storeId: storeId)
            banners = newBanners
            print("✅ Loaded \(banners.count) banners successfully")
        } catch {
            print("❌ Failed to load banners: \(error)")
            // Don't throw - banners are optional, but keep existing banners on error
        }
    }
    
    private func loadProducts(storeId: Int?) async throws {
        let homeProducts = try await productService.getHomePageProducts(storeId: storeId)
        trendingProducts = homeProducts.trending ?? []
        newArrivals = homeProducts.newArrivals ?? []
        bestSellers = homeProducts.bestSellers ?? []
        deals = homeProducts.deals ?? []
    }
    
    // Like Android's refreshData()
    func refresh() async {
        await loadData(forceRefresh: true)
    }
}
