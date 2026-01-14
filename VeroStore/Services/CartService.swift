//
//  CartService.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

@MainActor
class CartService: ObservableObject {
    static let shared = CartService()
    
    @Published var cart: Cart?
    @Published var localCartItems: [LocalCartItem] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let networkService = NetworkService.shared
    private let authService = AuthService.shared
    private let localStorage = LocalCartStorage.shared
    
    private init() {
        loadLocalCart()
        Task {
            await loadCart()
        }
        
        // Observe auth state changes to sync cart when user logs in
        Task {
            for await _ in NotificationCenter.default.notifications(named: .init("UserDidLogin")) {
                await syncLocalCartToServer()
                await loadCart()
            }
        }
    }
    
    func loadLocalCart() {
        localCartItems = localStorage.getCartItems()
    }
    
    func loadCart() async {
        guard authService.isAuthenticated else {
            // Not logged in - use local cart only
            loadLocalCart()
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            cart = try await networkService.request(Cart.self, endpoint: "Cart")
            // Sync local cart to server if we have local items
            await syncLocalCartToServer()
        } catch let error as NetworkError {
            if case .unauthorized = error {
                // Not authorized - use local cart
                loadLocalCart()
            } else {
                self.error = error.localizedDescription
            }
        } catch {
            // Network error - use local cart
            loadLocalCart()
        }
        
        isLoading = false
    }
    
    func addToCart(productId: Int, quantity: Int, productName: String, productImageUrl: String, productPrice: Double, variationId: Int? = nil, variationDisplayName: String? = nil) async {
        // Always add to local cart first
        let localItem = LocalCartItem(
            productId: productId,
            productName: productName,
            productImageUrl: productImageUrl,
            productPrice: productPrice,
            quantity: quantity,
            variationId: variationId,
            variationDisplayName: variationDisplayName
        )
        localStorage.addItem(localItem)
        loadLocalCart()
        
        // Try to sync to server if logged in
        if authService.isAuthenticated {
            do {
                let request = AddToCartRequest(productId: productId, quantity: quantity, variationId: variationId)
                let body = try JSONEncoder().encode(request)
                
                cart = try await networkService.request(
                    Cart.self,
                    endpoint: "Cart",
                    method: "POST",
                    body: body
                )
                // Clear local cart after successful sync
                localStorage.clearCart()
                loadLocalCart()
            } catch let error as NetworkError {
                if case .unauthorized = error {
                    // Keep in local cart
                } else {
                    print("Error adding to cart: \(error)")
                }
            } catch {
                print("Error adding to cart: \(error)")
            }
        }
    }
    
    func updateCartItem(productId: Int, quantity: Int, variationId: Int? = nil) async {
        // Update local cart
        localStorage.updateItem(productId: productId, quantity: quantity, variationId: variationId)
        loadLocalCart()
        
        // Try to sync to server if logged in
        if authService.isAuthenticated {
            do {
                let request = UpdateCartItemRequest(productId: productId, quantity: quantity, variationId: variationId)
                let body = try JSONEncoder().encode(request)
                
                cart = try await networkService.request(
                    Cart.self,
                    endpoint: "Cart",
                    method: "PUT",
                    body: body
                )
            } catch {
                print("Error updating cart: \(error)")
            }
        }
    }
    
    func removeCartItem(productId: Int, variationId: Int? = nil) async {
        // Remove from local cart
        localStorage.removeItem(productId: productId, variationId: variationId)
        loadLocalCart()
        
        // Try to sync to server if logged in
        if authService.isAuthenticated {
            do {
                cart = try await networkService.request(
                    Cart.self,
                    endpoint: "Cart/items/\(productId)",
                    method: "DELETE"
                )
            } catch {
                print("Error removing cart item: \(error)")
            }
        }
    }
    
    func clearCart() async {
        // Clear local cart
        localStorage.clearCart()
        loadLocalCart()
        
        // Try to sync to server if logged in
        if authService.isAuthenticated {
            do {
                _ = try await networkService.request(
                    EmptyResponse.self,
                    endpoint: "Cart",
                    method: "DELETE"
                )
                cart = nil
            } catch {
                print("Error clearing cart: \(error)")
            }
        }
    }
    
    private func syncLocalCartToServer() async {
        let localItems = localStorage.getCartItems()
        guard !localItems.isEmpty else { return }
        
        for item in localItems {
            do {
                let request = AddToCartRequest(productId: item.productId, quantity: item.quantity, variationId: item.variationId)
                let body = try JSONEncoder().encode(request)
                _ = try await networkService.request(Cart.self, endpoint: "Cart", method: "POST", body: body)
            } catch {
                print("Error syncing item \(item.productId): \(error)")
            }
        }
        
        // Clear local cart after sync
        localStorage.clearCart()
        loadLocalCart()
        // Reload server cart
        await loadCart()
    }
    
    var itemCount: Int {
        if authService.isAuthenticated, let cart = cart {
            return cart.itemCount
        } else {
            return localStorage.getItemCount()
        }
    }
    
    var total: Double {
        if authService.isAuthenticated, let cart = cart {
            return cart.total
        } else {
            return localStorage.getTotal()
        }
    }
    
    var items: [CartItem] {
        if authService.isAuthenticated, let cart = cart {
            return cart.items
        } else {
            // Convert local items to CartItem format
            return localCartItems.map { localItem in
                CartItem(
                    productId: localItem.productId,
                    productName: localItem.productName,
                    productImageUrl: localItem.productImageUrl,
                    productPrice: localItem.productPrice,
                    quantity: localItem.quantity,
                    variationId: localItem.variationId,
                    variationDisplayName: localItem.variationDisplayName
                )
            }
        }
    }
}
