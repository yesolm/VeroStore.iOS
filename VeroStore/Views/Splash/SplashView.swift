//
//  SplashView.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()
    @State private var showOnboarding = false
    @State private var showMainApp = false

    var body: some View {
        ZStack {
            Color.primaryOrange
                .ignoresSafeArea()

            VStack(spacing: 20) {
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        Image(systemName: "bag.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)

                        Text("VeroStore")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    }
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)

                        Text("Error Loading")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button(action: {
                            Task {
                                await viewModel.retry()
                            }
                        }) {
                            Text("Retry")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primaryOrange)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
        }
        .fullScreenCover(isPresented: $showMainApp) {
            MainTabView()
        }
        .task {
            await viewModel.loadInitialData()
        }
        .onChange(of: viewModel.shouldShowOnboarding) { _, newValue in
            showOnboarding = newValue
        }
        .onChange(of: viewModel.shouldShowMain) { _, newValue in
            showMainApp = newValue
        }
    }
}

#Preview {
    SplashView()
}
