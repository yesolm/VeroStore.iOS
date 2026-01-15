//
//
//  HomeView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI
import WebKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var storeService = StoreService.shared
    @State private var showStoreSelector = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Search bar - first row
                    NavigationLink(destination: SearchView()) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("search_products".localized)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        VStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(2.0)
                                .tint(.appPrimary)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 400)
                    } else if let error = viewModel.error {
                        ErrorView(message: error) {
                            Task {
                                await viewModel.refresh()
                            }
                        }
                    } else {
                        // Determine if store selector should be shown
                        let shouldShowStoreSelector = !viewModel.isLoading && !viewModel.categories.isEmpty
                        
                        // Store Selector or Skeleton
                        if shouldShowStoreSelector {
                            CategoryChipsView(
                                categories: viewModel.categories,
                                showStoreSelector: $showStoreSelector,
                                selectedStore: storeService.selectedStore
                            )
                            
                            // Progress bar under categories
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(LinearProgressViewStyle(tint: .appPrimary))
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                            }
                        } else {
                            // Skeleton for store selector
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 40)
                                .padding(.horizontal)
                                .redacted(reason: .placeholder)
                        }
                        
                        // Banners - Android ViewPager2 style carousel (AFTER categories)
                        if !viewModel.banners.isEmpty {
                            BannerCarouselView(banners: viewModel.banners)
                        }
                        
                        // Trending Products
                        if !viewModel.trendingProducts.isEmpty {
                            ProductGridSectionView(
                                title: storeService.selectedStore != nil ? "\(String(format: "available_in".localized)) \(storeService.selectedStore!.name)" : "trending".localized,
                                products: viewModel.trendingProducts
                            )
                        } else if viewModel.isLoading {
                            // Trending products skeleton
                            VStack(alignment: .leading, spacing: 10) {
                                Text("trending".localized)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                    .redacted(reason: .placeholder)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                                    ForEach(0..<4) { _ in
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 250)
                                            .redacted(reason: .placeholder)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // New Arrivals
                        if !viewModel.newArrivals.isEmpty {
                            ProductGridSectionView(
                                title: "new_arrivals".localized,
                                products: viewModel.newArrivals
                            )
                        } else if viewModel.isLoading {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("new_arrivals".localized)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                    .redacted(reason: .placeholder)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                                    ForEach(0..<4) { _ in
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 250)
                                            .redacted(reason: .placeholder)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Best Sellers
                        if !viewModel.bestSellers.isEmpty {
                            ProductGridSectionView(
                                title: "best_sellers".localized,
                                products: viewModel.bestSellers
                            )
                        } else if viewModel.isLoading {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("best_sellers".localized)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                    .redacted(reason: .placeholder)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                                    ForEach(0..<4) { _ in
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 250)
                                            .redacted(reason: .placeholder)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Deals
                        if !viewModel.deals.isEmpty {
                            ProductGridSectionView(
                                title: "deals".localized,
                                products: viewModel.deals
                            )
                        } else if viewModel.isLoading {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("deals".localized)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                    .redacted(reason: .placeholder)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                                    ForEach(0..<4) { _ in
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 250)
                                            .redacted(reason: .placeholder)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView()
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                Task {
                    await viewModel.loadData()
                }
            }
            .sheet(isPresented: $showStoreSelector) {
                StoreSelectorView()
            }
        }
    }
}

struct BannerCarouselView: View {
    let banners: [Banner]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                    NavigationLink(destination: destinationView(for: banner)) {
                        BannerCardView(banner: banner)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 48)
        }
        .frame(height: 380)
    }
    
    @ViewBuilder
    private func destinationView(for banner: Banner) -> some View {
        switch banner.linkType?.lowercased() {
        case "product":
            if let productId = banner.linkProductId {
                ProductDetailView(productId: productId)
            } else {
                EmptyView()
            }
        case "category":
            if let categoryId = banner.linkCategoryId {
                ProductsListView(categoryId: categoryId, categoryName: banner.title ?? "Category")
            } else {
                EmptyView()
            }
        case "url", "external":
            if let urlString = banner.linkUrl, let url = URL(string: urlString) {
                SafariView(url: url)
            } else {
                EmptyView()
            }
        default:
            EmptyView()
        }
    }
}

struct BannerCardView: View {
    let banner: Banner
    
    var body: some View {
        let cardWidth = UIScreen.main.bounds.width - 16 - 48 - 8
        
        ZStack(alignment: .topLeading) {
            // Banner image as background
            AsyncImage(url: URL(string: banner.imageUrl)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                @unknown default:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                }
            }
            .frame(width: cardWidth, height: 380)
            .clipped()
            
            // Title overlay at top
            if let title = banner.title, !title.isEmpty {
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .lineLimit(2)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
            }
        }
        .frame(width: cardWidth, height: 380)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
    }
}

// MARK: - Safari View for External Links
struct SafariView: View {
    let url: URL
    
    var body: some View {
        WebView(url: url)
            .navigationTitle("Loading...")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// Simple WebView wrapper for external URLs
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// Import WebKit at the top of the file
import WebKit

// Keep old grid view for backward compatibility (used in ProfileView)
struct BannerGridView: View {
    let banners: [Banner]
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(banners) { banner in
                AsyncImage(url: URL(string: banner.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: .infinity, height: 150)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(height: 150)  // Force fixed height
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}

struct CategoryChipsView: View {
    let categories: [Category]
    @Binding var showStoreSelector: Bool
    let selectedStore: Store?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Store selector as first item (small chip)
                Button(action: {
                    showStoreSelector = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "storefront.fill")
                            .font(.system(size: 12))
                        Text(selectedStore?.name ?? "select_store".localized)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(height: 40)
                    .background(Color.appPrimary.opacity(0.1))
                    .foregroundColor(.appPrimary)
                    .cornerRadius(20)
                }
                
                // Categories - Navigate to ProductsListView like in CategoriesView
                ForEach(categories) { category in
                    NavigationLink(destination: ProductsListView(categoryId: category.id, categoryName: category.name)) {
                        Text(category.name)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 0)
        }
    }
}

struct ProductGridSectionView: View {
    let title: String
    let products: [Product]
    private let columns = [
        GridItem(.fixed(170), spacing: 15),
        GridItem(.fixed(170), spacing: 15)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(products) { product in
                    NavigationLink(destination: ProductDetailView(productId: product.id)) {
                        ProductCardView(product: product)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ProductCardView: View {
    let product: Product
    
    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image - edge to edge on top and sides, FIXED HEIGHT
            AsyncImage(url: URL(string: product.primaryImageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                                .tint(.appPrimary)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 170, height: 180)
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
            .frame(width: 170, height: 180)
            
            // Product info with padding - FIXED HEIGHT
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Spacer(minLength: 0)
                
                Text("$\(ProductCardView.priceFormatter.string(from: NSNumber(value: product.price)) ?? String(format: "%.2f", product.price))")
                    .font(.headline)
                    .foregroundColor(.appPrimary)
            }
            .padding(12)
            .frame(width: 170, alignment: .leading)
            .frame(height: 80)
        }
        .frame(width: 170, height: 260)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
