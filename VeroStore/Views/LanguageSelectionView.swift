//
//  LanguageSelectionView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct LanguageSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    @State private var selectedLanguage: String
    
    private let languages = [
        ("en", "English", "🇺🇸"),
        ("am", "አማርኛ (Amharic)", "🇪🇹")
    ]
    
    init(onComplete: (() -> Void)? = nil) {
        _selectedLanguage = State(initialValue: LocalizationHelper.shared.currentLanguage)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("select_language".localized)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)
                .padding()
            
            Text("language_selection_message".localized)
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .padding(.horizontal)
            
            ForEach(languages, id: \.0) { code, name, flagEmoji in
                Button(action: {
                    selectedLanguage = code
                    LocalizationHelper.shared.setLanguage(code)
                }) {
                    HStack {
                        // Flag emoji
                        Text(flagEmoji)
                            .font(.system(size: 32))
                        
                        Text(name)
                            .foregroundColor(.appTextPrimary)
                            .font(.body)
                        
                        Spacer()
                        
                        if selectedLanguage == code {
                            Image(systemName: "checkmark")
                                .foregroundColor(.appPrimary)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(selectedLanguage == code ? Color.appPrimary.opacity(0.1) : Color.appBorder.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedLanguage == code ? Color.appPrimary : Color.clear, lineWidth: 2)
                    )
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color.appBackground)
        .navigationTitle("language".localized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedLanguage = localizationHelper.currentLanguage
        }
        .observeLocalization() // Observe language changes
    }
}
