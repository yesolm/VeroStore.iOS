//
//  ProductsListView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct ProductsListView: View {
    let categoryId: Int?
    let categoryName: String
    @StateObject private var productService = ProductService.shared
    @StateObject private var storeService = StoreService.shared
    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var page = 1
    @State private var hasMore = true
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(products) { product in
                    NavigationLink(destination: ProductDetailView(productId: product.id)) {
                        ProductCardView(product: product)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .navigationTitle(categoryName)
        .onAppear {
            loadProducts()
        }
        .onChange(of: products.count) { _ in
            if !isLoading && hasMore {
                loadMoreProducts()
            }
        }
    }
    
    private func loadProducts() {
        guard hasMore && !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let storeId = storeService.selectedStore?.id
                let response = try await productService.getProducts(
                    page: page,
                    pageSize: 20,
                    storeId: storeId,
                    categoryId: categoryId
                )
                
                if page == 1 {
                    products = response.items
                } else {
                    products.append(contentsOf: response.items)
                }
                
                hasMore = response.page < response.totalPages
                page += 1
            } catch {
                print("Error loading products: \(error)")
            }
            isLoading = false
        }
    }
    
    private func loadMoreProducts() {
        guard hasMore && !isLoading else { return }
        loadProducts()
    }
}
