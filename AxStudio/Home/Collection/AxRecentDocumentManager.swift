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
    let localDocumentItemLoader = AxRecentLocalDocumentItemsLoader()
    
    let cloudDocumentItemLoader = AxRecentCloudDocumentItemsLoader()
    
    func setAuthAPI(_ authAPI: AxHttpAuthorizedAPIClient?) {
        self.cloudDocumentItemLoader.setAuthAPI(authAPI)
    }
    
    func publisher() -> AnyPublisher<[AxHomeDocument], Never> {
        let localDocumentItems = localDocumentItemLoader.publisher.map{ $0.map{ AxRecentDocumentItem(document: .local($0)) } }
        let cloudDocumentItems = cloudDocumentItemLoader.publisher.map{ $0.map{ AxRecentDocumentItem(document: .cloud($0)) } }
        
        let documentItems = localDocumentItems.combineLatest(cloudDocumentItems)
            .map{ ($0 + $1).sorted(by: { $0.modificationDate > $1.modificationDate }) }
            .map{ $0.map{ AxRecentDocumentFormatter.convertToDocumentData($0) } }
            .eraseToAnyPublisher()
        
        return documentItems
    }
}

final class AxRecentLocalDocumentItemsLoader {
    var publisher: AnyPublisher<[AxRecentDocumentItem.Local], Never> { subject.eraseToAnyPublisher() }
    
    var showTrashedDocuments = false { didSet { self.reloadItems() } }
    
    private var needsReload = false
    
    private let subject = CurrentValueSubject<[AxRecentDocumentItem.Local], Never>([])
    
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
        let documentItems = currentRecentDocumentItems()
        self.subject.send(documentItems)
    }
    
    private func currentRecentDocumentItems() -> [AxRecentDocumentItem.Local] {
        let urls = NSDocumentController.shared.recentDocumentURLs
                
        return urls
            .filter{ !$0.fileResource.isHidden }
            .map{ AxRecentDocumentItem.Local(modificationDate: $0.fileResource.modificationDate ?? Date(), url: $0)  }
    }
}

final class AxRecentCloudDocumentItemsLoader {
    
    var publisher: AnyPublisher<[AxRecentDocumentItem.Cloud], Never> { subject.eraseToAnyPublisher() }
    
    private let subject = CurrentValueSubject<[AxRecentDocumentItem.Cloud], Never>([])
    private var authAPI: AxHttpAuthorizedAPIClient? = nil
    private let dateFormatter = ISO8601DateFormatter() => {
        $0.formatOptions.insert(.withFractionalSeconds)
    }
    private var initialLoaded = false
    private var needsReload = false
    
    func setAuthAPI(_ authAPI: AxHttpAuthorizedAPIClient?) {
        if authAPI == nil { self.subject.send([]) }
        
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
        
        fetchDocumentItems(from: authAPI).sink{ self.subject.send($0) }
    }
    
    private func fetchDocumentItems(from authAPI: AxHttpAuthorizedAPIClient) -> Promise<[AxRecentDocumentItem.Cloud], Never> {
        authAPI.recentDocuments()
            .map{ $0.map{ self.convertToDocumentItem(from: $0, authAPI: authAPI) } }
            .replaceError(with: [])
    }
    
    private func convertToDocumentItem(from res: AxDocumentResponce, authAPI: AxHttpAuthorizedAPIClient) -> AxRecentDocumentItem.Cloud {
        let modificationDate = dateFormatter.date(from: res.lastOpenAt ?? res.updatedAt) ?? Date()
        return AxRecentDocumentItem.Cloud(modificationDate: modificationDate, authAPI: authAPI, documentData: res)
    }
}
