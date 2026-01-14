//
//  ProductDetailView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct ProductDetailView: View {
    let productId: Int
    @StateObject private var productService = ProductService.shared
    @StateObject private var cartService = CartService.shared
    @StateObject private var storeService = StoreService.shared
    @StateObject private var authService = AuthService.shared
    @State private var product: Product?
    @State private var variations: [ProductVariation] = []
    @State private var selectedVariationId: Int? = nil
    @State private var isLoading = true
    @State private var quantity = 1
    @State private var showAddedToCart = false
    @State private var showVariationError = false
    @State private var isInWishlist = false
    @State private var selectedImageIndex = 0
    @State private var showLoginPrompt = false
    @State private var variationsLoadFailed = false
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .scaleEffect(2.0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(minHeight: 400)
            } else if let product = product {
                VStack(alignment: .leading, spacing: 0) {
                    // Product Image - Full Width with floating heart button
                    ZStack(alignment: .topTrailing) {
                        if let images = product.images, !images.isEmpty {
                            let selectedImage = images[selectedImageIndex]
                            AsyncImage(url: URL(string: selectedImage.imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 400)
                                        .overlay(
                                            ProgressView()
                                                .scaleEffect(1.5)
                                        )
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 400)
                                        .clipped()
                                case .failure:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 400)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.largeTitle)
                                                .foregroundColor(.gray)
                                        )
                                @unknown default:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 400)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 400)
                        } else if let imageUrl = product.primaryImageUrl {
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 400)
                                        .overlay(
                                            ProgressView()
                                                .scaleEffect(1.5)
                                        )
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 400)
                                        .clipped()
                                case .failure:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 400)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.largeTitle)
                                                .foregroundColor(.gray)
                                        )
                                @unknown default:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 400)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 400)
                        }
                        
                        // Floating heart button
                        Button(action: toggleWishlist) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 44, height: 44)
                                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
                                
                                Image(systemName: isInWishlist ? "heart.fill" : "heart")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(isInWishlist ? .red : .appPrimary)
                            }
                        }
                        .padding(16)
                    }
                    
                    // Image Thumbnails Gallery
                    if let images = product.images, images.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                                    Button(action: {
                                        withAnimation {
                                            selectedImageIndex = index
                                        }
                                    }) {
                                        AsyncImage(url: URL(string: image.imageUrl)) { phase in
                                            switch phase {
                                            case .empty:
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .overlay(
                                                        ProgressView()
                                                            .scaleEffect(0.7)
                                                    )
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 70, height: 70)
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
                                        .frame(width: 70, height: 70)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    selectedImageIndex == index ? Color.appPrimary : Color.gray.opacity(0.3),
                                                    lineWidth: selectedImageIndex == index ? 3 : 1
                                                )
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                        .background(Color.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text(product.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("$\(String(format: "%.2f", product.price))")
                            .font(.title2)
                            .foregroundColor(.appPrimary)
                        
                        if let description = product.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            if let rating = product.rating {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", rating))
                                }
                            }
                            
                            Text("\(product.reviewCount) reviews")
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            if product.stockQuantity > 0 {
                                Text("\(product.stockQuantity) in stock")
                                    .foregroundColor(.green)
                            } else {
                                Text("Out of stock")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Variation Selection - ALWAYS SHOW if hasVariations
                        if product.hasVariations {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("select_options".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                if variationsLoadFailed {
                                    // Error state
                                    Text("Failed to load options. Product may not have variations configured.")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                        .padding()
                                } else if variations.isEmpty {
                                    // Loading state
                                    HStack {
                                        ProgressView()
                                        Text("Loading options...")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                } else {
                                    ForEach(variations) { variation in
                                        VariationOptionButton(
                                            variation: variation,
                                            isSelected: selectedVariationId == variation.id,
                                            onSelect: {
                                                selectedVariationId = variation.id
                                                showVariationError = false
                                            }
                                        )
                                    }
                                }
                                
                                if showVariationError {
                                    Text("please_select_option".localized)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.top, 4)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        // Quantity selector
                        HStack {
                            Text("quantity".localized + ":")
                            Spacer()
                            HStack(spacing: 16) {
                                Button(action: {
                                    if quantity > 1 {
                                        quantity -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(quantity > 1 ? .appPrimary : .gray)
                                }
                                .disabled(quantity <= 1)
                                
                                Text("\(quantity)")
                                    .font(.headline)
                                    .frame(minWidth: 40)
                                
                                Button(action: {
                                    let maxStock = getMaxStock()
                                    if quantity < maxStock {
                                        quantity += 1
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(quantity < getMaxStock() ? .appPrimary : .gray)
                                }
                                .disabled(quantity >= getMaxStock())
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Add to cart button
                        Button(action: {
                            addToCart()
                        }) {
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                Text("add_to_cart".localized)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canAddToCart() ? Color.appPrimary : Color.gray)
                            .cornerRadius(10)
                        }
                        .disabled(!canAddToCart())
                    }
                    .padding()
                }
            } else {
                Text("product_not_found".localized)
                    .foregroundColor(.gray)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareProduct) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .onAppear {
            loadProduct()
            checkWishlistStatus()
        }
        .alert("added_to_cart".localized, isPresented: $showAddedToCart) {
            Button("OK", role: .cancel) { }
        }
        .alert("login_required".localized, isPresented: $showLoginPrompt) {
            Button("cancel".localized, role: .cancel) { }
            Button("login".localized) {
                // Navigate to login - you can use NavigationLink or push
            }
        } message: {
            Text("login_to_add_favorites".localized)
        }
    }
    
    private func toggleWishlist() {
        // Check if user is authenticated
        guard authService.isAuthenticated else {
            showLoginPrompt = true
            return
        }
        
        guard let product = product else { return }
        
        // Toggle wishlist state
        isInWishlist.toggle()
        
        // TODO: Implement actual wishlist API call
        Task {
            do {
                if isInWishlist {
                    // await wishlistService.addToWishlist(productId: product.id)
                    print("Added to wishlist: \(product.id)")
                } else {
                    // await wishlistService.removeFromWishlist(productId: product.id)
                    print("Removed from wishlist: \(product.id)")
                }
            } catch {
                // Revert on error
                isInWishlist.toggle()
                print("Wishlist error: \(error)")
            }
        }
    }
    
    private func checkWishlistStatus() {
        // Only check if authenticated
        guard authService.isAuthenticated else {
            isInWishlist = false
            return
        }
        
        // TODO: Check if product is in wishlist via API
        // Task {
        //     isInWishlist = await wishlistService.isInWishlist(productId: productId)
        // }
        isInWishlist = false
    }
    
    private func shareProduct() {
        guard let product = product else { return }
        
        var shareItems: [Any] = []
        
        // Add product details
        let productText = """
        \(product.name)
        
        \(product.description ?? "")
        
        Price: $\(String(format: "%.2f", product.price))
        """
        shareItems.append(productText)
        
        // Add image URL if available
        if let imageUrl = product.primaryImageUrl, let url = URL(string: imageUrl) {
            shareItems.append(url)
        }
        
        let activityVC = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        
        // For iPad support
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            
            // Find the topmost presented view controller
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            
            // Configure for iPad
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            topVC.present(activityVC, animated: true)
        }
    }
    
    private func loadProduct() {
        Task {
            do {
                let storeId = storeService.selectedStore?.id
                product = try await productService.getProduct(id: productId, storeId: storeId)
                
                // Load variations if product has them
                if product?.hasVariations == true {
                    await loadVariations()
                }
            } catch {
                print("Error loading product: \(error)")
            }
            isLoading = false
        }
    }
    
    private func loadVariations() async {
        do {
            print("🔄 Loading variations for product: \(productId)")
            variations = try await productService.getProductVariations(productId: productId)
            print("✅ Loaded \(variations.count) variations")
            
            variationsLoadFailed = false
            
            // Auto-select first variation if only one exists
            if variations.count == 1 {
                selectedVariationId = variations.first?.id
            }
        } catch {
            print("❌ Error loading variations: \(error)")
            variationsLoadFailed = true
            variations = []
        }
    }
    
    private func canAddToCart() -> Bool {
        guard let product = product else { return false }
        
        // Check if out of stock
        if getMaxStock() == 0 { return false }
        
        // Check if variation selection is required
        if product.requireVariationSelection && product.hasVariations {
            return selectedVariationId != nil
        }
        
        return true
    }
    
    private func getMaxStock() -> Int {
        guard let product = product else { return 0 }
        
        if let selectedVariationId = selectedVariationId,
           let variation = variations.first(where: { $0.id == selectedVariationId }) {
            return variation.stockQuantity
        }
        
        return product.stockQuantity
    }
    
    private func addToCart() {
        guard let product = product else { return }
        
        // Validate variation selection
        if product.requireVariationSelection && product.hasVariations && selectedVariationId == nil {
            showVariationError = true
            return
        }
        
        let variationDisplayName = getVariationDisplayName()
        let finalPrice = getSelectedPrice()
        
        Task {
            await cartService.addToCart(
                productId: product.id,
                quantity: quantity,
                productName: product.name,
                productImageUrl: product.primaryImageUrl ?? "",
                productPrice: finalPrice,
                variationId: selectedVariationId,
                variationDisplayName: variationDisplayName
            )
            showAddedToCart = true
            quantity = 1 // Reset quantity
        }
    }
    
    private func getSelectedPrice() -> Double {
        guard let product = product else { return 0 }
        
        if let selectedVariationId = selectedVariationId,
           let variation = variations.first(where: { $0.id == selectedVariationId }),
           let variationPrice = variation.price {
            return variationPrice
        }
        
        return product.price
    }
    
    private func getVariationDisplayName() -> String? {
        guard let variationId = selectedVariationId,
              let variation = variations.first(where: { $0.id == variationId }) else {
            return nil
        }
        
        return variation.attributes
            .map { "\($0.name): \($0.value)" }
            .joined(separator: ", ")
    }
}
// Variation Option Button Component
struct VariationOptionButton: View {
    let variation: ProductVariation
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(variation.attributes.map { $0.value }.joined(separator: " / "))
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        if let price = variation.price {
                            Text("$\(String(format: "%.2f", price))")
                                .font(.subheadline)
                                .foregroundColor(.appPrimary)
                        }
                        
                        if variation.stockQuantity > 0 {
                            Text("• \(variation.stockQuantity) in stock")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("• Out of stock")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.appPrimary)
                        .font(.title3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.appPrimary : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .disabled(variation.stockQuantity == 0)
        .opacity(variation.stockQuantity == 0 ? 0.5 : 1.0)
    }
}

