//
//  ProductService.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

@MainActor
class ProductService: ObservableObject {
    static let shared = ProductService()
    
    private let networkService = NetworkService.shared
    
    private init() {}
    
    func getProducts(page: Int = 1, pageSize: Int = 20, searchTerm: String? = nil, storeId: Int? = nil, categoryId: Int? = nil) async throws -> ProductListResponse {
        var endpoint = "Products/paged?pageNumber=\(page)&pageSize=\(pageSize)"
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            endpoint += "&searchTerm=\(searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        if let storeId = storeId {
            endpoint += "&storeId=\(storeId)"
        }
        if let categoryId = categoryId {
            endpoint += "&categoryId=\(categoryId)"
        }
        
        return try await networkService.request(ProductListResponse.self, endpoint: endpoint)
    }
    
    func getProduct(id: Int, storeId: Int? = nil) async throws -> Product {
        var endpoint = "Products/\(id)"
        if let storeId = storeId {
            endpoint += "?storeId=\(storeId)"
        }
        
        return try await networkService.request(Product.self, endpoint: endpoint)
    }
    
    func getTrending(page: Int = 1, pageSize: Int = 20, storeId: Int? = nil) async throws -> ProductListResponse {
        var endpoint = "Products/trending?pageNumber=\(page)&pageSize=\(pageSize)"
        if let storeId = storeId {
            endpoint += "&storeId=\(storeId)"
        }
        
        return try await networkService.request(ProductListResponse.self, endpoint: endpoint)
    }
    
    func getNewArrivals(storeId: Int? = nil) async throws -> [Product] {
        var endpoint = "Products/newarrivals"
        if let storeId = storeId {
            endpoint += "?storeId=\(storeId)"
        }
        
        return try await networkService.request([Product].self, endpoint: endpoint)
    }
    
    func getBestSellers(storeId: Int? = nil) async throws -> [Product] {
        var endpoint = "Products/bestsellers"
        if let storeId = storeId {
            endpoint += "?storeId=\(storeId)"
        }
        
        return try await networkService.request([Product].self, endpoint: endpoint)
    }
    
    func getHomePageProducts(storeId: Int? = nil) async throws -> HomePageProductsDto {
        var endpoint = "Products/homepage"
        if let storeId = storeId {
            endpoint += "?storeId=\(storeId)"
        }
        
        return try await networkService.request(HomePageProductsDto.self, endpoint: endpoint)
    }
    
    func getProductVariations(productId: Int) async throws -> [ProductVariation] {
        let endpoint = "Products/\(productId)/variations"
        return try await networkService.request([ProductVariation].self, endpoint: endpoint)
    }
}
