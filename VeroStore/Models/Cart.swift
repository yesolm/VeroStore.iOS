//
//  Cart.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

struct Cart: Codable, Identifiable {
    let id: Int
    let userId: Int
    let createdDate: String
    let lastModifiedDate: String?
    let items: [CartItem]
    
    var total: Double {
        items.reduce(0) { $0 + ($1.productPrice * Double($1.quantity)) }
    }
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
}

struct CartItem: Codable, Identifiable, Hashable {
    let productId: Int
    let productName: String
    let productImageUrl: String
    let productPrice: Double
    let quantity: Int
    let variationId: Int?
    let variationDisplayName: String?
    
    // Computed id for Identifiable
    var id: String {
        "\(productId)-\(variationId ?? 0)"
    }
    
    // Custom coding keys to exclude id from encoding/decoding
    enum CodingKeys: String, CodingKey {
        case productId, productName, productImageUrl, productPrice, quantity, variationId, variationDisplayName
    }
    
    var totalPrice: Double {
        productPrice * Double(quantity)
    }
}

struct AddToCartRequest: Codable {
    let productId: Int
    let quantity: Int
    let variationId: Int?
}

struct UpdateCartItemRequest: Codable {
    let productId: Int
    let quantity: Int
    let variationId: Int?
}
