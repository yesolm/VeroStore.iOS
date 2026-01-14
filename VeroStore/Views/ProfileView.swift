//
//  ProfileView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var bannerService = BannerService.shared
    @StateObject private var storeService = StoreService.shared
    @StateObject private var categoryService = CategoryService.shared
    @State private var showSettings = false
    @State private var showStoreSelector = false
    @State private var showLanguageSelector = false
    @State private var banners: [Banner] = []
    @State private var categories: [Category] = []
    @State private var isLoadingBanners = false
    @State private var isLoadingCategories = false
    
    var body: some View {
        NavigationStack {
            Group {
                if authService.isAuthenticated, let user = authService.currentUser {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Modern Header with gradient background
                            ZStack(alignment: .top) {
                                // Gradient Background
                                LinearGradient(
                                    colors: [Color.appPrimary, Color.appPrimary.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(height: 220)
                                .ignoresSafeArea(edges: .top)
                                
                                VStack(spacing: 16) {
                                    // Settings gear icon
                                    HStack {
                                        Spacer()
                                        Menu {
                                            Button(action: {
                                                showStoreSelector = true
                                            }) {
                                                Label("select_store".localized, systemImage: "storefront")
                                            }
                                            
                                            Button(action: {
                                                showLanguageSelector = true
                                            }) {
                                                Label("language".localized, systemImage: "globe")
                                            }
                                        } label: {
                                            Image(systemName: "gearshape.fill")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .background(Color.white.opacity(0.2))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                    
                                    // Profile Avatar and Info
                                    VStack(spacing: 12) {
                                        // Avatar with border
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 100, height: 100)
                                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                            
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 45))
                                                .foregroundColor(.appPrimary)
                                        }
                                        
                                        VStack(spacing: 4) {
                                            Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            
                                            Text(user.email)
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                    }
                                }
                                .padding(.top, 20)
                            }
                            
                            // Content Section
                            VStack(spacing: 24) {
                                // Quick Actions Card
                                VStack(spacing: 0) {
                                    ProfileActionButton(
                                        icon: "bag.fill",
                                        title: "my_orders".localized,
                                        subtitle: "view_order_history".localized,
                                        iconColor: .blue
                                    ) {
                                        // Navigate to orders
                                    }
                                    
                                    Divider().padding(.leading, 60)
                                    
                                    ProfileActionButton(
                                        icon: "heart.fill",
                                        title: "my_wishlist".localized,
                                        subtitle: "saved_items".localized,
                                        iconColor: .red
                                    ) {
                                        // Navigate to wishlist
                                    }
                                    
                                    Divider().padding(.leading, 60)
                                    
                                    ProfileActionButton(
                                        icon: "storefront.fill",
                                        title: "select_store".localized,
                                        subtitle: storeService.selectedStore?.name ?? "no_store_selected".localized,
                                        iconColor: .appPrimary
                                    ) {
                                        showStoreSelector = true
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                                .padding(.horizontal)
                                
                                // Promotions/Banners Section
                                if !banners.isEmpty || isLoadingBanners {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("promotions".localized)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .padding(.horizontal)
                                        
                                        if !banners.isEmpty {
                                            ProfileBannerGridView(banners: banners)
                                        } else if isLoadingBanners {
                                            LazyVGrid(columns: [GridItem(.fixed(170), spacing: 15), GridItem(.fixed(170), spacing: 15)], spacing: 12) {
                                                ForEach(0..<2, id: \.self) { _ in
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(width: 170, height: 120)
                                                        .cornerRadius(12)
                                                        .redacted(reason: .placeholder)
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                
                                // Categories Section
                                if !categories.isEmpty || isLoadingCategories {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("shop_by_category".localized)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .padding(.horizontal)
                                        
                                        if !categories.isEmpty {
                                            LazyVGrid(columns: [GridItem(.fixed(170), spacing: 12), GridItem(.fixed(170), spacing: 12)], spacing: 12) {
                                                ForEach(categories) { category in
                                                    NavigationLink(destination: ProductsListView(categoryId: category.id, categoryName: category.name)) {
                                                        ProfileCategoryCardView(category: category)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                            .padding(.horizontal)
                                        } else if isLoadingCategories {
                                            LazyVGrid(columns: [GridItem(.fixed(170), spacing: 12), GridItem(.fixed(170), spacing: 12)], spacing: 12) {
                                                ForEach(0..<4, id: \.self) { _ in
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(width: 170, height: 150)
                                                        .cornerRadius(12)
                                                        .redacted(reason: .placeholder)
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                        
                                        // Progress indicator under categories
                                        if isLoadingCategories {
                                            ProgressView()
                                                .progressViewStyle(LinearProgressViewStyle(tint: .appPrimary))
                                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                                .padding(.horizontal)
                                                .padding(.top, 8)
                                        }
                                    }
                                }
                                
                                // Logout Button
                                Button(action: {
                                    Task {
                                        await authService.logout()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.right.square.fill")
                                        Text("logout".localized)
                                    }
                                    .font(.headline)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                            .padding(.top, 24)
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("welcome".localized)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("login_message".localized)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: AuthView()) {
                            Text("login_signup".localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.appPrimary)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .navigationTitle("profile".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Show gear icon for both logged in and logged out states
                if !authService.isAuthenticated {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {
                                showStoreSelector = true
                            }) {
                                Label("select_store".localized, systemImage: "storefront")
                            }
                            
                            Button(action: {
                                showLanguageSelector = true
                            }) {
                                Label("language".localized, systemImage: "globe")
                            }
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .foregroundColor(.appPrimary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showStoreSelector) {
                StoreSelectorView()
            }
            .sheet(isPresented: $showLanguageSelector) {
                NavigationStack {
                    LanguageSelectionView()
                }
            }
            .task {
                await loadBanners()
                await loadCategories()
            }
        }
    }
    
    private func loadBanners() async {
        isLoadingBanners = true
        do {
            // Load banners for the selected store (or all if no store selected)
            banners = try await bannerService.getActiveBanners(storeId: storeService.selectedStore?.id)
        } catch {
            // Silently fail - banners are not critical for profile view
            print("Failed to load banners: \(error)")
        }
        isLoadingBanners = false
    }
    
    private func loadCategories() async {
        guard let storeId = storeService.selectedStore?.id else {
            isLoadingCategories = false
            return
        }
        
        isLoadingCategories = true
        do {
            categories = try await categoryService.getCategories(storeId: storeId)
        } catch {
            // Silently fail - categories are not critical for profile view
            print("Failed to load categories: \(error)")
        }
        isLoadingCategories = false
    }
}

// Modern Action Button with Icon, Title and Subtitle
struct ProfileActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
        }
    }
}

// Custom BannerGridView for ProfileView with constrained images
struct ProfileBannerGridView: View {
    let banners: [Banner]
    private let columns = [
        GridItem(.fixed(170), spacing: 15),
        GridItem(.fixed(170), spacing: 15)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(banners) { banner in
                AsyncImage(url: URL(string: banner.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                                    .tint(.appPrimary)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 170, height: 120)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(width: 170, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
    }
}

// Custom CategoryCardView for ProfileView with constrained images
struct ProfileCategoryCardView: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageUrl = category.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                                    .tint(.appPrimary)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 170, height: 100)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.appPrimary.opacity(0.2))
                            .overlay(
                                Image(systemName: "square.grid.2x2")
                                    .font(.system(size: 30))
                                    .foregroundColor(.appPrimary)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(width: 170, height: 100)
            } else {
                Rectangle()
                    .fill(Color.appPrimary.opacity(0.2))
                    .frame(width: 170, height: 100)
                    .overlay(
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 30))
                            .foregroundColor(.appPrimary)
                    )
            }
            
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)
                .padding(8)
                .frame(width: 170, alignment: .leading)
                .frame(height: 50)
        }
        .frame(width: 170, height: 150)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : .appPrimary)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(isDestructive ? .red : .primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Preferences") {
                    NavigationLink(destination: LanguageSelectionView()) {
                        HStack {
                            Image(systemName: "globe")
                            Text("language".localized)
                        }
                    }
                }
            }
            .navigationTitle("settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

