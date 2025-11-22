//
//  AddressFormView.swift
//  VeroStore
//
//  Created by Claude on 11/22/25.
//

import SwiftUI

struct AddressFormView: View {
    @Binding var address: ShippingAddressDTO?
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var addressLine1: String = ""
    @State private var addressLine2: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var country: String = "US"
    @State private var phone: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Name Fields
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("First Name")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)

                                TextField("First Name", text: $firstName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Last Name")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)

                                TextField("Last Name", text: $lastName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }

                        // Address Line 1
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Address Line 1")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)

                            TextField("Street Address", text: $addressLine1)
                                .textFieldStyle(CustomTextFieldStyle())
                        }

                        // Address Line 2
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Address Line 2 (Optional)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)

                            TextField("Apt, Suite, etc.", text: $addressLine2)
                                .textFieldStyle(CustomTextFieldStyle())
                        }

                        // City
                        VStack(alignment: .leading, spacing: 8) {
                            Text("City")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)

                            TextField("City", text: $city)
                                .textFieldStyle(CustomTextFieldStyle())
                        }

                        // State and Zip
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("State")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)

                                TextField("State", text: $state)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Zip Code")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)

                                TextField("Zip Code", text: $zipCode)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                        }

                        // Phone
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)

                            TextField("Phone Number", text: $phone)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.phonePad)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Shipping Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAddress()
                    }
                    .disabled(!isValid)
                }
            }
        }
        .onAppear {
            if let address = address {
                firstName = address.firstName
                lastName = address.lastName
                addressLine1 = address.addressLine1
                addressLine2 = address.addressLine2 ?? ""
                city = address.city
                state = address.state
                zipCode = address.zipCode
                country = address.country
                phone = address.phone
            }
        }
    }

    private var isValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !addressLine1.isEmpty &&
        !city.isEmpty &&
        !state.isEmpty &&
        !zipCode.isEmpty &&
        !phone.isEmpty
    }

    private func saveAddress() {
        address = ShippingAddressDTO(
            firstName: firstName,
            lastName: lastName,
            addressLine1: addressLine1,
            addressLine2: addressLine2.isEmpty ? nil : addressLine2,
            city: city,
            state: state,
            zipCode: zipCode,
            country: country,
            phone: phone
        )
        onSave()
        dismiss()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
            )
    }
}

#Preview {
    AddressFormView(address: .constant(nil), onSave: {})
}
