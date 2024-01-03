//
//  AxHomeRecentCollectionPresenter.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import Combine
import AppKit
import SwiftEx
import AppKit
import AxComponents
import AxDocument
import CoreAudio
import AudioToolbox

final class AxHomeRecentCollectionViewModel: AxHomeDocumentCollectionViewModel {
    @ObservableProperty var homeDocuments = [AxHomeDocument]()
    
    var homeDocumentsPublisher: AnyPublisher<[AxHomeDocument], Never> {
        self.$homeDocuments.eraseToAnyPublisher()
    }
    
    var authAPI: AxHttpAuthorizedAPIClient?
    
    private let cloudDocumentManager: AxCloudDocumentManager
    
    private let recentDocumentProvider: AxRecentDocumentManager
    
    private var objectBag = Set<AnyCancellable>()

    init(cloudDocumentManager: AxCloudDocumentManager, recentDocumentProvider: AxRecentDocumentManager) {
        self.cloudDocumentManager = cloudDocumentManager
        self.recentDocumentProvider = recentDocumentProvider
        
        self.recentDocumentProvider.documentsPublisher()
            .sink{ self.homeDocuments = $0 }.store(in: &objectBag)
    }
    
    func itemModel(_ row: Int) -> AxHomeCollectionItemModel {
        AxHomeCollectionItemModel(document: self.homeDocuments[row], viewModel: self)
    }
    
    func openDocument(_ document: AxHomeDocument) {
        switch document {
        case let document as AxHomeLocalDocument: self.openLocalDocument(document)
        case let document as AxHomeCloudDocument: self.openCloudDocument(document)
        default: assertionFailure()
        }
    }
    
    func deleteDocument(_ document: AxHomeDocument) {
        switch document {
        case let document as AxHomeLocalDocument: self.deleteLocalDocument(document)
        case let document as AxHomeCloudDocument: self.deleteCloudDocument(document)
        default: assertionFailure()
        }
    }
    
    func copyLink(_ document: AxHomeDocument) {
        guard let authAPI = self.authAPI, let data = document as? AxHomeCloudDocument else { return }
        authAPI.shareLink(documentID: data.documentID)
            .peek{ res in
                NSPasteboard.general.prepareForNewContents(with: [])
                NSPasteboard.general.setString(res.invitationURL.absoluteString, forType: .string)
                ACToast.show(message: "Link Copied!")
            }
            .catchOnToast("Can't copy link.")
    }
    
    private func openCloudDocument(_ document: AxHomeCloudDocument) {
        self.cloudDocumentManager.openDocument(documentID: document.documentID).catchOnToast("Can't open cloud document.")
        
        self.recentDocumentProvider.reload()
    }
    
    private func openLocalDocument(_ document: AxHomeLocalDocument) {
        NSDocumentController.shared.openDocument(withContentsOf: document.url, display: true) {_, _, error in
            if let error = error { ACToast.showError(message: "Can't open Local document", error: error) }
        }
    }
    
    private func deleteLocalDocument(_ document: AxHomeLocalDocument) {
        if let currentDocument = NSDocumentController.shared.document(for: document.url) {
            currentDocument.close()
        }
        
        NSWorkspace.shared.recycle([document.url]) { table, err in
            guard err == nil else { return ACToast.show(message: "Document could not be deleted.") }
            ACToast.show(message: "Document deleted")
            NSSound.dragToTrash?.play()
        }
        self.recentDocumentProvider.reload()
    }
    
    
    func renameDocument(_ document: AxHomeDocument, to name: String) {
        guard let authAPI = self.authAPI, let data = document as? AxHomeCloudDocument else { return }

        authAPI.updateDocument(documentID: data.documentID, name: name)
            .peek{_ in self.recentDocumentProvider.reload() }
            .catchOnToast()
    }
    
    func openInFinder(_ document: AxHomeDocument) {
        guard let data = document as? AxHomeLocalDocument else { return }
        NSWorkspace.shared.selectFile(data.url.path, inFileViewerRootedAtPath: data.url.path)
    }
}

extension NSSound {
    static let dragToTrash = NSSound(contentsOfFile: "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif", byReference: true)
}

extension AxDocument {
    var __accountName: String? {
        get { localStorage["__accountName"] as? String } set { localStorage["__accountName"] = newValue }
    }
}

