//
//  SearchResultsView.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import SwiftUI

struct SearchResultsView: View {
    @Binding var searchText: String
    let storeId: Int
    @StateObject private var viewModel = SearchViewModel()
    @Environment(\.dismiss) var dismiss
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                        }

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)

                            TextField("Search products...", text: $searchText)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .focused($isSearchFocused)
                                .onChange(of: searchText) { _, newValue in
                                    Task {
                                        await viewModel.search(query: newValue, storeId: storeId)
                                    }
                                }
                                .onSubmit {
                                    Task {
                                        await viewModel.search(query: searchText, storeId: storeId)
                                    }
                                }

                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    viewModel.products = []
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.white)

                    // Results
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(50)
                        Spacer()
                    } else if searchText.isEmpty {
                        VStack(spacing: 15) {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Search for products")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                            Text("Try searching for electronics, fashion, or home decor")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .padding()
                    } else if viewModel.products.isEmpty {
                        VStack(spacing: 15) {
                            Spacer()
                            Image(systemName: "exclamationmark.magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No results found")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                            Text("Try different keywords")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(viewModel.products) { product in
                                    NavigationLink(destination: ProductDetailView(product: product)) {
                                        SearchResultRow(product: product)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                isSearchFocused = true
                if !searchText.isEmpty {
                    Task {
                        await viewModel.search(query: searchText, storeId: storeId)
                    }
                }
            }
        }
    }
}

struct SearchResultRow: View {
    let product: ProductDTO

    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            AsyncImage(url: URL(string: product.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(UIColor.systemGray6))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)

            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name ?? "Product")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.starYellow)
                        .font(.system(size: 10))

                    Text(String(format: "%.1f", product.rating))
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                }

                HStack(spacing: 6) {
                    if let discounted = product.discountedPrice {
                        Text("$\(String(format: "%.2f", discounted))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primaryOrange)

                        Text("$\(String(format: "%.2f", product.price))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .strikethrough()
                    } else {
                        Text("$\(String(format: "%.2f", product.price))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primaryOrange)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 12))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

@MainActor
class SearchViewModel: ObservableObject {
    @Published var products: [ProductDTO] = []
    @Published var isLoading = false

    private let apiService = APIService.shared
    private var searchTask: Task<Void, Never>?

    func search(query: String, storeId: Int) async {
        // Cancel previous search
        searchTask?.cancel()

        guard !query.isEmpty else {
            products = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s debounce

            guard !Task.isCancelled else { return }

            isLoading = true

            do {
                let result = try await apiService.fetchProducts(
                    pageSize: 50,
                    searchTerm: query,
                    locationId: storeId
                )
                if !Task.isCancelled {
                    products = result.items ?? []
                }
                isLoading = false
            } catch {
                if !Task.isCancelled {
                    products = []
                    isLoading = false
                }
            }
        }

        await searchTask?.value
    }
}

#Preview {
    SearchResultsView(searchText: .constant("headphones"), storeId: 1)
}
