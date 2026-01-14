//
//  Store.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

struct Store: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let address: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let phone: String?
    let email: String?
    let isActive: Bool
}
