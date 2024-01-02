//
//  AxHomeRecentCollectionPresenter.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import Combine
import AppKit
import SwiftEx
import AxComponents
import AxDocument
import CoreAudio
import AudioToolbox

final class AxHomeRecentCollectionPresenter {
    let viewModel = AxHomeDocumentCollectionViewModel()
    
    var authAPI: AxHttpAuthorizedAPIClient?
    
    private let cloudDocumentManager: AxCloudDocumentManager
    private let recentDocumentProvider: AxRecentDocumentProvider
    
    private var objectBag = Bag()

    init(cloudDocumentManager: AxCloudDocumentManager, recentDocumentProvider: AxRecentDocumentProvider) {
        self.cloudDocumentManager = cloudDocumentManager
        self.recentDocumentProvider = recentDocumentProvider
        
        self.recentDocumentProvider.publisher()
            .sink{ self.viewModel.itemData = $0 }.store(in: &objectBag)
        
        self.viewModel.openItemPublisher
            .sink{[unowned self] in self.openDocument($0) }.store(in: &objectBag)
        self.viewModel.copyLinkPublisher
            .sink{[unowned self] in self.copyLink($0) }.store(in: &objectBag)
        self.viewModel.deletePublisher
            .sink{[unowned self] in self.deleteDocument($0) }.store(in: &objectBag)
        self.viewModel.renamePublisher
            .sink{[unowned self] in self.renameDocument($0, to: $1) }.store(in: &objectBag)
        self.viewModel.openInFinderPublisher
            .sink{[unowned self] in self.openInFinder($0) }.store(in: &objectBag)
    }
    
    private func openDocument(_ data: AxHomeDocumentData) {
        switch data {
        case let data as AxHomeLocalDocumentData: self.openLocalDocument(data)
        case let data as AxHomeCloudDocumentData: self.openCloudDocument(data)
        default: assertionFailure()
        }
    }
    private func openCloudDocument(_ data: AxHomeCloudDocumentData) {
        self.cloudDocumentManager.openDocument(documentID: data.documentID).catchOnToast("Can't open cloud document.")
        
        self.recentDocumentProvider.cloudDocumentItemLoader.setNeedsReload()
    }
    private func openLocalDocument(_ data: AxHomeLocalDocumentData) {
        NSDocumentController.shared.openDocument(withContentsOf: data.url, display: true) {_, _, error in
            if let error = error { ACToast.showError(message: "Can't open Local document", error: error) }
        }
    }
    
    private func copyLink(_ data: AxHomeDocumentData) {
        guard let authAPI = self.authAPI, let data = data as? AxHomeCloudDocumentData else { return }
        authAPI.shareLink(documentID: data.documentID)
            .peek{ res in
                NSPasteboard.general.prepareForNewContents(with: [])
                NSPasteboard.general.setString(res.invitationURL.absoluteString, forType: .string)
                ACToast.show(message: "Link Copied!")
            }
            .catchOnToast("Can't copy link.")
    }
    private func deleteDocument(_ data: AxHomeDocumentData) {
        switch data {
        case let data as AxHomeLocalDocumentData: self.deleteLocalDocument(data)
        case let data as AxHomeCloudDocumentData: self.deleteCloudDocument(data)
        default: assertionFailure()
        }
    }
    
    private func deleteCloudDocument(_ data: AxHomeCloudDocumentData) {
        guard let authAPI = self.authAPI else { return }
        
        authAPI.deleteDocument(documentID: data.documentID)
            .peek{
                ACToast.show(message: "Document Deleted")
                self.recentDocumentProvider.cloudDocumentItemLoader.setNeedsReload()
                NSSound.dragToTrash?.play()
            }
            .catchOnToast("Document could not be deleted.")
    }
    private func deleteLocalDocument(_ data: AxHomeLocalDocumentData) {
        if let currentDocument = NSDocumentController.shared.document(for: data.url) {
            currentDocument.close()
        }
        
        NSWorkspace.shared.recycle([data.url]) { table, err in
            guard err == nil else { return ACToast.show(message: "Document could not be deleted.") }
            ACToast.show(message: "Document deleted")
            NSSound.dragToTrash?.play()
        }
        self.recentDocumentProvider.localDocumentItemLoader.setNeedsReload()
    }
    
    
    private func renameDocument(_ data: AxHomeDocumentData, to name: String) {
        guard let authAPI = self.authAPI, let data = data as? AxHomeCloudDocumentData else { return }

        authAPI.updateDocument(documentID: data.documentID, name: name)
            .peek{_ in
                self.recentDocumentProvider.cloudDocumentItemLoader.setNeedsReload()
            }
            .catchOnToast()
    }
    private func openInFinder(_ data: AxHomeDocumentData) {
        guard let data = data as? AxHomeLocalDocumentData else { return }
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
