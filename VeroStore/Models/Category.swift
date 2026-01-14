//
//  Category.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

struct Category: Codable, Identifiable, Hashable {
    let id: Int
    let uuid: String?
    let name: String
    let description: String?
    let imageUrl: String?
    let parentCategoryId: Int?
    let displayOrder: Int
}
