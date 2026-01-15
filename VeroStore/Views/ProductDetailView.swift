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
    @State private var addedToCartMessage = ""
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
                    // Product Image - Full Width with floating heart button - SWIPABLE
                    VStack(spacing: 0) {
                        ZStack(alignment: .topTrailing) {
                            if let images = product.images, !images.isEmpty {
                                TabView(selection: $selectedImageIndex) {
                                    ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                                        GeometryReader { geometry in
                                            AsyncImage(url: URL(string: image.imageUrl)) { phase in
                                                switch phase {
                                                case .empty:
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.2))
                                                        .overlay(
                                                            ProgressView()
                                                                .scaleEffect(1.5)
                                                        )
                                                        .frame(width: geometry.size.width, height: 400)
                                                case .success(let loadedImage):
                                                    loadedImage
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: geometry.size.width, height: 400)
                                                case .failure:
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.2))
                                                        .overlay(
                                                            Image(systemName: "photo")
                                                                .font(.largeTitle)
                                                                .foregroundColor(.gray)
                                                        )
                                                        .frame(width: geometry.size.width, height: 400)
                                                @unknown default:
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(width: geometry.size.width, height: 400)
                                                }
                                            }
                                            .frame(maxWidth: geometry.size.width)
                                        }
                                        .tag(index)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .frame(height: 400)
                            } else if let imageUrl = product.primaryImageUrl {
                                GeometryReader { geometry in
                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                                .overlay(
                                                    ProgressView()
                                                        .scaleEffect(1.5)
                                                )
                                                .frame(width: geometry.size.width, height: 400)
                                        case .success(let loadedImage):
                                            loadedImage
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: geometry.size.width, height: 400)
                                        case .failure:
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                                .overlay(
                                                    Image(systemName: "photo")
                                                        .font(.largeTitle)
                                                        .foregroundColor(.gray)
                                                )
                                                .frame(width: geometry.size.width, height: 400)
                                        @unknown default:
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: geometry.size.width, height: 400)
                                        }
                                    }
                                    .frame(maxWidth: geometry.size.width)
                                }
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
                        .frame(height: 400)
                        
                        // Thumbnail images
                        if let images = product.images, images.count > 1 {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                                        Button(action: {
                                            withAnimation {
                                                selectedImageIndex = index
                                            }
                                        }) {
                                            AsyncImage(url: URL(string: image.imageUrl)) { phase in
                                                switch phase {
                                                case .success(let img):
                                                    img
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 60, height: 60)
                                                        .clipped()
                                                case .failure, .empty:
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(width: 60, height: 60)
                                                @unknown default:
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(width: 60, height: 60)
                                                }
                                            }
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedImageIndex == index ? Color.appPrimary : Color.clear, lineWidth: 2)
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 8)
                        }
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
                        
                        // Variation Selection - Group by attribute type
                        if product.hasVariations {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("select_options".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                if variationsLoadFailed {
                                    // Error state
                                    HStack(spacing: 12) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                        Text("Failed to load options. Product may not have variations configured.")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(10)
                                } else if variations.isEmpty {
                                    // Loading state
                                    HStack(spacing: 12) {
                                        ProgressView()
                                        Text("Loading options...")
                                            .foregroundColor(.gray)
                                            .font(.subheadline)
                                    }
                                    .padding()
                                } else {
                                    // Group variations by attribute names
                                    let groupedAttributes = groupVariationAttributes()
                                    
                                    ForEach(Array(groupedAttributes.keys.sorted()), id: \.self) { attributeName in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(attributeName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.secondary)
                                            
                                            if let values = groupedAttributes[attributeName] {
                                                FlowLayout(spacing: 8) {
                                                    ForEach(values, id: \.self) { value in
                                                        AttributeChip(
                                                            value: value,
                                                            isSelected: isAttributeSelected(name: attributeName, value: value),
                                                            onSelect: {
                                                                selectVariationByAttribute(name: attributeName, value: value)
                                                            }
                                                        )
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Show selected variation details
                                    if let selectedVariationId = selectedVariationId,
                                       let selectedVariation = variations.first(where: { $0.id == selectedVariationId }) {
                                        Divider()
                                            .padding(.vertical, 4)
                                        
                                        HStack(spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Selected:")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Text(selectedVariation.attributes.map { $0.value }.joined(separator: " • "))
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                            }
                                            
                                            Spacer()
                                            
                                            if let price = selectedVariation.price {
                                                Text("$\(String(format: "%.2f", price))")
                                                    .font(.headline)
                                                    .foregroundColor(.appPrimary)
                                            }
                                            
                                            if selectedVariation.stockQuantity > 0 {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.caption)
                                                    Text("\(selectedVariation.stockQuantity) in stock")
                                                        .font(.caption)
                                                }
                                                .foregroundColor(.green)
                                            } else {
                                                Text("Out of stock")
                                                    .font(.caption)
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding()
                                        .background(Color.appPrimary.opacity(0.08))
                                        .cornerRadius(10)
                                    }
                                }
                                
                                if showVariationError {
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                        Text("please_select_option".localized)
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
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
        .overlay(alignment: .bottom) {
            // Toast notification for cart
            if showAddedToCart {
                ToastView(message: addedToCartMessage, icon: "checkmark.circle.fill")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(), value: showAddedToCart)
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            loadProduct()
            checkWishlistStatus()
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
            
            // Show toast notification
            addedToCartMessage = "\(quantity) × \(product.name) " + "added_to_cart".localized
            withAnimation {
                showAddedToCart = true
            }
            
            // Hide toast after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showAddedToCart = false
                }
            }
            
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
    
    // MARK: - Variation Attribute Grouping Helpers
    
    /// Groups all variations by their attribute names and returns unique values
    /// Example: ["Size": ["Small", "Medium", "Large"], "Color": ["Red", "Blue"]]
    private func groupVariationAttributes() -> [String: [String]] {
        var grouped: [String: Set<String>] = [:]
        
        for variation in variations {
            for attribute in variation.attributes {
                if grouped[attribute.name] == nil {
                    grouped[attribute.name] = Set<String>()
                }
                grouped[attribute.name]?.insert(attribute.value)
            }
        }
        
        return grouped.mapValues { Array($0).sorted() }
    }
    
    /// Checks if a specific attribute value is selected in the current variation
    private func isAttributeSelected(name: String, value: String) -> Bool {
        guard let selectedVariationId = selectedVariationId,
              let selectedVariation = variations.first(where: { $0.id == selectedVariationId }) else {
            return false
        }
        
        return selectedVariation.attributes.contains { $0.name == name && $0.value == value }
    }
    
    /// Selects a variation that matches the given attribute
    /// If multiple variations match, selects the first one
    private func selectVariationByAttribute(name: String, value: String) {
        // Find variations that have this attribute value
        let matchingVariations = variations.filter { variation in
            variation.attributes.contains { $0.name == name && $0.value == value }
        }
        
        if let firstMatch = matchingVariations.first {
            selectedVariationId = firstMatch.id
            showVariationError = false
        }
    }
}

// MARK: - Attribute Chip Component
struct AttributeChip: View {
    let value: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(value)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.appPrimary : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.appPrimary : Color.gray.opacity(0.3), lineWidth: 1.5)
                )
                .shadow(color: isSelected ? Color.appPrimary.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Flow Layout for Chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // New line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
// MARK: - Toast Notification View
struct ToastView: View {
    let message: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(Color.green)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}


