//
//  AxCloudDocumentOpener.swift
//  AxStudio
//
//  Created by yuki on 2021/09/19.
//

import AxModelCore
import AppKit
import AxComponents
import AxDocument
import SwiftEx
import AppKit

final class AxHomeCloudDocument: AxHomeDocument {
    let documentID: String
    
    unowned let manager: AxCloudDocumentManager
    
    override func documentTypeIcon() -> NSImage? { R.Home.Body.cloudDocumentIcon }
    
    override func documentDefaultThumbnail() -> NSImage? { R.Home.Body.cloudDocumentDefaultThumbnail }
    
    override func open() { self.manager.openDocument(self) }
    
    override func delete() { self.manager.deleteDocument(self) }
    
    override func rename(to name: String) {
        self.manager.renameDocument(self, to: name)
    }
    
    override func provideContextMenu(to menu: NSMenu, _ activateRename: @escaping () -> ()) {
        menu.addItem("Open", action: { self.manager.openDocument(self) })
        menu.addItem(.separator())
        menu.addItem("Copy Link", action: { self.manager.copyLink(self) })
        menu.addItem(.separator())
        menu.addItem("Rename", action: { activateRename() })
        menu.addItem("Delete", action: { self.manager.deleteDocument(self) })
    }
    
    init(title: String, modificationDate: Date, thumbnail: Promise<NSImage?, Never>?, documentID: String, manager: AxCloudDocumentManager) {
        self.documentID = documentID
        self.manager = manager
        super.init(title: title, modificationDate: modificationDate, thumbnail: thumbnail)
    }
}

final class AxCloudDocumentManager {
    @ObservableProperty var documents = [AxHomeCloudDocument]()
    
    var authAPI: AxHttpAuthorizedAPIClient? {
        didSet {
            self.documents = []
            self.windowManager.setAuthAPI(authAPI)
            self.setNeedsReload()
        }
    }
    
    private let windowManager: AxCloudDocumentWindowManager
    
    private let dateFormatter = ISO8601DateFormatter() => {
        $0.formatOptions.insert(.withFractionalSeconds)
    }

    private var initialLoaded = false

    private var needsReload = false
    
    init(windowManager: AxCloudDocumentWindowManager) {
        self.windowManager = windowManager
    }
    
    @discardableResult func createDocument() -> Promise<Void, Never> {
        guard let authAPI = self.authAPI else {
            ACToast.show(message: "Can't create document. (No API)")
            return .resolve()
        }
        
        return authAPI.createDocument()
            .peek{ self.openDocument(documentID: $0.id).catchOnToast() }
            .catchOnToast("Can't create document.")
    }

    func copyLink(_ document: AxHomeCloudDocument) {
        guard let authAPI = self.authAPI else { return NSSound.beep() }
        
        authAPI.shareLink(documentID: document.documentID)
            .peek{ res in
                NSPasteboard.general.prepareForNewContents(with: [])
                NSPasteboard.general.setString(res.invitationURL.absoluteString, forType: .string)
                ACToast.show(message: "Link Copied!")
            }
            .catchOnToast("Can't copy link.")
    }
    
    func renameDocument(_ document: AxHomeCloudDocument, to name: String) {
        guard let authAPI = self.authAPI else { return NSSound.beep() }
        
        authAPI.updateDocument(documentID: document.documentID, name: name)
            .peek{_ in self.setNeedsReload() }
            .catchOnToast()
    }
    
    
    func openDocument(_ document: AxHomeCloudDocument) {
        _ = self.openDocument(documentID: document.documentID)
    }
    
    @discardableResult func openDocument(documentID: String) -> Promise<Void, Never> {
        self.windowManager.openDocument(documentID: documentID)
            .peek { self.setNeedsReload() }
            .catchOnToast()
    }
    
    @discardableResult func removeAllDocuments() -> Promise<Void, Never> {
        guard let authAPI = self.authAPI else { NSSound.beep(); return .resolve() }
        
        return authAPI.recentDocuments()
            .flatMap{ $0.map{ authAPI.deleteDocument(documentID: $0.id) }.combineAll() }
            .catchOnToast()
    }

    
    func deleteDocument(_ document: AxHomeCloudDocument) {
        guard let authAPI = self.authAPI else { return NSSound.beep() }
        
        authAPI.deleteDocument(documentID: document.documentID)
            .peek{
                ACToast.show(message: "Document Deleted")
                NSSound.dragToTrash?.play()
                self.setNeedsReload()
            }
            .catchOnToast("Document could not be deleted.")
    }
    
    private func setNeedsReload() {
        if needsReload { return }; needsReload = true
        
        func reloadItems() {
            guard let authAPI = self.authAPI else { return }
            self.fetchDocumentItems(from: authAPI).sink{ self.documents = $0 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.needsReload = false
            reloadItems()
        }
    }
    
    private func fetchDocumentItems(from authAPI: AxHttpAuthorizedAPIClient) -> Promise<[AxHomeCloudDocument], Never> {
        authAPI.recentDocuments()
            .map{
                $0.map{ res in
                    let modificationDate = dateFormatter.date(from: res.lastOpenAt ?? res.updatedAt) ?? Date()
                    let thumbnail = AxDocumentPreviewManager.shared.cloudPreview(for: res.id)
                    return AxHomeCloudDocument(title: res.name, modificationDate: modificationDate, thumbnail: thumbnail, documentID: res.id, manager: self)
                }
            }
            .replaceError(with: [])
    }
}
