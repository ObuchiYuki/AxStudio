//
//  AxAccountViewModel.swift
//  AxStudio
//
//  Created by yuki on 2021/09/14.
//

import SwiftEx
import AppKit
import Combine

final class AxHomeAccountViewModel {
    var canLogout = false
    var canLogin = true
    
    @Observable var icon: NSImage = R.Home.Sidebar.accountNoIcon
    @Observable var title: String = "Name"
    @Observable var email: String? = nil
    
    let logoutPublisher = PassthroughSubject<Void, Never>()
    
    var accountFormModel: AxAccountFormModel?
    let signinFormModel: AxSigninFormPanelModel
    
    init(signinFormModel: AxSigninFormPanelModel) {
        self.signinFormModel = signinFormModel
    }
}

extension AxHomeAccountViewModel {
    func setDisconnected() {
        self.canLogin = false
        self.canLogout = false
        self.title = "No connection"
        self.email = nil
        self.icon = R.Home.Sidebar.accountNoIcon
    }
    
    func setNotLoggedin() {
        self.canLogin = true
        self.canLogout = false
        self.title = "Sign In"
        self.email = nil
        self.icon = R.Home.Sidebar.accountNoIcon
    }
    func setLoggingIn() {
        self.canLogin = false
        self.canLogout = false
        self.title = "Signing in..."
        self.email = nil
        self.icon = R.Home.Sidebar.accountNoIcon
    }
    
    func setLoggedIn(name: String, email: String, icon: NSImage) {
        self.canLogin = false
        self.canLogout = true
        self.title = name
        self.email = email
        self.icon = icon
    }
    
    func setProfileError(error: String) {
        self.canLogin = false
        self.canLogout = true
        self.title = error
        self.email = nil
        self.icon = R.Home.Sidebar.accountNoIcon
    }
}

