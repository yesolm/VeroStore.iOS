//
//  JWTDecoder.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import Foundation

struct JWTClaims: Codable {
    let sub: String?  // Subject (user ID)
    let email: String?
    let name: String?
    let given_name: String?
    let family_name: String?
    let roles: [String]?
    let exp: Int?  // Expiration time
    let iat: Int?  // Issued at

    // Custom properties
    var userId: String? { sub }
    var firstName: String? { given_name }
    var lastName: String? { family_name }
}

class JWTDecoder {
    static func decode(jwtToken: String) -> JWTClaims? {
        let segments = jwtToken.components(separatedBy: ".")
        guard segments.count > 1 else {
            print("Invalid JWT token format")
            return nil
        }

        // JWT payload is the second segment
        let payloadSegment = segments[1]

        // Add padding if needed (JWT Base64 doesn't use padding)
        var base64 = payloadSegment
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddingLength = 4 - (base64.count % 4)
        if paddingLength < 4 {
            base64 += String(repeating: "=", count: paddingLength)
        }

        guard let data = Data(base64Encoded: base64) else {
            print("Failed to decode base64")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let claims = try decoder.decode(JWTClaims.self, from: data)
            return claims
        } catch {
            print("Failed to decode JWT claims: \(error)")
            return nil
        }
    }

    static func isTokenExpired(jwtToken: String) -> Bool {
        guard let claims = decode(jwtToken: jwtToken),
              let exp = claims.exp else {
            return true
        }

        let expirationDate = Date(timeIntervalSince1970: TimeInterval(exp))
        return expirationDate < Date()
    }
}
