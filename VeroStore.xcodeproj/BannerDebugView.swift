//
//  BannerDebugView.swift
//  VeroStore
//
//  Debug view to test banner loading
//

import SwiftUI

struct BannerDebugView: View {
    @StateObject private var bannerService = BannerService.shared
    @StateObject private var storeService = StoreService.shared
    @State private var banners: [Banner] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Store Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Store Information")
                            .font(.headline)
                        
                        if let store = storeService.selectedStore {
                            Text("Selected Store: \(store.name)")
                            Text("Store ID: \(store.id)")
                        } else {
                            Text("No store selected")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    Divider()
                    
                    // Banner Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Banner Information")
                            .font(.headline)
                        
                        Text("Banners Count: \(banners.count)")
                        
                        if let error = errorMessage {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Load Buttons
                    VStack(spacing: 12) {
                        Button(action: loadBannersWithDeviceType) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Load Banners (iOS - deviceType=2)")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading)
                        
                        Button(action: loadAllBanners) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Load All Banners (No filter)")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading)
                    }
                    
                    Divider()
                    
                    // Banner List
                    if !banners.isEmpty {
                        Text("Loaded Banners")
                            .font(.headline)
                        
                        ForEach(banners) { banner in
                            BannerDebugCard(banner: banner)
                        }
                    } else if !isLoading {
                        Text("No banners loaded yet")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Banner Debug")
        }
    }
    
    private func loadBannersWithDeviceType() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                banners = try await bannerService.getActiveBanners(
                    storeId: storeService.selectedStore?.id,
                    deviceType: 2
                )
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
                banners = []
            }
            isLoading = false
        }
    }
    
    private func loadAllBanners() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Try to load without device type filter
                var endpoint = "Banners/active"
                if let storeId = storeService.selectedStore?.id {
                    endpoint += "?storeId=\(storeId)"
                }
                
                banners = try await NetworkService.shared.request([Banner].self, endpoint: endpoint)
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
                banners = []
            }
            isLoading = false
        }
    }
}

struct BannerDebugCard: View {
    let banner: Banner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: banner.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(8)
                case .failure:
                    Rectangle()
                        .fill(Color.red.opacity(0.2))
                        .frame(height: 120)
                        .overlay(Text("Failed to load"))
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 120)
                        .overlay(ProgressView())
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("ID: \(banner.id)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if let title = banner.title {
                    Text("Title: \(title)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text("Device Type: \(banner.deviceType)")
                    .font(.caption)
                
                Text("Active: \(banner.isActive ? "Yes" : "No")")
                    .font(.caption)
                    .foregroundColor(banner.isActive ? .green : .red)
                
                if let linkType = banner.linkType {
                    Text("Link Type: \(linkType)")
                        .font(.caption)
                }
                
                Text("Display Order: \(banner.displayOrder)")
                    .font(.caption)
            }
            .padding(8)
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    BannerDebugView()
}
