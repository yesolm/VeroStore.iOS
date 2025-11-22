//
//  SettingsView.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showDeleteAccountConfirm = false
    @State private var showLogoutConfirm = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Account Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Account")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.mediumGray)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 15)

                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "person",
                                title: "Edit Profile",
                                action: {
                                    // TODO: Implement edit profile
                                }
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "lock",
                                title: "Change Password",
                                action: {
                                    // TODO: Implement change password
                                }
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "envelope",
                                title: "Email Preferences",
                                action: {
                                    // TODO: Implement email preferences
                                }
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }

                    // Notifications Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Notifications")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.mediumGray)
                            .padding(.horizontal)
                            .padding(.top, 30)
                            .padding(.bottom, 15)

                        VStack(spacing: 0) {
                            SettingsToggleRow(
                                icon: "bell",
                                title: "Push Notifications",
                                isOn: .constant(true)
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsToggleRow(
                                icon: "envelope.badge",
                                title: "Email Notifications",
                                isOn: .constant(true)
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsToggleRow(
                                icon: "tag",
                                title: "Promotional Offers",
                                isOn: .constant(false)
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }

                    // Privacy Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Privacy & Security")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.mediumGray)
                            .padding(.horizontal)
                            .padding(.top, 30)
                            .padding(.bottom, 15)

                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "hand.raised",
                                title: "Privacy Policy",
                                action: {
                                    // TODO: Open privacy policy
                                }
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "doc.text",
                                title: "Terms of Service",
                                action: {
                                    // TODO: Open terms of service
                                }
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }

                    // App Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("App")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.mediumGray)
                            .padding(.horizontal)
                            .padding(.top, 30)
                            .padding(.bottom, 15)

                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "questionmark.circle",
                                title: "Help & Support",
                                action: {
                                    // TODO: Open help
                                }
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "info.circle",
                                title: "About",
                                subtitle: "Version 1.0.0",
                                action: {}
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }

                    // Danger Zone
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Danger Zone")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .padding(.top, 30)
                            .padding(.bottom, 15)

                        VStack(spacing: 0) {
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
                            }

                            Divider()
                                .padding(.leading, 60)

                            Button(action: {
                                showDeleteAccountConfirm = true
                            }) {
                                HStack(spacing: 15) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .frame(width: 30)

                                    Text("Delete Account")
                                        .font(.system(size: 16))
                                        .foregroundColor(.red)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.mediumGray)
                                        .font(.system(size: 14))
                                }
                                .padding()
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 30)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Logout", isPresented: $showLogoutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                Task {
                    await authManager.logout()
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showDeleteAccountConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                // TODO: Implement account deletion
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .foregroundColor(.primaryOrange)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.black)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                if subtitle == nil {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.mediumGray)
                        .font(.system(size: 14))
                }
            }
            .padding()
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.primaryOrange)
                .frame(width: 30)

            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.primaryOrange)
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
