//
//  NetworkService.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case unauthorized
    case unknown(Error)
}

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://api.cartbyvero.com/api/"
    private var authToken: String?
    
    private init() {}
    
    func setAuthToken(_ token: String?) {
        self.authToken = token
    }
    
    private func createRequest(endpoint: String, method: String = "GET", body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    func request<T: Decodable>(_ type: T.Type, endpoint: String, method: String = "GET", body: Data? = nil) async throws -> T {
        let request = try createRequest(endpoint: endpoint, method: method, body: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    throw NetworkError.unauthorized
                }
                // Log error details for debugging
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Server error \(httpResponse.statusCode): \(errorString)")
                }
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            // Handle empty responses
            if data.isEmpty && type != EmptyResponse.self {
                throw NetworkError.noData
            }
            
            do {
                let decoder = JSONDecoder()
                // Configure date decoding strategy if needed
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch let decodingError {
                // Log decoding error details
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Decoding error: \(decodingError)")
                    print("Response data: \(dataString)")
                }
                throw NetworkError.decodingError
            }
        } catch let urlError as URLError {
            print("URL error: \(urlError.localizedDescription) (code: \(urlError.code.rawValue))")
            throw NetworkError.unknown(urlError)
        } catch {
            throw error
        }
    }
}
