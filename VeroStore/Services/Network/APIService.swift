//
//  APIService.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation

class APIService {
    static let shared = APIService()
    private let client = APIClient.shared

    // MARK: - Stores

    func fetchStores() async throws -> [StoreDTO] {
        return try await client.request(endpoint: "/stores")
    }

    func fetchDefaultStore() async throws -> StoreDTO {
        return try await client.request(endpoint: "/stores/default")
    }

    // MARK: - Banners

    func fetchActiveBanners(storeId: Int) async throws -> [BannerDTO] {
        return try await client.request(
            endpoint: "/banners/active",
            queryParameters: ["storeId": "\(storeId)"]
        )
    }

    // MARK: - Categories

    func fetchCategories(locationId: Int) async throws -> [CategoryDTO] {
        return try await client.request(
            endpoint: "/categories/all",
            queryParameters: ["locationId": "\(locationId)"]
        )
    }

    // MARK: - Products

    func fetchProducts(
        pageNumber: Int = 1,
        pageSize: Int = 10,
        searchTerm: String? = nil,
        locationId: Int? = nil,
        categoryId: Int? = nil
    ) async throws -> ProductListResponseDTO {
        var params: [String: String] = [
            "pageNumber": "\(pageNumber)",
            "pageSize": "\(pageSize)"
        ]

        if let searchTerm = searchTerm {
            params["searchTerm"] = searchTerm
        }
        if let locationId = locationId {
            params["locationId"] = "\(locationId)"
        }
        if let categoryId = categoryId {
            params["categoryId"] = "\(categoryId)"
        }

        return try await client.request(endpoint: "/products", queryParameters: params)
    }

    func fetchProduct(id: Int, locationId: Int?) async throws -> ProductDTO {
        var params: [String: String] = [:]
        if let locationId = locationId {
            params["locationId"] = "\(locationId)"
        }

        return try await client.request(endpoint: "/products/\(id)", queryParameters: params)
    }

    func fetchBestSellers(storeId: Int) async throws -> [ProductDTO] {
        return try await client.request(
            endpoint: "/products/bestsellers",
            queryParameters: ["storeId": "\(storeId)"]
        )
    }

    func fetchNewArrivals(storeId: Int) async throws -> [ProductDTO] {
        return try await client.request(
            endpoint: "/products/newarrivals",
            queryParameters: ["storeId": "\(storeId)"]
        )
    }

    func fetchTrendingProducts(
        pageNumber: Int = 1,
        pageSize: Int = 10,
        storeId: Int
    ) async throws -> ProductListResponseDTO {
        return try await client.request(
            endpoint: "/products/trending",
            queryParameters: [
                "pageNumber": "\(pageNumber)",
                "pageSize": "\(pageSize)",
                "storeId": "\(storeId)"
            ]
        )
    }

    // MARK: - Authentication

    func login(email: String, password: String) async throws -> AuthResponse {
        let dto = LoginDTO(email: email, password: password, twoFactorCode: nil)
        return try await client.request(
            endpoint: "/account/login",
            method: .post,
            body: dto
        )
    }

    func register(
        email: String,
        password: String,
        firstName: String,
        lastName: String
    ) async throws -> AuthResponse {
        let dto = RegisterDTO(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            enableTwoFactor: false
        )
        return try await client.request(
            endpoint: "/account/register",
            method: .post,
            body: dto
        )
    }

    func googleLogin(idToken: String) async throws -> AuthResponse {
        let dto = GoogleAuthRequest(idToken: idToken)
        return try await client.request(
            endpoint: "/account/google-login",
            method: .post,
            body: dto
        )
    }

    func appleLogin(identityToken: String, authorizationCode: String) async throws -> AuthResponse {
        let dto = AppleAuthRequest(
            identityToken: identityToken,
            authorizationCode: authorizationCode
        )
        return try await client.request(
            endpoint: "/account/apple-login",
            method: .post,
            body: dto
        )
    }

    func logout() async throws {
        try await client.requestWithoutResponse(
            endpoint: "/account/logout",
            method: .post,
            requiresAuth: true
        )
    }

    // MARK: - Cart

    func fetchCart() async throws -> CartDTO {
        return try await client.request(
            endpoint: "/cart",
            requiresAuth: true
        )
    }

    func addToCart(productId: Int, quantity: Int) async throws -> CartDTO {
        let dto = AddToCartDTO(productId: productId, quantity: quantity)
        return try await client.request(
            endpoint: "/cart",
            method: .post,
            body: dto,
            requiresAuth: true
        )
    }

    func updateCartItem(productId: Int, quantity: Int) async throws -> CartDTO {
        let dto = UpdateCartItemDTO(productId: productId, quantity: quantity)
        return try await client.request(
            endpoint: "/cart/updateitem",
            method: .put,
            body: dto,
            requiresAuth: true
        )
    }

    func removeFromCart(productId: Int) async throws -> CartDTO {
        return try await client.request(
            endpoint: "/cart/items/\(productId)",
            method: .delete,
            requiresAuth: true
        )
    }

    func clearCart() async throws {
        try await client.requestWithoutResponse(
            endpoint: "/cart",
            method: .delete,
            requiresAuth: true
        )
    }

    // MARK: - Wishlist

    func fetchWishlist() async throws -> [ProductDTO] {
        return try await client.request(
            endpoint: "/wishlist",
            requiresAuth: true
        )
    }

    func addToWishlist(productId: Int) async throws {
        try await client.requestWithoutResponse(
            endpoint: "/wishlist/\(productId)",
            method: .post,
            requiresAuth: true
        )
    }

    func removeFromWishlist(productId: Int) async throws {
        try await client.requestWithoutResponse(
            endpoint: "/wishlist/\(productId)",
            method: .delete,
            requiresAuth: true
        )
    }

    func isInWishlist(productId: Int) async throws -> Bool {
        struct WishlistCheckResponse: Codable {
            let isInWishlist: Bool
        }
        let response: WishlistCheckResponse = try await client.request(
            endpoint: "/wishlist/check/\(productId)",
            requiresAuth: true
        )
        return response.isInWishlist
    }

    // MARK: - Orders

    func fetchOrders(
        pageNumber: Int = 1,
        pageSize: Int = 20
    ) async throws -> OrderListResponseDTO {
        return try await client.request(
            endpoint: "/orders",
            queryParameters: [
                "pageNumber": "\(pageNumber)",
                "pageSize": "\(pageSize)"
            ],
            requiresAuth: true
        )
    }

    func fetchOrder(id: Int) async throws -> OrderDTO {
        return try await client.request(
            endpoint: "/orders/\(id)",
            requiresAuth: true
        )
    }
}
