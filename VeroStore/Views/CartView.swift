//
//  CartView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct CartView: View {
    @StateObject private var cartService = CartService.shared
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if cartService.isLoading {
                    ProgressView()
                } else if !cartService.items.isEmpty {
                    VStack(spacing: 0) {
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(cartService.items) { item in
                                    CartItemRow(item: item)
                                }
                            }
                            .padding()
                        }
                        
                        // Order summary
                        VStack(spacing: 15) {
                            Divider()
                            
                            HStack {
                                Text("subtotal".localized)
                                Spacer()
                                Text("$\(String(format: "%.2f", cartService.total))")
                            }
                            
                            HStack {
                                Text("shipping".localized)
                                Spacer()
                                Text("shipping_calculated".localized)
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("total".localized)
                                    .font(.headline)
                                Spacer()
                                Text("$\(String(format: "%.2f", cartService.total))")
                                    .font(.headline)
                            }
                            
                            if authService.isAuthenticated {
                                NavigationLink(destination: CheckoutView()) {
                                    Text("proceed_to_checkout".localized)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.appPrimary)
                                        .cornerRadius(10)
                                }
                            } else {
                                NavigationLink(destination: AuthView()) {
                                    Text("proceed_to_checkout".localized)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.appPrimary)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("empty_cart_title".localized)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("empty_cart_message".localized)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            // Switch to home tab
                            NotificationCenter.default.post(name: NSNotification.Name("SwitchToHomeTab"), object: nil)
                        }) {
                            Text("continue_shopping".localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.appPrimary)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .navigationTitle("title_cart".localized)
            .onAppear {
                Task {
                    await cartService.loadCart()
                }
            }
        }
    }
}

struct CartItemRow: View {
    let item: CartItem
    @StateObject private var cartService = CartService.shared
    @State private var quantity: Int
    
    init(item: CartItem) {
        self.item = item
        _quantity = State(initialValue: item.quantity)
    }
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: item.productImageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 80, height: 80)
            .clipped()
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.productName)
                    .font(.headline)
                    .lineLimit(2)
                
                if let variationName = item.variationDisplayName {
                    Text(variationName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text("$\(String(format: "%.2f", item.productPrice))")
                    .font(.subheadline)
                    .foregroundColor(.appPrimary)
                
                // Quantity controls below price
                HStack(spacing: 8) {
                    Button(action: {
                        if quantity > 1 {
                            quantity -= 1
                            updateQuantity()
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(quantity > 1 ? .appPrimary : .gray)
                            .frame(width: 32, height: 32)
                            .background(quantity > 1 ? Color.appPrimary.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .disabled(quantity <= 1)
                    
                    Text("\(quantity)")
                        .font(.system(size: 16, weight: .medium))
                        .frame(minWidth: 40)
                    
                    Button(action: {
                        quantity += 1
                        updateQuantity()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appPrimary)
                            .frame(width: 32, height: 32)
                            .background(Color.appPrimary.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                .padding(.top, 4)
            }
            
            Spacer()
            
            Button(action: {
                removeItem()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 18))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private func updateQuantity() {
        Task {
            await cartService.updateCartItem(
                productId: item.productId,
                quantity: quantity,
                variationId: item.variationId
            )
        }
    }
    
    private func removeItem() {
        Task {
            await cartService.removeCartItem(productId: item.productId, variationId: item.variationId)
        }
    }
}

struct CheckoutView: View {
    @StateObject private var cartService = CartService.shared
    
    var body: some View {
        VStack {
            Text("checkout_functionality_coming_soon".localized)
                .foregroundColor(.gray)
                .padding()
            
            Spacer()
            
            Text("\(String(format: "total".localized)): $\(String(format: "%.2f", cartService.total))")
                .font(.title2)
                .fontWeight(.bold)
        }
        .navigationTitle("checkout".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}
