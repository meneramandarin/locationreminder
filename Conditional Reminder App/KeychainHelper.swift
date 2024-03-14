//
//  KeychainHelper.swift
//  Conditional Reminder App
//
//  Created by Marlene on 14.03.24.
//

import Foundation

class KeychainHelper {

    static let standard = KeychainHelper()
    private init() {}

    func save(_ data: Data, service: String, account: String) -> OSStatus {
        let query = [
            kSecValueData: data,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary

        // Add item if it doesn't already exist
        var status = SecItemAdd(query, nil)

        // Update the data if an existing item is found
        if status == errSecDuplicateItem {
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            status = SecItemUpdate(query, attributesToUpdate)
        }

        return status
    }

    func read(service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        SecItemCopyMatching(query, &result)

        return (result as? Data)
    }

    func delete(service: String, account: String) -> OSStatus {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            ] as CFDictionary

        return SecItemDelete(query)
    }
}
