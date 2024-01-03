//
//  +AxHomeDocumentItemModel.swift
//  AxStudio
//
//  Created by yuki on 2021/09/13.
//

import Combine
import Foundation
import SwiftEx
import AppKit
import AppKit


protocol AxHomeDocumentCollectionViewModel {
    func openDocument(_ document: AxHomeDocument)
    
    func copyLink(_ document: AxHomeDocument)
    
    func deleteDocument(_ document: AxHomeDocument)
    
    func renameDocument(_ document: AxHomeDocument, to name: String)
    
    func openInFinder(_ document: AxHomeDocument)
}

final class AxHomeCollectionItemModel {
    let document: AxHomeDocument
    
    let canCopyLink: Bool
    let canRename: Bool
    let canDelete: Bool
    let canOpenInFinder: Bool
    
    private let viewModel: any AxHomeDocumentCollectionViewModel
    
    func openDocument() { self.viewModel.openDocument(document) }
    
    func copyLink() { self.viewModel.copyLink(document) }
    
    func deleteDocument() { self.viewModel.deleteDocument(document) }
    
    func renameDocument(to name: String) { self.viewModel.renameDocument(document, to: name)}
    
    func openInFinder() { self.viewModel.openInFinder(document) }
    
    init(document: AxHomeDocument, viewModel: any AxHomeDocumentCollectionViewModel) {
        self.document = document
        self.viewModel = viewModel
                
        switch document.documentType {
        case .local:
            self.canCopyLink = false
            self.canRename = false
            self.canDelete = true
            self.canOpenInFinder = true
        case .cloud:
            self.canCopyLink = true
            self.canRename = true
            self.canDelete = true
            self.canOpenInFinder = false
        }
    }
}

