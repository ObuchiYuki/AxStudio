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
import LayoutEngine

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
    
    
    func openDocument(documentID: String)  {
        self.windowManager.openDocument(documentID: documentID)
            .peek { self.setNeedsReload() }
            .catchOnToast()
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
                    return AxHomeCloudDocument(title: res.name, modificationDate: modificationDate, thumbnail: thumbnail, documentID: res.id)
                }
            }
            .replaceError(with: [])
    }
}
