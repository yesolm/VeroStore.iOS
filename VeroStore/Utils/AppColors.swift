//
//  AppColors.swift
//  VeroStore
//
//  Created based on Android app colors
//

import SwiftUI

extension Color {
    static let appPrimary = Color(hex: "#7B4019")
    static let appSecondary = Color(hex: "#d4a373")
    static let appPrimaryDark = Color(hex: "#5A2F12")
    static let appSecondaryDark = Color(hex: "#B88A5F")
    static let appText = Color(hex: "#7B4019")
    static let appTextPrimary = Color(hex: "#212121")
    static let appTextSecondary = Color(hex: "#757575")
    static let appBackground = Color.white
    static let appSurface = Color.white
    static let appDivider = Color(hex: "#BDBDBD")
    static let appBorder = Color(hex: "#E0E0E0")
    static let appError = Color(hex: "#F44336")
    static let appGreen = Color(hex: "#4CAF50")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
// Custom back button for all views
extension View {
    func customBackButton(action: @escaping () -> Void) -> some View {
        self.navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: action) {
                        ZStack {
                            Circle()
                                .fill(Color.appPrimary.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appPrimary)
                        }
                    }
                }
            }
    }
}

