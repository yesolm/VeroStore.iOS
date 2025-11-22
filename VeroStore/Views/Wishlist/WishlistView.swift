//
//  WishlistView.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import SwiftUI

struct WishlistView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var wishlistManager = WishlistManager.shared
    @State private var showLogin = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                if !authManager.isAuthenticated {
                    // Not logged in state
                    VStack(spacing: 30) {
                        Spacer()

                        Image(systemName: "heart")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)

                        VStack(spacing: 10) {
                            Text("Your Wishlist Awaits")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)

                            Text("Login to save your favorite items")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: {
                            showLogin = true
                        }) {
                            Text("Login / Sign Up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.primaryOrange)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)

                        Spacer()
                    }
                } else if wishlistManager.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryOrange))
                            .scaleEffect(1.5)

                        Text("Loading wishlist...")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                } else if wishlistManager.wishlistItems.isEmpty {
                    // Empty wishlist
                    VStack(spacing: 30) {
                        Spacer()

                        Image(systemName: "heart")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)

                        VStack(spacing: 10) {
                            Text("Your wishlist is empty")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)

                            Text("Add items you love to your wishlist")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }

                        Spacer()
                    }
                } else {
                    // Wishlist with items
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(wishlistManager.wishlistItems) { product in
                                NavigationLink(destination: ProductDetailView(product: product)) {
                                    WishlistItemRow(product: product)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Wishlist")
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
        }
    }
}

struct WishlistItemRow: View {
    let product: ProductDTO
    @StateObject private var wishlistManager = WishlistManager.shared

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
            .cornerRadius(10)

            // Product Info
            VStack(alignment: .leading, spacing: 8) {
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

            // Heart icon - tap to remove
            Button(action: {
                Task {
                    await wishlistManager.removeFromWishlist(productId: product.id)
                }
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    WishlistView()
}
