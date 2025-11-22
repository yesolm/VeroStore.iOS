//
//  MainTabView.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var cartManager = CartManager.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)

            WishlistView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "heart.fill" : "heart")
                    Text("Wishlist")
                }
                .tag(1)

            CartView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "cart.fill" : "cart")
                    Text("Cart")
                }
                .badge(cartManager.itemCount)
                .tag(2)

            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.primaryOrange)
    }
}

#Preview {
    MainTabView()
}
