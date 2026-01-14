//
//  NotificationService.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0
    
    private let networkService = NetworkService.shared
    
    private init() {
        Task {
            await loadNotifications()
            await loadUnreadCount()
        }
    }
    
    func loadNotifications(page: Int = 1, pageSize: Int = 20) async {
        do {
            let response: NotificationListResponse = try await networkService.request(
                NotificationListResponse.self,
                endpoint: "Notifications?page=\(page)&pageSize=\(pageSize)"
            )
            notifications = response.items
        } catch {
            print("Error loading notifications: \(error)")
        }
    }
    
    func loadUnreadCount() async {
        do {
            let unread: [AppNotification] = try await networkService.request(
                [AppNotification].self,
                endpoint: "Notifications/unread"
            )
            unreadCount = unread.count
        } catch {
            print("Error loading unread count: \(error)")
        }
    }
    
    func markAsRead(id: Int) async {
        do {
            _ = try await networkService.request(
                EmptyResponse.self,
                endpoint: "Notifications/\(id)/read",
                method: "PUT"
            )
            await loadUnreadCount()
        } catch {
            print("Error marking notification as read: \(error)")
        }
    }
    
    func markAllAsRead() async {
        do {
            _ = try await networkService.request(
                EmptyResponse.self,
                endpoint: "Notifications/mark-all-read",
                method: "PUT"
            )
            await loadUnreadCount()
        } catch {
            print("Error marking all notifications as read: \(error)")
        }
    }
}
