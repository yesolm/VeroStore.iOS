//
//  BannerDTO.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation

struct BannerDTO: Codable, Identifiable {
    let id: Int
    let storeId: Int
    let storeName: String?
    let title: String?
    let imageUrl: String?
    let linkType: String?
    let linkProductId: Int?
    let linkProductName: String?
    let linkCategoryId: Int?
    let linkCategoryName: String?
    let linkUrl: String?
    let sortOrder: Int
    let isActive: Bool
    let created: Date
    let updated: Date
}
