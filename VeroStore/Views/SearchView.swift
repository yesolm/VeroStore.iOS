//
//  SearchView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var productService = ProductService.shared
    @StateObject private var storeService = StoreService.shared
    @StateObject private var searchHistoryManager = SearchHistoryManager.shared
    @State private var searchText = ""
    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var recentSearches: [String] = []
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom search bar with back button - NO NAVIGATION BAR
            HStack(spacing: 12) {
                // Back button
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.appPrimary)
                        .frame(width: 40, height: 40)
                }
                
                // Stylish Search field
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.appPrimary)
                        .font(.system(size: 18))
                    
                    TextField("search_products".localized, text: $searchText)
                        .focused($isSearchFocused)
                        .autocapitalization(.none)
                        .submitLabel(.search)
                        .onSubmit {
                            searchProducts()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            products = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 18))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
            
            Divider()
            
            // Content Area
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !products.isEmpty {
                // Search Results - LIST VIEW (Android style)
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(products) { product in
                            NavigationLink(destination: ProductDetailView(productId: product.id)) {
                                SearchResultRow(product: product)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            } else if searchText.isEmpty && !recentSearches.isEmpty {
                // Recent Searches (when search field is empty)
                RecentSearchesView(
                    recentSearches: recentSearches,
                    onSelectSearch: { query in
                        searchText = query
                        searchProducts()
                    },
                    onDeleteSearch: { query in
                        searchHistoryManager.removeSearch(query)
                        recentSearches = searchHistoryManager.getRecentSearches()
                    },
                    onClearAll: {
                        searchHistoryManager.clearAll()
                        recentSearches = searchHistoryManager.getRecentSearches()
                    }
                )
            } else if !searchText.isEmpty && products.isEmpty {
                // No results found
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("no_products_found".localized)
                        .foregroundColor(.gray)
                        .font(.headline)
                    Text("\"\(searchText)\"")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Empty state - show search hint
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("search_products_hint".localized)
                        .foregroundColor(.gray)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Load recent searches
            recentSearches = searchHistoryManager.getRecentSearches()
            
            // Auto-focus the search field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFocused = true
            }
        }
        .onChange(of: searchText) { newValue in
            // Real-time search as user types (debounced)
            if !newValue.isEmpty && newValue.count >= 2 {
                performDebouncedSearch()
            } else if newValue.isEmpty {
                products = []
            }
        }
    }
    
    private func searchProducts() {
        guard !searchText.isEmpty else { return }
        
        // Save to recent searches
        searchHistoryManager.addSearch(searchText)
        recentSearches = searchHistoryManager.getRecentSearches()
        
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
                await MainActor.run {
                    products = response.items
                    isLoading = false
                }
            } catch {
                print("Error searching products: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    // Debounced search for real-time typing
    private func performDebouncedSearch() {
        // Cancel previous search task if needed
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            
            // Check if search text hasn't changed
            guard !searchText.isEmpty else { return }
            
            await MainActor.run {
                searchProducts()
            }
        }
    }
}
// MARK: - Recent Searches View (Android SharedPreferences style)
struct RecentSearchesView: View {
    let recentSearches: [String]
    let onSelectSearch: (String) -> Void
    let onDeleteSearch: (String) -> Void
    let onClearAll: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("recent_searches".localized)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if !recentSearches.isEmpty {
                        Button(action: onClearAll) {
                            Text("clear_all".localized)
                                .font(.subheadline)
                                .foregroundColor(.appPrimary)
                        }
                    }
                }
                .padding()
                
                Divider()
                
                // Recent search items
                ForEach(recentSearches, id: \.self) { query in
                    Button(action: {
                        onSelectSearch(query)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            
                            Text(query)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                onDeleteSearch(query)
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .padding(.leading, 54)
                }
            }
        }
    }
}

// MARK: - Search Result Row (Android RecyclerView style)
struct SearchResultRow: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image - Square thumbnail
            AsyncImage(url: URL(string: product.primaryImageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            
            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text("$\(String(format: "%.2f", product.price))")
                    .font(.headline)
                    .foregroundColor(.appPrimary)
                
                HStack(spacing: 8) {
                    if let rating = product.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if product.stockQuantity > 0 {
                        Text("• In Stock")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("• Out of Stock")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Search History Manager (Like Android SharedPreferences)
class SearchHistoryManager: ObservableObject {
    static let shared = SearchHistoryManager()
    
    private let userDefaults = UserDefaults.standard
    private let searchHistoryKey = "recent_searches"
    private let maxHistoryCount = 10
    
    private init() {}
    
    func getRecentSearches() -> [String] {
        return userDefaults.stringArray(forKey: searchHistoryKey) ?? []
    }
    
    func addSearch(_ query: String) {
        var searches = getRecentSearches()
        
        // Remove if already exists (to move it to top)
        searches.removeAll { $0.lowercased() == query.lowercased() }
        
        // Add to beginning
        searches.insert(query, at: 0)
        
        // Keep only max count
        if searches.count > maxHistoryCount {
            searches = Array(searches.prefix(maxHistoryCount))
        }
        
        userDefaults.set(searches, forKey: searchHistoryKey)
    }
    
    func removeSearch(_ query: String) {
        var searches = getRecentSearches()
        searches.removeAll { $0 == query }
        userDefaults.set(searches, forKey: searchHistoryKey)
    }
    
    func clearAll() {
        userDefaults.removeObject(forKey: searchHistoryKey)
    }
}

