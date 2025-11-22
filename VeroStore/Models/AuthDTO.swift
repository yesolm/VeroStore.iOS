//
//  AuthDTO.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation

struct LoginDTO: Codable {
    let email: String
    let password: String
    let twoFactorCode: String?
}

struct RegisterDTO: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let enableTwoFactor: Bool?
}

struct GoogleAuthRequest: Codable {
    let idToken: String
}

struct AppleAuthRequest: Codable {
    let identityToken: String
    let authorizationCode: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: String
    let userId: String
    let email: String
    let firstName: String?
    let lastName: String?
    let roles: [String]?

    // Computed property to convert to UserDTO
    var user: UserDTO {
        UserDTO(
            id: Int(userId) ?? 0,
            email: email,
            firstName: firstName,
            lastName: lastName,
            phone: nil
        )
    }
}

struct UserDTO: Codable {
    let id: Int
    let email: String
    let firstName: String?
    let lastName: String?
    let phone: String?
}

struct RefreshTokenRequest: Codable {
    let accessToken: String
    let refreshToken: String
}
