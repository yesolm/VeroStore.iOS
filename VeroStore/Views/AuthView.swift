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
                        TextField("first_name".localized, text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("last_name".localized, text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    TextField("email_address".localized, text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("password".localized, text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !isLogin {
                        SecureField("confirm_password".localized, text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("phone_optional".localized, text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                    
                    Button(action: {
                        if isLogin {
                            login()
                        } else {
                            register()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isLogin ? "sign_in".localized : "create_account".localized)
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLoading ? Color.appPrimary.opacity(0.6) : Color.appPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
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
