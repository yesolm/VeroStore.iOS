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
        let allBanners = try await networkService.request([Banner].self, endpoint: endpoint)
        print("🎪 Received \(allBanners.count) banners from API")
        
        // Filter for mobile-compatible banners (deviceType = 0 for All, or 2 for Mobile)
        // This matches the Android behavior
        let mobileBanners = allBanners.filter { $0.isMobileCompatible && $0.isActive }
        print("🎪 Filtered to \(mobileBanners.count) mobile-compatible banners")
        
        return mobileBanners
    }
}
