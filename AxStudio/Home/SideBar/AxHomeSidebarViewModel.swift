//
//  AxHomeSidebarPresenter.swift
//  AxStudio
//
//  Created by yuki on 2021/09/19.
//

import AxDocument
import SwiftEx
import AppKit
import AppKit
import AxComponents
import Combine

final class AxHomeSidebarViewModel {
    
    @ObservableProperty var canCreateCloudDocument = false

    @ObservableProperty var isConnected: Bool = true { didSet { if isConnected != oldValue { updateViewModel() }  } }
    
    var authAPI: AxHttpAuthorizedAPIClient? { didSet { updateViewModel() } }

    let reloadPublisher = PassthroughSubject<Void, Never>()
    
    private let cloudDocumentManager: AxCloudDocumentManager
    
    private var objectBag = Set<AnyCancellable>()
    
    init(cloudDocumentManager: AxCloudDocumentManager) {
        self.cloudDocumentManager = cloudDocumentManager
        self.updateViewModel()
    }
    
    private func updateViewModel() {
        if !isConnected {
            self.canCreateCloudDocument = false
            return
        }
        if self.authAPI != nil {
            self.canCreateCloudDocument = true
        }else{
            self.canCreateCloudDocument = false
        }
    }
    
}
