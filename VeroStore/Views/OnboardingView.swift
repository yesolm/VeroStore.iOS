//
//  OnboardingView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI
import CoreLocation
import UserNotifications

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    let onComplete: (() -> Void)?
    
    @State private var onboardingStep = 0
    @State private var selectedLanguage: String? = nil
    @State private var locationStatus: CLAuthorizationStatus? = nil
    @State private var notificationAuthorized: Bool = false
    
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                switch onboardingStep {
                case 0:
                    languageSelectionStep
                case 1:
                    locationRequestStep
                case 2:
                    notificationPermissionStep
                default:
                    EmptyView()
                }
                
                Spacer()
                
                bottomButton
                    .padding()
            }
            .onAppear {
                // Set up location manager callback
                locationManager.onAuthorizationChanged = {
                    updateLocationStatus()
                }
                // Initialize status
                updateLocationStatus()
                updateNotificationStatus()
            }
            .onChange(of: onboardingStep) { newStep in
                // When moving to location step, refresh status
                if newStep == 1 {
                    // Small delay to ensure view is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.updateLocationStatus()
                    }
                } else if newStep == 2 {
                    updateNotificationStatus()
                }
            }
            .onChange(of: locationStatus) { newStatus in
                // Automatically advance when location is authorized
                if let status = newStatus, (status == .authorizedAlways || status == .authorizedWhenInUse) {
                    if onboardingStep == 1 {
                        print("✅ Location authorized, advancing to notification step")
                        onboardingStep = 2
                    }
                }
            }
            .observeLocalization() // Observe language changes
        }
    }
    
    // MARK: - Step Views
    
    private var languageSelectionStep: some View {
        VStack(spacing: 30) {
            Text("select_language".localized)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("language_selection_message".localized)
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ForEach(languages, id: \.0) { code, name, flagEmoji in
                Button(action: {
                    selectedLanguage = code
                    LocalizationHelper.shared.setLanguage(code)
                }) {
                    HStack {
                        // Flag emoji
                        Text(flagEmoji)
                            .font(.system(size: 32))
                        
                        Text(name)
                            .foregroundColor(.appTextPrimary)
                            .font(.body)
                        
                        Spacer()
                        
                        if selectedLanguage == code {
                            Image(systemName: "checkmark")
                                .foregroundColor(.appPrimary)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(selectedLanguage == code ? Color.appPrimary.opacity(0.1) : Color.appBorder.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedLanguage == code ? Color.appPrimary : Color.clear, lineWidth: 2)
                    )
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var locationRequestStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "location.fill")
                .font(.system(size: 100))
                .foregroundColor(.appPrimary)
            
            Text("enable_location".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("location_description".localized)
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var notificationPermissionStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "bell.fill")
                .font(.system(size: 100))
                .foregroundColor(.appPrimary)
            
            Text("stay_updated".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("notifications_description".localized)
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Bottom Button
    
    @ViewBuilder
    private var bottomButton: some View {
        switch onboardingStep {
        case 0:
            Button(action: {
                guard let language = selectedLanguage else { return }
                LocalizationHelper.shared.setLanguage(language)
                onboardingStep = 1
            }) {
                Text("get_started".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedLanguage != nil ? Color.appPrimary : Color.appPrimary.opacity(0.5))
                    .cornerRadius(10)
            }
            .disabled(selectedLanguage == nil)
            
        case 1:
            Button(action: {
                requestLocationPermission()
            }) {
                Text(locationButtonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appPrimary)
                    .cornerRadius(10)
            }
            .disabled(locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse)
            
        case 2:
            Button(action: {
                requestNotificationPermission()
            }) {
                Text(notificationButtonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appPrimary)
                    .cornerRadius(10)
            }
            .disabled(notificationAuthorized)
            
        default:
            EmptyView()
        }
    }
    
    private var locationButtonTitle: String {
        if locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse {
            return "enable_location".localized + " ✓"
        } else if locationStatus == .denied || locationStatus == .restricted {
            return "enable_location".localized + " (Settings)"
        } else {
            return "allow_location".localized
        }
    }
    
    private var notificationButtonTitle: String {
        notificationAuthorized ? "enable_notifications".localized + " ✓" : "enable_notifications".localized
    }
    
    // MARK: - Helper methods
    
    private func requestLocationPermission() {
        // Always check the current status first
        let currentStatus = CLLocationManager.authorizationStatus()
        print("🔍 Current location status: \(currentStatus.rawValue)")
        locationStatus = currentStatus
        
        switch currentStatus {
        case .notDetermined:
            print("📍 Requesting location permission...")
            // Request permission - this will trigger the OS dialog
            // Make sure we're on the main thread
            DispatchQueue.main.async {
                self.locationManager.requestWhenInUseAuthorization()
            }
        case .denied, .restricted:
            print("⚠️ Location permission denied/restricted, opening settings...")
            // Open app settings for user to enable
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        case .authorizedAlways, .authorizedWhenInUse:
            print("✅ Location already authorized")
            // Already authorized, proceed to next step
            onboardingStep = 2
        @unknown default:
            print("❓ Unknown location status")
            break
        }
    }
    
    func updateLocationStatus() {
        let newStatus = CLLocationManager.authorizationStatus()
        print("🔄 Location status updated: \(newStatus.rawValue)")
        locationStatus = newStatus
        
        if newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse {
            print("✅ Location authorized, moving to next step")
            // Move to next step if we're on location step
            if onboardingStep == 1 {
                onboardingStep = 2
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                notificationAuthorized = granted
                if granted {
                    // Complete onboarding
                    completeOnboarding()
                }
            }
        }
    }
    
    private func updateNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationAuthorized = settings.authorizationStatus == .authorized
                if notificationAuthorized {
                    completeOnboarding()
                }
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "has_completed_onboarding")
        onComplete?()
        dismiss()
    }
    
    // MARK: - Languages
    
    private let languages = [
        ("en", "English", "🇺🇸"),
        ("am", "አማርኛ (Amharic)", "🇪🇹")
    ]
}

// MARK: - LocationManager

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var onAuthorizationChanged: (() -> Void)?
    
    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }
    
    override init() {
        super.init()
        print("📍 LocationManager initialized")
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestWhenInUseAuthorization() {
        print("📍 Calling requestWhenInUseAuthorization()")
        let currentStatus = manager.authorizationStatus
        print("📍 Current status before request: \(currentStatus.rawValue)")
        
        if currentStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            print("📍 Permission request sent")
        } else {
            print("⚠️ Cannot request - status is not .notDetermined, it's: \(currentStatus.rawValue)")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("📍 Authorization changed to: \(status.rawValue)")
        DispatchQueue.main.async {
            self.onAuthorizationChanged?()
        }
    }
}

