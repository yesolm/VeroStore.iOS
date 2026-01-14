//
//  SplashView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct SplashView: View {
    @StateObject private var authService = AuthService.shared
    @State private var isReady = false
    @State private var showOnboarding = false
    @State private var showMain = false
    
    var body: some View {
        Group {
            if showMain {
                MainTabView()
            } else if showOnboarding {
                OnboardingView(onComplete: {
                    showOnboarding = false
                    showMain = true
                })
            } else {
                ZStack {
                    Color.white.ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        
                        // App Logo with Cart text
                        HStack(spacing: 16) {
                            // Your actual app icon from Assets
                            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                                .resizable()
                                .frame(width: 120, height: 120)
                                .cornerRadius(24)
                                .shadow(color: .appPrimary.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            Text("Cart")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.appPrimary)
                        }
                        
                        Spacer()
                        
                        if !isReady {
                            ProgressView()
                                .tint(.appPrimary)
                                .padding()
                        }
                    }
                }
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            // Check if onboarding was completed
            if UserDefaults.standard.bool(forKey: "has_completed_onboarding") && !showMain {
                showOnboarding = false
                showMain = true
            }
        }
    }
    
    private func checkOnboardingStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isReady = true
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "has_completed_onboarding")
            
            if hasCompletedOnboarding {
                showMain = true
            } else {
                showOnboarding = true
            }
        }
    }
}
