//
//  OAuth2TokenStorage.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 02.08.2023.
//
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {
    }
    private let keychainWrapper = KeychainWrapper.standard
    
    var token: String? {
        get {
            return keychainWrapper.string(forKey: Constants.bearerToken)
        }
        set {
            guard let newValue = newValue else { return }
            keychainWrapper.set(newValue, forKey: Constants.bearerToken)
        }
    }
    func clearToken() {
        KeychainWrapper.standard.removeObject(forKey: Constants.bearerToken)
    }
}
