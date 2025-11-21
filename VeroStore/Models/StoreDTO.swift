//
//  StoreDTO.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation

struct StoreDTO: Codable, Identifiable {
    let id: Int
    let uuid: UUID?
    let name: String?
    let address: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?
    let phone: String?
    let email: String?
    let currency: String?
    let paymentMethods: String?
    let operatingHours: String?
    let isActive: Bool?
    let isDefault: Bool?
}
