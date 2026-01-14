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
    let deviceType: Int
    let isActive: Bool
    let displayOrder: Int
}
