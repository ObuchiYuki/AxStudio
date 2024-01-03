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

final class AxHomeViewModel {

    let recentCollectionViewModel: AxHomeRecentCollectionViewModel
    
    let accountViewModel: AxHomeAccountViewModel
    
    @ObservableProperty var isConnected = false
    
    @ObservableProperty var authAPI: AxHttpAuthorizedAPIClient? { didSet { self.onUpdateAuthAPI(authAPI) } }
    
    private(set) var autoSigninPromise = Promise<Void, Never>.resolve()
    
    let requireInternetConnection: Bool
    
    let api: AxHttpAPIClient
    let secureLibrary: AxSecureSigninInfoLibrary
    let reachability: Reachability
    
    let joinManager: AxHomeJoinManager
    let cloudDocumentManager: AxCloudDocumentManager
    let cloudDocumentWindowManager: AxCloudDocumentWindowManager
    let localDocumentManager: AxLocalDocumentManager
    
    private var objectBag = Set<AnyCancellable>()

    init(
        api: AxHttpAPIClient,
        secureLibrary: AxSecureSigninInfoLibrary,
        reachability: Reachability,
        requireInternetConnection: Bool
    ) {
        self.api = api
        self.requireInternetConnection = requireInternetConnection
        self.secureLibrary = secureLibrary
        self.reachability = reachability
        self.cloudDocumentWindowManager = AxCloudDocumentWindowManager(userDefaults: .standard)
        self.cloudDocumentManager = AxCloudDocumentManager(windowManager: self.cloudDocumentWindowManager)
        self.localDocumentManager = AxLocalDocumentManager()
        
        self.recentCollectionViewModel = AxHomeRecentCollectionViewModel(
            cloudDocumentManager: cloudDocumentManager, localDocumentManager: localDocumentManager
        )
        self.accountViewModel = AxHomeAccountViewModel(
            api: api, secureLibrary: secureLibrary, reachability: reachability
        )
        self.joinManager = AxHomeJoinManager(
            api: api, cloudDocumentManager: cloudDocumentManager, secureLibrary: secureLibrary, reachability: reachability
        )
        
        self.makeBindings()
        self.initialLoad()
    }
    
    private func makeBindings() {
        self.accountViewModel.authAPIPublisher
            .sink{ self.authAPI = $0 }.store(in: &objectBag)
        self.accountViewModel.logoutPublisher
            .sink{ self.authAPI = nil }.store(in: &objectBag)
        self.accountViewModel.profilePublisher
            .sink{ self.cloudDocumentWindowManager.profile = $0 }.store(in: &objectBag)
        self.joinManager.authAPIPublisher
            .sink{ self.authAPI = $0 }.store(in: &objectBag)
    }

    private func initialLoad() {
        self.reachability.publisher
            .sink{[self] in
                let isConnected = $0.connection != .unavailable || !requireInternetConnection
                self.isConnected = isConnected
                self.accountViewModel.isConnected = isConnected
                self.joinManager.isConnected = isConnected
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
        self.cloudDocumentManager.authAPI = authAPI
        self.accountViewModel.authAPI = authAPI
        self.joinManager.authAPI = authAPI
    }
}

extension AxHomeViewModel {
    static func make(api: AxHttpAPIClient, serviceKey: String, requireInternetConnection: Bool) -> AxHomeViewModel {
        let keychain = Keychain(service: serviceKey)
        let secureLibrary = AxSecureSigninInfoLibrary(keychain: keychain)
        let reachability = try! Reachability()
        
        return AxHomeViewModel(
            api: api, 
            secureLibrary: secureLibrary,
            reachability: reachability,
            requireInternetConnection: requireInternetConnection
        )
    }

    static func makeLocalhost(_ config: AxHttpClientDebugConfig? = nil) -> AxHomeViewModel {
        self.make(api: .localhost(config), serviceKey: "com.axstudio.localhost", requireInternetConnection: false)
    }

    static func makeProduction() -> AxHomeViewModel {
        self.make(api: .production, serviceKey: "com.axstudio.secure", requireInternetConnection: true)
    }
    
}
