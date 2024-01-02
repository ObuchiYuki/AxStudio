//
//  AxHomeDocumentCollectionViewModel.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import Combine
import SwiftEx
import AppKit

final class AxHomeDocumentCollectionViewModel {
    @ObservableProperty var itemData = [AxHomeDocumentData]()
    
    let openItemPublisher = PassthroughSubject<AxHomeDocumentData, Never>()
    let copyLinkPublisher = PassthroughSubject<AxHomeDocumentData, Never>()
    let deletePublisher = PassthroughSubject<AxHomeDocumentData, Never>()
    let renamePublisher = PassthroughSubject<(AxHomeDocumentData, String), Never>()
    let openInFinderPublisher = PassthroughSubject<AxHomeDocumentData, Never>()
    
    func itemModel(for row: Int) -> AxHomeCollectionItemModel {
        AxHomeCollectionItemModel(data: itemData[row], viewModel: self)
    }
}
