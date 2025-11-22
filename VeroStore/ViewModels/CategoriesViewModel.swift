//
//  CategoriesViewModel.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import Foundation

@MainActor
class CategoriesViewModel: ObservableObject {
    @Published var categories: [CategoryDTO] = []
    @Published var products: [ProductDTO] = []
    @Published var selectedCategory: CategoryDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared
    private let dbManager = DatabaseManager.shared

    func loadCategories() async {
        guard let store = dbManager.getDefaultStore() else {
            errorMessage = "No store selected"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            categories = try await apiService.fetchCategories(locationId: store.id)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func loadProducts(for category: CategoryDTO) async {
        guard let store = dbManager.getDefaultStore() else {
            errorMessage = "No store selected"
            return
        }

        selectedCategory = category
        isLoading = true
        errorMessage = nil

        do {
            let result = try await apiService.fetchProducts(
                pageSize: 50,
                locationId: store.id,
                categoryId: category.id
            )
            products = result.items ?? []
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
