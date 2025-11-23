//
//  CartDTO.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation

struct CartDTO: Codable, Identifiable {
    let id: Int
    let userId: Int
    let storeId: Int
    let createdDate: Date
    let lastModifiedDate: Date?
    let items: [CartItemDTO]?

    var subtotal: Double {
        items?.reduce(0) { $0 + $1.totalPrice } ?? 0
    }

    var tax: Double {
        subtotal * 0.08 // 8% tax rate, should come from API
    }

    var shippingFee: Double {
        subtotal > 50 ? 0 : 5.0 // Free shipping over $50
    }

    var discount: Double? {
        nil // Discount should come from API if applied
    }

    var totalAmount: Double {
        subtotal + tax + shippingFee - (discount ?? 0)
    }
}

struct CartItemDTO: Codable {
    let productId: Int
    let productName: String?
    let productImageUrl: String?
    let productPrice: Double
    let quantity: Int

    var totalPrice: Double {
        productPrice * Double(quantity)
    }
}

struct AddToCartDTO: Codable {
    let productId: Int
    let quantity: Int
}

struct UpdateCartItemDTO: Codable {
    let productId: Int
    let quantity: Int
}
