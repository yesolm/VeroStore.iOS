//
//  ProductDTO.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation

struct ProductDTO: Codable, Identifiable {
    let id: Int
    let uuid: UUID?
    let name: String?
    let description: String?
    let sku: String?
    let price: Double
    let cost: Double
    let categoryId: Int
    let categoryName: String?
    let imageUrl: String?
    let isBestSeller: Bool
    let isNewArrival: Bool
    let discountedPrice: Double?
    let isActive: Bool
    let created: Date
    let updated: Date
    let storeInventory: [ProductStoreInventoryDTO]?

    var rating: Double {
        // Generate a random rating between 4.0 and 5.0 for demo
        Double.random(in: 4.0...5.0)
    }

    var reviewCount: Int {
        // Generate a random review count for demo
        Int.random(in: 100...2000)
    }

    var discountPercentage: Int? {
        guard let discountedPrice = discountedPrice, price > 0 else { return nil }
        return Int(((price - discountedPrice) / price) * 100)
    }
}

struct ProductStoreInventoryDTO: Codable {
    let storeId: Int
    let storeName: String?
    let stockQuantity: Int
    let reservedQuantity: Int
    let availableStock: Int
    let lowStockThreshold: Int
    let isAvailable: Bool
}

struct ProductListResponseDTO: Codable {
    let items: [ProductDTO]?
    let totalCount: Int
    let pageNumber: Int
    let pageSize: Int
    let totalPages: Int
}
