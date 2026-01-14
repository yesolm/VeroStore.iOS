//
//  AuthService.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authToken: String?
    
    private let networkService = NetworkService.shared
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "auth_token"
    private let userKey = "current_user"
    
    private init() {
        loadAuthState()
    }
    
    func loadAuthState() {
        if let token = userDefaults.string(forKey: tokenKey) {
            authToken = token
            networkService.setAuthToken(token)
            isAuthenticated = true
            
            if let userData = userDefaults.data(forKey: userKey),
               let user = try? JSONDecoder().decode(User.self, from: userData) {
                currentUser = user
            }
        }
    }
    
    func login(email: String, password: String) async throws {
        let request = LoginRequest(email: email, password: password)
        let body = try JSONEncoder().encode(request)
        
        do {
            let response: AuthResponse = try await networkService.request(
                AuthResponse.self,
                endpoint: "Account/login",
                method: "POST",
                body: body
            )
            
            // Convert AuthResponse to User object
            let user = User(
                id: Int(response.userId) ?? 0,
                email: response.email,
                firstName: response.firstName,
                lastName: response.lastName,
                phone: nil,
                role: response.roles?.first
            )
            
            saveAuthState(token: response.accessToken, user: user)
        } catch let error as NetworkError {
            switch error {
            case .unauthorized:
                throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid email or password"])
            case .serverError(let code):
                let errorMessage = code == 400 ? "Invalid email or password" : "Server error: \(code)"
                throw NSError(domain: "AuthError", code: code, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            case .decodingError:
                throw NSError(domain: "AuthError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server. Please try again."])
            default:
                throw error
            }
        } catch {
            throw error
        }
    }
    
    func register(email: String, password: String, firstName: String, lastName: String, phone: String?) async throws {
        let request = RegisterRequest(email: email, password: password, firstName: firstName, lastName: lastName, phone: phone)
        let body = try JSONEncoder().encode(request)
        
        do {
            let response: AuthResponse = try await networkService.request(
                AuthResponse.self,
                endpoint: "Account/register",
                method: "POST",
                body: body
            )
            
            // Convert AuthResponse to User object
            let user = User(
                id: Int(response.userId) ?? 0,
                email: response.email,
                firstName: response.firstName,
                lastName: response.lastName,
                phone: phone,
                role: response.roles?.first
            )
            
            saveAuthState(token: response.accessToken, user: user)
        } catch let error as NetworkError {
            switch error {
            case .serverError(let code):
                let errorMessage = code == 400 ? "Registration failed. Email may already be in use." : "Server error: \(code)"
                throw NSError(domain: "AuthError", code: code, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            case .decodingError:
                throw NSError(domain: "AuthError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server. Please try again."])
            default:
                throw error
            }
        } catch {
            throw error
        }
    }
    
    func logout() async {
        do {
            _ = try await networkService.request(
                EmptyResponse.self,
                endpoint: "Account/logout",
                method: "POST"
            )
        } catch {
            // Continue with logout even if API call fails
        }
        
        clearAuthState()
    }
    
    func forgotPassword(email: String) async throws {
        let body = try JSONEncoder().encode(["email": email])
        
        _ = try await networkService.request(
            EmptyResponse.self,
            endpoint: "Account/forgot-password",
            method: "POST",
            body: body
        )
    }
    
    private func saveAuthState(token: String, user: User) {
        authToken = token
        networkService.setAuthToken(token)
        currentUser = user
        isAuthenticated = true
        
        userDefaults.set(token, forKey: tokenKey)
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: userKey)
        }
        
        // Notify that user logged in
        NotificationCenter.default.post(name: .init("UserDidLogin"), object: nil)
    }
    
    private func clearAuthState() {
        authToken = nil
        networkService.setAuthToken(nil)
        currentUser = nil
        isAuthenticated = false
        
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: userKey)
    }
}

struct EmptyResponse: Codable {}
