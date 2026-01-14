//
//  Notification.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

struct AppNotification: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let message: String
    let type: String?
    let isRead: Bool
    let createdAt: String
    let linkUrl: String?
}

struct NotificationListResponse: Codable {
    let items: [AppNotification]
    let totalCount: Int
    let totalPages: Int
    let page: Int
    let pageSize: Int
}
