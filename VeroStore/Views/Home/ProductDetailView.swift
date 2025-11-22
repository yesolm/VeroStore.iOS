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
    @State private var isInWishlist = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Product Image with overlay buttons
                ZStack(alignment: .topLeading) {
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

                    // Top buttons overlay
                    HStack {
                        // Back button
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                                .font(.system(size: 18, weight: .medium))
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }

                        Spacer()

                        // Heart button
                        Button(action: {
                            isInWishlist.toggle()
                            // TODO: Add to wishlist
                        }) {
                            Image(systemName: isInWishlist ? "heart.fill" : "heart")
                                .foregroundColor(isInWishlist ? .red : .black)
                                .font(.system(size: 18, weight: .medium))
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }

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
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(UIColor.systemGray4), lineWidth: 1.5)
                                    )
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

                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)

                    // Show toast
                    withAnimation {
                        showAddedToCart = true
                    }

                    // Auto-hide after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showAddedToCart = false
                        }
                    }
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

        // Toast Overlay
        if showAddedToCart {
            VStack {
                Spacer()

                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))

                    Text("Added to Cart")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.8))
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

                Spacer()
                    .frame(height: 100)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .zIndex(999)
        }
        }
        .background(Color.white)
        .navigationBarHidden(true)
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
