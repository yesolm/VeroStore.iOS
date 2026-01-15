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
    
    // Optional: If API returns translations as a separate object
    let translations: [String: ProductTranslation]?
    
    var primaryImageUrl: String? {
        images?.first(where: { $0.isPrimary })?.imageUrl ?? images?.first?.imageUrl ?? imageUrl
    }
    
    // Get localized name based on current language
    var localizedName: String {
        let currentLang = LocalizationHelper.shared.currentLanguage
        return translations?[currentLang]?.name ?? name
    }
    
    // Get localized description based on current language
    var localizedDescription: String? {
        let currentLang = LocalizationHelper.shared.currentLanguage
        return translations?[currentLang]?.description ?? description
    }
}

// Translation structure if API provides separate translation objects
struct ProductTranslation: Codable, Hashable {
    let name: String
    let description: String?
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
    
    // Optional: If API returns translations for attribute names/values
    let translations: [String: VariationAttributeTranslation]?
    
    // Get localized name based on current language
    var localizedName: String {
        let currentLang = LocalizationHelper.shared.currentLanguage
        return translations?[currentLang]?.name ?? name
    }
    
    // Get localized value based on current language
    var localizedValue: String {
        let currentLang = LocalizationHelper.shared.currentLanguage
        return translations?[currentLang]?.value ?? value
    }
}

// Translation structure for variation attributes
struct VariationAttributeTranslation: Codable, Hashable {
    let name: String
    let value: String
}


