//
//  User.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let firstName: String?
    let lastName: String?
    let phone: String?
    let role: String?
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: String
    let userId: String
    let email: String
    let firstName: String
    let lastName: String
    let roles: [String]?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let phone: String?
}

struct GoogleAuthRequest: Codable {
    let idToken: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}
