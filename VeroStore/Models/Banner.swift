//
//  Banner.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

struct Banner: Codable, Identifiable, Hashable {
    let id: Int
    let title: String?
    let imageUrl: String
    let linkType: String?
    let linkUrl: String?
    let linkCategoryId: Int?
    let linkProductId: Int?
    let deviceType: String
    let isActive: Bool
    let sortOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageUrl
        case linkType
        case linkUrl
        case linkCategoryId
        case linkProductId
        case deviceType
        case isActive
        case sortOrder
    }
}
