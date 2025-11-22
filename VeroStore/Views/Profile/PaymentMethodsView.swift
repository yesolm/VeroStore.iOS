//
//  PaymentMethodsView.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import SwiftUI

struct PaymentMethodsView: View {
    @StateObject private var paymentManager = PaymentManager.shared
    @State private var showAddCard = false
    @State private var methodToDelete: PaymentMethodDTO?
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if paymentManager.isLoading && paymentManager.paymentMethods.isEmpty {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryOrange))
                        .scaleEffect(1.5)

                    Text("Loading payment methods...")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
            } else if paymentManager.paymentMethods.isEmpty {
                // Empty state
                VStack(spacing: 30) {
                    Spacer()

                    Image(systemName: "creditcard")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)

                    VStack(spacing: 10) {
                        Text("No payment methods")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)

                        Text("Add a payment method to checkout faster")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: {
                        showAddCard = true
                    }) {
                        Text("Add Payment Method")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.primaryOrange)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)

                    Spacer()
                }
            } else {
                // Payment methods list
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(paymentManager.paymentMethods) { method in
                                PaymentMethodCard(
                                    method: method,
                                    onSetDefault: {
                                        Task {
                                            await paymentManager.setDefaultPaymentMethod(id: method.id)
                                        }
                                    },
                                    onDelete: {
                                        methodToDelete = method
                                        showDeleteConfirm = true
                                    }
                                )
                            }
                        }
                        .padding()
                    }

                    // Add Button
                    Button(action: {
                        showAddCard = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.white)
                            Text("Add Payment Method")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.primaryOrange)
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(
                        Color.white
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                    )
                }
            }
        }
        .navigationTitle("Payment Methods")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCard) {
            AddCardFormView(onSave: { _ in
                showAddCard = false
                Task {
                    await paymentManager.fetchPaymentMethods()
                }
            })
        }
        .alert("Delete Payment Method", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {
                methodToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let method = methodToDelete {
                    Task {
                        await paymentManager.deletePaymentMethod(id: method.id)
                        methodToDelete = nil
                    }
                }
            }
        } message: {
            if let method = methodToDelete {
                Text("Are you sure you want to delete \(method.brand ?? "Card") ending in \(method.last4 ?? "")? This action cannot be undone.")
            }
        }
        .task {
            await paymentManager.fetchPaymentMethods()
        }
    }
}

struct PaymentMethodCard: View {
    let method: PaymentMethodDTO
    let onSetDefault: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Card Icon
                Image(systemName: cardIcon)
                    .font(.system(size: 30))
                    .foregroundColor(.primaryOrange)
                    .frame(width: 50)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(method.brand ?? "Card")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)

                        if method.isDefault {
                            Text("Default")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(4)
                        }
                    }

                    Text("•••• •••• •••• \(method.last4 ?? "")")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)

                    if let expiryMonth = method.expiryMonth,
                       let expiryYear = method.expiryYear {
                        Text("Expires \(String(format: "%02d", expiryMonth))/\(String(format: "%02d", expiryYear))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                // Actions Menu
                Menu {
                    if !method.isDefault {
                        Button(action: onSetDefault) {
                            Label("Set as Default", systemImage: "checkmark.circle")
                        }
                    }

                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                        .background(Color.lightGray)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private var cardIcon: String {
        guard let brand = method.brand?.lowercased() else {
            return "creditcard.fill"
        }

        switch brand {
        case "visa":
            return "creditcard.fill"
        case "mastercard":
            return "creditcard.circle.fill"
        case "amex", "american express":
            return "creditcard.and.123"
        case "discover":
            return "creditcard.trianglebadge.exclamationmark"
        default:
            return "creditcard.fill"
        }
    }
}

#Preview {
    NavigationView {
        PaymentMethodsView()
    }
}
