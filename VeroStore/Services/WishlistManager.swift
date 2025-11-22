//
//  WishlistManager.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import Foundation
import Combine

@MainActor
class WishlistManager: ObservableObject {
    static let shared = WishlistManager()

    @Published var wishlistItems: [ProductDTO] = []
    @Published var wishlistProductIds: Set<Int> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared
    private let authManager = AuthManager.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Listen to auth changes
        authManager.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    Task { @MainActor in
                        await self?.fetchWishlist()
                    }
                } else {
                    // Clear wishlist when logged out
                    self?.wishlistItems = []
                    self?.wishlistProductIds = []
                }
            }
            .store(in: &cancellables)

        // Load wishlist if user is authenticated
        if authManager.isAuthenticated {
            Task {
                await fetchWishlist()
            }
        }
    }

    func fetchWishlist() async {
        guard authManager.isAuthenticated else { return }

        isLoading = true
        errorMessage = nil

        do {
            wishlistItems = try await apiService.fetchWishlist()
            wishlistProductIds = Set(wishlistItems.map { $0.id })
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func addToWishlist(productId: Int) async {
        guard authManager.isAuthenticated else {
            errorMessage = "Please login to add items to wishlist"
            return
        }

        do {
            try await apiService.addToWishlist(productId: productId)
            wishlistProductIds.insert(productId)
            // Refresh wishlist
            await fetchWishlist()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeFromWishlist(productId: Int) async {
        guard authManager.isAuthenticated else { return }

        do {
            try await apiService.removeFromWishlist(productId: productId)
            wishlistProductIds.remove(productId)
            // Refresh wishlist
            await fetchWishlist()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleWishlist(productId: Int) async {
        if wishlistProductIds.contains(productId) {
            await removeFromWishlist(productId: productId)
        } else {
            await addToWishlist(productId: productId)
        }
    }

    func isInWishlist(productId: Int) -> Bool {
        return wishlistProductIds.contains(productId)
    }

    func clearWishlist() async {
        // Clear all wishlist items
        for productId in wishlistProductIds {
            try? await apiService.removeFromWishlist(productId: productId)
        }
        wishlistItems = []
        wishlistProductIds = []
    }
}
