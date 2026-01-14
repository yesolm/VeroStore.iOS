//
//  NotificationsView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if notificationService.notifications.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bell")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("No notifications")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Your notifications will appear here")
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(notificationService.notifications) { notification in
                            NotificationRow(notification: notification)
                        }
                    }
                }
            }
            .navigationTitle("notifications".localized)
            .onAppear {
                Task {
                    await notificationService.loadNotifications()
                }
            }
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(notification.isRead ? Color.clear : Color.appPrimary)
                .frame(width: 10, height: 10)
                .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(notification.isRead ? .primary : .appPrimary)
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(formatDate(notification.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .onTapGesture {
            if !notification.isRead {
                Task {
                    await notificationService.markAsRead(id: notification.id)
                }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}
