//
//  SettingsMenuBottomSheet.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct SettingsMenuBottomSheet: View {
    @Environment(\.dismiss) var dismiss
    let onSelectStore: () -> Void
    let onChangeLanguage: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Header
            HStack {
                Text("settings".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.appTextPrimary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            Divider()
            
            // Store Selection Option
            Button(action: {
                dismiss()
                onSelectStore()
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.appPrimary)
                        .frame(width: 24, height: 24)
                    
                    Text("select_store".localized)
                        .font(.body)
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
            
            // Language Selection Option
            Button(action: {
                dismiss()
                onChangeLanguage()
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "globe")
                        .font(.system(size: 20))
                        .foregroundColor(.appPrimary)
                        .frame(width: 24, height: 24)
                    
                    Text("change_language".localized)
                        .font(.body)
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .background(Color.white)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.hidden) // We're showing our own drag indicator
    }
}
