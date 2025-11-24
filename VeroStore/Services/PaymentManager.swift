//
//  PaymentManager.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import Foundation
import PassKit
import Combine

@MainActor
class PaymentManager: NSObject, ObservableObject {
    static let shared = PaymentManager()

    @Published var paymentMethods: [PaymentMethodDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared
    private let authManager = AuthManager.shared

    var isApplePayAvailable: Bool {
        PKPaymentAuthorizationController.canMakePayments()
    }

    var canSetupApplePay: Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: [.visa, .masterCard, .amex, .discover])
    }

    private override init() {
        super.init()
    }

    func fetchPaymentMethods() async {
        guard authManager.isAuthenticated else { return }

        isLoading = true
        errorMessage = nil

        do {
            paymentMethods = try await apiService.fetchPaymentMethods()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func deletePaymentMethod(id: Int) async {
        do {
            try await apiService.deletePaymentMethod(id: id)
            await fetchPaymentMethods()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setDefaultPaymentMethod(id: Int) async {
        do {
            try await apiService.setDefaultPaymentMethod(id: id)
            await fetchPaymentMethods()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Apple Pay

    func createApplePayRequest(
        for cart: CartDTO,
        merchantIdentifier: String = "merchant.com.verostore",
        countryCode: String = "US",
        currencyCode: String = "USD"
    ) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantIdentifier
        request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        request.merchantCapabilities = .threeDSecure
        request.countryCode = countryCode
        request.currencyCode = currencyCode

        // Create payment summary items
        var paymentItems: [PKPaymentSummaryItem] = []

        // Add individual items
        if let items = cart.items {
            for item in items {
                let summaryItem = PKPaymentSummaryItem(
                    label: item.productName ?? "Product",
                    amount: NSDecimalNumber(value: item.productPrice * Double(item.quantity))
                )
                paymentItems.append(summaryItem)
            }
        }

        // Add tax if applicable
        if cart.tax > 0 {
            let taxItem = PKPaymentSummaryItem(
                label: "Tax",
                amount: NSDecimalNumber(value: cart.tax)
            )
            paymentItems.append(taxItem)
        }

        // Add shipping if applicable
        if cart.shippingFee > 0 {
            let shippingItem = PKPaymentSummaryItem(
                label: "Shipping",
                amount: NSDecimalNumber(value: cart.shippingFee)
            )
            paymentItems.append(shippingItem)
        }

        // Add discount if applicable
        if let discount = cart.discount, discount > 0 {
            let discountItem = PKPaymentSummaryItem(
                label: "Discount",
                amount: NSDecimalNumber(value: -discount)
            )
            paymentItems.append(discountItem)
        }

        // Add total
        let total = PKPaymentSummaryItem(
            label: "VeroStore",
            amount: NSDecimalNumber(value: cart.totalAmount)
        )
        paymentItems.append(total)

        request.paymentSummaryItems = paymentItems

        // Request shipping information
        request.requiredShippingContactFields = [.postalAddress, .phoneNumber, .name]
        request.requiredBillingContactFields = [.postalAddress]

        return request
    }

    func processApplePayPayment(
        payment: PKPayment,
        completion: @escaping (CheckoutResponse?, Error?) -> Void
    ) {
        // Extract payment token
        guard let paymentData = String(data: payment.token.paymentData, encoding: .utf8) else {
            completion(nil, NSError(domain: "PaymentError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid payment data"]))
            return
        }

        // Extract shipping address
        guard let shippingContact = payment.shippingContact,
              let postalAddress = shippingContact.postalAddress else {
            completion(nil, NSError(domain: "PaymentError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing shipping address"]))
            return
        }

        let shippingAddress = ShippingAddressDTO(
            firstName: shippingContact.name?.givenName ?? "",
            lastName: shippingContact.name?.familyName ?? "",
            addressLine1: postalAddress.street,
            addressLine2: nil,
            city: postalAddress.city,
            state: postalAddress.state,
            zipCode: postalAddress.postalCode,
            country: postalAddress.isoCountryCode,
            phone: shippingContact.phoneNumber?.stringValue ?? ""
        )

        // Create checkout request
        let checkoutRequest = CheckoutRequest(
            storeId: 0, // Will be set from cart
            paymentMethodType: "apple_pay",
            paymentMethodId: nil,
            applePayToken: paymentData,
            shippingAddress: shippingAddress,
            billingAddress: nil,
            saveAddress: true
        )

        Task {
            do {
                let response = try await apiService.checkout(request: checkoutRequest)
                await MainActor.run {
                    completion(response, nil)
                }
            } catch {
                await MainActor.run {
                    completion(nil, error)
                }
            }
        }
    }
}

// MARK: - Apple Pay Delegate

extension PaymentManager: PKPaymentAuthorizationControllerDelegate {
    nonisolated func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss()
    }

    nonisolated func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        Task { @MainActor in
            self.processApplePayPayment(payment: payment) { response, error in
                if let error = error {
                    let result = PKPaymentAuthorizationResult(status: .failure, errors: [error])
                    completion(result)
                } else {
                    let result = PKPaymentAuthorizationResult(status: .success, errors: nil)
                    completion(result)
                }
            }
        }
    }
}
