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

final class AxRecentCloudDocumentItemsLoader {
    
    @ObservableProperty var documents = [AxHomeCloudDocument]()
    
    private var authAPI: AxHttpAuthorizedAPIClient? = nil

    private let dateFormatter = ISO8601DateFormatter() => {
        $0.formatOptions.insert(.withFractionalSeconds)
    }

    private var initialLoaded = false

    private var needsReload = false
    
    func setAuthAPI(_ authAPI: AxHttpAuthorizedAPIClient?) {
        if authAPI == nil { self.documents = [] }
        
        self.authAPI = authAPI
        self.reloadItems()
    }
    
    func setNeedsReload() {
        if needsReload { return }; needsReload = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.needsReload = false
            self.reloadItems()
        }
    }
    
    private func reloadItems() {
        guard let authAPI = self.authAPI else { return }
        self.fetchDocumentItems(from: authAPI).sink{ self.documents = $0 }
    }
    
    private func fetchDocumentItems(from authAPI: AxHttpAuthorizedAPIClient) -> Promise<[AxHomeCloudDocument], Never> {
        authAPI.recentDocuments()
            .map{ $0.map{ self.convertToDocumentItem(from: $0, authAPI: authAPI) } }
            .replaceError(with: [])
    }
    
    private func convertToDocumentItem(from res: AxDocumentResponce, authAPI: AxHttpAuthorizedAPIClient) -> AxHomeCloudDocument {
        let modificationDate = dateFormatter.date(from: res.lastOpenAt ?? res.updatedAt) ?? Date()
        
        let thumbnail = AxDocumentPreviewManager.shared.cloudPreview(for: res.id)
        
        return AxHomeCloudDocument(title: res.name, modificationDate: modificationDate, thumbnail: thumbnail, documentID: res.id)
    }
}
