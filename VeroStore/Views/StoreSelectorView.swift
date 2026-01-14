//
//  StoreSelectorView.swift
//  VeroStore
//
//  Created based on Android app
//

import SwiftUI

struct StoreSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var storeService = StoreService.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(storeService.stores) { store in
                    Button(action: {
                        storeService.selectStore(store)
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(store.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if let address = store.address {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            if storeService.selectedStore?.id == store.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.appPrimary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("select_store".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}
