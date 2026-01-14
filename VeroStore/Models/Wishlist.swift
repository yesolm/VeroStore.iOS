//
//  Wishlist.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

struct Wishlist: Codable, Identifiable {
    let id: Int
    let userId: Int
    let items: [WishlistItem]
}

struct WishlistItem: Codable, Identifiable, Hashable {
    let id: Int
    let productId: Int
    let product: Product
    let addedAt: String
}

struct AddToWishlistRequest: Codable {
    let productId: Int
}
