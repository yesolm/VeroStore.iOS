//
//  CartManager.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation
import Combine

class CartManager: ObservableObject {
    static let shared = CartManager()

    @Published var cart: CartDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared
    private let authManager = AuthManager.shared

    var itemCount: Int {
        cart?.items?.reduce(0) { $0 + $1.quantity } ?? 0
    }

    private init() {
        // Load cart if user is authenticated
        if authManager.isAuthenticated {
            Task {
                await fetchCart()
            }
        }
    }

    @MainActor
    func fetchCart() async {
        guard authManager.isAuthenticated else { return }

        isLoading = true
        errorMessage = nil

        do {
            cart = try await apiService.fetchCart()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    @MainActor
    func addToCart(productId: Int, quantity: Int = 1) async {
        guard authManager.isAuthenticated else {
            errorMessage = "Please login to add items to cart"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            cart = try await apiService.addToCart(productId: productId, quantity: quantity)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    @MainActor
    func updateQuantity(productId: Int, quantity: Int) async {
        guard authManager.isAuthenticated else { return }

        isLoading = true
        errorMessage = nil

        do {
            cart = try await apiService.updateCartItem(productId: productId, quantity: quantity)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    @MainActor
    func removeItem(productId: Int) async {
        guard authManager.isAuthenticated else { return }

        isLoading = true
        errorMessage = nil

        do {
            cart = try await apiService.removeFromCart(productId: productId)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    @MainActor
    func clearCart() async {
        guard authManager.isAuthenticated else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await apiService.clearCart()
            cart = nil
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
