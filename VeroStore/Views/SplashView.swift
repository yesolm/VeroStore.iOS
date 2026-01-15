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
                    // Background
                    Color.white
                        .ignoresSafeArea()
                    
                    // App Logo - centered
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .scaleEffect(isReady ? 1.0 : 0.8)
                        .opacity(isReady ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isReady)
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
        // Show logo animation immediately
        withAnimation {
            isReady = true
        }
        
        // Wait a bit then proceed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "has_completed_onboarding")
            
            withAnimation {
                if hasCompletedOnboarding {
                    showMain = true
                } else {
                    showOnboarding = true
                }
            }
        }
    }
}
