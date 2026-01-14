//
//  LocalCartStorage.swift
//  VeroStore
//
//  Created based on Android app - local cart for offline/unauthorized users
//

import Foundation

struct LocalCartItem: Codable, Identifiable {
    var id: String {
        "\(productId)-\(variationId ?? 0)"
    }
    let productId: Int
    let productName: String
    let productImageUrl: String
    let productPrice: Double
    var quantity: Int
    let variationId: Int?
    let variationDisplayName: String?
    let addedAt: Date
    
    init(productId: Int, productName: String, productImageUrl: String, productPrice: Double, quantity: Int, variationId: Int? = nil, variationDisplayName: String? = nil) {
        self.productId = productId
        self.productName = productName
        self.productImageUrl = productImageUrl
        self.productPrice = productPrice
        self.quantity = quantity
        self.variationId = variationId
        self.variationDisplayName = variationDisplayName
        self.addedAt = Date()
    }
}

class LocalCartStorage {
    static let shared = LocalCartStorage()
    private let userDefaults = UserDefaults.standard
    private let cartKey = "local_cart_items"
    
    private init() {}
    
    func getCartItems() -> [LocalCartItem] {
        guard let data = userDefaults.data(forKey: cartKey),
              let items = try? JSONDecoder().decode([LocalCartItem].self, from: data) else {
            return []
        }
        return items
    }
    
    func addItem(_ item: LocalCartItem) {
        var items = getCartItems()
        
        // Check if item already exists (same product and variation)
        if let index = items.firstIndex(where: { $0.productId == item.productId && $0.variationId == item.variationId }) {
            items[index].quantity += item.quantity
        } else {
            items.append(item)
        }
        
        saveItems(items)
    }
    
    func updateItem(productId: Int, quantity: Int, variationId: Int? = nil) {
        var items = getCartItems()
        if let index = items.firstIndex(where: { $0.productId == productId && $0.variationId == variationId }) {
            items[index].quantity = quantity
            saveItems(items)
        }
    }
    
    func removeItem(productId: Int, variationId: Int? = nil) {
        var items = getCartItems()
        items.removeAll { $0.productId == productId && $0.variationId == variationId }
        saveItems(items)
    }
    
    func clearCart() {
        userDefaults.removeObject(forKey: cartKey)
    }
    
    private func saveItems(_ items: [LocalCartItem]) {
        if let data = try? JSONEncoder().encode(items) {
            userDefaults.set(data, forKey: cartKey)
        }
    }
    
    func getItemCount() -> Int {
        return getCartItems().reduce(0) { $0 + $1.quantity }
    }
    
    func getTotal() -> Double {
        return getCartItems().reduce(0) { $0 + ($1.productPrice * Double($1.quantity)) }
    }
}
