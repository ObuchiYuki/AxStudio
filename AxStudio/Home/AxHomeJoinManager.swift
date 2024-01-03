//
//  AxHomeJoinDocumentPresenter.swift
//  AxStudio
//
//  Created by yuki on 2021/09/19.
//

import AppKit
import Combine
import AxDocument
import SwiftEx
import AppKit
import AxComponents

final class AxHomeJoinManager {
    var authAPI: AxHttpAuthorizedAPIClient?
    
    let authAPIPublisher = PassthroughSubject<AxHttpAuthorizedAPIClient, Never>()
    
    var isConnected: Bool = false
    
    private let api: AxHttpAPIClient
    private let cloudDocumentManager: AxCloudDocumentManager
    private let secureLibrary: AxSecureSigninInfoLibrary
    private let reachability: Reachability
    private let recentDocumentProvider: AxRecentDocumentManager
    
    private var signinBag = Set<AnyCancellable>()
    
    init(api: AxHttpAPIClient, cloudDocumentManager: AxCloudDocumentManager, secureLibrary: AxSecureSigninInfoLibrary, recentDocumentProvider: AxRecentDocumentManager, reachability: Reachability) {
        self.api = api
        self.cloudDocumentManager = cloudDocumentManager
        self.secureLibrary = secureLibrary
        self.recentDocumentProvider = recentDocumentProvider
        self.reachability = reachability
    }
    
    func joinDocument(_ token: String, window: NSWindow) {
        if !isConnected {
            ACToast.show(message: "No Internet Connection")
            return
        }
        
        if let authAPI = self.authAPI {
            authAPI.joinDocument(token: token)
                .flatMap{ self.cloudDocumentManager.openDocument(documentID: $0.documentID) }
                .catchOnToast("Can't Join Document")
                .wait(on: DispatchQueue.main, for: 0.1)
                .sink{ self.recentDocumentProvider.cloudDocumentItemLoader.setNeedsReload() }
        }else{
            self.signinBag.removeAll()
            let model = AxSigninFormPanelModel(api: api, secureLibrary: secureLibrary, reachability: reachability)
            model.infomativeText = "Documentの参加にはログインが必要です"
            model.authAPIPublisher
                .sink{[unowned self] in
                    self.onLogin($0, token: token, window: window)
                }
                .store(in: &signinBag)
            ACFormPanel(initialProvider: ACSigninFormProvider(model: model)).showSheet(on: window)
        }
    }
    
    private func onLogin(_ authAPI: AxHttpAuthorizedAPIClient, token: String, window: NSWindow) {
        authAPIPublisher.send(authAPI)
        
        self.joinDocument(token, window: window)
    }
}
