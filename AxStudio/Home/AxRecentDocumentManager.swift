//
//  AxRecentDocumentProvider.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import SwiftEx
import AppKit
import AppKit
import Combine
import AxDocument
import AxModelCore

final class AxRecentDocumentManager {
    private let localDocumentItemLoader = AxRecentLocalDocumentItemsLoader()
    
    private let cloudDocumentItemLoader = AxRecentCloudDocumentItemsLoader()
    
    func reload() {
        self.localDocumentItemLoader.setNeedsReload()
        self.cloudDocumentItemLoader.setNeedsReload()
    }
    
    func setAuthAPI(_ authAPI: AxHttpAuthorizedAPIClient?) {
        self.cloudDocumentItemLoader.setAuthAPI(authAPI)
    }
    
    func documentsPublisher() -> AnyPublisher<[AxHomeDocument], Never> {
        self.localDocumentItemLoader.$documents.combineLatest(self.cloudDocumentItemLoader.$documents)
            .map{ ($0 + $1).sorted(by: { $0.modificationDate > $1.modificationDate }) }
            .eraseToAnyPublisher()
    }
}
