//
//  SearchView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct SearchView: View {
    @StateObject private var productService = ProductService.shared
    @StateObject private var storeService = StoreService.shared
    @State private var searchText = ""
    @State private var products: [Product] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if products.isEmpty && !searchText.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No products found")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(products) { product in
                                NavigationLink(destination: ProductDetailView(productId: product.id)) {
                                    ProductCardView(product: product)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("search".localized)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "search_products".localized)
            .onChange(of: searchText) { newValue in
                if !newValue.isEmpty {
                    searchProducts()
                } else {
                    products = []
                }
            }
    }
    
    private func searchProducts() {
        guard !searchText.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                let storeId = storeService.selectedStore?.id
                let response = try await productService.getProducts(
                    page: 1,
                    pageSize: 50,
                    searchTerm: searchText,
                    storeId: storeId
                )
                products = response.items
            } catch {
                print("Error searching products: \(error)")
            }
            isLoading = false
        }
    }
}
