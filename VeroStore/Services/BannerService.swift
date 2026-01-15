//
//  BannerService.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

@MainActor
class BannerService: ObservableObject {
    static let shared = BannerService()
    
    private let networkService = NetworkService.shared
    
    private init() {}
    
    func getActiveBanners(storeId: Int?) async throws -> [Banner] {
        var endpoint = "Banners/active"
        if let storeId = storeId {
            endpoint += "?storeId=\(storeId)"
        }
        
        print("🎪 Fetching banners from: \(endpoint)")
        let banners = try await networkService.request([Banner].self, endpoint: endpoint)
        print("🎪 Received \(banners.count) banners from API")
        
        return banners
    }
}
