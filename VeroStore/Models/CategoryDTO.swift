//
//  CategoryDTO.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation

struct CategoryDTO: Codable, Identifiable {
    let id: Int
    let uuid: UUID?
    let name: String?
    let description: String?
    let slug: String?
    let parentId: Int?
    let parentName: String?
    let imageUrl: String?
    let displayOrder: Int
    let isActive: Bool
    let created: Date
    let updated: Date
    let storeCategories: [StoreCategoryStatusDTO]?
}

struct StoreCategoryStatusDTO: Codable {
    let storeId: Int
    let storeName: String?
    let isEnabled: Bool
    let displayOrder: Int
}
