//
//  AxAccountModel.swift
//  AxStudio
//
//  Created by yuki on 2021/09/20.
//

import AppKit
import SwiftEx
import AppKit
import AxDocument
import Combine

final class AxAccountFormModel {
    @ObservableProperty var icon: NSImage
    @ObservableProperty var name: String
    @ObservableProperty var email: String
    
    let logoutPublisher = PassthroughSubject<Void, Never>()
    
    let authAPI: AxHttpAuthorizedAPIClient
    let reachability: Reachability
    let secureLibrary: AxSecureSigninInfoLibrary
    
    init(icon: NSImage, name: String, email: String, authAPI: AxHttpAuthorizedAPIClient, secureLibrary: AxSecureSigninInfoLibrary, reachability: Reachability) {
        self.icon = icon
        self.name = name
        self.email = email
        self.authAPI = authAPI
        self.secureLibrary = secureLibrary
        self.reachability = reachability
    }
}


