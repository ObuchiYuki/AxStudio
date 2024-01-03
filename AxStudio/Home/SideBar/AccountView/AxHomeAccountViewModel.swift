//
//  AxHomeAccountPresenter.swift
//  AxStudio
//
//  Created by yuki on 2021/09/19.
//

import AppKit
import AxDocument
import SwiftEx
import AppKit
import Combine
import AxComponents

final class AxHomeAccountViewModel {
    
    @ObservableProperty var canLogin = false
    @ObservableProperty var canLogout = false
    @ObservableProperty var title: String?
    @ObservableProperty var email: String?
    @ObservableProperty var icon: NSImage = R.Home.Sidebar.accountNoIcon
    
    let authAPIPublisher = PassthroughSubject<AxHttpAuthorizedAPIClient, Never>()
    
    let profilePublisher = PassthroughSubject<AxUserProfile, Never>()
    
    let logoutPublisher = PassthroughSubject<Void, Never>()
    
    let signinFormModel: AxSigninFormPanelModel
    
    var accountFormModel: AxAccountFormModel?
    
    var authAPI: AxHttpAuthorizedAPIClient? {
        didSet { self.updateViewModel() }
    }
    
    var isConnected: Bool = true {
        didSet { if isConnected != oldValue { self.updateViewModel() } }
    }
    
    private let api: AxHttpAPIClient
    private let secureLibrary: AxSecureSigninInfoLibrary
    private let reachability: Reachability
    private var objectBag = Set<AnyCancellable>()
    
    init(api: AxHttpAPIClient, secureLibrary: AxSecureSigninInfoLibrary, reachability: Reachability) {
        self.api = api
        self.secureLibrary = secureLibrary
        self.reachability = reachability
        self.signinFormModel = AxSigninFormPanelModel(api: api, secureLibrary: secureLibrary, reachability: reachability)
        self.updateViewModel()
    }
    
    func logout() {
        self.secureLibrary.remove()
        self.logoutPublisher.send()
    }
    private func updateViewModel() {
        guard isConnected else { return self.setDisconnected() }
        guard let authAPI = self.authAPI else { return self.setNotLoggedin() }
        
        self.setLoggingIn()
        
        authAPI.getProfile()
            .peek{ self.onGetProfile($0, authAPI: authAPI) }
            .catch{_ in self.setProfileError(error: "Can't get profile.") }
    }
    
    private func onGetProfile(_ profile: AxUserProfile, authAPI: AxHttpAuthorizedAPIClient) {
        self.profilePublisher.send(profile)
        self.setLoggedIn(name: profile.name, email: profile.email, icon: R.Home.Sidebar.defaultProfile)
        
        let accountFormModel = AxAccountFormModel(
            icon: R.Home.Sidebar.defaultProfile, name: profile.name, email: profile.email,
            authAPI: authAPI, secureLibrary: secureLibrary, reachability: reachability
        )
        
        if let profileURL = profile.profileURL {
            URLSession.shared.data(for: profileURL)
                .receive(on: .main)
                .peek{ if let icon = NSImage(data: $0) {
                    self.icon = icon
                    accountFormModel.icon = icon
                }}
                .catchOnToast()
        }
        
        accountFormModel.$name
            .sink{[unowned self] in self.title = $0 }.store(in: &objectBag)
        accountFormModel.$email
            .sink{[unowned self] in self.email = $0 }.store(in: &objectBag)
        accountFormModel.$icon
            .sink{[unowned self] in self.icon = $0 }.store(in: &objectBag)
        accountFormModel.logoutPublisher
            .sink{ self.logout() }.store(in: &objectBag)
        
        self.accountFormModel = accountFormModel
    }
    
    private func setDisconnected() {
        self.canLogin = false
        self.canLogout = false
        self.title = "No connection"
        self.email = nil
        self.icon = R.Home.Sidebar.accountNoIcon
    }

    private func setNotLoggedin() {
        self.canLogin = true
        self.canLogout = false
        self.title = "Sign In"
        self.email = nil
        self.icon = R.Home.Sidebar.accountNoIcon
    }
    private func setLoggingIn() {
        self.canLogin = false
        self.canLogout = false
        self.title = "Signing in..."
        self.email = nil
        self.icon = R.Home.Sidebar.accountNoIcon
    }

    private func setLoggedIn(name: String, email: String, icon: NSImage) {
        self.canLogin = false
        self.canLogout = true
        self.title = name
        self.email = email
        self.icon = icon
    }

    private func setProfileError(error: String) {
        self.canLogin = false
        self.canLogout = true
        self.title = error
        self.email = nil
        self.icon = R.Home.Sidebar.accountNoIcon
    }
}
