//
//  RegisterView.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import SwiftUI
import AuthenticationServices

struct RegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))

                        Text("Sign up to get started")
                            .font(.system(size: 16))
                            .foregroundColor(.mediumGray)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    // First Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.mediumGray)
                                .frame(width: 20)

                            TextField("First Name", text: $viewModel.firstName)
                                .textContentType(.givenName)
                        }
                        .padding()
                        .background(Color.lightGray)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // Last Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.mediumGray)
                                .frame(width: 20)

                            TextField("Last Name", text: $viewModel.lastName)
                                .textContentType(.familyName)
                        }
                        .padding()
                        .background(Color.lightGray)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

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
                                .textContentType(.newPassword)
                        }
                        .padding()
                        .background(Color.lightGray)
                        .cornerRadius(10)
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

                    // Register Button
                    Button(action: {
                        Task {
                            await viewModel.register()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign Up")
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
                            .signUp,
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

                    // Terms and Privacy
                    Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                        .font(.system(size: 12))
                        .foregroundColor(.mediumGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

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
        }
        .onChange(of: viewModel.isAuthenticated) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

#Preview {
    RegisterView()
}
