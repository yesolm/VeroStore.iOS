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
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Text("Welcome Back!")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)

                            Text("Login to continue shopping")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)

                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)

                                TextField("Email", text: $viewModel.email)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .foregroundColor(.black)
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .password
                                    }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)

                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)

                                SecureField("Password", text: $viewModel.password)
                                    .textContentType(.password)
                                    .foregroundColor(.black)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.go)
                                    .onSubmit {
                                        Task {
                                            await viewModel.login()
                                        }
                                    }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
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
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 1)

                            Text("OR")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 10)

                            Rectangle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 1)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)

                        // Social Login Buttons
                        VStack(spacing: 15) {
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
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)

                        // Sign Up Link
                        HStack(spacing: 5) {
                            Text("Don't have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)

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
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
            .onAppear {
                focusedField = .email
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
