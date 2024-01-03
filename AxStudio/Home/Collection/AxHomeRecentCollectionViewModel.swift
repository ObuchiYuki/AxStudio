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
    
    private let cloudDocumentManager: AxCloudDocumentManager
    
    private let localDocumentManager: AxLocalDocumentManager
    
    private let sandboxDocumentManager: AxSandboxDocumentManager
    
    private var objectBag = Set<AnyCancellable>()
    
    init(
        cloudDocumentManager: AxCloudDocumentManager,
        localDocumentManager: AxLocalDocumentManager,
        sandboxDocumentManager: AxSandboxDocumentManager
    ) {
        self.cloudDocumentManager = cloudDocumentManager
        self.localDocumentManager = localDocumentManager
        self.sandboxDocumentManager = sandboxDocumentManager
        
        self.cloudDocumentManager.$documents.combineLatest(localDocumentManager.$documents)
            .sink{[unowned self] in
                self.homeDocuments = ($0 + $1).sorted(by: { $0.modificationDate < $1.modificationDate })
            }
            .store(in: &objectBag)
    }

    func itemModel(_ row: Int) -> AxHomeCollectionItemModel {
        AxHomeCollectionItemModel(document: self.homeDocuments[row], viewModel: self)
    }
    
    /// ここら辺はどこかで別の場所に
    func openDocument(_ document: AxHomeDocument) {
        switch document {
        case let document as AxHomeLocalDocument: self.localDocumentManager.openDocument(document)
        case let document as AxHomeCloudDocument: self.cloudDocumentManager.openDocument(document)
        case let document as AxHomeSandboxDocument: self.sandboxDocumentManager.openDocument(document)
        default: assertionFailure()
        }
    }
    
    func deleteDocument(_ document: AxHomeDocument) {
        switch document {
        case let document as AxHomeLocalDocument: self.localDocumentManager.deleteDocument(document)
        case let document as AxHomeCloudDocument: self.cloudDocumentManager.deleteCloudDocument(document)
        case let document as AxHomeSandboxDocument: self.sandboxDocumentManager.deleteDocument(document)
        default: assertionFailure()
        }
    }
    
    func copyLink(_ document: AxHomeDocument) {
        switch document {
        case let document as AxHomeLocalDocument: NSSound.beep()
        case let document as AxHomeCloudDocument: self.cloudDocumentManager.copyLink(document)
        default: assertionFailure()
        }
    }
    
    func renameDocument(_ document: AxHomeDocument, to name: String) {
        switch document {
        case let document as AxHomeLocalDocument: NSSound.beep()
        case let document as AxHomeCloudDocument: self.cloudDocumentManager.renameDocument(document, to: name)
        case let document as AxHomeSandboxDocument: self.sandboxDocumentManager.renameDocument(document, to: name)
        default: assertionFailure()
        }
    }
    
    func openInFinder(_ document: AxHomeDocument) {
        switch document {
        case let document as AxHomeLocalDocument: self.localDocumentManager.openInFinder(document)
        case let document as AxHomeCloudDocument: NSSound.beep()
        case let document as AxHomeSandboxDocument: self.sandboxDocumentManager.openInFinder(document)
        default: assertionFailure()
        }
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

