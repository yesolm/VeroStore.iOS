//
//  LocalizationHelper.swift
//  VeroStore
//
//  Created based on Android app
//

import Foundation
import SwiftUI

class LocalizationHelper: ObservableObject {
    static let shared = LocalizationHelper()
    
    @Published var currentLanguage: String = "en" {
        didSet {
            // Trigger UI update when language changes
            objectWillChange.send()
        }
    }
    
    private let languageKey = "selected_language"
    
    private init() {
        currentLanguage = UserDefaults.standard.string(forKey: languageKey) ?? "en"
    }
    
    func setLanguage(_ languageCode: String) {
        guard currentLanguage != languageCode else { return }
        
        print("🌐 Changing language from \(currentLanguage) to \(languageCode)")
        currentLanguage = languageCode
        UserDefaults.standard.set(languageCode, forKey: languageKey)
        UserDefaults.standard.synchronize()
        
        // Force UI update
        DispatchQueue.main.async {
            self.objectWillChange.send()
            // Post notification for views that need to refresh
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: languageCode)
        }
    }
    
    func localizedString(_ key: String) -> String {
        let language = currentLanguage
        
        // Try to find the .lproj bundle
        // Method 1: Direct path lookup
        if let lprojPath = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: lprojPath) {
            let localized = bundle.localizedString(forKey: key, value: key, table: "Localizable")
            if localized != key {
                return localized
            }
        }
        
        // Method 2: Look in Localization subdirectory (if files are there)
        if let bundlePath = Bundle.main.resourcePath {
            let lprojPath = "\(bundlePath)/Localization/\(language).lproj"
            if FileManager.default.fileExists(atPath: lprojPath),
               let bundle = Bundle(path: lprojPath) {
                let localized = bundle.localizedString(forKey: key, value: key, table: "Localizable")
                if localized != key {
                    return localized
                }
            }
        }
        
        // Method 3: Try to load from source directory (for development)
        let sourcePath = "/Users/yesehake/Documents/GitHub/VeroStore.iOS/VeroStore/Localization/\(language).lproj"
        if FileManager.default.fileExists(atPath: sourcePath),
           let bundle = Bundle(path: sourcePath) {
            let localized = bundle.localizedString(forKey: key, value: key, table: "Localizable")
            if localized != key {
                return localized
            }
        }
        
        // Fallback to English
        if let lprojPath = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let bundle = Bundle(path: lprojPath) {
            let localized = bundle.localizedString(forKey: key, value: key, table: "Localizable")
            if localized != key {
                return localized
            }
        }
        
        // Final fallback - return key if no translation found
        print("⚠️ Translation not found for key: '\(key)' in language: \(language)")
        return key
    }
}

extension String {
    var localized: String {
        // Access the shared instance to trigger observation
        let helper = LocalizationHelper.shared
        return helper.localizedString(self)
    }
}

// View modifier to observe language changes
struct LocalizedView: ViewModifier {
    @ObservedObject var localizationHelper = LocalizationHelper.shared
    
    func body(content: Content) -> some View {
        content
            .id(localizationHelper.currentLanguage) // Force view refresh on language change
    }
}

extension View {
    func observeLocalization() -> some View {
        modifier(LocalizedView())
    }
}
