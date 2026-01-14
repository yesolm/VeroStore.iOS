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
    
    func getActiveBanners(storeId: Int?, deviceType: Int = 2) async throws -> [Banner] {
        var endpoint = "Banners/active?deviceType=\(deviceType)"
        if let storeId = storeId {
            endpoint += "&storeId=\(storeId)"
        }
        
        return try await networkService.request([Banner].self, endpoint: endpoint)
    }
}
