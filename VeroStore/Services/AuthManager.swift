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
    @Published var userRoles: [String] = []
    @Published var jwtClaims: JWTClaims?

    private let apiClient = APIClient.shared
    private let userDefaults = UserDefaults.standard

    private let isAuthenticatedKey = "is_authenticated"
    private let currentUserKey = "current_user"
    private let userRolesKey = "user_roles"

    private init() {
        loadAuthState()
    }

    private func loadAuthState() {
        isAuthenticated = userDefaults.bool(forKey: isAuthenticatedKey)

        if let userData = userDefaults.data(forKey: currentUserKey),
           let user = try? JSONDecoder().decode(UserDTO.self, from: userData) {
            currentUser = user
        }

        if let roles = userDefaults.stringArray(forKey: userRolesKey) {
            userRoles = roles
        }

        // Try to decode JWT claims from stored access token
        if let accessToken = userDefaults.string(forKey: "accessToken") {
            jwtClaims = JWTDecoder.decode(jwtToken: accessToken)
        }
    }

    func login(response: AuthResponse) {
        apiClient.setTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)

        // Decode JWT claims
        if let claims = JWTDecoder.decode(jwtToken: response.accessToken) {
            jwtClaims = claims

            // Extract roles from JWT
            if let roles = claims.roles {
                userRoles = roles
                userDefaults.set(roles, forKey: userRolesKey)
            }

            // Update user with JWT claims if available
            var user = response.user
            if user.firstName == nil, let firstName = claims.firstName {
                user = UserDTO(
                    id: user.id,
                    email: user.email,
                    firstName: firstName,
                    lastName: claims.lastName ?? user.lastName,
                    phone: user.phone
                )
            }
            currentUser = user
        } else {
            // Fallback to response user
            currentUser = response.user
            if let roles = response.roles {
                userRoles = roles
                userDefaults.set(roles, forKey: userRolesKey)
            }
        }

        isAuthenticated = true

        userDefaults.set(true, forKey: isAuthenticatedKey)
        if let userData = try? JSONEncoder().encode(currentUser) {
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
        userRoles = []
        jwtClaims = nil

        userDefaults.removeObject(forKey: isAuthenticatedKey)
        userDefaults.removeObject(forKey: currentUserKey)
        userDefaults.removeObject(forKey: userRolesKey)
    }

    // Helper methods for role checking
    func hasRole(_ role: String) -> Bool {
        return userRoles.contains(role)
    }

    func isAdmin() -> Bool {
        return hasRole("admin")
    }

    func isManager() -> Bool {
        return hasRole("manager")
    }
}
