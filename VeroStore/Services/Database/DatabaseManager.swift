//
//  DatabaseManager.swift
//  VeroStore
//
//  Created by Claude on 11/21/25.
//

import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()

    private let userDefaults = UserDefaults.standard

    private let storesKey = "cached_stores"
    private let defaultStoreIdKey = "default_store_id"

    private init() {}

    // MARK: - Stores

    func saveStores(_ stores: [StoreDTO]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(stores) {
            userDefaults.set(encoded, forKey: storesKey)
        }
    }

    func getStores() -> [StoreDTO]? {
        guard let data = userDefaults.data(forKey: storesKey) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([StoreDTO].self, from: data)
    }

    func saveDefaultStoreId(_ id: Int) {
        userDefaults.set(id, forKey: defaultStoreIdKey)
    }

    func getDefaultStoreId() -> Int? {
        let id = userDefaults.integer(forKey: defaultStoreIdKey)
        return id > 0 ? id : nil
    }

    func getDefaultStore() -> StoreDTO? {
        guard let stores = getStores(),
              let defaultId = getDefaultStoreId() else { return nil }
        return stores.first { $0.id == defaultId }
    }

    // MARK: - Clear All

    func clearAll() {
        userDefaults.removeObject(forKey: storesKey)
        userDefaults.removeObject(forKey: defaultStoreIdKey)
    }
}
