//
//  CategoriesView.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var showProductList = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Categories")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)

                            Text("Browse products by category")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)

                        if viewModel.isLoading && viewModel.categories.isEmpty {
                            // Loading State
                            VStack(spacing: 20) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryOrange))
                                    .scaleEffect(1.5)

                                Text("Loading categories...")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else if let error = viewModel.errorMessage {
                            // Error State
                            VStack(spacing: 15) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red)

                                Text(error)
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)

                                Button(action: {
                                    Task {
                                        await viewModel.loadCategories()
                                    }
                                }) {
                                    Text("Retry")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 12)
                                        .background(Color.primaryOrange)
                                        .cornerRadius(10)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else if viewModel.categories.isEmpty {
                            // Empty State
                            VStack(spacing: 15) {
                                Image(systemName: "square.grid.2x2")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)

                                Text("No categories available")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else {
                            // Categories Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 15),
                                GridItem(.flexible(), spacing: 15)
                            ], spacing: 15) {
                                ForEach(viewModel.categories) { category in
                                    CategoryGridCard(category: category) {
                                        Task {
                                            await viewModel.loadProducts(for: category)
                                            showProductList = true
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .refreshable {
                    await viewModel.loadCategories()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showProductList) {
                if let category = viewModel.selectedCategory {
                    CategoryProductsView(
                        category: category,
                        products: viewModel.products,
                        isLoading: viewModel.isLoading
                    )
                }
            }
        }
        .task {
            await viewModel.loadCategories()
        }
    }
}

struct CategoryGridCard: View {
    let category: CategoryDTO
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(Color.primaryOrange.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: categoryIcon(for: category.name ?? ""))
                        .font(.system(size: 35))
                        .foregroundColor(.primaryOrange)
                }

                // Category Name
                Text(category.name ?? "Category")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }

    private func categoryIcon(for name: String) -> String {
        let lowercased = name.lowercased()

        if lowercased.contains("electronic") || lowercased.contains("tech") {
            return "laptopcomputer"
        } else if lowercased.contains("cloth") || lowercased.contains("fashion") || lowercased.contains("apparel") {
            return "tshirt.fill"
        } else if lowercased.contains("food") || lowercased.contains("grocery") {
            return "cart.fill"
        } else if lowercased.contains("home") || lowercased.contains("furniture") {
            return "house.fill"
        } else if lowercased.contains("book") || lowercased.contains("media") {
            return "book.fill"
        } else if lowercased.contains("sport") || lowercased.contains("fitness") {
            return "sportscourt.fill"
        } else if lowercased.contains("toy") || lowercased.contains("game") {
            return "gamecontroller.fill"
        } else if lowercased.contains("beauty") || lowercased.contains("health") {
            return "heart.fill"
        } else if lowercased.contains("pet") {
            return "pawprint.fill"
        } else if lowercased.contains("garden") || lowercased.contains("outdoor") {
            return "leaf.fill"
        } else {
            return "square.grid.2x2.fill"
        }
    }
}

struct CategoryProductsView: View {
    let category: CategoryDTO
    let products: [ProductDTO]
    let isLoading: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                if isLoading && products.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryOrange))
                            .scaleEffect(1.5)

                        Text("Loading products...")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                } else if products.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "bag")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("No products in this category")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(products) { product in
                                NavigationLink(destination: ProductDetailView(product: product)) {
                                    CategoryProductRow(product: product)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(category.name ?? "Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

struct CategoryProductRow: View {
    let product: ProductDTO

    var body: some View {
        HStack(spacing: 15) {
            // Product Image
            AsyncImage(url: URL(string: product.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(UIColor.systemGray6))
                    .overlay(
                        ProgressView()
                    )
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            .clipped()

            // Product Details
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name ?? "Product")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)

                // Rating
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(product.rating) ? "star.fill" : "star")
                            .foregroundColor(.starYellow)
                            .font(.system(size: 12))
                    }

                    Text(String(format: "%.1f", product.rating))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                // Price
                HStack(spacing: 8) {
                    if let discounted = product.discountedPrice {
                        Text("$\(String(format: "%.2f", discounted))")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primaryOrange)

                        Text("$\(String(format: "%.2f", product.price))")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .strikethrough()
                    } else {
                        Text("$\(String(format: "%.2f", product.price))")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primaryOrange)
                    }
                }
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    CategoriesView()
}
