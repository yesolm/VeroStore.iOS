//
//  CategoryService.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

@MainActor
class CategoryService: ObservableObject {
    static let shared = CategoryService()
    
    private let networkService = NetworkService.shared
    
    private init() {}
    
    func getCategories(storeId: Int) async throws -> [Category] {
        return try await networkService.request([Category].self, endpoint: "Categories?storeId=\(storeId)")
    }
}
