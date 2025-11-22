//
//  HomeViewModel.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var banners: [BannerDTO] = []
    @Published var categories: [CategoryDTO] = []
    @Published var products: [ProductDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedStore: StoreDTO?

    private let apiService = APIService.shared
    private let dbManager = DatabaseManager.shared
    private var hasLoadedInitialData = false

    init() {
        selectedStore = dbManager.getDefaultStore()
    }

    func loadDataIfNeeded() async {
        guard !hasLoadedInitialData else {
            print("📊 Data already loaded, skipping...")
            return
        }
        await loadData()
        hasLoadedInitialData = true
    }

    func loadData() async {
        guard let store = selectedStore ?? dbManager.getDefaultStore() else {
            errorMessage = "No store selected"
            return
        }

        selectedStore = store
        isLoading = true
        errorMessage = nil

        async let bannersTask = apiService.fetchActiveBanners(storeId: store.id)
        async let categoriesTask = apiService.fetchCategories(locationId: store.id)
        async let productsTask = apiService.fetchProducts(pageSize: 20, locationId: store.id)

        do {
            let (fetchedBanners, fetchedCategories, fetchedProducts) = try await (bannersTask, categoriesTask, productsTask)

            banners = fetchedBanners
            categories = fetchedCategories
            products = fetchedProducts.items ?? []
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func searchProducts(query: String) async {
        guard let store = selectedStore else { return }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await apiService.fetchProducts(
                pageSize: 20,
                searchTerm: query,
                locationId: store.id
            )
            products = result.items ?? []
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
