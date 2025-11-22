//
//  HomeView.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var showSearchResults = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 15) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)

                            TextField("Search products...", text: $searchText)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .onTapGesture {
                                    showSearchResults = true
                                }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        // Store and Categories Row
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Store Selector
                                StoreSelector(viewModel: viewModel)

                                // Category Bubbles
                                ForEach(viewModel.categories.prefix(6)) { category in
                                    CategoryBubble(category: category) {
                                        // Filter by category
                                        Task {
                                            await viewModel.loadProducts(categoryId: category.id)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                    .background(Color.white)

                    // Content
                    ScrollView {
                        VStack(spacing: 20) {
                            if viewModel.isLoading && viewModel.banners.isEmpty {
                                ProgressView()
                                    .padding(50)
                            } else if let error = viewModel.errorMessage {
                                ErrorView(error: error) {
                                    Task { await viewModel.loadData() }
                                }
                            } else {
                                // Banners
                                if !viewModel.banners.isEmpty {
                                    BannersCarousel(banners: viewModel.banners)
                                }

                                // Products Section
                                ProductsSection(
                                    title: "Available in \(viewModel.selectedStore?.city ?? "Your Area")",
                                    products: viewModel.products
                                )
                            }
                        }
                    }
                    .background(Color.white)
                    .refreshable {
                        await viewModel.loadData()
                    }
                }
            }
            .task {
                await viewModel.loadDataIfNeeded()
            }
            .sheet(isPresented: $showSearchResults) {
                SearchResultsView(searchText: $searchText, storeId: viewModel.selectedStore?.id ?? 0)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StoreSelector: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showStoreSelection = false

    var body: some View {
        Button(action: {
            showStoreSelection = true
        }) {
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .foregroundColor(.primaryOrange)
                    .font(.system(size: 12))

                Text(viewModel.selectedStore?.city ?? "Select Store")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)

                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .font(.system(size: 10))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(20)
        }
        .sheet(isPresented: $showStoreSelection) {
            StoreSelectionSheet(viewModel: viewModel, isPresented: $showStoreSelection)
        }
    }
}

struct StoreSelectionSheet: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isPresented: Bool
    @State private var stores: [StoreDTO] = []

    var body: some View {
        NavigationView {
            List(stores) { store in
                Button(action: {
                    viewModel.selectStore(store)
                    isPresented = false
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.name ?? "Store")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)

                            Text("\(store.city ?? ""), \(store.state ?? "")")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        if store.id == viewModel.selectedStore?.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.primaryOrange)
                        }
                    }
                }
            }
            .navigationTitle("Select Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            stores = DatabaseManager.shared.getStores() ?? []
        }
    }
}

struct CategoryBubble: View {
    let category: CategoryDTO
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.name ?? "")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
        }
    }
}

struct ErrorView: View {
    let error: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Error: \(error)")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)

            Button("Retry") {
                retry()
            }
            .foregroundColor(.primaryOrange)
        }
        .padding(50)
    }
}

struct BannersCarousel: View {
    let banners: [BannerDTO]
    @State private var currentIndex = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                AsyncImage(url: URL(string: banner.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(UIColor.systemGray6))
                }
                .frame(height: 180)
                .clipped()
                .tag(index)
            }
        }
        .frame(height: 180)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}

struct ProductsSection: View {
    let title: String
    let products: [ProductDTO]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ],
                spacing: 15
            ) {
                ForEach(products) { product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        ProductCard(product: product)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 20)
    }
}

struct ProductCard: View {
    let product: ProductDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
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
                .frame(height: 150)
                .clipped()
                .cornerRadius(10)

                if let discount = product.discountPercentage {
                    Text("\(discount)% OFF")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                        .padding(8)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name ?? "Product")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.starYellow)
                        .font(.system(size: 10))

                    Text(String(format: "%.1f", product.rating))
                        .font(.system(size: 12))
                        .foregroundColor(.black)

                    Text("(\(product.reviewCount))")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
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
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
}
