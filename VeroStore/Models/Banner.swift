//
//  Banner.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

struct Banner: Codable, Identifiable, Hashable {
    let id: Int
    let storeId: Int?
    let storeName: String?
    let title: String?
    let imageUrl: String
    let backgroundColor: String? // Hex color code (e.g., "#6366F1")
    private let deviceType: DeviceTypeValue? // Can be Int (0, 1, 2) or String ("All", "Web", "Mobile")
    let linkType: String?
    let linkUrl: String?
    let linkCategoryId: Int?
    let linkCategoryName: String?
    let linkProductId: Int?
    let linkProductName: String?
    let isActive: Bool
    let sortOrder: Int
    let created: String?
    let updated: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case storeId
        case storeName
        case title
        case imageUrl
        case backgroundColor
        case deviceType
        case linkType
        case linkUrl
        case linkCategoryId
        case linkCategoryName
        case linkProductId
        case linkProductName
        case isActive
        case sortOrder
        case created
        case updated
    }
    
    /// Converts deviceType to integer: 0 = All, 1 = Web, 2 = Mobile
    func getDeviceTypeInt() -> Int {
        guard let deviceType = deviceType else { return 0 }
        switch deviceType {
        case .int(let value):
            return value
        case .string(let value):
            switch value.lowercased() {
            case "all": return 0
            case "web": return 1
            case "mobile": return 2
            default: return 0
            }
        }
    }
    
    /// Check if this banner should be shown on mobile (deviceType == 0 or 2)
    var isMobileCompatible: Bool {
        let type = getDeviceTypeInt()
        return type == 0 || type == 2 // All or Mobile
    }
}

// Helper enum to decode deviceType which can be Int or String from API
enum DeviceTypeValue: Codable, Hashable {
    case int(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            self = .int(0) // Default to All
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        }
    }
}
