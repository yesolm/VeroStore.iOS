//
//  AddCardFormView.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import SwiftUI

struct AddCardFormView: View {
    let onSave: (PaymentMethodDTO) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var cardNumber: String = ""
    @State private var expiryMonth: String = ""
    @State private var expiryYear: String = ""
    @State private var cvv: String = ""
    @State private var cardholderName: String = ""
    @State private var setAsDefault: Bool = false
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Card Preview
                        CardPreview(
                            cardNumber: cardNumber,
                            cardholderName: cardholderName,
                            expiryMonth: expiryMonth,
                            expiryYear: expiryYear
                        )
                        .padding()

                        // Card Number
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Card Number")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)

                            TextField("1234 5678 9012 3456", text: $cardNumber)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.numberPad)
                                .onChange(of: cardNumber) { _, newValue in
                                    cardNumber = formatCardNumber(newValue)
                                }
                        }

                        // Cardholder Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cardholder Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)

                            TextField("John Doe", text: $cardholderName)
                                .textFieldStyle(CustomTextFieldStyle())
                                .textInputAutocapitalization(.words)
                        }

                        // Expiry and CVV
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Expiry Date")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)

                                HStack(spacing: 10) {
                                    TextField("MM", text: $expiryMonth)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .keyboardType(.numberPad)
                                        .frame(width: 60)
                                        .onChange(of: expiryMonth) { _, newValue in
                                            if newValue.count > 2 {
                                                expiryMonth = String(newValue.prefix(2))
                                            }
                                        }

                                    Text("/")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)

                                    TextField("YY", text: $expiryYear)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .keyboardType(.numberPad)
                                        .frame(width: 60)
                                        .onChange(of: expiryYear) { _, newValue in
                                            if newValue.count > 2 {
                                                expiryYear = String(newValue.prefix(2))
                                            }
                                        }
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("CVV")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)

                                SecureField("123", text: $cvv)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .onChange(of: cvv) { _, newValue in
                                        if newValue.count > 4 {
                                            cvv = String(newValue.prefix(4))
                                        }
                                    }
                            }
                        }

                        // Set as Default
                        Toggle(isOn: $setAsDefault) {
                            Text("Set as default payment method")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }
                        .tint(.primaryOrange)
                        .padding(.horizontal)

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveCard()
                        }
                    }
                    .disabled(!isValid || isProcessing)
                }
            }
        }
    }

    private var isValid: Bool {
        let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        return cleanCardNumber.count >= 13 &&
               !cardholderName.isEmpty &&
               expiryMonth.count == 2 &&
               expiryYear.count == 2 &&
               cvv.count >= 3
    }

    private func formatCardNumber(_ number: String) -> String {
        let cleaned = number.replacingOccurrences(of: " ", with: "")
        var formatted = ""

        for (index, character) in cleaned.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted += String(character)
        }

        return String(formatted.prefix(19)) // 16 digits + 3 spaces
    }

    private func saveCard() async {
        isProcessing = true
        errorMessage = nil

        let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let last4 = String(cleanCardNumber.suffix(4))

        // Determine card brand from number
        let brand = getCardBrand(cleanCardNumber)

        let dto = AddPaymentMethodDTO(
            type: "credit_card",
            cardToken: "tok_\(UUID().uuidString)", // In production, use actual tokenization
            last4: last4,
            brand: brand,
            expiryMonth: Int(expiryMonth),
            expiryYear: Int(expiryYear),
            isDefault: setAsDefault
        )

        do {
            let savedMethod = try await APIService.shared.addPaymentMethod(dto: dto)
            await MainActor.run {
                isProcessing = false
                onSave(savedMethod)
                dismiss()
            }
        } catch {
            await MainActor.run {
                isProcessing = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func getCardBrand(_ cardNumber: String) -> String {
        let firstDigit = cardNumber.prefix(1)
        let firstTwoDigits = cardNumber.prefix(2)

        if firstDigit == "4" {
            return "Visa"
        } else if firstTwoDigits >= "51" && firstTwoDigits <= "55" {
            return "Mastercard"
        } else if firstTwoDigits == "34" || firstTwoDigits == "37" {
            return "Amex"
        } else if firstTwoDigits >= "60" && firstTwoDigits <= "65" {
            return "Discover"
        }

        return "Card"
    }
}

struct CardPreview: View {
    let cardNumber: String
    let cardholderName: String
    let expiryMonth: String
    let expiryYear: String

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.primaryOrange, Color.primaryOrange.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

            VStack(alignment: .leading, spacing: 20) {
                // Card chip
                HStack {
                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.8))

                    Spacer()

                    Text(getCardBrand())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                // Card number
                Text(cardNumber.isEmpty ? "•••• •••• •••• ••••" : cardNumber)
                    .font(.system(size: 22, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)

                // Name and Expiry
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CARDHOLDER")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))

                        Text(cardholderName.isEmpty ? "JOHN DOE" : cardholderName.uppercased())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("EXPIRES")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))

                        Text("\(expiryMonth.isEmpty ? "MM" : expiryMonth)/\(expiryYear.isEmpty ? "YY" : expiryYear)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 200)
    }

    private func getCardBrand() -> String {
        let cleanNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        guard !cleanNumber.isEmpty else { return "CARD" }

        let firstDigit = cleanNumber.prefix(1)
        if firstDigit == "4" {
            return "VISA"
        } else if cleanNumber.hasPrefix("5") {
            return "MASTERCARD"
        } else if cleanNumber.hasPrefix("3") {
            return "AMEX"
        }

        return "CARD"
    }
}

#Preview {
    AddCardFormView(onSave: { _ in })
}
