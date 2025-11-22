//
//  OrderDTO.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import Foundation

struct OrderDTO: Codable, Identifiable {
    let id: Int
    let uuid: UUID
    let userId: Int
    let storeId: Int
    let storeName: String?
    let orderNumber: String?
    let status: String
    let totalAmount: Double
    let subtotal: Double
    let tax: Double
    let shippingFee: Double
    let discount: Double?
    let paymentMethod: String?
    let shippingAddress: String?
    let created: Date
    let updated: Date
    let items: [OrderItemDTO]?
}

struct OrderItemDTO: Codable, Identifiable {
    var id: Int { productId }
    let productId: Int
    let productName: String?
    let productImageUrl: String?
    let quantity: Int
    let price: Double
    let subtotal: Double
}

struct OrderListResponseDTO: Codable {
    let data: [OrderDTO]
    let pageNumber: Int
    let pageSize: Int
    let totalRecords: Int
    let totalPages: Int
}
