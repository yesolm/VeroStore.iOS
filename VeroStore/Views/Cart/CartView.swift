//
//  CartView.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import SwiftUI

struct CartView: View {
    @StateObject private var cartManager = CartManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showLogin = false
    @State private var navigateToCheckout = false

    var body: some View {
        NavigationView {
            if !authManager.isAuthenticated {
                // Not logged in state - show local cart
                if !cartManager.localCartItems.isEmpty {
                    // Local cart with items
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(cartManager.localCartItems) { item in
                                    LocalCartItemView(item: item)
                                }
                            }
                            .padding()
                        }

                        // Bottom Section
                        VStack(spacing: 15) {
                            // Total
                            HStack {
                                Text("Total:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)

                                Spacer()

                                Text("$\(String(format: "%.2f", cartManager.localCartItems.reduce(0) { $0 + ($1.productPrice * Double($1.quantity)) }))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primaryOrange)
                            }

                            // Login to Checkout
                            Button(action: {
                                showLogin = true
                            }) {
                                Text("Login to Checkout")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.primaryOrange)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                    }
                    .navigationTitle("Shopping Cart")
                } else {
                    // Empty local cart
                    VStack(spacing: 30) {
                        Spacer()

                        Image(systemName: "cart")
                            .font(.system(size: 80))
                            .foregroundColor(.mediumGray)

                        VStack(spacing: 10) {
                            Text("Your cart is empty")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)

                            Text("Start shopping to add items")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }

                        Spacer()
                    }
                    .background(Color.white.ignoresSafeArea())
                    .navigationTitle("Shopping Cart")
                }

                // Sheet for login
            } else if let cart = cartManager.cart, let items = cart.items, !items.isEmpty {
                // Cart with items
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(items, id: \.productId) { item in
                                CartItemView(item: item)
                            }
                        }
                        .padding()
                    }

                    // Bottom Checkout Section
                    VStack(spacing: 15) {
                        // Total
                        HStack {
                            Text("Total:")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)

                            Spacer()

                            Text("$\(String(format: "%.2f", cart.totalAmount))")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primaryOrange)
                        }

                        // Checkout Button
                        NavigationLink(
                            destination: CheckoutView(cart: cart),
                            isActive: $navigateToCheckout
                        ) {
                            EmptyView()
                        }
                        .hidden()

                        Button(action: {
                            navigateToCheckout = true
                        }) {
                            Text("Proceed to Checkout")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.primaryOrange)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
                .navigationTitle("Shopping Cart")
            } else {
                // Empty cart
                VStack(spacing: 30) {
                    Spacer()

                    Image(systemName: "cart")
                        .font(.system(size: 80))
                        .foregroundColor(.mediumGray)

                    VStack(spacing: 10) {
                        Text("Your cart is empty")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)

                        Text("Add items to get started")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .background(Color.white.ignoresSafeArea())
                .navigationTitle("Shopping Cart")
            }
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        .task {
            if authManager.isAuthenticated {
                await cartManager.fetchCart()
            }
        }
    }
}

struct CartItemView: View {
    let item: CartItemDTO
    @StateObject private var cartManager = CartManager.shared
    @State private var quantity: Int

    init(item: CartItemDTO) {
        self.item = item
        _quantity = State(initialValue: item.quantity)
    }

    var body: some View {
        HStack(spacing: 15) {
            // Product Image
            AsyncImage(url: URL(string: item.productImageUrl ?? "")) { image in
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
            .frame(width: 80, height: 80)
            .cornerRadius(10)

            // Product Info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.productName ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)

                Text("$\(String(format: "%.2f", item.productPrice))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primaryOrange)

                // Quantity Controls
                HStack(spacing: 15) {
                    Button(action: {
                        if quantity > 1 {
                            quantity -= 1
                            Task {
                                await cartManager.updateQuantity(productId: item.productId, quantity: quantity)
                            }
                        }
                    }) {
                        Image(systemName: "minus")
                            .foregroundColor(.darkGray)
                            .frame(width: 30, height: 30)
                            .background(Color.lightGray)
                            .cornerRadius(6)
                    }

                    Text("\(quantity)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(minWidth: 30)

                    Button(action: {
                        quantity += 1
                        Task {
                            await cartManager.updateQuantity(productId: item.productId, quantity: quantity)
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.primaryOrange)
                            .cornerRadius(6)
                    }

                    Spacer()

                    // Delete Button
                    Button(action: {
                        Task {
                            await cartManager.removeItem(productId: item.productId)
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct LocalCartItemView: View {
    let item: LocalCartItem
    @StateObject private var cartManager = CartManager.shared
    @State private var quantity: Int

    init(item: LocalCartItem) {
        self.item = item
        _quantity = State(initialValue: item.quantity)
    }

    var body: some View {
        HStack(spacing: 15) {
            // Product Image
            AsyncImage(url: URL(string: item.productImageUrl ?? "")) { image in
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
            .frame(width: 80, height: 80)
            .cornerRadius(10)

            // Product Info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.productName ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)

                Text("$\(String(format: "%.2f", item.productPrice))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primaryOrange)

                // Quantity Controls
                HStack(spacing: 15) {
                    Button(action: {
                        if quantity > 1 {
                            quantity -= 1
                            Task {
                                await cartManager.updateQuantity(productId: item.productId, quantity: quantity)
                            }
                        }
                    }) {
                        Image(systemName: "minus")
                            .foregroundColor(.black)
                            .frame(width: 30, height: 30)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                            )
                            .cornerRadius(6)
                    }

                    Text("\(quantity)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(minWidth: 30)

                    Button(action: {
                        quantity += 1
                        Task {
                            await cartManager.updateQuantity(productId: item.productId, quantity: quantity)
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.primaryOrange)
                            .cornerRadius(6)
                    }

                    Spacer()

                    // Delete Button
                    Button(action: {
                        Task {
                            await cartManager.removeItem(productId: item.productId)
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    CartView()
}
