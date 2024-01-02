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

enum AxDocumentType { case local, cloud }

final class AxHomeCollectionItemModel {
    let data: AxHomeDocumentData
    
    private let viewModel: AxHomeDocumentCollectionViewModel
    
    let canCopyLink: Bool
    let canRename: Bool
    let canDelete: Bool
    let canOpenInFinder: Bool
    
    func openItem() { viewModel.openItemPublisher.send(data) }
    func copyLink() { viewModel.copyLinkPublisher.send(data) }
    func delete() { viewModel.deletePublisher.send(data) }
    func rename(_ name: String) { viewModel.renamePublisher.send((data, name)) }
    func openInFinder() { viewModel.openInFinderPublisher.send(data) }
    
    init(data: AxHomeDocumentData, viewModel: AxHomeDocumentCollectionViewModel) {
        self.data = data
        self.viewModel = viewModel
                
        switch data.documentType {
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

