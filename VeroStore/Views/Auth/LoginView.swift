//
//  LoginView.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showRegister = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Welcome Back!")
                            .font(.system(size: 28, weight: .bold))

                        Text("Login to continue shopping")
                            .font(.system(size: 16))
                            .foregroundColor(.mediumGray)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.mediumGray)
                                .frame(width: 20)

                            TextField("Email", text: $viewModel.email)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        .padding()
                        .background(Color.lightGray)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.mediumGray)
                                .frame(width: 20)

                            SecureField("Password", text: $viewModel.password)
                                .textContentType(.password)
                        }
                        .padding()
                        .background(Color.lightGray)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // Forgot Password
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Text("Forgot Password?")
                                .font(.system(size: 14))
                                .foregroundColor(.primaryOrange)
                        }
                    }
                    .padding(.horizontal)

                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Login Button
                    Button(action: {
                        Task {
                            await viewModel.login()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.primaryOrange)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.lightGray)
                            .frame(height: 1)

                        Text("OR")
                            .font(.system(size: 14))
                            .foregroundColor(.mediumGray)
                            .padding(.horizontal, 10)

                        Rectangle()
                            .fill(Color.lightGray)
                            .frame(height: 1)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    // Social Login Buttons
                    VStack(spacing: 15) {
                        // Google Sign In
                        Button(action: {
                            // Handle Google Sign In
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20))

                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.darkGray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.lightGray, lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }

                        // Apple Sign In
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: { request in
                                request.requestedScopes = [.email, .fullName]
                            },
                            onCompletion: { result in
                                switch result {
                                case .success(let authorization):
                                    Task {
                                        await viewModel.handleAppleSignIn(authorization: authorization)
                                    }
                                case .failure(let error):
                                    viewModel.errorMessage = error.localizedDescription
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Sign Up Link
                    HStack(spacing: 5) {
                        Text("Do not have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.mediumGray)

                        Button(action: {
                            showRegister = true
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primaryOrange)
                        }
                    }
                    .padding(.top, 10)

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.darkGray)
                    }
                }
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
        }
        .onChange(of: viewModel.isAuthenticated) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

#Preview {
    LoginView()
}
