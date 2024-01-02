//
//  AxHomeAccountPresenter.swift
//  AxStudio
//
//  Created by yuki on 2021/09/19.
//

import AppKit
import AxDocument
import SwiftEx
import Combine
import AxComponents

final class AxHomeAccountPresenter {
    let viewModel: AxHomeAccountViewModel
    
    let authAPIPublisher = PassthroughSubject<AxHttpAuthorizedAPIClient, Never>()
    let profilePublisher = PassthroughSubject<AxUserProfile, Never>()
    let logoutPublisher = PassthroughSubject<Void, Never>()
    
    var authAPI: AxHttpAuthorizedAPIClient? {
        didSet { self.updateViewModel() }
    }
    var isConnected: Bool = true {
        didSet { if isConnected != oldValue { self.updateViewModel() } }
    }
    
    private let api: AxHttpAPIClient
    private let secureLibrary: AxSecureSigninInfoLibrary
    private let reachability: Reachability
    private let signinFormModel: AxSigninFormPanelModel
    private var objectBag = Bag()
    
    init(api: AxHttpAPIClient, secureLibrary: AxSecureSigninInfoLibrary, reachability: Reachability) {
        self.api = api
        self.secureLibrary = secureLibrary
        self.reachability = reachability
        self.signinFormModel = AxSigninFormPanelModel(api: api, secureLibrary: secureLibrary, reachability: reachability)
        self.viewModel = AxHomeAccountViewModel(signinFormModel: signinFormModel)
        
        self.makeBindings()
        self.updateViewModel()
    }
    
    private func makeBindings() {
        self.viewModel.logoutPublisher
            .sink{ self.logout() }.store(in: &objectBag)
        self.signinFormModel.authAPIPublisher
            .sink{ self.authAPIPublisher.send($0) }.store(in: &objectBag)
    }
    
    private func logout() {
        self.secureLibrary.remove()
        self.logoutPublisher.send()
    }
        
    private func updateViewModel() {
        guard isConnected else { return self.viewModel.setDisconnected() }
        guard let authAPI = self.authAPI else { return self.viewModel.setNotLoggedin() }
        
        self.viewModel.setLoggingIn()
        
        authAPI.getProfile()
            .peek{ self.onGetProfile($0, authAPI: authAPI) }
            .catch{_ in self.viewModel.setProfileError(error: "Can't get profile.") }
    }
    
    private func onGetProfile(_ profile: AxUserProfile, authAPI: AxHttpAuthorizedAPIClient) {
        self.profilePublisher.send(profile)
        self.viewModel.setLoggedIn(name: profile.name, email: profile.email, icon: R.Home.Sidebar.defaultProfile)
        
        let accountFormModel = AxAccountFormModel(
            icon: R.Home.Sidebar.defaultProfile, name: profile.name, email: profile.email,
            authAPI: authAPI, secureLibrary: secureLibrary, reachability: reachability
        )
        
        if let profileURL = profile.profileURL {
            URLSession.shared.data(for: profileURL)
                .receive(on: .main)
                .peek{ if let icon = NSImage(data: $0) {
                    self.viewModel.icon = icon
                    accountFormModel.icon = icon
                }}
                .catchOnToast()
        }
        
        accountFormModel.$name
            .sink{[unowned self] in viewModel.title = $0 }.store(in: &objectBag)
        accountFormModel.$email
            .sink{[unowned self] in viewModel.email = $0 }.store(in: &objectBag)
        accountFormModel.$icon
            .sink{[unowned self] in viewModel.icon = $0 }.store(in: &objectBag)
        accountFormModel.logoutPublisher
            .sink{ self.logout() }.store(in: &objectBag)
        
        self.viewModel.accountFormModel = accountFormModel
    }
}
