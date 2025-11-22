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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 15) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.mediumGray)

                            TextField("Search products...", text: $searchText)
                                .font(.system(size: 16))
                                .onSubmit {
                                    Task {
                                        await viewModel.searchProducts(query: searchText)
                                    }
                                }

                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    Task {
                                        await viewModel.loadData()
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.mediumGray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.lightGray)
                        .cornerRadius(10)
                        .padding(.horizontal)

                        // Location Selector
                        if let store = viewModel.selectedStore {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.primaryOrange)
                                    .font(.system(size: 14))

                                Text(store.city ?? "New York")
                                    .font(.system(size: 14, weight: .medium))

                                Image(systemName: "chevron.down")
                                    .foregroundColor(.mediumGray)
                                    .font(.system(size: 12))

                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .background(Color.white)

                    // Content
                    if viewModel.isLoading && viewModel.banners.isEmpty {
                        ProgressView()
                            .padding(50)
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 20) {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)

                            Button("Retry") {
                                Task {
                                    await viewModel.loadData()
                                }
                            }
                            .foregroundColor(.primaryOrange)
                        }
                        .padding(50)
                    } else {
                        VStack(spacing: 20) {
                            // Banners
                            if !viewModel.banners.isEmpty {
                                BannersCarousel(banners: viewModel.banners)
                            }

                            // Categories
                            if !viewModel.categories.isEmpty {
                                CategoriesSection(categories: viewModel.categories)
                            }

                            // Products Section
                            ProductsSection(
                                title: "Available in \(viewModel.selectedStore?.city ?? "Your Area")",
                                products: viewModel.products
                            )
                        }
                    }
                }
            }
            .background(Color.white)
            .refreshable {
                await viewModel.loadData()
            }
            .task {
                await viewModel.loadDataIfNeeded()
            }
        }
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
                        .fill(Color.lightGray)
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

struct CategoriesSection: View {
    let categories: [CategoryDTO]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Categories")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categories.prefix(6)) { category in
                        CategoryCard(category: category)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CategoryCard: View {
    let category: CategoryDTO

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: category.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.lightGray)
                    .overlay(
                        Image(systemName: "square.grid.2x2")
                            .foregroundColor(.mediumGray)
                    )
            }
            .frame(width: 100, height: 80)
            .cornerRadius(10)

            Text(category.name ?? "")
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
        }
        .frame(width: 100)
    }
}

struct ProductsSection: View {
    let title: String
    let products: [ProductDTO]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ],
                spacing: 15
            ) {
                ForEach(products) { product in
                    ProductCard(product: product)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 20)
    }
}

struct ProductCard: View {
    let product: ProductDTO
    @StateObject private var cartManager = CartManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: product.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.lightGray)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.mediumGray)
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
                Text(product.name ?? "")
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.starYellow)
                        .font(.system(size: 10))

                    Text(String(format: "%.1f", product.rating))
                        .font(.system(size: 12))
                        .foregroundColor(.darkGray)

                    Text("(\(product.reviewCount))")
                        .font(.system(size: 10))
                        .foregroundColor(.mediumGray)
                }

                HStack(spacing: 6) {
                    if let discounted = product.discountedPrice {
                        Text("$\(String(format: "%.2f", discounted))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primaryOrange)

                        Text("$\(String(format: "%.2f", product.price))")
                            .font(.system(size: 12))
                            .foregroundColor(.mediumGray)
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
        .onTapGesture {
            Task {
                await cartManager.addToCart(productId: product.id)
            }
        }
    }
}

struct CategoriesView: View {
    var body: some View {
        NavigationView {
            Text("Categories")
                .navigationTitle("Categories")
        }
    }
}

#Preview {
    HomeView()
}
