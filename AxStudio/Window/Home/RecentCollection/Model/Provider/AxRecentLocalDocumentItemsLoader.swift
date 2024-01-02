//
//  AxRecentLocalDocumentItemsLoader.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import Combine
import Foundation
import AppKit

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
