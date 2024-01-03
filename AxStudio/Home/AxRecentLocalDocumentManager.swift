//
//  AxRecentLocalDocumentManager.swift
//  AxStudio
//
//  Created by yuki on 2024/01/03.
//

import Foundation


final class AxRecentLocalDocumentManager {
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
