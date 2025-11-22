//
//  MyOrdersView.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import SwiftUI

struct MyOrdersView: View {
    @StateObject private var viewModel = MyOrdersViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if viewModel.isLoading && viewModel.orders.isEmpty {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryOrange))
                        .scaleEffect(1.5)

                    Text("Loading orders...")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
            } else if viewModel.orders.isEmpty {
                // Empty state
                VStack(spacing: 30) {
                    Spacer()

                    Image(systemName: "bag")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)

                    VStack(spacing: 10) {
                        Text("No orders yet")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)

                        Text("Your order history will appear here")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()
                }
            } else {
                // Orders list
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.orders) { order in
                            NavigationLink(destination: OrderDetailView(orderId: order.id)) {
                                OrderRow(order: order)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("My Orders")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadOrders()
        }
    }
}

struct OrderRow: View {
    let order: OrderDTO

    private var statusColor: Color {
        switch order.status.lowercased() {
        case "pending":
            return .orange
        case "processing":
            return .blue
        case "shipped":
            return .purple
        case "delivered":
            return .green
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Order header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.orderNumber ?? String(order.id))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)

                    Text(formatDate(order.created))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }

                Spacer()

                // Status badge
                Text(order.status.capitalized)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor)
                    .cornerRadius(12)
            }

            Divider()

            // Order items preview
            if let items = order.items?.prefix(3) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(items)) { item in
                        HStack(spacing: 10) {
                            AsyncImage(url: URL(string: item.productImageUrl ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.lightGray)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.mediumGray)
                                    )
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.productName ?? "Product")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .lineLimit(1)

                                Text("Qty: \(item.quantity)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Text("$\(String(format: "%.2f", item.subtotal))")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primaryOrange)
                        }
                    }
                }

                if let totalItems = order.items?.count, totalItems > 3 {
                    Text("+ \(totalItems - 3) more items")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            Divider()

            // Total
            HStack {
                Text("Total")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)

                Spacer()

                Text("$\(String(format: "%.2f", order.totalAmount))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primaryOrange)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

@MainActor
class MyOrdersViewModel: ObservableObject {
    @Published var orders: [OrderDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    func loadOrders() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.fetchOrders()
            orders = response.data
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

// Order detail view
struct OrderDetailView: View {
    let orderId: Int
    @StateObject private var viewModel = OrderDetailViewModel()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
            } else if let order = viewModel.order {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Order info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Order #\(order.orderNumber ?? String(order.id))")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)

                            HStack {
                                Text("Status:")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)

                                Text(order.status.capitalized)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primaryOrange)
                            }

                            HStack {
                                Text("Store:")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)

                                Text(order.storeName ?? "N/A")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                            }

                            if let address = order.shippingAddress {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Shipping Address:")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)

                                    Text(address)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                        // Items
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Items")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal)

                            if let items = order.items {
                                ForEach(items) { item in
                                    HStack(spacing: 12) {
                                        AsyncImage(url: URL(string: item.productImageUrl ?? "")) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Rectangle()
                                                .fill(Color.lightGray)
                                        }
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(10)

                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(item.productName ?? "Product")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.black)

                                            Text("Qty: \(item.quantity)")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)

                                            Text("$\(String(format: "%.2f", item.price)) each")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        Text("$\(String(format: "%.2f", item.subtotal))")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.primaryOrange)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                            }
                        }

                        // Order summary
                        VStack(spacing: 12) {
                            HStack {
                                Text("Subtotal")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$\(String(format: "%.2f", order.subtotal))")
                                    .foregroundColor(.black)
                            }

                            HStack {
                                Text("Tax")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$\(String(format: "%.2f", order.tax))")
                                    .foregroundColor(.black)
                            }

                            HStack {
                                Text("Shipping")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$\(String(format: "%.2f", order.shippingFee))")
                                    .foregroundColor(.black)
                            }

                            if let discount = order.discount, discount > 0 {
                                HStack {
                                    Text("Discount")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("-$\(String(format: "%.2f", discount))")
                                        .foregroundColor(.green)
                                }
                            }

                            Divider()

                            HStack {
                                Text("Total")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                Spacer()
                                Text("$\(String(format: "%.2f", order.totalAmount))")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primaryOrange)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadOrder(id: orderId)
        }
    }
}

@MainActor
class OrderDetailViewModel: ObservableObject {
    @Published var order: OrderDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    func loadOrder(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            order = try await apiService.fetchOrder(id: id)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

#Preview {
    NavigationView {
        MyOrdersView()
    }
}
