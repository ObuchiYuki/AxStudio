//
//  AxSecureSigninInfoLibrary.swift
//  AxStudio
//
//  Created by yuki on 2021/09/13.
//

import KeychainAccess
import AxComponents

final class AxSecureSigninInfoLibrary {
        
    private let keychain: Keychain
    
    init(keychain: Keychain) { self.keychain = keychain }
    
    func set(email: String? = nil, password: String? = nil) {
        if let email = email { keychain["email"] = email }
        if let password = password { keychain["pass"] = password }
    }
    
    func get() -> (email: String, password: String)? {
        guard let password = keychain["pass"], let email = keychain["email"] else { return nil }
        return (email: email, password: password)
    }
    
    func remove() {
        do {
            try keychain.remove("pass")
            try keychain.remove("email")
        }catch {
            print(error)
        }
    }
}
