//
//  AxHomeModel.swift
//  AxComponents
//
//  Created by yuki on 2021/01/24.
//  Copyright © 2021 yuki. All rights reserved.
//

import AppKit
import Combine
import SwiftEx
import AppKit
import Promise
import AxComponents
import AxDocument
import KeychainAccess

final class AxHomeWindowViewModel {

    let recentCollectionPresenter: AxHomeRecentCollectionPresenter
    let sidebarViewModel: AxHomeSidebarViewModel
    let accountViewPresneter: AxHomeAccountPresenter
    let joinDocumentPresneter: AxHomeJoinDocumentPresenter
    
    private(set) var autoSigninPromise = Promise<Void, Never>.resolve()
    
    let requireInternetConnection: Bool
    let api: AxHttpAPIClient
    let secureLibrary: AxSecureSigninInfoLibrary
    let reachability: Reachability
    let cloudDocumentManager: AxCloudDocumentManager
    let recentDocumentProvider: AxRecentDocumentProvider

    var authAPI: AxHttpAuthorizedAPIClient? { didSet { self.onUpdateAuthAPI(authAPI) } }
    private var objectBag = Set<AnyCancellable>()

    init(
        api: AxHttpAPIClient, secureLibrary: AxSecureSigninInfoLibrary, reachability: Reachability,
        cloudDocumentManager: AxCloudDocumentManager,
        recentDocumentProvider: AxRecentDocumentProvider,
        requireInternetConnection: Bool
    ) {
        self.api = api
        self.requireInternetConnection = requireInternetConnection
        self.secureLibrary = secureLibrary
        self.reachability = reachability
        self.cloudDocumentManager = cloudDocumentManager
        self.recentDocumentProvider = recentDocumentProvider
        
        self.recentCollectionPresenter = AxHomeRecentCollectionPresenter(cloudDocumentManager: cloudDocumentManager, recentDocumentProvider: recentDocumentProvider)
        self.sidebarViewModel = AxHomeSidebarViewModel(cloudDocumentManager: cloudDocumentManager)
        self.accountViewPresneter = AxHomeAccountPresenter(api: api, secureLibrary: secureLibrary, reachability: reachability)
        self.joinDocumentPresneter = AxHomeJoinDocumentPresenter(api: api, cloudDocumentManager: cloudDocumentManager, secureLibrary: secureLibrary, recentDocumentProvider: recentDocumentProvider, reachability: reachability)
        
        self.makeBindings()
        self.initialLoad()
    }
    
    private func makeBindings() {
        self.accountViewPresneter.authAPIPublisher
            .sink{ self.authAPI = $0 }.store(in: &objectBag)
        self.accountViewPresneter.logoutPublisher
            .sink{ self.authAPI = nil }.store(in: &objectBag)
        self.accountViewPresneter.profilePublisher
            .sink{ self.cloudDocumentManager.profile = $0 }.store(in: &objectBag)
        
        self.sidebarViewModel.reloadPublisher
            .sink{ self.recentDocumentProvider.cloudDocumentItemLoader.setNeedsReload() }.store(in: &objectBag)
        self.joinDocumentPresneter.authAPIPublisher
            .sink{ self.authAPI = $0 }.store(in: &objectBag)
    }

    private func initialLoad() {
        self.reachability.publisher
            .sink{[self] in
                let isConnected = $0.connection != .unavailable || !requireInternetConnection
                self.sidebarViewModel.isConnected = isConnected
                self.accountViewPresneter.isConnected = isConnected
                self.joinDocumentPresneter.isConnected = isConnected
            }
            .store(in: &objectBag)
        
        self.signInIfPossible()
    }
    
    private func signInIfPossible() {
        guard self.reachability.connection != .unavailable || !requireInternetConnection else {
            return
        }
        guard let signinInfo = self.secureLibrary.get() else {
            return
        }
        
        self.autoSigninPromise = .init()
        self.api.login(email: signinInfo.email, pass: signinInfo.password)
            .peek{ self.authAPI = $0 }
            .catch{ error in
                ACToast.show(message: "サインインに失敗しました"); self.authAPI = nil
            }
            .sink{
                self.autoSigninPromise.resolve()
            }
    }


    private func onUpdateAuthAPI(_ authAPI: AxHttpAuthorizedAPIClient?) {
        self.cloudDocumentManager.setAuthAPI(authAPI)
        self.recentDocumentProvider.setAuthAPI(authAPI)
        
        self.recentCollectionPresenter.authAPI = self.authAPI
        self.sidebarViewModel.authAPI = authAPI
        self.accountViewPresneter.authAPI = authAPI
        self.joinDocumentPresneter.authAPI = authAPI
    }
}

extension AxHomeWindowViewModel {
    static func make(api: AxHttpAPIClient, serviceKey: String, requireInternetConnection: Bool) -> AxHomeWindowPresenter {
        let keychain = Keychain(service: serviceKey)
        let secureLibrary = AxSecureSigninInfoLibrary(keychain: keychain)
        let reachability = try! Reachability()
        let cloudDocumentManager = AxCloudDocumentManager(userDefaults: .standard)
        let recentDocumentProvider = AxRecentDocumentProvider()
        
        return AxHomeWindowPresenter(
            api: api, secureLibrary: secureLibrary, reachability: reachability, cloudDocumentManager: cloudDocumentManager, recentDocumentProvider: recentDocumentProvider, requireInternetConnection: requireInternetConnection
        )
    }

    static func makeLocalhost(_ config: AxHttpClientDebugConfig? = nil) -> AxHomeWindowPresenter {
        self.make(api: .localhost(config), serviceKey: "com.axstudio.localhost", requireInternetConnection: false)
    }

    static func makeProduction() -> AxHomeWindowPresenter {
        self.make(api: .production, serviceKey: "com.axstudio.secure", requireInternetConnection: true)
    }
    
}
