//
//  APIClient.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(Int, String?)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message ?? "Unknown error")"
        case .unauthorized:
            return "Unauthorized. Please login again."
        }
    }
}

class APIClient {
    static let shared = APIClient()

    private let baseURL = "https://api.cartbyvero.com/api"
    private let session: URLSession

    private var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "accessToken") }
        set { UserDefaults.standard.set(newValue, forKey: "accessToken") }
    }

    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "refreshToken") }
        set { UserDefaults.standard.set(newValue, forKey: "refreshToken") }
    }

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }

    func setTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func clearTokens() {
        self.accessToken = nil
        self.refreshToken = nil
    }

    private func createRequest(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable? = nil,
        queryParameters: [String: String]? = nil,
        requiresAuth: Bool = false
    ) throws -> URLRequest {
        var urlString = "\(baseURL)\(endpoint)"

        // Add query parameters
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            let queryString = queryParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += "?\(queryString)"
        }

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add authorization header if required
        if requiresAuth, let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        // Add body if provided
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        }

        return request
    }

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        queryParameters: [String: String]? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        let request = try createRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            queryParameters: queryParameters,
            requiresAuth: requiresAuth
        )

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }

                let errorMessage = String(data: data, encoding: .utf8)
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                // Try multiple date formats
                let formatters = [
                    // ISO8601 with fractional seconds and no timezone
                    { () -> DateFormatter in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        return formatter
                    }(),
                    // ISO8601 with fractional seconds (shorter)
                    { () -> DateFormatter in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        return formatter
                    }(),
                    // ISO8601 without fractional seconds
                    { () -> DateFormatter in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        return formatter
                    }(),
                    // Standard ISO8601 with timezone
                    ISO8601DateFormatter()
                ]

                for formatter in formatters {
                    if let iso8601Formatter = formatter as? ISO8601DateFormatter {
                        if let date = iso8601Formatter.date(from: dateString) {
                            return date
                        }
                    } else if let dateFormatter = formatter as? DateFormatter {
                        if let date = dateFormatter.date(from: dateString) {
                            return date
                        }
                    }
                }

                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string: \(dateString)"
                )
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    func requestWithoutResponse(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable? = nil,
        queryParameters: [String: String]? = nil,
        requiresAuth: Bool = false
    ) async throws {
        let request = try createRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            queryParameters: queryParameters,
            requiresAuth: requiresAuth
        )

        do {
            let (_, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }
                throw APIError.serverError(httpResponse.statusCode, nil)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
