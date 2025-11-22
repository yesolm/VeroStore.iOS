//
//  PaymentDTO.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import Foundation

enum PaymentMethodType: String, Codable {
    case creditCard = "credit_card"
    case applePay = "apple_pay"
    case googlePay = "google_pay"
    case paypal = "paypal"
}

struct PaymentMethodDTO: Codable, Identifiable {
    let id: Int
    let userId: Int
    let type: String
    let last4: String?
    let brand: String?
    let expiryMonth: Int?
    let expiryYear: Int?
    let isDefault: Bool
    let created: Date
    let updated: Date
}

struct AddPaymentMethodDTO: Codable {
    let type: String
    let cardToken: String?
    let last4: String?
    let brand: String?
    let expiryMonth: Int?
    let expiryYear: Int?
    let isDefault: Bool
}

struct PaymentIntentDTO: Codable {
    let id: Int
    let orderId: Int
    let amount: Double
    let currency: String
    let status: String
    let paymentMethodType: String?
    let clientSecret: String?
    let created: Date
}

struct CreatePaymentIntentRequest: Codable {
    let orderId: Int
    let paymentMethodType: String
    let savePaymentMethod: Bool?
}

struct CheckoutRequest: Codable {
    let storeId: Int
    let paymentMethodType: String
    let paymentMethodId: Int?
    let applePayToken: String?
    let shippingAddress: ShippingAddressDTO
    let billingAddress: ShippingAddressDTO?
    let saveAddress: Bool?
}

struct ShippingAddressDTO: Codable {
    let firstName: String
    let lastName: String
    let addressLine1: String
    let addressLine2: String?
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let phone: String
}

struct CheckoutResponse: Codable {
    let orderId: Int
    let orderNumber: String
    let totalAmount: Double
    let paymentStatus: String
    let requiresAction: Bool?
    let clientSecret: String?
}
