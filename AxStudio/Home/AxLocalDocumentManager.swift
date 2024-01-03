//
//  AxRecentLocalDocumentManager.swift
//  AxStudio
//
//  Created by yuki on 2024/01/03.
//

import AxModelCore
import AppKit
import AxComponents
import AxDocument
import SwiftEx
import AppKit
import LayoutEngine

final class AxHomeLocalDocument: AxHomeDocument {
    let url: URL
    
    unowned let manager: AxLocalDocumentManager
    
    override func documentTypeIcon() -> NSImage? { R.Home.Body.localDocumentIcon }
    
    override func documentDefaultThumbnail() -> NSImage? { R.Home.Body.localDocumentDefaultThumbnail }
    
    override func open() { manager.openDocument(self) }
    
    override func delete() { self.manager.deleteDocument(self) }
    
    override func provideContextMenu(to menu: NSMenu, _ activateRename: @escaping () -> ()) {
        menu.addItem("Open", action: { self.manager.openDocument(self) })
        menu.addItem("Delete", action: { self.manager.deleteDocument(self) })
        menu.addItem("Open in Finder", action: { self.manager.openInFinder(self) })
    }
    
    init(title: String, modificationDate: Date, thumbnail: Promise<NSImage?, Never>?, url: URL, manager: AxLocalDocumentManager) {
        self.url = url
        self.manager = manager
        super.init(title: title, modificationDate: modificationDate, thumbnail: thumbnail)
    }
}

final class AxLocalDocumentManager {
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
    
    func createDocument() {
        do {
            try NSDocumentController.shared.openUntitledDocumentAndDisplay(true)
        }catch{
            ACToast.show(message: "Can't create document. (Local)")
        }
    }
    
    func setNeedsReload() {
        if self.needsReload { return }; self.needsReload = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reloadItems()
            self.needsReload = false
        }
    }
    
    func openDocument(_ document: AxHomeLocalDocument) {
        NSDocumentController.shared.openDocument(withContentsOf: document.url, display: true) {_, _, error in
            if let error = error {
                ACToast.showError(message: "Can't open Local document", error: error)
            }
            
            self.setNeedsReload()
        }
    }
    
    func deleteDocument(_ document: AxHomeLocalDocument) {
        if let currentDocument = NSDocumentController.shared.document(for: document.url) {
            currentDocument.close()
        }
        
        NSWorkspace.shared.recycle([document.url]) { table, err in
            guard err == nil else { return ACToast.show(message: "Document could not be deleted.") }
            ACToast.show(message: "Document deleted")
            NSSound.dragToTrash?.play()
        }
        
        self.setNeedsReload()
    }
    
    func openInFinder(_ document: AxHomeDocument) {
        guard let data = document as? AxHomeLocalDocument else { return }
        NSWorkspace.shared.selectFile(data.url.path, inFileViewerRootedAtPath: data.url.path)
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
                    title: title, modificationDate: modificationDate, thumbnail: thumbnail, url: url, manager: self
                )
            }
    }
}
