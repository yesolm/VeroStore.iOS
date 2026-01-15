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
    
    // Optional: If API returns translations as a separate object
    let translations: [String: CategoryTranslation]?
    
    // Get localized name based on current language
    var localizedName: String {
        let currentLang = LocalizationHelper.shared.currentLanguage
        return translations?[currentLang]?.name ?? name
    }
    
    // Get localized description based on current language
    var localizedDescription: String? {
        let currentLang = LocalizationHelper.shared.currentLanguage
        return translations?[currentLang]?.description ?? description
    }
}
// Translation structure if API provides separate translation objects
struct CategoryTranslation: Codable, Hashable {
    let name: String
    let description: String?
}


