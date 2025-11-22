//
//  CartManager.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation
import Combine

// Local cart item for offline storage
struct LocalCartItem: Codable, Identifiable {
    var id: Int { productId }
    let productId: Int
    var quantity: Int
    let productName: String?
    let productImageUrl: String?
    let productPrice: Double
    let addedDate: Date
}

@MainActor
class CartManager: ObservableObject {
    static let shared = CartManager()

    @Published var cart: CartDTO?
    @Published var localCartItems: [LocalCartItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared
    private let authManager = AuthManager.shared
    private let localCartKey = "local_cart_items"
    private var cancellables = Set<AnyCancellable>()

    var itemCount: Int {
        if authManager.isAuthenticated {
            return cart?.items?.reduce(0) { $0 + $1.quantity } ?? 0
        } else {
            return localCartItems.reduce(0) { $0 + $1.quantity }
        }
    }

    private init() {
        // Load local cart from UserDefaults
        loadLocalCart()

        // Listen to auth changes
        authManager.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    Task { @MainActor in
                        await self?.syncLocalCartToServer()
                    }
                }
            }
            .store(in: &cancellables)

        // Load cart if user is authenticated
        if authManager.isAuthenticated {
            Task {
                await fetchCart()
            }
        }
    }

    private func loadLocalCart() {
        if let data = UserDefaults.standard.data(forKey: localCartKey),
           let items = try? JSONDecoder().decode([LocalCartItem].self, from: data) {
            localCartItems = items
        }
    }

    private func saveLocalCart() {
        if let data = try? JSONEncoder().encode(localCartItems) {
            UserDefaults.standard.set(data, forKey: localCartKey)
        }
    }

    private func clearLocalCart() {
        localCartItems = []
        UserDefaults.standard.removeObject(forKey: localCartKey)
    }

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

    func addToCart(productId: Int, quantity: Int = 1, productName: String? = nil, productImageUrl: String? = nil, productPrice: Double = 0) async {
        if authManager.isAuthenticated {
            // Add to server cart
            isLoading = true
            errorMessage = nil

            do {
                cart = try await apiService.addToCart(productId: productId, quantity: quantity)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        } else {
            // Add to local cart
            if let index = localCartItems.firstIndex(where: { $0.productId == productId }) {
                // Update existing item
                localCartItems[index].quantity += quantity
            } else {
                // Add new item
                let item = LocalCartItem(
                    productId: productId,
                    quantity: quantity,
                    productName: productName,
                    productImageUrl: productImageUrl,
                    productPrice: productPrice,
                    addedDate: Date()
                )
                localCartItems.append(item)
            }
            saveLocalCart()
        }
    }

    func updateQuantity(productId: Int, quantity: Int) async {
        if authManager.isAuthenticated {
            // Update server cart
            isLoading = true
            errorMessage = nil

            do {
                cart = try await apiService.updateCartItem(productId: productId, quantity: quantity)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        } else {
            // Update local cart
            if let index = localCartItems.firstIndex(where: { $0.productId == productId }) {
                if quantity > 0 {
                    localCartItems[index].quantity = quantity
                } else {
                    localCartItems.remove(at: index)
                }
                saveLocalCart()
            }
        }
    }

    func removeItem(productId: Int) async {
        if authManager.isAuthenticated {
            // Remove from server cart
            isLoading = true
            errorMessage = nil

            do {
                cart = try await apiService.removeFromCart(productId: productId)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        } else {
            // Remove from local cart
            localCartItems.removeAll { $0.productId == productId }
            saveLocalCart()
        }
    }

    func clearCart() async {
        if authManager.isAuthenticated {
            // Clear server cart
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
        } else {
            // Clear local cart
            clearLocalCart()
        }
    }

    private func syncLocalCartToServer() async {
        guard authManager.isAuthenticated, !localCartItems.isEmpty else { return }

        print("🔄 Syncing \(localCartItems.count) local cart items to server...")

        // Add all local items to server cart
        for item in localCartItems {
            do {
                cart = try await apiService.addToCart(productId: item.productId, quantity: item.quantity)
            } catch {
                print("❌ Failed to sync item \(item.productId): \(error.localizedDescription)")
            }
        }

        // Clear local cart after sync
        clearLocalCart()

        // Fetch latest cart from server
        await fetchCart()

        print("✅ Local cart synced to server")
    }
}
