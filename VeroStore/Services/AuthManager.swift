//
//  AuthManager.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var currentUser: UserDTO?

    private let apiClient = APIClient.shared
    private let userDefaults = UserDefaults.standard

    private let isAuthenticatedKey = "is_authenticated"
    private let currentUserKey = "current_user"

    private init() {
        loadAuthState()
    }

    private func loadAuthState() {
        isAuthenticated = userDefaults.bool(forKey: isAuthenticatedKey)

        if let userData = userDefaults.data(forKey: currentUserKey),
           let user = try? JSONDecoder().decode(UserDTO.self, from: userData) {
            currentUser = user
        }
    }

    func login(response: AuthResponse) {
        apiClient.setTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        let user = response.user
        currentUser = user
        isAuthenticated = true

        userDefaults.set(true, forKey: isAuthenticatedKey)
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: currentUserKey)
        }
    }

    func logout() async {
        do {
            try await APIService.shared.logout()
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }

        apiClient.clearTokens()
        currentUser = nil
        isAuthenticated = false

        userDefaults.removeObject(forKey: isAuthenticatedKey)
        userDefaults.removeObject(forKey: currentUserKey)
    }
}
