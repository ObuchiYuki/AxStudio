//
//  AxHomeSidebarPresenter.swift
//  AxStudio
//
//  Created by yuki on 2021/09/19.
//

import AxDocument
import SwiftEx
import AppKit
import AxComponents
import Combine

final class AxHomeSidebarPresenter {
    
    let viewModel = AxHomeSidebarViewModel()
    
    var authAPI: AxHttpAuthorizedAPIClient? { didSet { updateViewModel() } }
    var isConnected: Bool = true { didSet { if isConnected != oldValue { updateViewModel() }  } }
    
    let reloadPublisher = PassthroughSubject<Void, Never>()
    
    private let cloudDocumentManager: AxCloudDocumentManager
    private var objectBag = Bag()
    
    init(cloudDocumentManager: AxCloudDocumentManager) {
        self.cloudDocumentManager = cloudDocumentManager
        
        self.viewModel.createCloudDocumentPublisher
            .sink{ self.createCloudDocument() }.store(in: &objectBag)
        self.viewModel.createLocalDocumentPublisher
            .sink{ self.createLocalDocument() }.store(in: &objectBag)
        
        self.updateViewModel()
    }
    
    private func updateViewModel() {
        if !isConnected {
            self.viewModel.canCreateCloudDocument = false
            return
        }
        if self.authAPI != nil {
            self.viewModel.canCreateCloudDocument = true
        }else{
            self.viewModel.canCreateCloudDocument = false
        }
    }
    
    private func createCloudDocument() {
        guard let authAPI = self.authAPI else { return ACToast.show(message: "Can't create document. (No API)") }
        
        let (root, nodes) = AxDocument.makeInitialObjects()
        authAPI.createDocument(root: root, nodes: nodes)
            .peek{
                self.cloudDocumentManager.openDocument(documentID: $0.id).catchOnToast()
                self.reloadPublisher.send()
            }
            .catchOnToast("Can't create document.")
    }
    
    private func createLocalDocument() {
        do {
            try NSDocumentController.shared.openUntitledDocumentAndDisplay(true)
        }catch{
            ACToast.show(message: "Can't create document. (Local)")
        }
    }
}
