//
//  CheckoutView.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import SwiftUI
import PassKit

struct CheckoutView: View {
    @StateObject private var viewModel: CheckoutViewModel
    @StateObject private var cartManager = CartManager.shared
    @StateObject private var paymentManager = PaymentManager.shared
    @Environment(\.dismiss) var dismiss

    init(cart: CartDTO) {
        _viewModel = StateObject(wrappedValue: CheckoutViewModel(cart: cart))
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Shipping Address Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Shipping Address")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)

                        if viewModel.shippingAddress != nil {
                            ShippingAddressCard(
                                address: viewModel.shippingAddress!,
                                onEdit: {
                                    viewModel.showAddressForm = true
                                }
                            )
                        } else {
                            Button(action: {
                                viewModel.showAddressForm = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.primaryOrange)
                                    Text("Add Shipping Address")
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Payment Method Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Payment Method")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)

                        // Apple Pay Option
                        if paymentManager.isApplePayAvailable {
                            PaymentMethodOption(
                                icon: "applelogo",
                                title: "Apple Pay",
                                subtitle: "Pay with Apple Pay",
                                isSelected: viewModel.selectedPaymentType == .applePay,
                                action: {
                                    viewModel.selectedPaymentType = .applePay
                                }
                            )
                        }

                        // Saved Cards
                        ForEach(paymentManager.paymentMethods) { method in
                            PaymentMethodOption(
                                icon: "creditcard.fill",
                                title: "\(method.brand ?? "Card") •••• \(method.last4 ?? "")",
                                subtitle: method.isDefault ? "Default" : "",
                                isSelected: viewModel.selectedPaymentMethodId == method.id,
                                action: {
                                    viewModel.selectedPaymentType = .creditCard
                                    viewModel.selectedPaymentMethodId = method.id
                                }
                            )
                        }

                        // Add New Card Option
                        Button(action: {
                            viewModel.showAddCardForm = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.primaryOrange)
                                Text("Add New Card")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Order Summary
                    if let cart = viewModel.cart {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Order Summary")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)

                            VStack(spacing: 10) {
                                HStack {
                                    Text("Subtotal")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", cart.subtotal))")
                                        .foregroundColor(.black)
                                }

                                if cart.tax > 0 {
                                    HStack {
                                        Text("Tax")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("$\(String(format: "%.2f", cart.tax))")
                                            .foregroundColor(.black)
                                    }
                                }

                                if cart.shippingFee > 0 {
                                    HStack {
                                        Text("Shipping")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("$\(String(format: "%.2f", cart.shippingFee))")
                                            .foregroundColor(.black)
                                    }
                                }

                                if let discount = cart.discount, discount > 0 {
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
                                    Text("$\(String(format: "%.2f", cart.totalAmount))")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.primaryOrange)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top)
            }

            // Bottom Checkout Button
            VStack {
                Spacer()

                Button(action: {
                    viewModel.proceedToPayment()
                }) {
                    if viewModel.isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Place Order - $\(String(format: "%.2f", viewModel.cart?.totalAmount ?? 0))")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.canProceed ? Color.primaryOrange : Color.gray)
                .cornerRadius(12)
                .disabled(!viewModel.canProceed || viewModel.isProcessing)
                .padding(.horizontal)
                .padding(.bottom, 20)
                .background(
                    Color.white
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                )
            }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showAddressForm) {
            AddressFormView(
                address: $viewModel.shippingAddress,
                onSave: {
                    viewModel.showAddressForm = false
                }
            )
        }
        .sheet(isPresented: $viewModel.showAddCardForm) {
            AddCardFormView(onSave: { card in
                viewModel.showAddCardForm = false
                Task {
                    await paymentManager.fetchPaymentMethods()
                }
            })
        }
        .alert("Order Placed!", isPresented: $viewModel.showSuccessAlert) {
            Button("View Order") {
                viewModel.navigateToOrder = true
                dismiss()
            }
            Button("Continue Shopping") {
                dismiss()
            }
        } message: {
            Text("Your order has been placed successfully!")
        }
        .alert("Payment Failed", isPresented: $viewModel.showErrorAlert) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .task {
            await paymentManager.fetchPaymentMethods()
        }
    }
}

struct PaymentMethodOption: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .foregroundColor(.primaryOrange)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primaryOrange)
                        .font(.system(size: 22))
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.system(size: 22))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryOrange : Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

struct ShippingAddressCard: View {
    let address: ShippingAddressDTO
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(address.firstName) \(address.lastName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                Button(action: onEdit) {
                    Text("Edit")
                        .font(.system(size: 14))
                        .foregroundColor(.primaryOrange)
                }
            }

            Text(address.addressLine1)
                .font(.system(size: 14))
                .foregroundColor(.gray)

            if let addressLine2 = address.addressLine2, !addressLine2.isEmpty {
                Text(addressLine2)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            Text("\(address.city), \(address.state) \(address.zipCode)")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Text(address.phone)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
        )
    }
}

// MARK: - View Model

@MainActor
class CheckoutViewModel: ObservableObject {
    @Published var cart: CartDTO?
    @Published var shippingAddress: ShippingAddressDTO?
    @Published var selectedPaymentType: PaymentMethodType = .creditCard
    @Published var selectedPaymentMethodId: Int?
    @Published var showAddressForm = false
    @Published var showAddCardForm = false
    @Published var isProcessing = false
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage: String?
    @Published var navigateToOrder = false

    private let apiService = APIService.shared
    private let paymentManager = PaymentManager.shared
    private let cartManager = CartManager.shared

    init(cart: CartDTO) {
        self.cart = cart
    }

    var canProceed: Bool {
        return shippingAddress != nil &&
               (selectedPaymentType == .applePay || selectedPaymentMethodId != nil)
    }

    func proceedToPayment() {
        guard canProceed else { return }

        if selectedPaymentType == .applePay {
            presentApplePay()
        } else {
            Task {
                await processCheckout()
            }
        }
    }

    private func presentApplePay() {
        guard let cart = cart else { return }

        let request = paymentManager.createApplePayRequest(for: cart)

        if let controller = PKPaymentAuthorizationController(paymentRequest: request) {
            controller.delegate = paymentManager
            controller.present { presented in
                if !presented {
                    print("Failed to present Apple Pay")
                }
            }
        }
    }

    private func processCheckout() async {
        guard let shippingAddress = shippingAddress,
              let cart = cart else { return }

        isProcessing = true
        errorMessage = nil

        let request = CheckoutRequest(
            storeId: cart.storeId,
            paymentMethodType: selectedPaymentType.rawValue,
            paymentMethodId: selectedPaymentMethodId,
            applePayToken: nil,
            shippingAddress: shippingAddress,
            billingAddress: nil,
            saveAddress: true
        )

        do {
            let response = try await apiService.checkout(request: request)
            isProcessing = false
            showSuccessAlert = true

            // Clear cart after successful checkout
            await cartManager.clearCart()
        } catch {
            isProcessing = false
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

#Preview {
    NavigationView {
        CheckoutView(cart: CartDTO(
            id: 1,
            userId: 1,
            storeId: 1,
            subtotal: 100.0,
            tax: 8.0,
            shippingFee: 5.0,
            discount: 0,
            totalAmount: 113.0,
            created: Date(),
            updated: Date(),
            items: []
        ))
    }
}
