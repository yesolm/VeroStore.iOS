//
//  ProfileView.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showLogin = false

    var body: some View {
        NavigationView {
            if authManager.isAuthenticated {
                LoggedInProfileView()
            } else {
                LoggedOutProfileView(showLogin: $showLogin)
            }
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
    }
}

struct LoggedInProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showLogoutConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Profile Header
                VStack(spacing: 15) {
                    // Avatar
                    Circle()
                        .fill(Color.lightGray)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.mediumGray)
                        )

                    // User Info
                    VStack(spacing: 5) {
                        if let user = authManager.currentUser {
                            Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)

                            Text(user.email)
                                .font(.system(size: 14))
                                .foregroundColor(.mediumGray)
                        }
                    }
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
                .background(Color.white)

                // Account Information Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("Account Information")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.mediumGray)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 15)

                    VStack(spacing: 0) {
                        ProfileMenuItem(
                            icon: "envelope",
                            title: authManager.currentUser?.email ?? ""
                        )

                        Divider()
                            .padding(.leading, 60)

                        ProfileMenuItem(
                            icon: "phone",
                            title: authManager.currentUser?.phone ?? "+1 234 567 8900"
                        )
                    }
                    .background(Color.white)
                }

                // Quick Actions Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("Quick Actions")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.mediumGray)
                        .padding(.horizontal)
                        .padding(.top, 30)
                        .padding(.bottom, 15)

                    VStack(spacing: 0) {
                        ProfileMenuButton(
                            icon: "bag",
                            title: "My Orders",
                            iconColor: .primaryOrange
                        )

                        Divider()
                            .padding(.leading, 60)

                        ProfileMenuButton(
                            icon: "gearshape",
                            title: "Settings",
                            iconColor: .primaryOrange
                        )

                        Divider()
                            .padding(.leading, 60)

                        Button(action: {
                            showLogoutConfirm = true
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                    .frame(width: 30)

                                Text("Logout")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.mediumGray)
                                    .font(.system(size: 14))
                            }
                            .padding()
                            .background(Color.white)
                        }
                    }
                    .background(Color.white)
                }

                Spacer(minLength: 30)
            }
            .background(Color.white)
        }
        .background(Color.white)
        .navigationTitle("Profile")
        .alert("Logout", isPresented: $showLogoutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                Task {
                    await authManager.logout()
                }
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
}

struct LoggedOutProfileView: View {
    @Binding var showLogin: Bool

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Icon
            Circle()
                .fill(Color.lightGray)
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.mediumGray)
                )

            // Text
            VStack(spacing: 10) {
                Text("Welcome!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)

                Text("Login to access your profile and orders")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            // Login Button
            Button(action: {
                showLogin = true
            }) {
                Text("Login / Sign Up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.primaryOrange)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Profile")
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.mediumGray)
                .frame(width: 30)

            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)

            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}

struct ProfileMenuButton: View {
    let icon: String
    let title: String
    var iconColor: Color = .primaryOrange

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 30)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding()
            .background(Color.white)
        }
    }
}

#Preview {
    ProfileView()
}
