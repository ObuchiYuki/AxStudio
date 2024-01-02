//
//  AxDataValidator.swift
//  AxStudio
//
//  Created by yuki on 2021/09/13.
//

import Foundation

enum AxDataValidator {
    static func isValidEmail(_ value: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        let nsstring = value as NSString
        
        return regex.firstMatch(in: value, options: [], range: NSRange(location: 0, length: nsstring.length)) != nil
    }
    static func isValidPassword(_ value: String) -> Bool {
        value.count >= 8
    }
    static func isValidName(_ value: String) -> Bool {
        value.count >= 1
    }
}
