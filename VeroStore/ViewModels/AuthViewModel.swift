//
//  AuthViewModel.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation
import AuthenticationServices

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false

    private let apiService = APIService.shared
    private let authManager = AuthManager.shared

    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.login(email: email, password: password)
            authManager.login(response: response)
            isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func register() async {
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.register(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            authManager.login(response: response)
            isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func handleGoogleSignIn(idToken: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.googleLogin(idToken: idToken)
            authManager.login(response: response)
            isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func handleAppleSignIn(authorization: ASAuthorization) async {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8),
              let authorizationCode = credential.authorizationCode,
              let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
            errorMessage = "Failed to get Apple credentials"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.appleLogin(
                identityToken: identityTokenString,
                authorizationCode: authCodeString
            )
            authManager.login(response: response)
            isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
