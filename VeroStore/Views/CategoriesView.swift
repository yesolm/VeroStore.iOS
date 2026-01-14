//
//  CategoriesView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var categoryService = CategoryService.shared
    @StateObject private var storeService = StoreService.shared
    @State private var categories: [Category] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if categories.isEmpty {
                    VStack {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No categories available")
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(categories) { category in
                                NavigationLink(destination: ProductsListView(categoryId: category.id, categoryName: category.name)) {
                                    CategoryCardView(category: category)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("categories".localized)
            .onAppear {
                loadCategories()
            }
        }
    }
    
    private func loadCategories() {
        guard let storeId = storeService.selectedStore?.id else { return }
        isLoading = true
        
        Task {
            do {
                categories = try await categoryService.getCategories(storeId: storeId)
            } catch {
                print("Error loading categories: \(error)")
            }
            isLoading = false
        }
    }
}

struct CategoryCardView: View {
    let category: Category
    
    var body: some View {
        VStack {
            if let imageUrl = category.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 120)
                .clipped()
                .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.appPrimary.opacity(0.2))
                    .frame(height: 120)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 40))
                            .foregroundColor(.appPrimary)
                    )
            }
            
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.top, 8)
        }
    }
}
