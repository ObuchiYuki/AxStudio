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

final class AxRecentLocalDocumentItemsLoader {
    @ObservableProperty var documents = [AxHomeLocalDocument]()
    
    var showTrashedDocuments = false { didSet { self.reloadItems() } }
    
    private var needsReload = false
    
    init() {
        // receive notification
        NotificationCenter.default.addObserver(forName: AxDocumentController.recentDocumentNotificationName, object: nil, queue: nil) {_ in
            self.setNeedsReload()
        }
        NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: nil, queue: nil) {_ in
            self.setNeedsReload()
        }
        NotificationCenter.default.addObserver(forName: NSWindow.didBecomeKeyNotification, object: nil, queue: nil) {_ in
            self.setNeedsReload()
        }
        // initial load
        self.setNeedsReload()
    }
    
    func setNeedsReload() {
        if self.needsReload { return }; self.needsReload = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reloadItems()
            self.needsReload = false
        }
    }
    
    private func reloadItems() {
        self.documents = self.currentRecentDocumentItems()
    }
    
    private func currentRecentDocumentItems() -> [AxHomeLocalDocument] {
        NSDocumentController.shared.recentDocumentURLs
            .filter{ !$0.fileResource.isHidden }
            .map{ url in
                let title = url.deletingPathExtension().lastPathComponent
                let thumbnail = AxDocumentPreviewManager.shared.localPreview(for: url)
                let modificationDate = url.fileResource.modificationDate ?? Date()
                
                return AxHomeLocalDocument(
                    title: title, modificationDate: modificationDate, thumbnail: thumbnail, url: url
                )
            }
    }
}
