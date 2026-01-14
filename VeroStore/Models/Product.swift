//
//  Product.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

struct Product: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let price: Double
    let imageUrl: String?
    let images: [ProductImage]?
    let categoryId: Int?
    let stockQuantity: Int
    let sku: String?
    let rating: Double?
    let reviewCount: Int
    let isActive: Bool
    let hasVariations: Bool
    let requireVariationSelection: Bool
    let isEbtEligible: Bool
    
    var primaryImageUrl: String? {
        images?.first(where: { $0.isPrimary })?.imageUrl ?? images?.first?.imageUrl ?? imageUrl
    }
}

struct ProductImage: Codable, Identifiable, Hashable {
    let id: Int
    let productId: Int
    let imageUrl: String
    let sortOrder: Int
    let isPrimary: Bool
}

struct ProductListResponse: Codable {
    let items: [Product]
    let totalCount: Int
    let totalPages: Int
    let page: Int
    let pageSize: Int
}

struct HomePageProductsDto: Codable {
    let trending: [Product]?
    let newArrivals: [Product]?
    let bestSellers: [Product]?
    let deals: [Product]?
}
struct ProductVariation: Codable, Identifiable {
    let id: Int
    let productId: Int
    let sku: String?
    let price: Double?
    let stockQuantity: Int
    let attributes: [VariationAttribute]
    let isActive: Bool
}

struct VariationAttribute: Codable, Identifiable {
    let id: Int
    let name: String
    let value: String
}

