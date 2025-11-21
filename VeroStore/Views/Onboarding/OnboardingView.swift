//
//  OnboardingView.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import SwiftUI
import CoreLocation
import UserNotifications

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showMainApp = false

    var body: some View {
        ZStack {
            if currentPage == 0 {
                LocationPermissionView {
                    withAnimation {
                        currentPage = 1
                    }
                }
            } else {
                NotificationPermissionView {
                    completeOnboarding()
                }
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            MainTabView()
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "has_completed_onboarding")
        showMainApp = true
    }
}

struct LocationPermissionView: View {
    let onContinue: () -> Void
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "location.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.primaryOrange)

            Text("Enable Location")
                .font(.system(size: 28, weight: .bold))

            Text("We need your location to show you nearby stores and products available in your area.")
                .font(.system(size: 16))
                .foregroundColor(.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 15) {
                Button(action: {
                    locationManager.requestPermission()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onContinue()
                    }
                }) {
                    Text("Enable Location")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryOrange)
                        .cornerRadius(12)
                }

                Button(action: onContinue) {
                    Text("Skip for now")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.mediumGray)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}

struct NotificationPermissionView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "bell.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.primaryOrange)

            Text("Enable Notifications")
                .font(.system(size: 28, weight: .bold))

            Text("Get notified about exclusive deals, order updates, and new arrivals.")
                .font(.system(size: 16))
                .foregroundColor(.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 15) {
                Button(action: {
                    requestNotificationPermission()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onContinue()
                    }
                }) {
                    Text("Enable Notifications")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryOrange)
                        .cornerRadius(12)
                }

                Button(action: onContinue) {
                    Text("Skip for now")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.mediumGray)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
}

#Preview {
    OnboardingView()
}
