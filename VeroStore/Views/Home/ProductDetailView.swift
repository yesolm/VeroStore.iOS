//
//  ProductDetailView.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import SwiftUI

struct ProductDetailView: View {
    let product: ProductDTO
    @StateObject private var cartManager = CartManager.shared
    @State private var quantity = 1
    @State private var showAddedToCart = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .clipped()

                VStack(alignment: .leading, spacing: 15) {
                    // Product Name
                    Text(product.name ?? "Product")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)

                    // Rating
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(product.rating) ? "star.fill" : "star")
                                    .foregroundColor(.starYellow)
                                    .font(.system(size: 14))
                            }
                        }

                        Text(String(format: "%.1f", product.rating))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)

                        Text("(\(product.reviewCount) reviews)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }

                    // Price
                    HStack(spacing: 10) {
                        if let discounted = product.discountedPrice {
                            Text("$\(String(format: "%.2f", discounted))")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primaryOrange)

                            Text("$\(String(format: "%.2f", product.price))")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                                .strikethrough()

                            if let discount = product.discountPercentage {
                                Text("\(discount)% OFF")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .cornerRadius(4)
                            }
                        } else {
                            Text("$\(String(format: "%.2f", product.price))")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primaryOrange)
                        }
                    }

                    Divider()

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)

                        Text(product.description ?? "No description available")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .lineSpacing(4)
                    }

                    Divider()

                    // Quantity Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quantity")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)

                        HStack(spacing: 15) {
                            Button(action: {
                                if quantity > 1 {
                                    quantity -= 1
                                }
                            }) {
                                Image(systemName: "minus")
                                    .foregroundColor(.black)
                                    .frame(width: 40, height: 40)
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(8)
                            }

                            Text("\(quantity)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .frame(minWidth: 50)

                            Button(action: {
                                quantity += 1
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.primaryOrange)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            // Add to Cart Button
            Button(action: {
                Task {
                    await cartManager.addToCart(
                        productId: product.id,
                        quantity: quantity,
                        productName: product.name,
                        productImageUrl: product.imageUrl,
                        productPrice: product.discountedPrice ?? product.price
                    )
                    showAddedToCart = true
                }
            }) {
                HStack {
                    Image(systemName: "cart.fill")
                    Text("Add to Cart")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.primaryOrange)
                .cornerRadius(12)
            }
            .padding()
            .background(Color.white)
        }
        .alert("Added to Cart", isPresented: $showAddedToCart) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(product.name ?? "Product") has been added to your cart")
        }
    }
}

#Preview {
    NavigationView {
        ProductDetailView(product: ProductDTO(
            id: 1,
            uuid: UUID(),
            name: "Wireless Bluetooth Headphones",
            description: "Premium quality wireless headphones with noise cancellation",
            sku: "WBH-001",
            price: 249.99,
            cost: 100.00,
            categoryId: 1,
            categoryName: "Electronics",
            imageUrl: nil,
            isBestSeller: true,
            isNewArrival: false,
            discountedPrice: 199.99,
            isActive: true,
            created: Date(),
            updated: Date(),
            storeInventory: nil
        ))
    }
}
