//
//  AxRecentDocumentProvider.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import SwiftEx
import AppKit
import Combine
import AxDocument
import AxModelCore

final class AxRecentDocumentProvider {
    let localDocumentItemLoader = AxRecentLocalDocumentItemsLoader()
    let cloudDocumentItemLoader = AxRecentCloudDocumentItemsLoader()
    
    func setAuthAPI(_ authAPI: AxHttpAuthorizedAPIClient?) {
        self.cloudDocumentItemLoader.setAuthAPI(authAPI)
    }
    
    func publisher() -> AnyPublisher<[AxHomeDocumentData], Never> {
        let localDocumentItems = localDocumentItemLoader.publisher.map{ $0.map{ AxRecentDocumentItem(document: .local($0)) } }
        let cloudDocumentItems = cloudDocumentItemLoader.publisher.map{ $0.map{ AxRecentDocumentItem(document: .cloud($0)) } }
        
        let documentItems = localDocumentItems.combineLatest(cloudDocumentItems)
            .map{ ($0 + $1).sorted(by: { $0.modificationDate > $1.modificationDate }) }
            .map{ $0.map{ AxRecentDocumentFormatter.convertToDocumentData($0) } }
            .eraseToAnyPublisher()
        
        return documentItems
    }
}

