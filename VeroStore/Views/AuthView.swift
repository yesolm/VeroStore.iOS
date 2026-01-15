//
//  AuthView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct AuthView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthService.shared
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showForgotPassword = false
    
    var body: some View {
        ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.appPrimary)
                    
                    Text(isLogin ? "welcome_back".localized : "create_account".localized)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(isLogin ? "sign_in_to_account".localized : "join_vero_today".localized)
                        .foregroundColor(.gray)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    if !isLogin {
                        StylishTextField(
                            icon: "person.fill",
                            placeholder: "first_name".localized,
                            text: $firstName
                        )
                        
                        StylishTextField(
                            icon: "person.fill",
                            placeholder: "last_name".localized,
                            text: $lastName
                        )
                    }
                    
                    StylishTextField(
                        icon: "envelope.fill",
                        placeholder: "email_address".localized,
                        text: $email,
                        keyboardType: .emailAddress
                    )
                    
                    StylishSecureField(
                        icon: "lock.fill",
                        placeholder: "password".localized,
                        text: $password
                    )
                    
                    if !isLogin {
                        StylishSecureField(
                            icon: "lock.fill",
                            placeholder: "confirm_password".localized,
                            text: $confirmPassword
                        )
                        
                        StylishTextField(
                            icon: "phone.fill",
                            placeholder: "phone_optional".localized,
                            text: $phone,
                            keyboardType: .phonePad
                        )
                    }
                    
                    Button(action: {
                        if isLogin {
                            login()
                        } else {
                            register()
                        }
                    }) {
                        HStack(spacing: 12) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: isLogin ? "arrow.right.circle.fill" : "person.badge.plus.fill")
                                    .font(.system(size: 20))
                                Text(isLogin ? "sign_in".localized : "create_account".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: isLoading ? [Color.appPrimary.opacity(0.6)] : [Color.appPrimary, Color.appPrimary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(color: Color.appPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                    .disabled(isLoading)
                    
                    if isLogin {
                        Button("forgot_password".localized) {
                            showForgotPassword = true
                        }
                        .foregroundColor(.appPrimary)
                    }
                    
                    HStack {
                        Text(isLogin ? "dont_have_account".localized : "already_have_account".localized)
                        Button(isLogin ? "sign_up".localized : "sign_in".localized) {
                            isLogin.toggle()
                            errorMessage = nil
                        }
                        .foregroundColor(.appPrimary)
                    }
                }
                .padding()
            }
            .navigationTitle(isLogin ? "login".localized : "register".localized)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
            .onChange(of: authService.isAuthenticated) { authenticated in
                if authenticated {
                    dismiss()
                }
            }
    }
    
    private func login() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "please_fill_all_fields".localized
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                try await authService.login(email: email, password: password)
                // Dismiss will be handled by onChange observer
            } catch let error as NSError {
                errorMessage = error.localizedDescription
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func register() {
        guard !email.isEmpty && !password.isEmpty && !firstName.isEmpty && !lastName.isEmpty else {
            errorMessage = "please_fill_required_fields".localized
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "passwords_do_not_match".localized
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.register(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    phone: phone.isEmpty ? nil : phone
                )
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("forgot_password_title".localized)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("forgot_password_subtitle".localized)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextField("email_address".localized, text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                Button(action: sendResetLink) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("send_reset_link".localized)
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.appPrimary)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(isLoading)
                
                Spacer()
            }
            .navigationTitle("forgot_password_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close".localized) {
                        dismiss()
                    }
                }
            }
            .alert("reset_link_sent".localized, isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("reset_link_message".localized)
            }
        }
    }
    
    private func sendResetLink() {
        guard !email.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                try await authService.forgotPassword(email: email)
                showSuccess = true
            } catch {
                print("Error sending reset link: \(error)")
            }
            isLoading = false
        }
    }
}
// MARK: - Stylish Text Field Components

struct StylishTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.appPrimary)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
        )
    }
}

struct StylishSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @State private var isSecure = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.appPrimary)
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
            }
            
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
        )
    }
}

